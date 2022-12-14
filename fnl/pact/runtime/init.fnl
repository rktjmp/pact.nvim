(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: '*dout*} :pact.log
     {: 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     PubSub :pact.pubsub
     Package :pact.package
     {:format fmt} string)

(local Runtime {})

;; TODO deprecated for Package.walk-* (?)
(fn Runtime.walk-packages [runtime f ?acc]
  "Depth walk the package graphs, optionally with an accumulator. See `ruin.depth-walk'."
  (fn nid [n] n.depends-on)
  (if ?acc
    (E.reduce #(E.depth-walk f $3 $1 nid)
              ?acc runtime.packages)
    (E.each #(E.depth-walk f $2 nid)
            runtime.packages)))

(fn Runtime.add-proxied-plugins [runtime proxies]
  ;; TODO rewrite doc
  "User defined plugins are wrapped in a thin proxy function so nothing else
  needs be required until we actually have to touch the plugin data.
  This means what we get given to the initial UI is actually a list of
  functions that need to be expanded into specs."

  (fn unproxy-spec-graph [proxies]
    ;; TODO rewrite doc
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
    (fn unroll [proxy]
      (match (proxy)
        (where r (R.ok? r))
        (let [spec (R.unwrap r)
              package (Package.userspec->package spec)
              dependencies (->> (E.map #(unroll $2 $1) spec.dependencies)
                                ;; set backlink in dependencies to parent for
                                ;; ease of use
                                (E.map #(E.set$ $2 :depended-by package)))]
          ;; userspec->package cant set this to real packages, so we must do it
          ;; after construction.
          (E.set$ package :depends-on dependencies))
        (where r (R.err? r))
        ;; retain errors in tree for reporting reasons
        (values r)))
    ;; The proxies list contains one list per call to make-pact, so we'll
    ;; collate them all.
    (->> proxies
         (E.flatten)
         (E.map #(unroll $2))))
  ;; User plugins arrive as as a graph but they're wrapped in a proxy function
  ;; for performance reasons. We'll unproxy them into real values first.
  ;; This graph can have duplicates or conflicting specs but we resolve that
  ;; later.
  ;; TODO: ideally this would soft fail only the parts with a loop
  ;; TODO: warn on duplicate canonical ids
  ;; TODO: also "provides: id" option
  ;; TODO: does a loop even matter? we install all things independently anyway,
  ;; so if a depends on b depends on a, we end up with flat a + b, and we can
  ;; just install them? 
  (E.set$ runtime :packages (unproxy-spec-graph proxies)))

(fn transaction-path [runtime transaction]
  (FS.join-path runtime.path.data transaction.id))

;; TODO
(fn Runtime.exec-discover-orphans [runtime])

(fn parse-disk-layout [runtime]
  "Look at current disk state, possibly prepare it to a known good state, then
  set some information on runtime"
  ;; must have some directories created
  (E.each #(FS.make-path $2)
          [runtime.path.root runtime.path.data runtime.path.repos])

  ;; look for current HEAD transaction symlink
  ;; otherwise create one to a default checkout
  (let [current-head (match (vim.loop.fs_lstat runtime.path.head)
                       {:type :link} (vim.loop.fs_readlink runtime.path.head)
                       (nil _ :ENOENT) (let [t-path (transaction-path runtime {:id 1})]
                                         (FS.make-path t-path)
                                         (FS.symlink t-path runtime.path.head)
                                         {:type :link} (vim.loop.fs_readlink runtime.path.head)))
        transaction-id (string.match current-head ".+/([^/]-)$")]
    (set runtime.transaction.head.id transaction-id)
    ;; TODO: put somewhere else? better name?
    (set runtime.path.transaction current-head))

  runtime)

(fn Runtime.workflow-stats [runtime]
  {:active (+ (length runtime.scheduler.local.active)
              (length runtime.scheduler.remote.active))
   :queued (+ (length runtime.scheduler.local.queue)
              (length runtime.scheduler.remote.queue))})

(fn Runtime.new [opts]
  (let [Scheduler (require :pact.workflow.scheduler)
        FS (require :pact.workflow.exec.fs)]
    (-> {:path {:root (FS.join-path (vim.fn.stdpath :data) :site/pack/pact)
                :head (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/data/HEAD)
                :data (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/data)
                :repos (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/data/repos)}
         :transaction {:head {}
                       :pending {}
                       :historic []}
         :packages {}
         :scheduler {:remote (Scheduler.new {:concurrency-limit opts.concurrency-limit})
                     :local (Scheduler.new {:concurrency-limit opts.concurrency-limit})}
         :walk-packages Runtime.walk-packages}
        (parse-disk-layout))))

(set Runtime.Command {})

(fn Runtime.Command.discover-status []
  (fn [runtime]
    (use Discover :pact.runtime.discover)
    (Discover.current-status runtime)))

(fn Runtime.Command.solve-package [package]
  (fn [runtime]
    (use Solve :pact.runtime.solve)
    (Solve.solve runtime package)))

(fn Runtime.dispatch [runtime command]
  (match (command runtime)
    v (print v))
  runtime)

(values Runtime)
