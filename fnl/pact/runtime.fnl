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

(var *last-id* 0)
(fn gen-monotonic-id []
  (set *last-id* (+ 1 *last-id*))
  *last-id*)

(fn spec->package [spec]
  ;; Warning: some of these properties are place holders and should be
  ;; filled by another process.
  (let [root spec.id
        package-name (string.match spec.name ".+/([^/]-)$")
        package-path (FS.join-path (if spec.opt? :opt :start) package-name)]
    {:pact :plugin
     :id spec.id
     :monotonic-id (gen-monotonic-id) ;; globally unique between all packages
     :spec spec
     :name spec.name
     :source spec.source
     :constraint spec.constraint
     :depended-by []
     :depends-on spec.dependencies ;; placeholder
     :path {:root root ;; placeholder
            :rtp package-path ;; placeholder
            :head (FS.join-path root :HEAD)} ;; placeholder
     :order 0 ;(E.reduce #(+ $1 1) 1 runtime.packages)
     :events []
     :state :waiting
     :text "waiting for scheduler"}))


(fn Runtime.walk-packages [runtime f ?acc]
  "Utility to depth-walk the package graph."
  (if ?acc
    (E.depth-walk f runtime.package-graph ?acc #$1.depends-on)
    (E.depth-walk f runtime.package-graph #$1.depends-on)))

(fn Runtime.update-package-list [runtime]
  "Flatten a package-graph down into:

  {package-id {:contraints [a ...]
               :depends-on [id ...]
               :depended-by [id ...]
               :packages [package ...]}
   ...}

  Most interaction with packages is done via the manifest as it has
  key based lookup and collates multiple constraints, etc. Note that packages
  is plural as one canonical package may be used in multiple places - with
  different constraints and configuration!

  We retain the graph in full form mostly for contextual error reporting."
  (let [f (fn [acc node history]
            (let [parent (E.last history)]
              (when (and parent (not (R.err? node)))
                (match (. acc node.id)
                  nil (do
                        (tset acc node.id {:constraints [[parent.id node.constraint]]
                                           :depends-on (E.map #$2.id node.depends-on)
                                           :depended-by [(?. node :depended-by :id)]
                                           :packages [node]}))
                  x (do
                      (E.append$ x.constraints [parent.id node.constraint])
                      (E.concat$ x.depends-on (E.map #$2.id node.depends-on))
                      (E.append$ x.depended-by (?. node :depended-by :id))
                      (E.append$ x.packages node))))
              acc))]
    (set runtime.package-list (Runtime.walk-packages runtime f {}))
    runtime))

(fn Runtime.add-proxied-plugins [runtime proxies]
  "User defined plugins are wrapped in a thin proxy function so nothing else
  needs be required until we actually have to touch the plugin data.
  This means what we get given to the initial UI is actually a list of
  functions that need to be expanded into specs."

  (fn unproxy-spec-graph [proxies]
    "Given a graph of proxies from user-defined plugins, unpack into
    a usable graph structure with packages.

    This becomes our primary representation of the graph, as other transitive
    plugins found must be added as a dependency of something existing, so we will
    never need an alternate 'root' or reorganised tree.

    Errors in the proxy are retained in-place for contextual error reporting.

    Does not perform any deduplication or collision detection."
    ;; TODO? technically this will infinitely recurse if a literal loop is
    ;; injected, but that's actually pretty difficult to do as each spec is
    ;; individually created. You'd have to really go outside the lines and force
    ;; an existing expanded node into the graph. """lexical""" loops can happen,
    ;; where nodes depend on the same package by its canonical name, but those
    ;; don't atually "loop" in the graph.
    (fn unroll [proxy graph]
      ;; unwrap the proxy
      (match (proxy)
        (where r (R.ok? r))
        (let [spec (R.unwrap r)
              package (spec->package spec)
              dependencies (->> (E.reduce #(unroll $3 $1)
                                          ;; use fresh subgraph
                                          [] spec.dependencies)
                                ;; set backlink for ease of use
                                (E.map #(do
                                          (set $2.depended-by package)
                                          $2)))]
          (E.append$ graph package)
          (tset package :depends-on dependencies))
        (where r (R.err? r))
        (E.append$ graph r))
      graph)
  ;; proxies may contain multiple "roots" if make-pact was called multiple
  ;; times, but we now collate them under one graph.
  (E.flat-map #(E.reduce #(unroll $3 $1) [] $2) proxies))

  ;; User plugins arrive as as a graph but they're wrapped in a proxy function
  ;; for performance reasons. We'll unproxy them into real values first.
  ;; This graph can have duplicates or conflicting specs but we resolve that
  ;; later.
  (tset runtime :package-graph {:id :pact
                                :depends-on (unproxy-spec-graph proxies)})
  ;; unproxying doesn't set absolute paths, update them with runtime data.
  (Runtime.walk-packages runtime
                         (fn [node]
                           (when node.path
                             (E.each #(tset node :path $1
                                            (FS.join-path (. runtime :path $2)
                                                          (. node :path $1)))
                                     {:root :repos :rtp :root :head :repos}))))
  (Runtime.update-package-list runtime)
  ;; TODO: ideally this would soft fail only the parts with a loop
  ;; TODO: warn on duplicate canonical ids
  ;; TODO: also "provides: id"
  ;; TODO: does a loop even matter? we install all things independently
  ;; anyway, so if a depends on b depends on a, we end up with flat a +
  ;; b, and we can just install them? 
  ;; _ (validate-DAG spec-graph)
  runtime)

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

  (->> (E.map #(E.hd $2.packages) runtime.package-list)
       ; (E.sort #(<= $1.order $2.order))
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
