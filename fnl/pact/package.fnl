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

(fn next-id [n] n.depends-on)

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
     :state :waiting
     :text "waiting for scheduler"}))

; (fn Package.commit-path [package commit]
;   (FS.join-path package.root commit.sha))

(fn Package.source [package]
  ;; TODO should handle git, local, lua rocks, etc
  (match package.source
    [:git url] url
    _ (error "can't get package source for unknown source type")))

(fn Package.packages->seq [package-trees]
  "create seq of all packages in thes graph"
  (E.reduce #(E.depth-walk (fn [acc node]
                             (if (not (R.err? node))
                               (E.append$ acc node)
                               acc))
                           $3 $1 next-id)
            [] package-trees))

;; TODO: canonical-setS and proably cid -> [...]
(fn* Package.packages->canonical-set
  (where [package-trees] (table? package-trees))
  (E.reduce #(E.depth-walk (fn [acc node]
                             (if (and (not (R.err? node))
                                      (not (. acc node.canonical-id)))
                               (E.set$ acc node.canonical-id node)
                               acc))
                           $3 $1 next-id)
            {} package-trees))

(fn* Package.walk-packages
  "Depth walk given package tree, calling `(f package history)`."
  (where [f package-trees] (and (function? f) (table? package-trees)))
  (E.each #(E.depth-walk f $2 next-id)
          package-trees))

(fn* Package.reduce-packages
  (where [f ?acc package-trees] (and (function? f) (table? package-trees)))
  (E.reduce #(E.depth-walk f $3 $1 next-id)
            ?acc package-trees))

(fn* Package.find-packages
  (where [f package-trees] (and (function? f) (table? package-trees)))
  ;; TODO: performance optimisation target, can call reduced
  (Package.reduce-packages (fn [list node history]
                             (if (f node history)
                                (E.append$ list node)
                                list))
                           [] package-trees))

; (fn Package.iter-packages [package-trees]
;   "Create an iterator which returns `package-uid` `package` when called"
;   ;; This is really pretty inefficent but also probably doesn't matter so much unless
;   ;; there are thousands of plugins.
;   ;; Improvement depends on ruin.depth-walk using a better internal structure
;   ;; instead of relying on the current stack.
;   (var i 0)
;   (let [seq (Package.packages->seq package-trees)
;         *next* (fn []
;                  (set i (+ i 1))
;                  (match (. seq i)
;                    package (values package.uid package)))]
;     (values *next* {} {})))

(fn* Package.find-canonical-set
  "Given package or canonical-id, find all other packages in the canonical set"
  (where [package package-trees] (. package :canonical-id))
  (Package.find-canonical-set package.canonical-id package-trees)
  (where [canonical-id package-trees] (string? canonical-id))
  (Package.find-packages #(match? {:canonical-id canonical-id} $1) package-trees))

;; experimental...
(set Package.Tree {:walk Package.walk-packages
                   :reduce Package.reduce-packages
                   :map #(Package.Tree.reduce (fn [acc n h]
                                                (E.append$ acc ($1 n h)))
                                              [] $2)
                   :each #(Package.Tree.reduce (fn [_ n h] (do
                                                             ($1 n h)
                                                             nil))
                                               nil $2)
                   :find Package.find-packages
                   :find-canonical-set Package.find-canonical-set
                   :->seq Package.packages->seq
                   :->canonical-sets Package.packages->canonical-set})

(values Package)
