(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use inspect :pact.inspect
     gen-id :pact.gen-id
     E :pact.lib.ruin.enum
     R :pact.lib.ruin.result
     {:format fmt} string
     {:loop uv} vim)

(local M {})

(fn start-timer [task]
  (E.set$ task :timer (uv.now)))

(fn stop-timer [task]
  (E.set$ task :timer (- (uv.now) task.timer)))

(fn resume [task ...]
  "Called by the scheduler, task should yield or return a value"
  (match [(coroutine.resume task.thread ...)]
    ;; A task function may yield the following values:
    ;; [false error] <- not technically yielded, thrown by any internal errors
    ;; [true thread] <- task is waiting on another coroutine
    ;; [true [task ...]] <- task is waiting on a subtask(s)
    ;; [true [f msg]] <- infomation message and message handler
    ;; [true :halt value] <- final result, do not contuine to schedule the task
    ;;
    ;; We return the following values:
    ;; [:trace [f msg]] <- dispatch message via f
    ;; [:wait thread|[tasks]] <- we're waiting for sub tasks, suspend us
    ;; [:halt value] <- unschedule us, we no longer want to progress
    (where [true [msg-f msg]] (and (function? msg-f msg)))
    (do
      (table.insert task.events [:message msg])
      (values :trace [msg-f msg]))

    ;; "Awaited" portions of a task should yield the future/thread.
    ;; We instruct the scheduler to return to us later.
    ;; Legacy await for single thread, used by git/spawn TODO rewrite git?
    (where [true thread] (thread? thread))
    (do
      (table.insert task.events [:suspended])
      (tset task :awaiting [thread])
      (values :wait thread))

    ;; awaiting multiple threads, assumes all are threads ...
    (where [true [t & ts]] (M.task? t))
    (do
      (table.insert task.events [:suspended])
      (table.insert ts 1 t) ;; reform
      (tset task :awaiting ts)
      (values :wait ts))

    ;; result.ok signals that the task has terminated
    (where [true ok] (R.ok? ok))
    (do
      (stop-timer task)
      (tset task :value ok)
      (table.insert task.events [:value ok])
      (values :halt ok))

    ;; result.err signals we had a detected error, probably disk in poor state
    ;; or remote not responding, etc.
    (where [true err] (R.err? err))
    (do
      (stop-timer task)
      (tset task :value err)
      (table.insert task.events [:value err])
      (values :halt err))

    ;; This is an actual *crash* inside the coroutine, so we're matching on
    ;; pcall return.
    [false err]
    (let [err (R.err (debug.traceback task.thread err))]
      (stop-timer task)
      (tset task :value err)
      (table.insert task.events [:crash err])
      (values :crash err))

    ;; Shouldn't get here ... perhaps the task forgot to wrap the return
    ;; value.
    any (let [t-s (inspect task true)
              d-s (inspect any true)
              msg "OOPS! A task returned an unexpected value! Please report this error!"
              err (string.format "%s, task: %s data: %s" msg t-s d-s)]
          (vim.schedule #(vim.api.nvim_err_writeln err))
          (values :halt err))))

(fn M.exec [task]
  (fn still-awaiting? [tasks]
    (->> (E.map (fn [_ task-or-thread]
                  (if (M.task? task-or-thread)
                    task-or-thread.thread
                    task-or-thread))
                tasks)
         (E.any? #(not= :dead (coroutine.status $2)))))

  (match task
    ;; Never run before
    (where task (= nil task.timer))
    (do
      (start-timer task)
      (resume task))

    ;; task is paused by some threads, so just return to scheduler for continuation later
    (where {: awaiting} (still-awaiting? awaiting))
    (values :wait awaiting)

    ;; has some threads but the the threads are finished, clear awaiting and resume.
    (where {: awaiting} (not (still-awaiting? awaiting)))
    (let [vals (E.reduce (fn [vals i t]
                           (when (M.task? t)
                             (tset vals i t.value))
                           vals)
                         [] awaiting)]
      (tset task :awaiting nil)
      (resume task (E.unpack vals 1 (length awaiting))))

    ;; otherwise just resume the task
    (where task)
    (resume task)))

(fn M.task? [t]
  ;; *very* loose definition...
  (match? {: thread} t))

(fn M.await [...]
  (coroutine.yield (E.pack ...)))

(fn M.trace [msg ...]
  "Output a 'trace message'. When called from a task, the message is dispatched
  to the first found `traced` handler. When called from outside a task the
  message is printed.

  Assumes task is running on default scheduler."
  (let [{: default-scheduler : trace} (require :pact.task.scheduler)
        msg (fmt msg ...)]
    (match (coroutine.running)
      thread (trace default-scheduler thread msg)
      _ (print :default-trace msg))))

(fn* M.run
  "Run given task on the default scheduler. As a convenience, passing a
  function instead of a task creates an anonymous task and runs it.

  Accepts an option table to pass to `scheduler.queue-task`."
  (where [f] (function? f))
  (-> f (M.new) (M.run))
  (where [f opts] (and (function? f) (table? opts)))
  (-> f (M.new) (M.run opts))
  (where [task] (M.task? task))
  (M.run task {})
  (where [task opts] (and (M.task? task) (table? opts)))
  (let [{: queue-task : default-scheduler} (require :pact.task.scheduler)]
    (queue-task default-scheduler task opts)
    task))

(fn* M.new
  (where [f] (function? f))
  (M.new :anonymous f)
  (where [id f] (and (function? f) (string? id)))
  (let [t {:id (gen-id (.. id :-task))
           :thread nil
           :value nil
           :events []
           :timer nil
           :awaiting nil}]
    (set t.thread (coroutine.create (fn [...]
                                      (set t.value (f ...))
                                      t.value)))
    t))

;; alias
(set M.task M.new)
(set M.async M.run)

M
