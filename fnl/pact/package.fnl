;;; Package
;;;
;;; Where a `Pact.Plugin.Spec` represents some vague details about where a
;;; plugin might come from and how it prefers to handle updates, a package
;;; represents much more concrete facts such as a location on disk, the current
;;; checkout sha, any pending actions, running logs, etc.
;;;
;;; Users operate with the spec to define a desired state but the package is
;;; the truth.
;;;
;;; Ideally packages are actually somewhat agnostic to source and type. Most
;;; commonly they will be just git-repo+nvim-plugin but it should also handle
;;; luarocks, cargo, etc if desired.

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     Log :pact.log
     {:format fmt} string)


(local Health {})
(local Package {:Action {}
                :Health Health})

(fn Health.healthy [] [:healthy])
(fn Health.healthy? [h] (match? [:healthy] h))

(fn Health.degraded [msg] [:degraded msg])
(fn Health.degraded? [h] (match? [:degraded] h))

(fn Health.failing [msg] [:failing msg])
(fn Health.failing? [h] (match? [:failing] h))

(fn Health.update [old new]
  (let [[old-kind & rest-old] old
        [new-kind & rest-new] new
        msgs #(E.concat$ [] rest-new rest-old)
        score #(. {:healthy 0 :degraded 1 :failing 2} $1)]
    (if (< (score old-kind) (score new-kind))
      [new-kind (E.unpack (msgs))]
      [old-kind (E.unpack (msgs))])))

(var *last-id* 0)
(fn gen-uid []
  (set *last-id* (+ 1 *last-id*))
  ;; string not number so we get kv tables instead of potentially sparse seqs
  (.. "package-" *last-id*))

(fn Package.userspec->package [spec]
  ;; Warning: some of these properties are place holders and should be
  ;; filled by another process.
  (let [root spec.canonical-id
        package-name (or (string.match spec.name ".+/([^/]-)$")
                         (string.gsub spec.name "/" "-")) ;; TODO this will smell
        rtp-path (FS.join-path (if spec.opt? :opt :start) package-name)]
    (-> {:type :plugin
         :canonical-id spec.canonical-id ;; shared between packages with same origin
         :uid (gen-uid) ;; globally unique between all packages
         :spec spec
         :name spec.name
         :source spec.source
         :constraint spec.constraint
         :depended-by nil
         :depends-on (or spec.dependencies []) ;; placeholder
         ;; these are kept relative as they will be different for every transaction
         :path {:root root ;; github-user-repo-nvim/ ;; TODO deprecate
                :rtp rtp-path ;; start|opt/package.nvim ;; TODO deprecate
                :head (FS.join-path root :HEAD)} ;; TODO deprecate
         :order 0 ;(E.reduce #(+ $1 1) 1 runtime.packages)
         :events []
         :workflows []
         :action [:hold]
         :health (Health.healthy)
         :state :state-prop-deprecated
         :text "waiting for scheduler" ;; TODO: deprecate this, UI not package
         :install {:path rtp-path} ;; start|opt/<name>
         :git {:remote {:origin (. spec.source 2)}
               :repo {:path (FS.join-path root :HEAD)} ;; github-user-repo-nvim/HEAD
               :checkout {:path nil ;; github-user-repo-nvim/sha
                          :HEAD nil} ;; TODO HEAD -> commit for consistency
               :target {:commit nil ;; solves to commit
                        :distance nil ;; local..commit
                        :logs [] ;; git log local..commit
                        :breaking? false} ;; any log has breaking in it
               :latest {:commit nil} ;; latest "version" found
               :commits []}}
        (setmetatable {:__newindex (fn [t k v]
                                     (if (not= :depended-by k)
                                       (print :new-key t.name k v))
                                     (rawset t k v))
                       :__index (fn [t k]
                                  (match (. Package k)
                                    (where f (function? f)) f
                                    _ nil))}))))

(λ Package.update-target-logs [package logs]
  (set package.git.target.logs logs)
  (set package.git.target.breaking? (E.any? #$2.breaking? logs))
  package)

(λ Package.worktree-path [package commit]
  (FS.join-path (string.match package.git.repo.path "(.+)HEAD$")
                commit.short-sha))

(fn Package.add-event [package workflow event]
  (Log.log [workflow.id event])
  (table.insert package.events 1 [workflow.id event])
  package)

(fn Package.update-health [package health]
  "Set health to current health level or degrade, you can never improve health."
  (assert (or (Health.healthy? health)
              (Health.degraded? health)
              (Health.failing? health))
          "update-health given non-health value")
  ;; health changes should propagate down and up?
  (set package.health (Health.update package.health health))
  (if package.depended-by
    (Package.update-health package.depended-by
                           (Health.degraded "degraded by subpackage")))
  package)

(fn Package.update-commits [package commits]
  (set package.git.commits commits)
  package)

(fn Package.set-head [package commit]
  (set package.git.checkout.HEAD commit)
  (set package.git.checkout.path (Package.worktree-path package commit))
  package)

(fn Package.track-workflow [package wf]
  ;; For UI purposes we want to know what wf's are related to a package and
  ;; know if they're running or waiting. This is a smell but will do for now TODO
  (tset package :workflows wf true)
  package)

(fn Package.untrack-workflow [package wf]
  (tset package :workflows wf nil)
  package)

(fn Package.update-latest [package version]
  (Log.log [:latest package.name package.git version])
  (set package.git.latest.commit version)
  package)

(fn Package.healthy? [package]
  (Package.Health.healthy? package.health))

(fn Package.degraded? [package]
  (Package.Health.degraded? package.health))

(fn Package.failing? [package]
  (Package.Health.failing? package.health))

(fn Package.stageable? [package]
  (and (Package.healthy? package)
       (Package.solved? package)
       (not (Package.in-sync? package))))

(fn Package.staged? [package]
  (= (?. package :action 1) :stage))

(fn Package.held? [package]
  (= (?. package :action 1) :hold))

(fn Package.in-sync? [package]
  "Is the given package in sync with its remote?"
  (and (Package.on-disk? package)
       (Package.solved? package)
       (= package.git.checkout.HEAD.sha package.git.target.commit.sha)))

(fn Package.on-disk? [package]
  "Does the package exist on disk?"
  (not-nil? package.git.checkout.path))

(fn Package.solved? [package]
  "Is the package constraint solved?"
  (not-nil? package.git.target.commit))

(λ Package.loading? [package]
  (and (nil? package.git.target.commit)))

(fn Package.solve [package commit]
  (set package.git.target.commit commit)
  package)

(fn Package.stage [package]
  ;; See runtime stage command for rules around staging (for now)
  (match-let [true (Package.healthy? package)
              commit package.git.target.commit]
    (values (E.set$ package :action [:stage commit])
            (R.ok))
    (else
      false (values package (R.err "cannot stage unhealthy package"))
      nil (values package (R.err "cannot stage package, no target commit set")))))

(fn Package.unstage [package]
  (values (E.set$ package :action [:hold]) (R.ok)))

(fn Package.source [package]
  ;; TODO should handle git, local, lua rocks, etc
  (match package.source
    [:git url] url
    _ (error "can't get package source for unknown source type")))

;; TODO probably Package.walk-down package + Package.walk-up package and detect
;; if packages or package?
(fn Package.iter [packages opts]
  ;; TODO: currently we maintain [(make-pact) (make-pact)] in runtime.packages
  ;; so we need the each in this. It does make iterating just one package and
  ;; its dependencies awkward (?) as you need to pass int [package].
  ;; Previously we had a placeholder "root" package, which may return with
  ;; metapackages? It's awkward in a different away as you either must discard it
  ;; on return or hide it in the UI or ...
  (fn next-id [n] n.depends-on)
  (let [opts (or opts {})
        f (fn []
            (E.each #(E.depth-walk (fn [package history]
                                     (if (or (not (R.err? package)) opts.include-err?)
                                       (coroutine.yield package history)))
                                   $2 next-id)
                    packages)
            ;; nil to termitate iter
            nil)
        iter (fn [coro]
               (let [r (E.pack (coroutine.resume coro))]
                 (match r
                   [true _] (E.unpack r 2)
                   [false _] (error (E.unpack r 2)))))]
    (values iter (coroutine.create f) 0)))

(values Package)
