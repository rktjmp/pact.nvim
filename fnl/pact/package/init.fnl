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
     FS :pact.fs
     Log :pact.log
     gen-id :pact.gen-id
     Health :pact.package.health
     {:format fmt} string)

(local Package {:Health Health})

(fn common-spec->package [spec]
  ;; Warning: some of these properties are place holders and should be
  ;; filled by another process.
  (let [root spec.canonical-id
        ;; The name should be something the user recognises, which is normally
        ;; user/repo, but we may be given something specific.
        ;; However we can't clone the repo to user/repo, and instead use
        ;; user-repo.
        package-name (or (string.match spec.name ".+/([^/]-)$")
                         (string.gsub spec.name "/" "-")) ;; TODO this will smell
        rtp-path (FS.join-path (if spec.opt? :opt :start) package-name)]
    {;; package data
     :uid (gen-id :plugin-package) ;; globally unique between all packages, even those
     ;; with the same c-id
     :canonical-id spec.canonical-id ;; shared between packages with same origin
     :name spec.name ;; generally visible name TODO these need better diferentiated names
     :package-name package-name ;; installed as-name
     :depended-by nil
     :depends-on (or spec.dependencies []) ;; placeholder
     :install {:path rtp-path} ;; start|opt/<name>
     :after spec.after
     :opt? spec.opt?

     ;; general bookkeeping
     :health (Health.healthy)
     :ready? false ;; TODO loading?
     :transacting? false
     :tasks {:waiting 0
             :active 0}

     :constraint spec.constraint
     :events []

     :action :unknown}))

(fn* Package.spec->package
  (where [[:git spec]])
  (let [base (common-spec->package spec)]
    (set base.kind :git)
    (set base.git {:origin spec.source
                   :current {:commit nil}
                   :target {:commit nil ;; solves to commit
                            :distance nil ;;
                            :breaking? false} ;; any log has breaking in it
                   :latest {:commit nil}}) ;; latest "version" found
    (setmetatable base {:__index (fn [t k]
                                   (match (. Package k)
                                     (where f (function? f)) f
                                     _ nil))}))
  (where [[:rock spec]])
  (let [base (common-spec->package spec)]
    (set base.kind :rock)
    (set base.rock {:server spec.server
                    :name spec.rock-name})
    (setmetatable base {:__index (fn [t k]
                                   (match (. Package k)
                                     (where f (function? f)) f
                                     _ nil))})))

(fn Package.increment-tasks-waiting [package]
  (set package.tasks.waiting (+ package.tasks.waiting 1))
  package)

(fn Package.decrement-tasks-waiting [package]
  (set package.tasks.waiting (math.max 0 (- package.tasks.waiting 1)))
  package)

(fn Package.increment-tasks-active [package]
  (set package.tasks.active (+ package.tasks.active 1))
  package)

(fn Package.decrement-tasks-active [package]
  (set package.tasks.active (math.max 0 (- package.tasks.active 1)))
  package)

(fn* Package.add-event
  (where [package event])
  (Package.add-event package :no-ctx event)
  (where [package ctx event])
  (do
    (Log.log [ctx event])
    (table.insert package.events 1 [ctx event])
    package))

(fn Package.update-health [package health]
  "Set health to current health level or degrade, you can never improve health."
  (assert (or (Health.healthy? health)
              (Health.degraded? health)
              (Health.failing? health))
          "update-health given non-health value")
  (set package.health (Health.update package.health health))
  (if (and package.depended-by (or (Health.degraded? health) (Health.failing? health)))
    (Package.update-health package.depended-by
                           (Health.degraded "degraded by subpackage")))
  package)

(λ Package.degrade-health [package message]
  (Package.update-health package (Package.Health.degraded message)))

(λ Package.fail-health [package message]
  (Package.update-health package (Package.Health.failing message)))

(fn Package.healthy? [package]
  (Package.Health.healthy? package.health))

(fn Package.degraded? [package]
  (Package.Health.degraded? package.health))

(fn Package.failing? [package]
  (Package.Health.failing? package.health))

(fn Package.set-current-commit [package ?commit]
  (set package.git.current.commit ?commit)
  package)

(λ Package.set-target-commit [package commit]
  (set package.git.target.commit commit)
  package)

(λ Package.set-target-commit-meta [package distance breaking?]
  (set package.git.target.distance distance)
  (set package.git.target.breaking? breaking?)
  package)

(λ Package.set-latest-commit [package version]
  (set package.git.latest.commit version)
  package)

(λ Package.ready? [package]
  "ready for interaction"
  (= true package.ready?))

(fn* Package.aligned?
  (where [package] package.git)
  (and (not-nil? package.git.target.commit)
       (not-nil? package.git.current.commit)
       (= package.git.target.commit.sha package.git.current.commit.sha))
  (where [package] package.rock)
  false)

(fn* Package.installed?
  (where [package] package.git)
  (not-nil? package.git.current.commit)
  (where [package] package.rock)
  false)

;; TODO retain -> ... dont-change? 
;; does it make more sense to describe the states as
;; align -> change to match constraint (covers install and sync)
;; discard -> specifically drop
;; persist | hold | status-quo | static | retain(?) ->
;;    keep any current state (dont install dont sync dont discard)
(λ Package.retaining? [package]
  (match? {:action :retain} package))

(λ Package.discarding? [package]
  (match? {:action :discard} package))

(λ Package.aligning? [package]
  (match? {:action :align} package))

(fn* Package.align-to-target
  "checkout constraint target in transaction")

(fn+ Package.align-to-target (where [package] package.git)
  (match-let [true (Package.healthy? package)]
    (set package.action :align)
    (R.ok package)
    (else
      false (R.err "cannot stage unhealthy package")
      nil (R.err "unable to stage package, no target commit to checkout!"))))

(fn* Package.align-to-checkout
  "checkout constraint target in transaction")

(fn+ Package.align-to-checkout (where [package] package.git)
  (match-let [commit package.git.current.commit]
    (set package.action :retain)
    (R.ok package)
    (else
      nil (R.err "unable to stage package, no checkout commit to checkout!"))))

(fn* Package.discard
  "do not bring package ahead in transaction")

(fn+ Package.discard [package]
    (set package.action :discard)
    (R.ok package))

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
                                   $ next-id)
                    packages))
        iter (fn [coro]
               (let [r (E.pack (coroutine.resume coro))]
                 (match r
                   [true _] (E.unpack r 2)
                   [false _] (error (E.unpack r 2)))))]
    (values iter (coroutine.create f) 0)))

(fn Package.find-canonical-set [package packages]
  (E.map #(if (= package.canonical-id $.canonical-id) $)
         #(Package.iter packages)))

(values Package)
