(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: '*dout*} :pact.log
     {: 'result-let} :pact.lib.ruin.result
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
          commits package.commits
          repo (rel-path->abs-path :repos package.path.head)
          wf (solve-constraints/new package.canonical-id repo constraints commits)]
      (tset package.workflows wf true)
      (wf:attach-handler
        (fn [e]
          (update-sibling (fn [p]
                            (tset package.workflows wf nil)
                            (E.append$ p.events e)
                            (set p.text (vim.inspect e {:newline ""}))
                            (PubSub.broadcast p :solved))))
        (fn [e]
          (update-sibling (fn [p]
                            (tset package.workflows wf nil)
                            ;; store the error and set generic fail message
                            (E.append$ p.events e)
                            (set p.text (fmt "could not solve %s-way constraint due to error in canonical sibling" (length constraints)))
                            (set p.state :warning)
                            (PubSub.broadcast p :error)))
          (match e
            ;; just an error, apply to all
            (where [:err msg nil] (string? msg))
            (update-sibling (fn [p]
                            (tset package.workflows wf nil)
                            (E.append$ p.events e)
                            (set p.text msg)
                            (set p.state :error)
                            (PubSub.broadcast p :error)))
            ;; otherwise we have a list of failed
            _ (E.each (fn [_ details]
                        (match details
                          [[_ uid] msg] (-> (E.find-value #(match? {:uid uid} $2) siblings)
                                            (E.set$ :text msg) ;;TODO we'll not set text directly when we have more errors defined, it should just be the UI interpreting them
                                            (E.set$ :state :error))
                          _ (error details)))
                      [(R.unwrap e)])))
        (fn [msg]
          (update-sibling (fn [p]
                            (E.append$ p.events msg)
                            (set p.text msg)
                            (PubSub.broadcast p :events-changed)))))
      (runtime.scheduler.local:add-workflow wf))))

Solve
