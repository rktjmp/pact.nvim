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

(fn still-awaiting? [tasks]
  (->> (E.map (fn [_ task-or-thread]
                (if (M.task? task-or-thread)
                  task-or-thread.thread
                  task-or-thread))
              tasks)
       (E.any? #(not= :dead (coroutine.status $2)))))

(fn resume [task ...]
  "Called by the scheduler, task should yield or return a value"
  (match [(coroutine.resume task.thread ...)]
    ;; A task function may yield the following values:
    ;; [false error] <- not technically yielded, thrown by any internal errors
    ;; [true thread] <- task is waiting on another coroutine
    ;; [true [task ...]] <- task is waiting on a subtask
    ;; [true :cont info...] <- infomation message (we pass this up)
    ;; [true :halt value...] <- inform scheduler to unschedule us, value is stored
    ;;                          as task result.
    ;; We return the following values:
    ;; [:cont value] <- keep us scheduled
    ;; [:halt value] <- unschedule us, we no longer want to progress

    ;; Coroutines can yield a string up to pass information messages to the
    ;; scheduler. These should always request contiunation.
    (where [true msg] (string? msg))
    (do
      (table.insert task.events [:message msg])
      (values :cont msg))

    ;; "Awaited" portions of a task should yield the future/thread.
    ;; We instruct the scheduler to return to us later.
    ;; Legacy await for single thread, used by git/spawn
    (where [true thread] (thread? thread))
    (do
      (table.insert task.events [:suspended])
      (tset task :awaiting [thread])
      (values :cont thread))

    ;; awaiting multiple threads, assumes all are threads ...
    (where [true [t & ts]] (M.task? t))
    (do
      (table.insert task.events [:suspended])
      (table.insert ts 1 t) ;; reform
      (tset task :awaiting ts)
      (values :cont ts))

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
    (let [err (R.err err)]
      (stop-timer task)
      (tset task :value err)
      (values :halt err))

    ;; Shouldn't get here ... perhaps the task forgot to wrap the return
    ;; value.
    any (let [t-s (inspect task true)
              d-s (inspect any true)
              msg "OOPS! A task returned an unexpected value! Please report this error!"
              err (string.format "%s, task: %s data: %s" msg t-s d-s)]
          (vim.schedule #(vim.api.nvim_err_writeln err))
          (values :halt err))))

(fn M.exec [task]
  (match task
    ;; Never run before
    (where task (= nil task.timer))
    (do
      (start-timer task)
      (resume task {:await M.await :log #(M.log task $...)}))

    ;; task is paused by some threads, so just return to scheduler for continuation later
    (where {: awaiting} (still-awaiting? awaiting))
    (values :cont awaiting)

    ;; has some threads but the the threads are finished, clear awaiting and resume.
    (where {: awaiting} (not (still-awaiting? awaiting)))
    (let [vals (E.map #(if (M.task? $2) $2.value) awaiting)] ;; TODO this should be packed via reduce and unpacked
      (print "awaited..." (inspect vals))
      (tset task :awaiting nil)
      (resume task (E.unpack vals)))

    ;; otherwise just resume the task
    (where task)
    (resume task)))

(fn M.task? [t]
  ;; *very* loose definition...
  (match? {: thread} t))

(fn M.await [...]
  (coroutine.yield (E.pack ...)))

(fn M.log [task msg ...]
  ;; We may be awaiting on sub task and logs from those tasks *should* be
  ;; able to end up at the same handler as the originating task. This is
  ;; simplest done by passing a task `log` function to sub-task runs.
  ;;
  ;; However, we will be suspended when those sub tasks are running and
  ;; we wont be able to yield anything, instead we'll queue the messages
  ;; into the task and rely on the scheduler to pull them off and
  ;; dispatch them.
  ;;
  ;; The other option, passing the dispatcher directly into the task
  ;; would work but too tightly binds the task function to the caller,
  ;; where as I think it makes more sense that a task exists alone and
  ;; when run, resolve/reject/message handlers are attached in that context.
  (let [msg (fmt msg ...)]
    (if (coroutine.running)
      (coroutine.yield msg)
      (table.insert task.sub-task-messages msg))))

(fn* M.run
  "Run given task on the default scheduler, optionally table with :resolved
  :rejected and :message callbacks."
  (where [f] (function? f))
  (-> f (M.new) (M.run))
  (where [f opts] (and (function? f) (table? opts)))
  (-> f (M.new) (M.run opts))
  (where [task] (M.task? task))
  (M.run task {})
  (where [task opts] (and (M.task? task) (table? opts)))
  (let [{: queue-task : default-scheduler} (require :pact.task.scheduler)]
    (queue-task default-scheduler
                task
                (?. opts :resolved)
                (?. opts :rejected)
                (?. opts :message))
    task))

(fn* M.new
  (where [f] (function? f))
  (M.new :anonymous f)
  (where [id f] (and (function? f) (string? id)))
  (let [t {:id (gen-id (.. id :-task))
           :thread nil
           :sub-task-messages []
           :events []
           :timer nil
           :awaiting nil}
        _ (set t.thread (coroutine.create
                          (fn [...]
                            (set t.value (f ...))
                            t.value)))]
    t))

M
