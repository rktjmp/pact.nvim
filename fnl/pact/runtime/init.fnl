(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     PubSub :pact.pubsub
     Package :pact.package
     Transaction :pact.runtime.transaction
     {:format fmt} string)

(local Runtime {})

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
        ;; retain errors in tree for reporting reasons
        (where r (R.err? r))
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

;; TODO
(fn Runtime.exec-discover-orphans [runtime])

(fn smoke-test-first-run [runtime]
  "Look at current disk state, possibly prepare it to a known good state, then
  set some information on runtime"
  ;; must have some directories created
  (E.each #(FS.make-path $2)
          [runtime.path.root runtime.path.data runtime.path.repos])

  (match (vim.loop.fs_lstat runtime.path.head)
    (nil _ :ENOENT) (let [t (Transaction.new runtime.path.data
                                             runtime.path.repos
                                             runtime.path.head)]
                      (FS.make-path t.path.root)
                      (FS.make-path (FS.join-path t.path.root :start))
                      (FS.make-path (FS.join-path t.path.root :opt))
                      (FS.symlink t.path.root runtime.path.head)))

  ;; look for current HEAD transaction symlink otherwise create one to a
  ;; default checkout
  ;; TODO this could be stronger
  (match (vim.loop.fs_lstat (FS.join-path runtime.path.root :start))
    (nil _ :ENOENT) (FS.symlink (FS.join-path runtime.path.head :start)
                                (FS.join-path runtime.path.root :start)))

  (match (vim.loop.fs_lstat (FS.join-path runtime.path.root :opt))
    (nil _ :ENOENT) (FS.symlink (FS.join-path runtime.path.head :opt)
                                (FS.join-path runtime.path.root :opt)))

  runtime)

(fn parse-disk-layout [runtime]
  "Look at current disk state, possibly prepare it to a known good state, then
  set some information on runtime"
  (let [current-head  (vim.loop.fs_readlink runtime.path.head) ;; TODO: re-add error checks
        transaction-id (string.match current-head ".+/([^/]-)$")]
    (set runtime.transaction.head.id transaction-id)
    (set runtime.path.transaction current-head)) ;; TODO: put somewhere else? better name?

  runtime)

(fn Runtime.workflow-stats [runtime]
  {:active (+ (length runtime.scheduler.local.active)
              (length runtime.scheduler.remote.active))
   :queued (+ (length runtime.scheduler.local.queue)
              (length runtime.scheduler.remote.queue))})

(fn Runtime.new [opts]
  (let [Scheduler (require :pact.workflow.scheduler)
        FS (require :pact.workflow.exec.fs)
        data-path (FS.join-path (vim.fn.stdpath :data) :pact)
        repos-path (FS.join-path data-path :repos)]
    (-> {:path {:root (FS.join-path (vim.fn.stdpath :data) :site/pack/pact)
                :data data-path
                :head (FS.join-path data-path :HEAD)
                :repos repos-path}
         :transaction {:head {:id nil}
                       :staged (Transaction.new data-path repos-path)
                       :historic []}
         :packages {}
         :scheduler {:remote (Scheduler.new {:concurrency-limit opts.concurrency-limit})
                     :local (Scheduler.new {:concurrency-limit opts.concurrency-limit})}}
        (smoke-test-first-run)
        (parse-disk-layout))))

(set Runtime.Command {})


