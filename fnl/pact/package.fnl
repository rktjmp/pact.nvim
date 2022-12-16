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
     {:format fmt} string)

(local Package {:Action {}})

; (fn Package.Action.none [package]
;   (doto package
;         (tset :action [:none])))

; (fn Package.new [plugin]
;   "Create a new package from a plugin spec"
;   (-> {:id (.. plugin.id :-package)
;        :spec plugin
;        :source (. plugin :source)
;        :path {:root false
;               :HEAD false}
;        :facts {}
;        :events []}
;       (Package.Action.none)))

(var *last-id* 0)
(fn gen-uid []
  (set *last-id* (+ 1 *last-id*))
  ;; string not number so we get kv tables instead of potentially sparse seqs
  (.. "package-" *last-id*))

(fn Package.userspec->package [spec]
  ;; Warning: some of these properties are place holders and should be
  ;; filled by another process.
  (let [root spec.canonical-id
        package-name (string.match spec.name ".+/([^/]-)$") ;; TODO this will smell
        package-path (FS.join-path (if spec.opt? :opt :start) package-name)]
    {:type :plugin
     :canonical-id spec.canonical-id ;; shared between packages with same origin
     :uid (gen-uid) ;; globally unique between all packages
     :spec spec
     :name spec.name
     :source spec.source
     :constraint spec.constraint
     :depended-by nil
     :depends-on spec.dependencies ;; placeholder
     ;; these are kept relative as they will be different for every transaction
     :path {:root root ;; github-user-repo-nvim/
            :rtp package-path ;; start|opt/package.nvim
            :head (FS.join-path root :HEAD)} ;; github-user-repo-nvim/HEAD
     :order 0 ;(E.reduce #(+ $1 1) 1 runtime.packages)
     :events []
     :workflows []
     :state :waiting
     :text "waiting for scheduler"}))

; (fn Package.commit-path [package commit]
;   (FS.join-path package.root commit.sha))

(fn Package.source [package]
  ;; TODO should handle git, local, lua rocks, etc
  (match package.source
    [:git url] url
    _ (error "can't get package source for unknown source type")))

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
