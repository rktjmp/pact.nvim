(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
      {: 'result-> : 'result-let} :pact.lib.ruin.result
      E :pact.lib.ruin.enum
      Datastore :pact.datastore
      Solver :pact.solver
      PubSub :pact.pubsub
      Package :pact.package
      Constraint :pact.plugin.constraint
      {:format fmt} string
      {:new task/new :run async :await await :trace trace} :pact.task)

(λ ingest-package [datastore canonical-id packages]
  (result-let [canonical-package (. packages 1)
               _ (trace "ingesting package %s" canonical-id)
               _ (-> (async #(Datastore.ingest-package datastore
                                                       :git
                                                       canonical-id
                                                       canonical-package.git.remote.origin
                                                       canonical-package.install.path))
                     (await)
                     (R.map-err (fn [e]
                                  (E.map #(-> $2
                                             (Package.update-health (Package.Health.failing (tostring e)))
                                             (PubSub.broadcast :changed))
                                         packages)
                                  (R.err e))))]
    (R.ok)))

(λ find-package-by-constraint [packages constraint]
  (E.find-value #(Constraint.equal? $2.constraint constraint)
                packages))

(λ set-error-for-unsolved [package relevant-result all-ok? n-packages]
  (match [all-ok? (R.ok? relevant-result)]
    [true _]
    (-> package
        ;; This is a funny edge case where all
        ;; constraints were solved but there was no
        ;; shared commit between them, so technically
        ;; they fail as a collection.
        ;; TODO: E.hd may give "non-latest" for versions
        (Package.set-target-commit (E.hd (. (R.unwrap relevant-result) :commits)))
        (Package.fail-health (fmt "no single commit satisfied %s-way constraint"
                                  n-packages)))
    [_ true]
    (-> package
        ;; sibling constraint was actually ok
        (Package.set-target-commit (R.unwrap relevant-result))
        (Package.degrade-health (fmt "could not solve %s-way constraint due to error in canonical sibling"
                                     n-packages)))
    [_ false]
    (-> package
        ;; sibling constraint failed, so we have specific error
        (Package.fail-health (. (R.unwrap relevant-result) :msg)))))

(λ solve-package [datastore canonical-id packages]
  ;; This is all pretty gross, we get ok<commit> when solved or
  ;; err<[ok<constraint, commit>, err<constraint, msg>]> when unsolved.
  ;; The nested array is so we can pair solve-fails to packages that *failed*
  ;; and attach warning to other packages that *did* solve, but because of a
  ;; sibling failure are actually not usable.
  (result-let [_ (trace "solving package %s" canonical-id)
               ;; need to define this here for access to await for now at least. TODO
               verify-sha #(Datastore.verify-sha datastore canonical-id $)
               set-target-commit (fn [c]
                                   (E.each #(-> $2
                                                (Package.set-target-commit c)
                                                (PubSub.broadcast :changed))
                                           packages))
               set-errors (fn [results]
                            ;; This may be called with a mixture of ok-commit for constraints
                            ;; that were solved and err-constraints for constraints that could
                            ;; not be solved.
                            ;; The workflow is considered a "failure", but we do want to show
                            ;; which packages were vaguely ok, and which packages are actually
                            ;; borked.
                            (let [all-ok? (E.all? #(R.ok? $2) results)]
                              (E.each (fn [_ result]
                                        (let [{: constraint} (R.unwrap result)
                                              package (find-package-by-constraint packages constraint)]
                                          (set-error-for-unsolved package result all-ok? (length packages))))
                                      results))
                            ;; we don't consider the task failed because it didn't solve
                            (R.ok))
               commits (Datastore.commits-by-canonical-id datastore canonical-id)
               constraints (E.map #$2.constraint packages)
               solved (-> (async #(Solver.solve-constraints constraints commits verify-sha))
                          (await)
                          (R.map set-target-commit
                                 set-errors))
               latest (-> (async #(Solver.solve-constraints [(Constraint.git :version "> 0.0.0")]
                                                            commits
                                                            verify-sha))
                          (await)
                          (R.map (fn [c]
                                   (E.map #(Package.set-latest-commit $2 c)
                                          packages)
                                   (R.ok))
                                 #(R.ok)))]
    ;; solve errors are not hard errors and are handled
    ;; separately above, so if no other step failed,
    ;; we're actually "ok" regardless.
    (R.ok)))

(λ initial-load [datastore all-packages]
  (->> (E.group-by #(values $1.canonical-id $1)
                   #(Package.iter all-packages))
       (E.map (fn [canonical-id sibling-packages]
                (async (fn []
                         (E.each #(set $2.tasks (+ $2.tasks 1)) sibling-packages)
                         (await (async #(ingest-package datastore canonical-id sibling-packages)))
                         (await (async #(solve-package datastore canonical-id sibling-packages)))
                         (E.each #(set $2.tasks (- $2.tasks 1)) sibling-packages)
                         (R.ok))
                       {:traced (fn [msg]
                                  (E.each #(-> $2
                                               (Package.add-event :some-task msg)
                                               (PubSub.broadcast :changed))
                                          sibling-packages))})))))