(fn Runtime.Command.discover-status []
  (fn [runtime]
    (use DiscoverRemote :pact.runtime.discover.remote
         DiscoverLocal :pact.runtime.discover.local
         Scheduler :pact.workflow.scheduler)
    (let [packages (E.map #$ #(Package.iter runtime.packages))]
      (->> (E.group-by #(. $2 :canonical-id) packages)
           (E.map (fn [_ canonical-set]
                    [(DiscoverLocal.workflow canonical-set
                                             runtime.path.transaction)
                     (DiscoverRemote.workflow canonical-set
                                              runtime.path.repos)
                     ;; remember a package for triggering solve workflow
                     (. canonical-set 1)]))
           (E.each (fn [_ [local-wf remote-wf canonical-package]]
                     (let [set-id (Scheduler.add-workflow-set runtime.scheduler.remote
                                                              [local-wf remote-wf])]
                       (PubSub.subscribe set-id
                                         (fn []
                                           (E.each #(Runtime.dispatch runtime $2)
                                                   [(Runtime.Command.solve-package canonical-package)
                                                    (Runtime.Command.solve-latest canonical-package)]))))))))))

(fn Runtime.Command.solve-package [package]
  (fn [runtime]
    (use Solve :pact.runtime.solve)
    (Solve.solve runtime package)))

(fn Runtime.Command.solve-latest [package]
  (fn [runtime]
    (use SolveLatest :pact.runtime.solve.latest)
    (SolveLatest.solve runtime package)))

(fn Runtime.Command.stage-package-tree [package]
  "Set package state to staged, this will also propagate *down* its
  dependency tree. If any package in the tree is unhealthy, the stage command
  will fail. If any parent of the package is unhealthy, the stage command will
  fail.

  Note that staging propagates *down* but checks *up and down*."
  (fn [runtime]
    (fn all-parents-ok? [package acc]
      (match [acc package.depended-by]
        [false _ ] false
        ;; Important note: If A -> B, and A is in-sync - and therefore "not
        ;; stageable" we must still allow B to be staged!
        [true parent] (all-parents-ok? parent (and acc (or (Package.stageable? package)
                                                           (Package.in-sync? package))))
        [true nil] (and acc (or (Package.stageable? package)
                                (Package.in-sync? package)))))
    (if (and ;; the direct package must be stagable
             (Package.stageable? package)
             ;; and all children must be in-sync or stagable
             (E.all? #(or (Package.stageable? $1)
                          (Package.in-sync? $1))
                     #(Package.iter (or package.depends-on [])))
             ;; and any parent must be in-sync or stageable
             (all-parents-ok? package true))
      (do
        (E.each #(do
                   ;; We know the main package was allowed, and we do want to
                   ;; stage any children, if they are stageable.
                   ;; TODO: staging in-sync is effectively a no-op and we could just allow it for simpler code path
                   (if (Package.stageable? $)
                     (Package.stage $))
                   (PubSub.broadcast $ :changed))
                   #(Package.iter [package]))
        (R.ok))
      (do
        (R.err "unable to stage tree, some packages unstagable")))))

(fn Runtime.Command.unstage-package-tree [package]
  "Set package state to unstaged, this will also propagate *down* its
  dependency tree. Any unhealthy packages in the tree are ignored."
  (fn [runtime]
    ;; TODO decide on propagation rules
    ;; TODO: perhaps nicer if stage returned ok-err, but then it can't return
    ;; package for chaning and would be out of step with other functions.
    ;; Either find a way to disambuguate the behaviour.
    (E.each #(do
               (Package.unstage $)
               (PubSub.broadcast $ :changed))
            #(Package.iter [package]))
    (R.ok)))

(fn Runtime.Command.run-transaction []
  ;; todo check any staged to commit ...
  (fn [runtime]
    (let [t (Transaction.new runtime.path.data runtime.path.repos runtime.path.head)
          stage-wfs (->> (E.group-by #(values $1.canonical-id $1)
                                     #(Package.iter runtime.packages))
                         (E.map (fn [c-id [package & _]]
                                  (if (Package.staged? package)
                                    [package (Transaction.stage-package t package)]))))
          {:setup setup-wf :commit commit-wf :rollback rollback-wf} (Transaction.workflows t)]
      (E.each (fn [_ [canonical-package wf]]
                (->> (E.map #(if (= $1.canonical-id canonical-package.canonical-id) $1)
                            #(Package.iter runtime.packages))
                     (E.each #(do
                                (Package.track-workflow $2 wf)
                                (wf:attach-handler
                                  (fn [ok]
                                    (-> $2
                                        (Package.add-event wf ok)
                                        (Package.untrack-workflow wf)
                                        (PubSub.broadcast :changed)))
                                  (fn [err]
                                    (-> $2
                                        (Package.add-event wf err)
                                        (Package.untrack-workflow wf)
                                        (PubSub.broadcast :changed)))
                                  (fn [msg]
                                    (-> $2
                                        (Package.add-event wf msg)
                                        (PubSub.broadcast :changed))))))))
              stage-wfs)
      ;; TODO bit of callback hell here but we'll fix it in post.
      (setup-wf:attach-handler
        (fn [ok]
          ;; start stage-wfs
          (vim.pretty_print "Setup transaction, starting staging")
          (let [set-id (-> (E.map #(. $2 2) stage-wfs)
                           (runtime.scheduler.remote:add-workflow-set))]
            (PubSub.subscribe set-id (fn [x]
                                       (commit-wf:attach-handler
                                        (fn [e] (vim.pretty_print :commit-wf-ok e))
                                        (fn [e] (vim.pretty_print :commit-wf-err e))
                                        (fn [e] (vim.pretty_print :commit-wf-msg e)))
                                       (runtime.scheduler.local:add-workflow commit-wf)
                                       ;; commit
                                       ;; this needs ... check packages for
                                       ;; health? check all stage-wf callbacks
                                       ;; were Ok?
                                       ))))
        (fn [err]
          (vim.pretty_print :err err)))
      (runtime.scheduler.local:add-workflow setup-wf))))

(fn Runtime.dispatch [runtime command]
  (match (command runtime)
    (where x (R.err? x)) (vim.notify (R.unwrap x) vim.log.levels.ERROR))
  runtime)

(values Runtime)
