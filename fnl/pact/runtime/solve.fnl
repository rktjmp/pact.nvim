(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result-let} :pact.lib.ruin.result
     {: inspect!} :pact.lib.ruin.debug
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     PubSub :pact.pubsub
     Package :pact.package
     Runtime :pact.runtime
     {:format fmt} string)

(local Solve {})

(fn Solve.solve [runtime package]
  (fn rel-path->abs-path [in path]
    (FS.join-path (. runtime :path in) path))

  (let [{:new solve-constraints/new} (require :pact.workflow.status.solve-constraints)
        siblings (E.map #(if (= $1.canonical-id package.canonical-id) $1)
                        #(Package.iter runtime.packages))
        update-siblings #(E.each (fn [_ p] ($1 p)) siblings)]
    ;; Pair each constraint with its package so any targetable errors can be
    ;; propagated back to the correct package.
    (let [constraints (E.map #[$2.uid $2.constraint] siblings)
          s-way-cons (fmt "%s-way constraint%s" (length constraints) (if (= 1 (length constraints))
                                                                       "" "s"))
          commits package.git.commits
          repo (rel-path->abs-path :repos package.path.head) ;; TODO into module
          wf (solve-constraints/new package.canonical-id repo constraints commits)]
      (update-siblings #(Package.track-workflow $ wf))
      (wf:attach-handler
        (fn [ok-commit]
          (update-siblings #(-> $
                                (Package.untrack-workflow wf)
                                (Package.add-event wf ok-commit)
                                (Package.solve (R.unwrap ok-commit))
                                (PubSub.broadcast :solved)))
          (use DiscoverLogs :pact.runtime.discover.logs
               Scheduler :pact.workflow.scheduler)
         ; (vim.pretty_print :check package.git)
          (if package.git.checkout.HEAD
            (let [wf (DiscoverLogs.workflow package runtime.path.repos)]
              (Scheduler.add-workflow runtime.scheduler.local wf))))
        (fn [ok-commits-err-constraints]
          ;; This may be called with a mixture of ok-commit for constraints
          ;; that were solved and err-constraints for constraints that could
          ;; not be solved.
          ;; The workflow is considered a "failure", but we do want to show
          ;; which packages were vaguely ok, and which packages are actually
          ;; borked.
          (let [all-ok? (E.all? #(R.ok? $2) (R.unwrap ok-commits-err-constraints))
                find-result (fn [uid]
                              (E.find-value #(= (. (R.unwrap $2) :package-uid) uid)
                                            (R.unwrap ok-commits-err-constraints)))]
            (update-siblings (fn [p]
                              (Package.untrack-workflow p wf)
                              (let [relevant-result (find-result p.uid)]
                                (Package.add-event p wf relevant-result)
                                (match [all-ok? (R.ok? relevant-result)]
                                  [true _]
                                  (-> p
                                      ;; This is a funny edge case where all
                                      ;; constraints were solved but there was no
                                      ;; shared commit between them, so technically
                                      ;; they fail as a collection.
                                      ;; TODO: E.hd may give "non-latest" for versions
                                      (Package.solve (E.hd (. (R.unwrap relevant-result) :commits)))
                                      (Package.update-health (Package.Health.failing (fmt "no single commit satisfied %s"
                                                                                          s-way-cons))))
                                  [_ true]
                                  (-> p
                                      ;; sibling constraint was actually ok
                                      (Package.solve (R.unwrap relevant-result))
                                      (Package.update-health (Package.Health.degraded
                                                               (fmt "could not solve %s due to error in canonical sibling"
                                                                    s-way-cons))))
                                  [_ false]
                                  (-> p
                                      ;; sibling constraint failed, so we have specific error
                                      (Package.update-health (Package.Health.failing
                                                               (. (R.unwrap relevant-result) :msg))))))
                                (PubSub.broadcast p :error)))))
        (fn [msg]
          (update-siblings #(-> $
                                (Package.add-event wf msg)
                                (PubSub.broadcast :events-changed)))))
      (runtime.scheduler.local:add-workflow wf))))

Solve
