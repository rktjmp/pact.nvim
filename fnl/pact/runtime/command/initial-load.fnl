(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
      {: 'result-> : 'result-let} :pact.lib.ruin.result
      E :pact.lib.ruin.enum
      FS :pact.fs
      Datastore :pact.datastore
      Solver :pact.solver
      PubSub :pact.pubsub
      Package :pact.package
      Commit :pact.git.commit
      Constraint :pact.plugin.constraint
      {:format fmt} string
      {:new task/new :run task/run :await task/await :trace task/trace} :pact.task)

(λ process-initial-packages [runtime-prefix datastore all-packages]
  (fn make-process-task [sibling-packages canonical-id]
    ;; solving - perhaps incorrectly - performs checks against commit
    ;; constraints to ensure the commit actually exists, and so needs a proxy
    ;; into the data store to check with.
    ;; Probably the commit constraints (or all constraints?) could be pre-checked
    ;; by the data store (not as constraints but as commits), then the solver
    ;; can strictly resolve between them. TODO
    ;; It does bleed some of the "what is a constraint" into the other domain.
    (fn verify-sha [sha]
      (-> (Datastore.Git.verify-commit datastore canonical-id (Commit.new sha))
          (task/run)
          (task/await)))
    ;; returns task & opts as we want to attach the tracer to the sibling packages
    [(task/new (fmt :process-package-%s canonical-id)
               (fn []
                 (E.each #(set $.tasks (+ $.tasks 1)) sibling-packages)
                 (result-let [;; pull out some information
                              {:install {:path install-path} :git {: origin}} (E.hd sibling-packages)
                              ds-p (-> (Datastore.Git.register datastore canonical-id origin)
                                       (task/run)
                                       (task/await))
                              commits (-> (Datastore.Git.fetch-commits datastore canonical-id)
                                          (task/run)
                                          (task/await))
                              ;; current head is just informational, so dispatch a task and forget about it
                              _ (task/run #(result-let [installs-to (FS.join-path runtime-prefix install-path)
                                                        head (-> (Datastore.Git.commit-at-path datastore installs-to)
                                                                 (task/run)
                                                                 (task/await))
                                                        commit (match-try head
                                                                 {: sha} (E.find #(match? {:sha sha} $) commits)
                                                                 commit commit
                                                                 (catch _ nil))]
                                             (E.each #(Package.set-current-commit $ commit)
                                                     sibling-packages)
                                             (R.ok)))
                              constraints (E.map #$.constraint sibling-packages)
                              ;; solver returns a result, but we want to catch and work on it ourselves
                              _ (match (Solver.solve constraints commits verify-sha)
                                  ;; sovled case is very easy, we just set the target to the commit
                                  [:ok commit]
                                  (E.each #(Package.set-target-commit $ commit) sibling-packages)
                                  ;; unsolved is more compilicated as we want to show *which* packages failed to solve.
                                  ;; this means we get back a list of <ok:constraint+commit> and <err:constraint+msg>
                                  ;; results, and we need to re-pair those constraints with their packages and extract
                                  ;; the error messages
                                  [:err mixed]
                                  (E.each #(match $
                                             [:ok {: constraint :commits [c]}]
                                             (->> (E.filter #(Constraint.equal? $.constraint constraint)
                                                            sibling-packages)
                                                  (E.each #(-> $
                                                               (Package.set-target-commit c)
                                                               (Package.degrade-health "degraded by sibling"))))
                                             [:err {: constraint : msg}]
                                             (->> (E.filter #(Constraint.equal? $.constraint constraint)
                                                            sibling-packages)
                                                  (E.each #(-> $
                                                               (Package.fail-health msg)))))
                                          mixed))
                              ;; note the highest version if there is one
                              highest-version-constraint (Constraint.git :version "> 0.0.0")
                              _ (match (Solver.solve [highest-version-constraint] commits verify-sha)
                                  [:ok commit]  (E.each #(Package.set-latest-commit $ commit) sibling-packages)
                                  [:err _] nil)]
                   (R.ok))
                 (E.each #(do
                            (set $.tasks (- $.tasks 1))
                            (PubSub.broadcast $ :changed))
                         sibling-packages)
                 (R.ok)))
     {:traced (fn [msg]
                (E.each #(-> $
                             (Package.add-event :some-task msg)
                             (PubSub.broadcast :changed))
                        sibling-packages))}])
  (->> (E.group-by #(values $.canonical-id $)
                   #(Package.iter all-packages))
       (E.map make-process-task)
       (E.map (fn [[task opts]]
                (task/run task opts)))))
