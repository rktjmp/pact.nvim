(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     gen-id :pact.gen-id
     Log :pact.log
     {:format fmt} string
     {:loop uv} vim)

(fn task-iter [root-task]
  (let [next-id #$.children
        iter (fn []
               (E.depth-walk (fn [task]
                               (coroutine.yield task))
                             root-task next-id)
               nil)]
    (values (coroutine.wrap iter) 0 0)))

(fn add-task-context-child [parent-context child-context]
  (table.insert parent-context.children child-context)
  (set child-context.parent parent-context))

(fn remove-task-context-child [task-context child-context]
  (set task-context.children (E.reject #(= $2.id child-context.id)
                                       task-context.children)))

(fn make-timer-cb [scheduler]
  (fn []
    ;; walk tasks and collect the first N deepest we find.
    (let [runnable (E.reduce (fn [acc task-context]
                               (if (E.empty? task-context.children)
                                 (table.insert acc task-context))
                               (if (= (length acc) scheduler.concurrency-limit)
                                 (E.reduced acc)
                                 acc))
                             [] #(task-iter {:id :scheduler-root
                                             :children scheduler.tasks}))
          ;; run tasks we found
          {:exec task/exec} (require :pact.task)
          results (E.map (fn [_ task-context]
                           (when (not= task-context.id :scheduler-root)
                             (let [_ (set scheduler.current-task task-context)
                                   (action value) (task/exec task-context.task)
                                   _ (set scheduler.current-task nil)]
                               [task-context action value])))
                         runnable)
          ;; remove any finished tasks
          _ (E.each (fn [_ [task-context action _value]]
                      (match action
                        :halt (match task-context
                                {: parent} (remove-task-context-child parent task-context)
                                {:parent nil} (set scheduler.tasks (E.reject #(= $2.id task-context.id)
                                                                             scheduler.tasks)))))
                    results)
          ;; dispatch any results
          _ (E.each (fn [_ [task-context action value]]
                      (print task-context.id action value)))]
      (when (= 0 (length scheduler.tasks))
        (uv.timer_stop scheduler.timer-handle)
        (uv.close scheduler.timer-handle)
        (tset scheduler :timer-handle nil)))))

;     ;; dequeue upto concurrency-limit
;     (while (and (< (length scheduler.active) scheduler.concurrency-limit)
;                 (< 0 (length scheduler.queue)))
;       (let [task (table.remove scheduler.queue 1)]
;         (table.insert scheduler.active 1 task)))

;     ;; tick every active task
;     (let [{: exec} (require :pact.task)
;           ;; pair the tasks with the run results so we can drop halted and
;           ;; retain continued wfs in the active list.
;           {:halt halted :cont continued :wait waiting}
;           (->> (E.group-by
;                  (fn [_ meta-task]
;                    (set scheduler.current-task meta-task)
;                    (match (exec meta-task.task)
;                      (action value) (values action [meta-task value])
;                      _ (vim.schedule
;                          #(error (debug.traceback meta-task.task.thread
;                                                   "task.exec did not return 2 values")))))
;                  scheduler.active)
;                (E.merge$ {:halt [] :cont [] :wait []}))]
;       ;; stopped running anything
;       (set scheduler.current-task nil)
;       ;; collect anything that wants to be scheduled again, and update the
;       ;; currently active list. Do this before dispatching any messaages so
;       ;; any error in that occurs in dispatching doesn't leave zombie tasks.
;       (tset scheduler :active (E.map (fn [_ [meta-task _result]] meta-task) continued))
;       (E.concat$ scheduler.queue (E.map (fn [_ [meta-task _]] meta-task) waiting))
;       ; (print (vim.inspect halted) (vim.inspect continued) (vim.inspect waiting))
;       ;; dispatch any messages
;       (->> (E.flatten [halted continued])
;            (E.map (fn [_ [{: task : messaged : resolved : rejected} result]]
;                     (macro safely-call [...]
;                       `(match (pcall ,...)
;                          (false err#) (vim.schedule
;                                         #(error (fmt "task pcall error: %s %s %s"
;                                                      ,(sym :task.id) err# (debug.traceback ,(sym :task.thread)))))))
;                     ;; log errors separately to rejected calls for now TODO drop this?
;                     (when (R.err? result)
;                       (Log.log [task.id result])
;                       (vim.schedule #(vim.notify (fmt "task error: %s %s %s"
;                                                       task.id result (debug.traceback task.thread))
;                                                 vim.log.levels.WARN)))
;                     ;; dispatch any sub-task messages that could not be
;                     ;; yielded by the normal fashion.
;                     (E.each #(safely-call messaged $2) task.sub-task-messages)
;                     (set task.sub-task-messages [])
;                     ;; dispatch regular result
;                     (match result
;                       (where ok (R.ok? ok)) (safely-call resolved ok)
;                       (where err (R.err? err)) (safely-call rejected err)
;                       (where msg (string? msg)) (safely-call messaged msg)))))
;       ;; stop or nah?
;       (when (= 0 (length scheduler.queue) (length scheduler.active))
;         (uv.timer_stop scheduler.timer-handle)
;         (uv.close scheduler.timer-handle)
;         (tset scheduler :timer-handle nil)))))

(fn queue-task [scheduler task ?resolved ?rejected ?messaged]
  "Enqueue a task with on-event and on-complete callbacks.
  Starts scheduler loop if it's not currently running"
  (assert (and task.thread task.id) "add-task arg did not look like task")
  (let [task-context {:id (gen-id :task-context)
                      :task task
                      :parent nil
                      :children []
                      :resolved (or ?resolved #nil)
                      :rejected (or ?rejected #nil)
                      :messaged (or ?messaged #nil)}]
    (match scheduler.current-task
      t (do
          (set task-context.parent t)
          (table.insert t.children task-context))
      nil (table.insert scheduler.tasks task-context))
    (when (= nil scheduler.timer-handle)
      (let [h (uv.new_timer)]
        (tset scheduler :timer-handle h)
        (uv.timer_start h 0 scheduler.timer-rate-per-ms (make-timer-cb scheduler))))
    nil))

; (fn shutdown [scheduler]
;   "Force halt a scheduler, in-progress tasks may be lost."
;   (uv.timer_stop scheduler.timer-handle)
;   ;; TODO write for tree
;   ;; in-flight tasks may still have open processes, but those processes
;   ;; will end, resolve their future, but the scheduler will no longer care
;   ;; about the containing thread, so *I think* that wont leak.
;   ;; TODO think about memory here when less tired.
;   (each [i _ (ipairs scheduler.queue)]
;     (tset scheduler.queue i nil))
;   (tset scheduler :active nil)
;   (uv.close scheduler.timer-handle))

(fn* new
  (where [])
  (new {})
  (where [opts])
  {:id (gen-id :scheduler)
   :concurrency-limit (or (?. opts :concurrency-limit) 5)
   :tasks []
   :timer-handle nil
   :timer-rate-per-ms (/ 1000 60)})

(local default-scheduler (new))

{: new
 : queue-task
 ; : shutdown
 : default-scheduler}
