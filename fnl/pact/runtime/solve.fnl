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
          commits package.commits
          repo (rel-path->abs-path :repos package.path.head)
          wf (solve-constraints/new package.canonical-id repo constraints commits)]
      (tset package.workflows wf true)
      (wf:attach-handler
        (fn [e]
          (update-sibling (fn [p]
                            (tset package.workflows wf nil)
                            (E.append$ p.events e)
                            (set p.text (tostring e))
                            (PubSub.broadcast p :solved))))
        (fn [e]
          (update-sibling (fn [p]
                            (tset package.workflows wf nil)
                            ;; store the error and set generic fail message
                            (E.append$ p.events (R.err e))
                            (set p.text (fmt "could not solve %s-way constraint due to error in canonical sibling" (length constraints)))
                            (set p.state :warning)
                            (PubSub.broadcast p :error)))
          ;; now attach specific errors to each sibling if possible
          (E.each (fn [_ [[_ uid] msg]]
                    (-> (E.find-value #(match? {:uid uid} $2) siblings)
                        (E.set$ :text msg) ;;TODO we'll not set text directly when we have more errors defined, it should just be the UI interpreting them
                        (E.set$ :state :error)))
                  [e]))
        (fn [msg]
          (update-sibling (fn [p]
                            (E.append$ package.events msg)
                            (set package.text msg)
                            (PubSub.broadcast package :events-changed)))))
      (runtime.scheduler.local:add-workflow wf))))

Solve
