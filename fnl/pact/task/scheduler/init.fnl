(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     gen-id :pact.gen-id
     Log :pact.log
     {:format fmt} string
     {:loop uv} vim)

(fn make-timer-cb [scheduler]
  (fn []
    ;; can we add an additional task to the active list?
    (while (and (< (length scheduler.active) scheduler.concurrency-limit)
                (< 0 (length scheduler.queue)))
      ;; activate task
      (let [task (table.remove scheduler.queue 1)]
        (table.insert scheduler.active 1 task)))
    ;; tick every active task
    (let [{: exec} (require :pact.task)
          ;; pair the tasks with the run results so we can drop halted and
          ;; retain continued wfs in the active list.
          {:halt halted :cont continued}
          (->> (E.group-by
                 #(match (exec $2.task)
                    (action value) (values action [$2 value])
                    _ (vim.schedule
                        ;; TODO debug.traceback this
                        #(error "task.exec did not return 2 values")))
                 scheduler.active)
               (E.merge$ {:halt [] :cont []}))]
      ;; collect anything that wants to be scheduled again, and update the
      ;; currently active list. Do this before dispatching any messaages so
      ;; any error in that occurs in dispatching doesn't leave zombie tasks.
      (tset scheduler :active (E.map (fn [_ [meta-task _result]] meta-task) continued))
      ;; dispatch any messages
      (->> (E.flatten [halted continued])
           (E.map (fn [_ [{: task : message : resolved : rejected} result]]
                    (macro safely-call [...]
                      `(match (pcall ,...)
                         (false err#) (vim.schedule
                                        #(error (fmt "task pcall error: %s %s %s"
                                                     ,(sym :task.id) err# (debug.traceback ,(sym :task.thread)))))))
                    ;; log errors separately to rejected calls for now TODO drop this?
                    (when (R.err? result)
                      (Log.log [task.id result])
                      (vim.schedule #(error (fmt "task error: %s %s %s"
                                                 task.id result (debug.traceback task.thread)))))
                    ;; dispatch any sub-task messages that could not be
                    ;; yielded by the normal fashion.
                    (E.each #(safely-call message $2) task.sub-task-messages)
                    (set task.sub-task-messages [])
                    ;; dispatch regular result
                    (match result
                      (where ok (R.ok? ok)) (safely-call resolved ok)
                      (where err (R.err? err)) (safely-call rejected err)
                      (where msg (string? msg)) (safely-call message msg)))))
      ;; stop or nah?
      (when (= 0 (length scheduler.queue) (length scheduler.active))
        (uv.timer_stop scheduler.timer-handle)
        (uv.close scheduler.timer-handle)
        (tset scheduler :timer-handle nil)))))

(fn queue-task [scheduler task ?resolved ?rejected ?message]
  "Enqueue a task with on-event and on-complete callbacks.
  Starts scheduler loop if it's not currently running"
  (assert (and task.thread task.id) "add-task arg did not look like task")
  (table.insert scheduler.queue {:task task
                                 :resolved (or ?resolved #nil)
                                 :rejected (or ?rejected #nil)
                                 :message (or ?message #nil)})

  (when (= nil scheduler.timer-handle)
    (let [h (uv.new_timer)]
      (tset scheduler :timer-handle h)
      (uv.timer_start h 0 scheduler.timer-rate-per-ms (make-timer-cb scheduler)))))

(fn shutdown [scheduler]
  "Force halt a scheduler, in-progress tasks may be lost."
  (uv.timer_stop scheduler.timer-handle)
  ;; in-flight tasks may still have open processes, but those processes
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
  {:id (gen-id :scheduler)
   :concurrency-limit (or (?. opts :concurrency-limit) 5)
   :queue []
   :active []
   :timer-handle nil
   :timer-rate-per-ms (/ 1000 60)})

(local default-scheduler (new))

{: new
 : queue-task
 : shutdown
 : default-scheduler}
