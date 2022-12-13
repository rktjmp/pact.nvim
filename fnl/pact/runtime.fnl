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

(fn Runtime.walk-packages [runtime f ?acc]
  "Depth walk the package graphs, optionally with an accumulator. See `ruin.depth-walk'."
  (fn nid [n] n.depends-on)
  (if ?acc
    (E.reduce #(E.depth-walk f $3 $1 nid)
              ?acc runtime.packages)
    (E.each #(E.depth-walk f $2 nid)
            runtime.packages)))

;; TODO: this may be less useful than it seems. The UI will probably always
;; walk all packages because it needs to show more contextual information
;; (this package is staged because of shared dependency, this package for this
;; dependency is pinned to x@y). When things can be shared such as "state"/text
;; they need to be copied out anyway. It also needs to be kept in sync as new
;; packages appear, without any hanging references.
;; Simpler just to walk the tree all the time no?
; (fn Runtime.update-package-list [runtime]
;   "Flatten a packages down into:

;   {package-id {:contraints [a ...]
;                :depends-on [id ...]
;                :depended-by [id ...]
;                :packages [package ...]}
;    ...}

;   Most interaction with packages is done via the manifest as it has
;   key based lookup and collates multiple constraints, etc. Note that packages
;   is plural as one canonical package may be used in multiple places - with
;   different constraints and configuration!

;   We retain the graph in full form mostly for contextual error reporting."
;   (fn new-meta-package [package]
;     {:canonical-id package.canonical-id
;      :constraints [[package.canonical-id package.constraint]]
;      :depends-on (E.map #$2.canonical-id package.depends-on)
;      :depended-by [(?. package :depended-by :canonical-id)]
;      :after :TODO
;      :name package.name
;      :source package.source
;      :path package.path
;      :state :waiting
;      :defined-by [package]})
;   (fn patch-meta-package [existing new]
;     (let [?parent new.depended-by
;           constraint (if ?parent
;                        [?parent.canonical-id new.constraint]
;                        [new.canonical-id new.constraint])]
;       (E.append$ existing.constraints constraint)
;       (E.concat$ existing.depends-on (E.map #$2.canonical-id new.depends-on))
;       (E.append$ existing.depended-by (?. new :depended-by :canonical-id))
;       (E.append$ existing.defined-by new.uid)
;       existing))

;   (let [f (fn [acc node history]
;             (let [parent (E.last history)]
;               (when (and parent (not (R.err? node)))
;                 (match (. acc node.canonical-id)
;                   nil (tset acc node.canonical-id (new-meta-package node))
;                   x (patch-meta-package x node)))
;               acc))]
;     (set runtime.package-list (Runtime.walk-packages runtime f {}))
;     runtime))

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
    (fn unroll [proxy graph]
      ;; unwrap the proxy
      (match (proxy)
        (where r (R.ok? r))
        (let [spec (R.unwrap r)
              package (Package.userspec->package spec)
              dependencies (->> (E.reduce #(unroll $3 $1)
                                          ;; use fresh subgraph
                                          [] spec.dependencies)
                                ;; set backlink in dependencies to parent for
                                ;; ease of use
                                (E.map #(doto $2 (tset :depended-by package))))]
          ;; userspec->package cant set this to real packages
          (tset package :depends-on dependencies)
          ;; and add to the graph!
          (E.append$ graph package))
        (where r (R.err? r))
        (E.append$ graph r))
      graph)
    ;; The proxies list contains one list per call to make-pact, so we'll
    ;; collate them all.
    (E.flat-map #(E.reduce #(unroll $3 $1)
                           [] $2)
                proxies))

  ;; User plugins arrive as as a graph but they're wrapped in a proxy function
  ;; for performance reasons. We'll unproxy them into real values first.
  ;; This graph can have duplicates or conflicting specs but we resolve that
  ;; later.
  (tset runtime :packages (unproxy-spec-graph proxies))
  ;; TODO: ideally this would soft fail only the parts with a loop
  ;; TODO: warn on duplicate canonical ids
  ;; TODO: also "provides: id" option
  ;; TODO: does a loop even matter? we install all things independently anyway,
  ;; so if a depends on b depends on a, we end up with flat a + b, and we can
  ;; just install them? 
  ;; _ (validate-DAG spec-graph)
  runtime)

(fn Runtime.exec-solve-tree [runtime package]
  true)


(fn exec-discover-package-facts [package]
  true)

(fn exec-discover-canonical-package-facts [runtime package]
  "Find facts relating to every package sharing the same canonical id."
  (use DiscoverCanonicalFacts :pact.workflow.status.discover-canonical-facts
       Scheduler :pact.workflow.scheduler)
  true)

(fn rel-path->abs-path [runtime in path]
  (FS.join-path (. runtime :path in) path))

(fn find-siblings-packages [runtime package]
  (Package.find-packages #(= $1.canonical-id package.canonical-id)
                         runtime.packages))

(fn Runtime.exec-solve-package-constraints [runtime package]
  (let [{:new solve-constraints/new} (require :pact.workflow.status.solve-constraints)
        siblings (find-siblings-packages runtime package)
        update-sibling #(E.each (fn [_ p] ($1 p)) siblings)]
    ;; Pair each constraint with its package so any targetable errors can be
    ;; propagated back to the correct package.
    (let [constraints (E.map #[$2.uid $2.constraint] siblings)
          commits package.commits
          repo (rel-path->abs-path runtime :repos package.path.head)
          wf (solve-constraints/new package.canonical-id repo constraints commits)
          handler (fn handler [event]
                    (match event
                      (where e (R.ok? e))
                      (do
                        (update-sibling (fn [p]
                                          (E.append$ p.events e)
                                          (set p.text (vim.inspect (R.unwrap e) {:newline ""}))
                                          (PubSub.broadcast p :solved)))
                        (PubSub.unsubscribe wf handler))
                      (where e (R.err? e))
                      (do
                        (update-sibling (fn [p]
                                          ;; store the error and set generic fail message
                                          (E.append$ p.events e)
                                          (set p.text (fmt "could not solve %s-way constraint due to error in canonical sibling" (length constraints)))
                                          (set p.state :warning)
                                          (PubSub.broadcast p :error)))
                        ;; now attach specific errors to each sibling if possible
                        (E.each (fn [_ [[_ uid] msg]]
                                  (-> (E.find-value #(match? {:uid uid} $2) siblings)
                                      (E.set$ :text msg)
                                      (E.set$ :state :error)))
                               [(R.unwrap e)])
                      (PubSub.unsubscribe wf handler))
                      (where msg (string? msg))
                      (do
                        (update-sibling (fn [p]
                                          (E.append$ package.events msg)
                                          (set package.text msg)
                                          (PubSub.broadcast package :events-changed))))))]
      (PubSub.subscribe wf handler)
      (runtime.scheduler:add-workflow wf))))

(fn Runtime.discover-current-status [runtime]
  "Find existing local and remote commits about the current set of packages then
  start the solver workflow for every package."
  (use DiscoverViableCommits :pact.workflow.status.discover-viable-commits
       DiscoverHeadCommit :pact.workflow.status.discover-head-commit
       Scheduler :pact.workflow.scheduler)

  (fn trigger-next [package]
    (match package.__facts-workflow
      [:ok true true true]
      ;; TODO this is really ugly atm, looking every time to see if the whole
      ;; canonical set has finished or not.
      (let [siblings (find-siblings-packages runtime package)]
        ;; need all sibling constraints before we can try to solve
        (when (E.all? #(match? [:ok true true true] $2.__facts-workflow) siblings)
          ;; once all siblings are done we can solve for all at once.
          (E.each #(set $2.__facts-workflow nil) siblings)
          (Runtime.exec-solve-package-constraints runtime package)))
      [:err _] (error :some-error-cant-solve)))

  (fn make-canonical-facts-wf [package]
    (let [;; we need to propagate canonical facts between all related packages
          siblings (Package.find-packages #(= $1.canonical-id package.canonical-id)
                                          runtime.packages)
          update-siblings #(E.each (fn [_ p] ($1 p)) siblings)
          wf (DiscoverViableCommits.new
               package.canonical-id
               (Package.source package)
               (rel-path->abs-path runtime :repos package.path.head))
          handler (fn handler [event]
                    (match event
                      (where e (R.ok? e))
                      (let [commits (R.unwrap e)]
                        (update-siblings (fn [package]
                                           (set package.commits (E.reduce #(E.set$ $1 $2 $3)
                                                                          (or package.commits {})
                                                                          commits))
                                           (set package.__facts-workflow
                                                (R.join package.__facts-workflow (R.ok true)))
                                           (set package.state :unstaged)))
                        (Runtime.exec-solve-tree runtime package)
                        (PubSub.broadcast package :facts-changed)
                        (PubSub.unsubscribe wf handler)
                        (update-siblings (fn [package] (trigger-next package))))
                      (where e (R.err? e))
                      (do
                        (update-siblings (fn [package]
                                           (set package.text (R.unwrap e))
                                           (set package.state :error)
                                           (set package.__facts-workflow
                                                (R.join package.__facts-workflow (R.err false)))))
                        (PubSub.broadcast package :facts-changed)
                        (PubSub.unsubscribe wf handler)
                        (update-siblings (fn [package] (trigger-next package))))
                      (where msg (string? msg))
                      (update-siblings (fn [package]
                                          (E.append$ package.events msg)
                                          (set package.text msg)
                                          (PubSub.broadcast package :events-changed)))))]
      (PubSub.subscribe wf handler)
      wf))

  (fn make-unique-facts-wf [package]
    (let [wf (DiscoverHeadCommit.new
               package.canonical-id
               (rel-path->abs-path runtime :transaction package.path.rtp))
          handler (fn handler [event]
                    (match event
                      (where e (R.ok? e))
                      (let [commits (R.unwrap e)]
                        (set package.commits (E.reduce #(E.set$ $1 $2 $3)
                                                       (or package.commits {})
                                                       commits))
                        (set package.state :unstaged)
                        (set package.__facts-workflow (R.join package.__facts-workflow
                                                              (R.ok true)))
                        (PubSub.broadcast package :facts-changed)
                        (PubSub.unsubscribe wf handler)
                        (trigger-next package))
                      (where e (R.err? e))
                      (do
                        (set package.text (R.unwrap e))
                        (set package.state :error)
                        (set package.__facts-workflow (R.join package.__facts-workflow
                                                              (R.err false)))
                        (PubSub.broadcast package :error)
                        (PubSub.unsubscribe wf handler)
                        (trigger-next package))
                      (where msg (string? msg))
                      (do
                        (E.append$ package.events msg)
                        (set package.text msg)
                        (PubSub.broadcast package :events-changed))))]
      (PubSub.subscribe wf handler)
      wf))

  ;; We can fetch canonically-relevant facts in one go for multiple packages
  ;; but must fetch the individual current sha separately. These are
  ;; sort of racey in status-messages but for now we'll let that slide.
  (let [;; TODO remove true value when ruin updated
        _ (Package.walk-packages #(set $1.__facts-workflow (R.ok true))
                                 runtime.packages)
        canonical-wfs (->> (Package.packages->canonical-set runtime.packages)
                           (E.map #(make-canonical-facts-wf $2)))
        unique-wfs (->> (Package.packages->seq runtime.packages)
                        (E.map #(make-unique-facts-wf $2)))]
    (E.each #(Scheduler.add-workflow runtime.scheduler $2)
            canonical-wfs)
    (E.each #(Scheduler.add-workflow runtime.scheduler $2)
            unique-wfs))
  runtime)

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
  (let [active (length runtime.scheduler.active)
        queued (length runtime.scheduler.queue)]
    {:active active
     :queued queued}))

(fn Runtime.new [opts]
  (let [Scheduler (require :pact.workflow.scheduler)
        FS (require :pact.workflow.exec.fs)
        scheduler (Scheduler.new {:concurrency-limit opts.concurrency-limit})]
    (-> {:path {:root (FS.join-path (vim.fn.stdpath :data) :site/pack/pact)
                :head (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/data/HEAD)
                :data (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/data)
                :repos (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/data/repos)}
         :transaction {:head {}}
         :packages {}
         :scheduler scheduler ;; TODO: we can have more than one scheduler,
                              ;; really we want to rate limit remote work not local checks
         :walk-packages Runtime.walk-packages}
        (parse-disk-layout))))

(values Runtime)
