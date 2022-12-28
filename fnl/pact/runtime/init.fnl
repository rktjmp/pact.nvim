(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result-> : 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     inspect :pact.inspect
     FS :pact.fs
     Datastore :pact.datastore
     Solver :pact.solver
     PubSub :pact.pubsub
     Package :pact.package
     Constraint :pact.plugin.constraint
     Transaction :pact.runtime.transaction
     {:format fmt} string)

(local Runtime {})

;; TODO (fn Runtime.exec-discover-orphans [runtime])

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
              dependencies (->> (E.map #(unroll $1) spec.dependencies)
                                ;; set backlink in dependencies to parent for
                                ;; ease of use
                                (E.map #(E.set$ $ :depended-by package)))]
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
         (E.map unroll)))
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

(λ legacy-check [runtime-path]
  (->> [:start :opt]
       (E.map #(FS.join-path runtime-path $))
       (E.map #(FS.lstat $))
       (E.all? #(or (= :link $) (= :nothing $)))
       (#(when (not $)
           (-> (fmt (.. "Whoops! %s contained unexpected content.\n"
                        "You may have an existing legacy pact install, "
                        "please see updated installation instructions and config format.\n"
                        "You'll have to remove the directory listed above too.\n")
                    runtime-path)
               (vim.notify vim.log.levels.ERROR))
           (error :pact-halt)))))

(λ bootstrap-filesystem [runtime]
  ;; ensure root dirs exist
  (E.each FS.make-path [runtime.path.data runtime.path.runtime])
  (match (Transaction.latest runtime.datastore runtime.path.data)
    nil (result-let [t (Transaction.new runtime.datastore runtime.path.data)
                     _ (Transaction.prepare t)
                     _ (Transaction.commit t)]
          t))
  ;; ensure rtp/start|opt link to HEAD
  (->> [:start :opt]
       (E.each #(match (FS.lstat (FS.join-path runtime.path.runtime $))
                  :nothing (FS.symlink (FS.join-path runtime.path.head $)
                                       (FS.join-path runtime.path.runtime $))))))

(λ Runtime.new [opts]
  (let [FS (require :pact.fs)
        Datastore (require :pact.datastore)
        data-path (FS.join-path (vim.fn.stdpath :data) :pact)
        repos-path (FS.join-path data-path :repos)
        head-path (FS.join-path data-path :HEAD)
        runtime-path (FS.join-path (vim.fn.stdpath :data) :site/pack/pact)
        runtime {:path {:runtime runtime-path ;; where pact exists in the rtp for loading
                        :data data-path ;; where pact stores all its data, repos, transactions, etc
                        :head head-path} ;; link path thats updated to point at current transaction
                 :datastore (Datastore.new data-path)
                 :packages {}}]
    (legacy-check runtime-path)
    (bootstrap-filesystem runtime)
    (vim.pretty_print runtime)
    runtime))

(set Runtime.Command {})

(λ Runtime.Command.initial-load [runtime]
  (let [ingest-first (require :pact.runtime.command.initial-load)]
    (ingest-first runtime.path.runtime runtime.datastore runtime.packages)
    (R.ok)))

(λ Runtime.Command.sync-package-tree [runtime package]
  "Set package state to staged, this will also propagate *down* its
  dependency tree. If any package in the tree is unhealthy, the stage command
  will fail. If any parent of the package is unhealthy, the stage command will
  fail.

  Note that staging propagates *down* but checks *up and down*."
  (fn can-sync? [package]
    (and (Package.healthy? package)
         package.git.target.commit))

  (fn depends-ons-can-sync? [package]
    (if (not (E.empty? package.depends-on))
      (E.all? #(and (can-sync? $1) (depends-ons-can-sync? $1))
              #(Package.iter package.depends-on))
      true))

  (fn depended-bys-can-sync? [package]
    (if package.depended-by
      (and (Package.healthy? package.depended-by)
           (depended-bys-can-sync? package.depended-by))
      true))

  (fn propagate-between [package]
    (E.each #(when (= $1.canonical-id package.canonical-id)
               (set $1.action :sync))
            #(Package.iter runtime.packages)))

  (fn propagate [package]
    (propagate-between package)
    (E.each propagate
            #(Package.iter package.depends-on)))

  (if (and (can-sync? package)
           (depends-ons-can-sync? package)
           (depended-bys-can-sync? package))
    (do
      (propagate package)
      (R.ok))
    (R.err "unable to stage tree, some packages unstagable")))

(λ Runtime.Command.hold-package-tree [runtime package]
  "Hold package at current state, this may mean keeping a package at the
  current checkout, or not cloning the package at all if it does not exist yet."
  ;; set the direct package to hold
  (set package.action :hold)
  ;; now propagate down the tree, and between canonical siblings, but only if
  ;; that siblings parent is also held.

  (fn propagate-between [package]
    ;; only set sibling package to hold if its parent is already held
    ;; or it has no parent, otherwise rely on holding of *its* parent
    ;; to propagate down.
    (E.each #(if (and (= $1.canonical-id package.canonical-id)
                     (or (= $1.depended-by nil)
                         (= $1.depended-by.action :hold)))
              (set $1.action :hold))
           #(Package.iter runtime.packages)))
  (fn propagate-down [package]
    (E.each propagate-between
            #(Package.iter package.depends-on)))
  (propagate-down package))

(fn Runtime.Command.discard [package])

(fn Runtime.Command.run-transaction [runtime]
  (local {:new task/new :run task/run :await task/await : trace} (require :pact.task))
  (local inspect (require :pact.inspect))
  (task/run #(result-let [t (Transaction.new runtime.datastore runtime.path.data)
                          _ (Transaction.prepare t)
                          ;; TODO topological sort these as a combined graph
                          _ (print (inspect t.id) (inspect t.path))
                          _ (trace "run t")
                          flat-packages (E.reduce (fn [acc package]
                                                    (E.set$ acc package.canonical-id package))
                                                  [] #(Package.iter runtime.packages))
                          _ (trace "flat-pack")
                          package-tasks (E.map (fn [p]
                                                 (-> (match p.action
                                                      :discard (task/new :discard #(Transaction.discard-package t p))
                                                      :hold (task/new :hold #(Transaction.retain-package t p))
                                                      :sync (task/new :sync #(Transaction.sync-package t p))
                                                      _ (task/new #(R.err [:unhandled p.action])))
                                                     (task/run {:traced #(-> p
                                                                             (Package.add-event :some-task $)
                                                                             (PubSub.broadcast :changed))})))
                                               flat-packages)
                          _ (trace "made-tasks")
                          _ (print (inspect package-tasks))
                          ;; TODO we await each task separately until await can handle a seq of tasks
                          ;;      and return a seq of values.
                          results (E.map #(task/await $) package-tasks)
                          _ (trace "end-awaited")
                          ;; TODO check results of each
                          ;; if ok do afters
                          ;; then save transaction
                          _ (Transaction.commit t)]
               (R.ok :arst)
               )
            {:traced print}))


(fn Runtime.dispatch [runtime command]
  (if command
    (match (command runtime)
      (where x (R.err? x)) (vim.notify (R.unwrap x) vim.log.levels.ERROR)))
  runtime)

(values Runtime)
