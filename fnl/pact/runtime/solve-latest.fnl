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

(local SolveLatest {})

(fn SolveLatest.solve [runtime package]
  (let [{:new solve-latest/new} (require :pact.workflow.status.solve-latest)
        siblings (E.reduce #(if (match? {:canonical-id package.canonical-id} $2)
                              (E.append$ $1 $2)
                              $1)
                           [] #(Package.iter runtime.packages))
        update-sibling #(E.each (fn [_ p] ($1 p)) siblings)]
    ;; Pair each constraint with its package so any targetable errors can be
    ;; propagated back to the correct package.
    (let [commits package.commits
          wf (solve-latest/new package.canonical-id commits)]
      (tset package.workflows wf true)
      (wf:attach-handler
        (fn [?version]
          (update-sibling (fn [package]
                            (tset package.workflows wf nil)
                            ;; TODO, cant append nil, worth recording "no latest"?
                            (if ?version
                              (E.append$ package.events ?version))
                            (set package.latest-version ?version)
                            ; (set package.text (tostring ?version))
                            (PubSub.broadcast package :solved-latest))))
        (fn [e]
          (error e))
        (fn [msg]
          (update-sibling (fn [package]
                            (E.append$ package.events msg)
                            (set package.text msg)
                            (PubSub.broadcast package :events-changed)))))
      (runtime.scheduler.local:add-workflow wf))))

SolveLatest
