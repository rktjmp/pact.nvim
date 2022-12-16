(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: '*dout*} :pact.log
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
        siblings (E.reduce #(if (match? {:canonical-id package.canonical-id} $2)
                              (E.append$ $1 $2)
                              $1)
                           [] #(Package.iter runtime.packages))
        update-sibling #(E.each (fn [_ p] ($1 p)) siblings)]
    ;; Pair each constraint with its package so any targetable errors can be
    ;; propagated back to the correct package.
    (let [constraints (E.map #[$2.uid $2.constraint] siblings)
          s-way-cons (fmt "%s-way constraint%s" (length constraints) (if (= 1 (length constraints))
                                                                       "" "s"))
          commits package.commits
          repo (rel-path->abs-path :repos package.path.head)
          wf (solve-constraints/new package.canonical-id repo constraints commits)]
      (tset package.workflows wf true)
      (wf:attach-handler
        (fn [e]
          (update-sibling (fn [p]
                            (tset package.workflows wf nil)
                            (E.append$ p.events e)
                            (print :solves-to (tostring e))
                            (set p.solves-to (R.unwrap e))
                            (set p.text (vim.inspect e {:newline ""}))
                            (PubSub.broadcast p :solved))))
        (fn [e]
          (local {true oks false errs} (E.group-by #(R.ok? $2) (R.unwrap e)))
          (local all-ok? (= (length (or oks [])) (length (R.unwrap e))))
          (update-sibling (fn [p]
                            (tset package.workflows wf nil)
                            (let [result (E.find-value #(= (. (R.unwrap $2) :package-uid) p.uid)
                                                       (R.unwrap e))]
                              (E.append$ p.events result)
                              ;; We'll put in a generic failure message, and
                              ;; those that have specific errors will get those
                              ;; next
                              (if (R.ok? result)
                                (set p.solves-to (R.unwrap e)))
                              (if (and true all-ok?)
                                (do
                                  (Package.update-health p
                                                         (Package.Health.failing
                                                           (fmt "no single commit satisfied %s"
                                                                s-way-cons)))
                                  (set p.text
                                       (fmt "no single commit satisfied %s" s-way-cons))
                                  (set p.state :error))
                                (do
                                  (Package.update-health p
                                                         (Package.Health.degraded
                                                           (fmt "could not solve %s due to error in canonical sibling"
                                                                s-way-cons)))
                                  (set p.text
                                       (fmt "could not solve %s due to error in canonical sibling" s-way-cons))
                                  (set p.state :warning)))
                              (PubSub.broadcast p :error))))
          (E.each (fn [_ e]
                    (let [{: package-uid : constraint : msg} (R.unwrap e)
                          p (E.find-value #(= $2.uid package-uid) siblings)]
                      (Package.update-health p (Package.Health.failing msg))
                      (set p.text msg)
                      (set p.state :error)
                      (PubSub.broadcast p :error)))
                  (or errs [])))

        (fn [msg]
          (update-sibling (fn [p]
                            (E.append$ p.events msg)
                            (set p.text msg)
                            (PubSub.broadcast p :events-changed)))))
      (runtime.scheduler.local:add-workflow wf))))

Solve
