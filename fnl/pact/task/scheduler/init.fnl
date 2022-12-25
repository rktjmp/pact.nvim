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
    ;; dequeue upto concurrency-limit
    (while (and (< (length scheduler.active) scheduler.concurrency-limit)
                (< 0 (length scheduler.queue)))
      (let [task (table.remove scheduler.queue 1)]
        (table.insert scheduler.active 1 task)))

    ;; tick every active task
    (let [{: exec} (require :pact.task)
          ;; pair the tasks with the run results so we can drop halted and
          ;; retain continued wfs in the active list.
          {:halt halted :cont continued :wait waiting}
          (->> (E.group-by
                 #(match (exec $2.task)
                    (action value) (values action [$2 value])
                    _ (vim.schedule
                        #(error (debug.traceback $2.task.thread
                                                 "task.exec did not return 2 values"))))
                 scheduler.active)
               (E.merge$ {:halt [] :cont [] :wait []}))]
      ;; collect anything that wants to be scheduled again, and update the
      ;; currently active list. Do this before dispatching any messaages so
      ;; any error in that occurs in dispatching doesn't leave zombie tasks.
      (tset scheduler :active (E.map (fn [_ [meta-task _result]] meta-task) continued))
      (E.concat$ scheduler.queue (E.map (fn [_ [meta-task _]] meta-task) waiting))
      ; (print (vim.inspect halted) (vim.inspect continued) (vim.inspect waiting))
      ;; dispatch any messages
      (->> (E.flatten [halted continued])
           (E.map (fn [_ [{: task : messaged : resolved : rejected} result]]
                    (macro safely-call [...]
                      `(match (pcall ,...)
                         (false err#) (vim.schedule
                                        #(error (fmt "task pcall error: %s %s %s"
                                                     ,(sym :task.id) err# (debug.traceback ,(sym :task.thread)))))))
                    ;; log errors separately to rejected calls for now TODO drop this?
                    (when (R.err? result)
                      (Log.log [task.id result])
                      (vim.schedule #(vim.notify (fmt "task error: %s %s %s"
                                                      task.id result (debug.traceback task.thread))
                                                vim.log.levels.WARN)))
                    ;; dispatch any sub-task messages that could not be
                    ;; yielded by the normal fashion.
                    (E.each #(safely-call messaged $2) task.sub-task-messages)
                    (set task.sub-task-messages [])
                    ;; dispatch regular result
                    (match result
                      (where ok (R.ok? ok)) (safely-call resolved ok)
                      (where err (R.err? err)) (safely-call rejected err)
                      (where msg (string? msg)) (safely-call messaged msg)))))
      ;; stop or nah?
      (when (= 0 (length scheduler.queue) (length scheduler.active))
        (uv.timer_stop scheduler.timer-handle)
        (uv.close scheduler.timer-handle)
        (tset scheduler :timer-handle nil)))))

(fn queue-task [scheduler task ?resolved ?rejected ?messaged]
  "Enqueue a task with on-event and on-complete callbacks.
  Starts scheduler loop if it's not currently running"
  (assert (and task.thread task.id) "add-task arg did not look like task")
  (let [index (if (coroutine.running) 1 (+ (length scheduler.queue) 1))]
    ;; TODO turn into tree?
    ;; Given tasks A B C, if they all spawn subtasks, we want to put the subtasks
    ;; at the head of the queue so they run earlier, otherwise we'd "start"
    ;; all tasks before they actually made any progress.
    ;; However We put the actual originating task at the tail of the queue after
    ;; executing it.
    ;; A B C -> aa B C A -> bb C A B -> ...
    ;; Otherwise we can lock the scheduler by filling it with "waiting" tasks.
    ;; Ideally we would actually track tasks as a tree so we could depth-first
    ;; each root task and be sure they run through before starting the next root
    ;; task.
    (table.insert scheduler.queue index {:task task
                                         :resolved (or ?resolved #nil)
                                         :rejected (or ?rejected #nil)
                                         :messaged (or ?messaged #nil)}))
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
   :waiting []
   :active []
   :timer-handle nil
   :timer-rate-per-ms (/ 1000 60)})

(local default-scheduler (new))

{: new
 : queue-task
 : shutdown
 : default-scheduler}
