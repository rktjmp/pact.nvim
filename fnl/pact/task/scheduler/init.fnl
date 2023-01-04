(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     PubSub :pact.pubsub
     gen-id :pact.gen-id
     Log :pact.log
     {:format fmt} string
     {:loop uv} vim)

(fn tasks-iter [tasks]
  (let [iter (fn []
               (E.each #(E.depth-walk (fn [task parents]
                                        (coroutine.yield task parents))
                                      $ #$.tasks)
                       tasks))]
    (values (coroutine.wrap iter) 0 0)))

(fn add-child-task [parent-context child-context]
  (table.insert parent-context.tasks child-context)
  (set child-context.parent parent-context))

(fn remove-child-task [task-context child-context]
  (set task-context.tasks (E.reject #(= $.id child-context.id)
                                       task-context.tasks)))

(fn make-timer-cb [scheduler]
  ;; walk tasks and collect the first N deepest we find.
  #(let [runnable (E.reduce (fn [acc task-context]
                              (if (E.empty? task-context.tasks)
                                (table.insert acc task-context))
                              (if (= (length acc) scheduler.concurrency-limit)
                                (E.reduced acc)
                                acc))
                            [] #(tasks-iter scheduler.tasks))
         ;; run tasks we found
         {:exec task/exec} (require :pact.task)
         results (E.map (fn [task-context]
                          (let [_ (set scheduler.current-task task-context)
                                (action value) (task/exec task-context.task)
                                _ (set scheduler.current-task nil)]
                            [task-context action value]))
                        runnable)
         ;; remove any finished tasks
         _ (E.each (fn [[task-context action _value]]
                     (match action
                       :halt (remove-child-task (or task-context.parent scheduler)
                                                task-context)
                       :crash (remove-child-task (or task-context.parent scheduler)
                                                 task-context)))
                   results)
         ;; handle any results
         _ (E.each (fn [[task-context action value]]
                     (match [action value]
                       [:trace [f msg]]
                       (match (pcall f msg)
                         (false err) (vim.schedule
                                       #(vim.notify (fmt "Task (%s) trace handler crashed: %s"
                                                         task-context.task.id
                                                         err)
                                                    vim.log.levels.ERROR)))
                       [:crash err]
                       (let [msg (debug.traceback task-context.task.thread
                                                  (fmt "Task (%s) crashed: %s"
                                                       task-context.task.id
                                                       (tostring err)))]
                         (Log.log msg) ;; TODO consistent logging
                         (vim.schedule #(vim.notify  msg vim.log.levels.ERROR)))
                       (where [:halt err] (R.err? err))
                       (vim.schedule
                         #(vim.notify (fmt "Task (%s) returned an error: %s"
                                           task-context.task.id
                                           (tostring err))
                                      vim.log.levels.WARN))))
                   results)]
     (PubSub.broadcast scheduler :tick)
     (when (= 0 (length scheduler.tasks))
       ; (print :stop-timer-uv (/ (- (vim.loop.hrtime) scheduler.created-at) 1_000_000))
       (uv.timer_stop scheduler.timer-handle)
       (uv.close scheduler.timer-handle)
       (tset scheduler :timer-handle nil))))

(fn trace [scheduler thread message]
  ;; find task owning thread, then search up to the first found message handler
  (local {: bward} (require :pact.lib.ruin.iter))
  (match-let [(task-context parents) (E.find (fn [task-context history]
                                               (= task-context.task.thread thread))
                                             #(tasks-iter scheduler.tasks))
              (_index {: traced}) (if task-context.traced
                                    (values 0 task-context)
                                    (E.find #(match? {: traced} $2)
                                            #(bward parents)))]
    (coroutine.yield [traced message])
    (else
      _ #nil)))

(fn queue-task [scheduler task ?opts]
  "Enqueue a task with on-event and on-complete callbacks.
  Starts scheduler loop if it's not currently running"
  (assert (and task.thread task.id) "add-task arg did not look like task")
  (let [task-context {:id (gen-id (.. task.id :-ctx))
                      :task task
                      :parent nil
                      :tasks []
                      :traced (?. ?opts :traced)}]
    (add-child-task (or scheduler.current-task scheduler) task-context)
    (when (= nil scheduler.timer-handle)
      (let [h (uv.new_timer)]
        (tset scheduler :timer-handle h)
        (tset scheduler :created-at (vim.loop.hrtime))
        (uv.timer_start h 0 scheduler.timer-rate-per-ms (make-timer-cb scheduler))))
    task))

(fn shutdown [scheduler]
  "Force halt a scheduler, in-progress tasks may be lost."
  (uv.timer_stop scheduler.timer-handle)
  (uv.close scheduler.timer-handle)
  (set scheduler.tasks []))

(fn* new
  (where [])
  (new {})
  (where [opts])
  {:id (gen-id :scheduler)
   :concurrency-limit (or (?. opts :concurrency-limit) 20)
   :tasks []
   :timer-handle nil
   :timer-rate-per-ms (/ 1000 30)})

(local default-scheduler (let [config (require :pact.config)]
                           (new {:concurrency-limit config.concurrency-limit})))

{: new
 : trace
 : queue-task
 : shutdown
 : default-scheduler}
