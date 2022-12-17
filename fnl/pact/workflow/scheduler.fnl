(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     Log :pact.log
     {:format fmt} string
     {:loop uv} vim)

(local hertz (/ 1000 60))

(var id 0)
(fn gen-id []
  (set id (+ 1 id))
  id)

(local {: broadcast} (require :pact.pubsub))

(fn make-timer-cb [scheduler]
  (fn []
    ;; can we add an additional task to the active list?
    (while (and (< (length scheduler.active) scheduler.concurrency-limit)
                (< 0 (length scheduler.queue)))
      ;; activate workflow
      (let [workflow (table.remove scheduler.queue 1)]
        (table.insert scheduler.active 1 workflow)))
    ;; tick every active workflow
    (let [{: run} (require :pact.workflow)
          {: ok? : err?} (require :pact.lib.ruin.result)
          ;; pair the workflows with the run results so we can drop halted and
          ;; retain continued wfs in the active list.
          {:halt halted :cont continued}
          (->> (E.group-by
                 #(match (run $2)
                    (action value) (values action [$2 value])
                    _ (error "workflow.run did not return 2 values"))
                 scheduler.active)
               (E.merge$ {:halt [] :cont []}))]
      ;; collect anything that wants to be scheduled again, and update the
      ;; currently active list. Do this before dispatching any messaages so
      ;; any error in that occurs in dispatching doesn't leave zombie workflows.
      (tset scheduler :active (E.map (fn [_ [wf _result]] wf) continued))
      ;; dispatch any messages
      (->> (E.flatten [halted continued])
           (E.map (fn [_ [wf result]]
                    (if (R.err? result)
                      (Log.log [wf.id result]))
                    (match (pcall #(wf:handle result))
                      (false err) (vim.schedule
                                    #(error (fmt "wf-handle pcall error: %s" err))))
                    (broadcast wf result))))
      ;; if any halted workflows belonged to a set and that set is no longer present
      ;; in the active or queued, broadcast a generic ok event.
      (->> (E.map #(. $2 1) halted)
           (E.reject #(nil? $2.workflow-set))
           (E.reject (fn [_ {: workflow-set}]
                       (or (E.any? #(= workflow-set $2.workflow-set) continued)
                           (E.any? #(= workflow-set $2.workflow-set) scheduler.queue))))
           (E.map #(broadcast $2.workflow-set (R.ok $2.workflow-set))))
      ;; stop or nah?
      (when (= 0 (length scheduler.queue) (length scheduler.active))
        (uv.timer_stop scheduler.timer-handle)
        (uv.close scheduler.timer-handle)
        (tset scheduler :timer-handle nil)))))

(fn add-workflow [scheduler workflow]
  "Enqueue a workflow with on-event and on-complete callbacks.
  Starts scheduler loop if it's not currently running"
  (table.insert scheduler.queue workflow)
  (when (= nil scheduler.timer-handle)
    (let [h (uv.new_timer)]
      (tset scheduler :timer-handle h)
      (uv.timer_start h 0 hertz (make-timer-cb scheduler)))))

(fn add-workflow-set [scheduler workflows]
  (local id {:id (gen-id)})
  (->> (E.map #(E.set$ $2 :workflow-set id) workflows)
       (E.map #(add-workflow scheduler $2)))
  id)

(fn stop [scheduler]
  "Force halt a scheduler, in-progress workflows may be lost."
  (uv.timer_stop scheduler.timer-handle)
  ;; in-flight workflows may still have open processes, but those processes
  ;; will end, resolve their future, but the scheduler will no longer care
  ;; about the containing thread, so *I think* that wont leak.
  ;; TODO think about memory here when less tired.
  (each [i _ (ipairs scheduler.queue)]
    (tset scheduler.queue i nil))
  (tset scheduler :active nil)
  (uv.close scheduler.timer-handle))

(fn* new
  (where [])
  (new {})
  (where [opts])
  {:id (gen-id)
   ;; TODO: pass in channel/broadcast here instead of contantising it
   :concurrency-limit (or (?. opts :concurrency-limit) 5)
   :queue []
   :active []
   :timer-handle nil
   : stop
   : add-workflow
   : add-workflow-set})

{: new
 : add-workflow : add-workflow-set
 : stop}
