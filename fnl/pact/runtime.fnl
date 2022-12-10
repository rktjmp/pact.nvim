(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     PubSub :pact.pubsub
     Package :pact.package
     {:format fmt} string)

(local Runtime {})

(fn unproxy-tree [proxies]
  "Given a tree of proxies from user-defined plugins, unpack into
  a usable tree structure with concrete plugins.
  Does not deduplcate or collision detect, jus returns it would expand."
  (fn unroll [proxy tree]
    ;; unwrap the proxy
    (match (proxy)
      (where r (R.ok? r))
      ;; spec was good, see if it exists in the lookup table
      (let [spec (R.unwrap r)]
        ;; insert spec into tree
        (E.append$ tree spec)
        ;; now unroll any sub dependencies into fresh tree but use same lookup table
        (tset spec :dependencies (E.reduce #(unroll $3 $1)
                                           [] spec.dependencies)))
      (where r (R.err? r))
      ;; the spec had an error in it so ... remember that?
      (E.append$ tree r))
    tree)
  ;; proxies may contain multiple "roots" if make-pact was called multiple
  ;; times, but we now collate them under one tree.
  (E.flat-map #(E.reduce #(unroll $3 $1) [] $2) proxies))

(fn Runtime.add-proxied-plugins [runtime proxies]
  "User defined plugins are wrapped in a thin proxy function so nothing else
  needs be required until we actually have to touch the plugin data.
  This means what we get given to the initial UI is actually a list of
  functions that need to be expanded into specs."

  (fn walk-tree [f tree parent]
    (print :walk-tree tree.id)
    (f tree parent)
    (E.each #(walk-tree f $2 tree) tree.dependencies))

  ;; first we just expand the given tree as .. given, ignore any duplicate
  ;; plugins or conflicting properties
  (let [tree (unproxy-tree proxies)
        ;; TODO: ideally this would soft fail only the parts with a loop
        ;; TODO: warn on duplicate canonical ids
        ;; TODO: also "provides: id"
        ;; _ (validate-DAG tree)

        ;; The tree is good at describing our structure, but it's arduous to update
        ;; with new dependencies (discovered/added after the fact) or to find a
        ;; particular plugin to inspect its data.
        ;; So we'll also maintain a flattend view of our plugins which will also
        ;; collate all constraints and relationships into a more processable format.:
        lookup {}
        _ (walk-tree (fn [node parent]
                       (match (. lookup node.id)
                         nil
                         (let [v {:specs [node]
                                  :constraints [(and parent [parent.id node.constraint])]}]
                           (tset lookup node.id v))
                         existing
                         (do
                           ;; TODO expand/error/whatever on collisions
                           (E.append$ existing.constraints (and [parent.id node.constraint]))
                           (E.append$ existing.specs node))
                         ))
                     {:id :make-pact
                      :dependencies tree})
    ]
    lookup)
  )


(fn Runtime.add-plugin [runtime plugin ?dependent-of]
  "Adds plugin from user-spec and returns (ok) or (err reason)"
  ;; TODO this also needs to support adding dependencies after the fact
  ;;      which might trigger re-solve, so probably if a dep gets added
  ;;      the parent(s) should be invalidated and re-published.
  ;; TODO it also needs to check the graph is DAG, perhaps solve can do that
  ;; instead.
  ;; TODO duplicate id/source/something flagging
  (match plugin
    (where plugin (R.ok? plugin))
    (let [spec (R.unwrap plugin)
          ;; TODO this *will* collide for git+ssh+http with same endpoint, just
          ;; drop protocol?
          canonical-id (-> (. spec.source 2)
                           (string.gsub "%W" "-")
                           (string.gsub "-+" "-"))
          root (FS.join-path runtime.path.repos canonical-id)
          package-name (string.match spec.name ".+/([^/]-)$")
          package-path (FS.join-path runtime.path.root
                                     (if spec.opt? :opt :start)
                                     package-name)
          package {:id canonical-id
                   :canonical-id canonical-id
                   :spec spec
                   :dependencies spec.dependencies
                   :name spec.name
                   ;; we always need at least our own constraint but
                   ;; dependencies may add extras here.
                   :constraints {canonical-id spec.constraints}
                   :path {:root root
                          :rtp package-path
                          :head (FS.join-path root :HEAD)}
                   :order (E.reduce #(+ $1 1) 1 runtime.packages)
                   :events []
                   :state :waiting
                   :text "waiting for scheduler"}]
      (match [?dependent-of (. runtime.packages ?dependent-of)]
        [nil _] (do
                  (tset runtime.packages package.id package)
                  (R.ok package))
        [key parent] (do
                       (tset runtime.packages package.id package)
                       (table.insert parent.dependencies package)
                       (R.ok package))
        [key nil] (do
                    (R.err (fmt "Tried to define dependent %s without parent existing %s"
                                package.id ?dependent-of)))))
    ;; probably an invalid spec given, fail out
    (where plugin (R.err? plugin))
    (values plugin)))

(fn Runtime.has-plugins? [runtime]
  ;; TODO
  true)

(fn Runtime.exec-solve-tree [runtime package]
  true)

(fn Runtime.discover-facts [runtime]
  (use DiscoverFacts :pact.workflow.status.discover-facts
       Scheduler :pact.workflow.scheduler)

  (fn make-wf [package]
    (let [url (. package :spec :source 2)
          wf (DiscoverFacts.new package.id url package.path.rtp)
          handler (fn handler [event]
                    (match event
                      (where e (R.ok? e))
                      (do
                        ;(tset package :facts (R.unwrap e))
                        (tset package :state :unstaged)
                        (Runtime.exec-solve-tree runtime package)
                        (PubSub.broadcast package :facts-changed)
                        (PubSub.unsubscribe wf handler))
                      (where e (R.err? e))
                      (do
                        (set package.text (R.unwrap e))
                        (tset package :state :error)
                        (PubSub.unsubscribe wf handler))
                      (where msg (string? msg))
                      (do
                        (E.append$ package.events msg)
                        (set package.text msg)
                        (PubSub.broadcast package :events-changed))))]
      (PubSub.subscribe wf handler)
      wf))

  (->> (E.map #$2 runtime.packages)
       (E.sort #(<= $1.order $2.order))
       (E.map #(let [wf (make-wf $2)]
                 (Scheduler.add-workflow runtime.scheduler wf)))))

;; TODO
(fn Runtime.exec-discover-orphans [runtime])

(fn Runtime.new [opts]
  (let [Scheduler (require :pact.workflow.scheduler)
        FS (require :pact.workflow.exec.fs)
        scheduler (Scheduler.new {:concurrency-limit opts.concurrency-limit})]
    {:path {:root (FS.join-path (vim.fn.stdpath :data) :site/pack/pact)
            :data (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/data)
            :repos (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/repos)}
     :packages {}
     :scheduler scheduler}))

(values Runtime)
