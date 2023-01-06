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
     Constraint :pact.package.spec.constraint
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
  (let [config (require :pact.config)
        FS (require :pact.fs)
        Datastore (require :pact.datastore)
        data-path config.path.data
        head-path config.path.head ;; TODO deprecated?
        runtime-path config.path.runtime
        runtime {:path {:runtime runtime-path ;; where pact exists in the rtp for loading
                        :data data-path ;; where pact stores all its data, repos, transactions, etc
                        :head head-path} ;; link path thats updated to point at current transaction
                 :datastore (Datastore.new data-path)
                 :transaction nil
                 :packages {}}]
    (legacy-check runtime-path)
    (bootstrap-filesystem runtime)
    runtime))

(set Runtime.Command {})

(λ Runtime.Command.initial-load [runtime]
  (let [ingest-first (require :pact.runtime.command.initial-load)]
    (ingest-first runtime.path.runtime runtime.datastore runtime.packages)
    (R.ok)))

(λ Runtime.Command.align-package-tree [runtime package]
  "Set package action to align, this will also propagate *down* its
  dependency tree. If any package in the tree is unhealthy, the stage command
  will fail. If any parent of the package is unhealthy, the stage command will
  fail.

  Note that staging propagates *down* but checks *up and down*."
  (fn can-align? [package]
    (and (Package.healthy? package)
         package.git.target.commit))

  (fn depends-ons-can-align? [package]
    (if (not (E.empty? package.depends-on))
      (E.all? #(and (can-align? $1) (depends-ons-can-align? $1))
              #(Package.iter package.depends-on))
      true))

  (fn depended-bys-can-align? [package]
    (if package.depended-by
      (and (Package.healthy? package.depended-by)
           (depended-bys-can-align? package.depended-by))
      true))

  (fn propagate-between [package]
    (->> (Package.find-canonical-set package runtime.packages)
         (E.each #(if (not (Package.aligned? $))
                    (set $.action :align)))))

  (fn propagate [package]
    (propagate-between package)
    (E.each propagate
            #(Package.iter package.depends-on)))

  (if (and (can-align? package)
           (depends-ons-can-align? package)
           (depended-bys-can-align? package))
    (do
      (propagate package)
      (R.ok))
    (R.err "unable to stage tree, some packages unstagable")))

(λ Runtime.Command.unstage-package-tree [runtime package]
  "Keep package at current state, whatever that may be. Existing packages
  should not be updated, new packages should not be installed, orphans should
  remain."
  (let [new-action #(if (Package.installed? $) :retain :discard)
        propagate-between (fn [package]
                            ;; If the parent of a package is also unstaged, we
                            ;; should unstage otherwise we should just keep the
                            ;; same action.
                            (let [canonical-set (Package.find-canonical-set package runtime.packages)]
                              (if (E.all? #(match (?. $ :depended-by :action)
                                             (where (or nil :discard :retain)) true
                                             _ false)
                                          canonical-set)
                                (E.each #(set $.action (new-action $))
                                        canonical-set))))]
    (E.each #(set $.action (new-action $))
            (Package.find-canonical-set package runtime.packages))
    (E.each propagate-between
            #(Package.iter package.depends-on))
    (R.ok)))

(λ Runtime.Command.discard-package-tree [runtime package]
  "Hold package at current state, this may mean keeping a package at the
  current checkout, or not cloning the package at all if it does not exist yet."
  (fn propagate-between [package]
    ;; only set sibling package to discard if its parent is already held
    ;; or it has no parent, otherwise rely on discarding of *its* parent
    ;; to propagate down.
    (E.each #(if (and (= $.canonical-id package.canonical-id)
                      (or (= $.depended-by nil)
                          (= $.depended-by.action :discard)))
               (set $.action :discard))
            #(Package.iter runtime.packages)))

  (fn propagate-down [package]
    (E.each propagate-between
            #(Package.iter package.depends-on)))

  ;; set the direct package to discard
  (if (Package.installed? package)
    (set package.action :discard)
    (set package.action :discard))
  (propagate-down package))

(λ Runtime.Command.get-logs [runtime package]
  (result-let [dsp (Datastore.package-by-canonical-id runtime.datastore package.canonical-id)
               from (?. package :git :current :commit)
               to (?. package :git :target :commit)]
    (match [from to]
      [{: sha} {: sha}] (R.err "cant diff without changes")
      [nil _] (R.err "cant diff without current commit")
      [_ nil] (R.err "cant diff without target commit")
      [a b] (let [{: run : await : trace} (require :pact.task)
                  task (Datastore.Git.logs-between dsp from to)]
              (run
                (fn []
                  (Package.increment-tasks-active package)
                  (trace "fetching logs")
                  (-> (run task)
                      (await)
                      (R.map (fn [logs]
                               (print logs)
                               (Package.decrement-tasks-active package)
                               (tset package :git :target :logs logs)
                               (R.ok))
                             (fn [err]
                               (Package.decrement-tasks-active package)
                               (print err)
                               (R.err err)))))
                {:traced (fn [msg] (Package.add-event package :logs msg))})
              (R.ok :task-started))
      _ (R.err "thinking-face-emoji"))))

(fn Runtime.Command.run-transaction [runtime update-win]
  (let [run-transaction (require :pact.runtime.command.run-transaction)]
    (run-transaction runtime update-win)))

(values Runtime)
