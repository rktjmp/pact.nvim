(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
      {: 'result-> : 'result-let} :pact.lib.ruin.result
      E :pact.lib.ruin.enum
      FS :pact.fs
      inspect :pact.inspect
      Datastore :pact.datastore
      Solver :pact.solver
      PubSub :pact.pubsub
      Package :pact.package
      Commit :pact.package.git.commit
      Constraint :pact.package.git.constraint
      {:format fmt} string
      {:new task/new :run task/run :await task/await :trace task/trace} :pact.task)

(λ distribute-solved-result [canonical-set solved-to]
  (match solved-to
    ;; sovled case is very easy, we just set the target to the commit
    [:ok commit]
    (do
      (E.each #(Package.set-target-commit $ commit)
              canonical-set)
      (R.ok commit))
    ;; unsolved is more compilicated as we want to show *which* packages failed to solve.
    ;; this means we get back a list of <ok:constraint+commit> and <err:constraint+msg>
    ;; results, and we need to re-pair those constraints with their packages and extract
    ;; the error messages
    [:err mixed]
    (do
      (E.each #(match $
                 [:ok {: constraint :commits [commit]}]
                 (->> (E.filter #(Constraint.equal? $.constraint constraint)
                                canonical-set)
                      (E.each (fn [p]
                                (Package.set-target-commit p commit)
                                (Package.degrade-health p "degraded by sibling"))))
                 [:err {: constraint : msg}]
                 (->> (E.filter #(Constraint.equal? $.constraint constraint)
                                canonical-set)
                      (E.each #(Package.fail-health $ msg))))
              mixed)
      (R.ok nil))))

(λ process-initial-packages [runtime-prefix datastore all-packages]
  (fn make-process-task [sibling-packages canonical-id]
    ;; solving - perhaps incorrectly - performs checks against commit
    ;; constraints to ensure the commit actually exists, and so needs a proxy
    ;; into the data store to check with.
    ;; Probably the commit constraints (or all constraints?) could be pre-checked
    ;; by the data store (not as constraints but as commits), then the solver
    ;; can strictly resolve between them. TODO
    ;; It does bleed some of the "what is a constraint" into the other domain.
    ;; returns task & opts as we want to attach the tracer to the sibling packages
    (E.each Package.increment-tasks-waiting sibling-packages)
    [(task/new (fmt :process-package-%s canonical-id)
               (fn []
                 (E.each Package.decrement-tasks-waiting sibling-packages)
                 (E.each Package.increment-tasks-active sibling-packages)
                 (-> (result-let [;; pull out some information
                                  {:install {:path install-path}
                                   :git {: origin}} (E.hd sibling-packages)
                                  dsp (-> (Datastore.Git.register datastore canonical-id origin)
                                          (task/run)
                                          (task/await))
                                  verify-sha (fn [sha]
                                               (-> (Datastore.Git.verify-commit dsp (Commit.new sha))
                                                   (task/run)
                                                   (task/await)))
                                  commits (-> (Datastore.Git.fetch-commits dsp)
                                              (task/run)
                                              (task/await))
                                  ;; find local HEAD if it exists
                                  installs-to (FS.join-path runtime-prefix install-path)
                                  head (-> (Datastore.Git.commit-at-path dsp installs-to)
                                           (task/run)
                                           (task/await))
                                  _ (if head
                                      (let [c (or (E.find #(match? {:sha head.sha} $) commits) head)]
                                        (E.each #(Package.set-current-commit $ c)
                                                sibling-packages)))
                                  constraints (E.map #$.constraint sibling-packages)
                                  ;; solver returns a result, but we want to catch and work on it ourselves
                                  solved (let [solved (Solver.solve constraints commits verify-sha)]
                                           (distribute-solved-result sibling-packages solved)
                                           ;; failure to solve should not fail the task, just
                                           ;; stop some "solve dependent" stuff
                                           (R.map solved
                                                  #(R.ok $)
                                                  #(R.ok nil)))
                                  ;; note the highest version if there is one
                                  highest-version-constraint (Constraint.version "> 0.0.0")
                                  _ (match (Solver.solve [highest-version-constraint] commits verify-sha)
                                      [:ok commit]  (E.each #(Package.set-latest-commit $ commit) sibling-packages)
                                      [:err _] nil)
                                  _ (when (and head solved)
                                      (->  #(result-let [dist-t (-> (Datastore.Git.distance-between dsp head solved)
                                                                    (task/run))
                                                         break-t (-> (Datastore.Git.breaking-between? dsp head solved)
                                                                     (task/run))
                                                         [distance breaking?] (task/await [dist-t break-t])]
                                                        ;; TODO result-let "bug"? this wont fail the result-let
                                                        ;; as we match into two things.
                                                        (if (and (R.ok? distance) (R.ok? breaking?))
                                                          (E.each #(Package.set-target-commit-meta $ (R.unwrap distance) (R.unwrap breaking?))
                                                                  sibling-packages)
                                                          (R.join distance breaking?)))
                                          (task/run) ;; TODO not awaiting here will drop the task because parent is not checked for any siblings before removing it from the list.
                                          (task/await)))]
                                 (E.each (fn [p]
                                           (if p.git.current.commit
                                             ;; exists, so try to keep existing
                                             (set p.action :retain)
                                             ;; new, so require explicit install opt-in
                                             (set p.action :discard))
                                           (set p.ready? true)
                                           (Package.decrement-tasks-active p))
                                         sibling-packages)
                                 (R.ok))
                     (R.map (fn [ok] ok)
                            (fn [err]
                              (E.each #(Package.fail-health $ (inspect err))
                                      sibling-packages)
                              err)))))
     {:traced (fn [msg]
                (E.each #(-> $
                             (Package.add-event :initial-load msg)
                             (PubSub.broadcast :changed))
                        sibling-packages))}])
  (->> (E.group-by #(values $.canonical-id $)
                   #(Package.iter all-packages))
       ;; load and process all packages
       (E.map make-process-task)
       (E.map (fn [[task opts]]
                (task/run task opts)))))
