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

(local Discover {})

(fn Discover.current-status [runtime]
  "Find existing local and remote commits about the current set of packages then
  start the solver workflow for every package."
  (use DiscoverViableCommits :pact.workflow.status.discover-viable-commits
       DiscoverHeadCommit :pact.workflow.status.discover-head-commit
       Runtime :pact.runtime
       {:add-workflow scheduler/add-workflow} :pact.workflow.scheduler)

  (fn rel-path->abs-path [in path]
    (FS.join-path (. runtime :path in) path))

  (fn trigger-next [package]
    (match package.__facts-workflow
      [:ok true true]
      ;; TODO this is really ugly atm, looking every time to see if the whole
      ;; canonical set has finished or not.
      (let [siblings (Package.find-canonical-set package runtime.packages)]
        ;; need all sibling constraints before we can try to solve
        (when (E.all? #(match? [:ok true true] $2.__facts-workflow) siblings)
          (E.each #(set $2.__facts-workflow nil) siblings)
          ;; Siblings all share the same constraint set so once we have all
          ;; commit data we can solve for run against one pacakge in the set.
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
               (rel-path->abs-path :repos package.path.head))
          handler (fn handler [event]
                    (match event
                      (where e (R.ok? e))
                      (let [commits (R.unwrap e)]
                        (update-siblings (fn [package]
                                           ;; merge new values in with 
                                           (set package.commits (E.reduce #(E.set$ $1 $2 $3)
                                                                          (or package.commits {})
                                                                          commits))
                                           (set package.__facts-workflow
                                                (R.join package.__facts-workflow (R.ok true)))
                                           (set package.state :unstaged)))
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
    (let [wf (DiscoverHeadCommit.new package.canonical-id
                                     (rel-path->abs-path :transaction package.path.rtp))
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
  (let [_ (Package.walk-packages #(set $1.__facts-workflow (R.ok))
                                 runtime.packages)
        canonical-wfs (->> (Package.packages->canonical-set runtime.packages)
                           (E.map #(make-canonical-facts-wf $2)))
        unique-wfs (->> (Package.packages->seq runtime.packages)
                        (E.map #(make-unique-facts-wf $2)))]
    (E.each #(scheduler/add-workflow runtime.scheduler.remote $2)
            canonical-wfs)
    (E.each #(scheduler/add-workflow runtime.scheduler.local $2)
            unique-wfs))
  runtime)

Discover
