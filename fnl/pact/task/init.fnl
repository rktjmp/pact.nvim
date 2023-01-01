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
    (->> (E.map (fn [task-or-thread]
                  (if (M.task? task-or-thread)
                    task-or-thread.thread
                    task-or-thread))
                tasks)
         (E.any? #(not= :dead (coroutine.status $)))))

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
    (let [vals (E.reduce (fn [vals t i]
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

(fn* M.await
     ;; TODO this can we check if we called await without run?
  ;; TODO: [tasks] should return [values], but right now it would expand to (values ...)
  ; "Await an async tasks completion. Accepts 1 task, n-tasks or [task ...]"
  ; (where [tasks] (seq? tasks))
  ; (coroutine.yield tasks)
  (where [...])
  (coroutine.yield (E.pack ...)))

(fn M.trace [msg ...]
  "Output a 'trace message'. When called from a task, the message is dispatched
  to the first found `traced` handler. When called from outside a task the
  message is discarded.

  Assumes task is running on default scheduler."
  (let [{: default-scheduler : trace} (require :pact.task.scheduler)
        msg (fmt msg ...)]
    (match (coroutine.running)
      thread (trace default-scheduler thread msg))))

(fn M.cb->await [func ...]
  ;; Must be called inside a coroutine.
  ;;
  ;; Must be passed a function that accepts an async callback as the last argument.
  ;;
  ;; Creates a co-routine that suspends itself after calling the given
  ;; function, and then un-suspends itself after the async callback occurs.
  ;; When it suspends, it returns its own coroutine, which can be treated as a
  ;; spin on a future/promise.
  ;;
  ;; Since the async callback resumes the suspended coroutine, we can check the
  ;; status of that coroutine to get the status of the "promise". When its
  ;; suspended or running, the value isn't resolved, when it's "dead", that
  ;; means the async callback has completed.
  ;;
  ;; This comes together with the second step, that (await ...) *also* suspends
  ;; the main coroutine, when it returns the "promise" to the scheduler. When
  ;; the scheduler sees the promise is resolved, it can resume the main
  ;; workflow coroutine.
  ;;
  ;; Once resumed, the final value can be returned to the main coroutine as if
  ;; it had been a syncronous call.
  ; (expect (= :function (type func)) "must be a function")
  (assert (coroutine.running) "must call await inside (async ...)")
  (local argv (E.pack ...))
  (var awaited-value nil)
  (fn create-thread [func argv]
    (let [await-co (coroutine.running)
          resolve-future (fn [...]
                           ;; store the return value
                           (set awaited-value (E.pack ...))
                           ;; kill our future
                           (coroutine.resume await-co))
          _ (table.insert argv resolve-future)
          _ (set argv.n (+ argv.n 1))
          ;; this *can* throw, which we will rethrow
          ;; nil, x is caught and returned as nil, x
          ;; any other value is returned as thread, x
          first-return (E.pack (func (E.unpack argv)))]
      (match first-return
        ;; assume nil + x is an error internally and we should not proceed
        [nil err & _rest] (E.unpack first-return)
        ;; otherwise assume we're ok to "thread"
        ;; now suspend this coroutine, as a future, when the future resumes
        ;; itself, we will terminate and the future will be "dead" at which
        ;; point we know we can resume the main coroutine.
        _ (coroutine.yield await-co (E.unpack first-return)))))
  (let [await-co (coroutine.create create-thread)
        vals (E.pack (coroutine.resume await-co func argv))]
    (match vals
      ;; internal error when running function, so behave the same
      [false err] (error err)
      ;; "error like" return, so assume thread failed. Repack values
      ;; and continue on to return them.
      [true nil & rest] (set awaited-value (E.pack (E.unpack vals 2)))
      ;; got thread, so we can suspend ourselves
      (where [true thread & rest] (thread? thread)) (coroutine.yield (E.unpack vals 2)))
    ;; once we're resumed, when the "future" becomes "dead" and the scheduler
    ;; has picked up again, we can return the sticky value set in the thread.
    (values (E.unpack awaited-value))))

(fn M.await-schedule [f]
  (M.cb->await (fn [cb]
                 (vim.schedule #(cb (f))))))

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
  (where [id f] (and (string? id) (function? f)))
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
