;;; Workflows

;; A workflow is a sequence of tasks, ran in order, then returning a result.
;; Workflow tasks are run inside a coroutine, which allows tasks with asyncronous
;; behaviour to act syncronously. Workflows expect to be ran by a scheduler, which
;; should call (run workflow).

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use result :pact.lib.ruin.result
     {: string? : thread?} :pact.lib.ruin.type
     E :pact.lib.ruin.enum
     R :pact.lib.ruin.result
     {:format fmt} string
     {:loop uv} vim)

(fn start-timer [workflow]
  (E.set$ workflow :timer (uv.now)))

(fn stop-timer [workflow]
  (E.set$ workflow :timer (- (uv.now) workflow.timer)))

(fn resume [workflow]
  "Called by the scheduler, workflow should yield or return a value"
  (match [(coroutine.resume workflow.thread)]
    ;; A workflow function may yield the following values:
    ;; [false error] <- not technically yielded, thrown by any internal errors
    ;; [true thread] <- workflow is waiting on another coroutine
    ;; [true :cont info...] <- infomation message (we pass this up)
    ;; [true :halt value...] <- inform scheduler to unschedule us, value is stored
    ;;                          as workflow result.
    ;; We return the following values:
    ;; [:cont value] <- keep us scheduled
    ;; [:halt value] <- unschedule us, we no longer want to progress

    ;; Coroutines can yield a string up to pass information messages to the
    ;; scheduler. These should always request contiunation.
    (where [true msg] (string? msg))
    (do
      (table.insert workflow.events [:message msg])
      (values :cont msg))

    ;; "Awaited" portions of a workflow should yield the future/thread.
    ;; We instruct the scheduler to return to us later.
    (where [true future] (thread? future))
    (do
      (table.insert workflow.events [:suspended])
      (tset workflow :future future)
      (values :cont future))

    ;; result.ok signals that the workflow has terminated
    (where [true ok] (result.ok? ok))
    (do
      (stop-timer workflow)
      (tset workflow :result ok)
      (table.insert workflow.events [:result ok])
      (values :halt ok))

    ;; result.err signals we had a detected error, probably disk in poor state
    ;; or remote not responding, etc.
    (where [true err] (result.err? err))
    (do
      (stop-timer workflow)
      (tset workflow :result err)
      (table.insert workflow.events [:result err])
      (values :halt err))

    ;; This is an actual *crash* inside the coroutine, so we're matching on
    ;; pcall return.
    [false err]
    (let [err (result.err err)]
      (stop-timer workflow)
      (tset workflow :result err)
      (values :halt err))

    ;; Shouldn't get here ... perhaps the workflow forgot to wrap the return
    ;; value.
    any (let [data (vim.inspect [workflow any] {:newline "" :indent ""})
              msg "OOPS! A workflow returned an unexpected value! Please report this error!"
              err (string.format "%s %s" msg data)]
          (vim.schedule #(vim.api.nvim_err_writeln err))
          (values :halt err))))

(fn run [workflow]
  (match workflow
    ;; Never run before
    (where workflow (= nil workflow.timer))
    (do
      (start-timer workflow)
      (resume workflow))
    ;; workflow is paused by future, so just return to scheduler for continuation later
    (where {: future} (not= :dead (coroutine.status future)))
    (values :cont future)
    ;; has future but the future finished, clear future and resume.
    (where {: future} (= :dead (coroutine.status workflow.future)))
    (do
      (tset workflow :future nil)
      (resume workflow))
    ;; otherwise just resume the workflow
    (where workflow)
    (resume workflow)))

(var id 0)
(fn gen-id []
  (set id (+ id 1))
  id)

(fn new [id f]
  (var handlers [])
  (var detach-current false)

  (fn* attach-handler
    "Attach handler to workflow which must provide an on-ok and on-err
    function, and an optional on-msg function. Handlers are run in order of
    attachment and may detatch by calling `detatch-handler` while running."
    (where [wf on-ok on-err] (and (function? on-ok) (function? on-err)))
    (attach-handler wf on-ok on-err #nil)
    (where [wf on-ok on-err on-msg] (and (function? on-ok) (function? on-err) (function? on-msg)))
    (let [a-handler {: on-ok : on-err : on-msg}]
      (table.insert handlers a-handler)
      wf))

  {:id (.. "workflow-" (gen-id) "-" id)
   :thread (coroutine.create f)
   :events []
   :timer nil
   :future nil
   :attach-handler attach-handler
   :detach-handler #(set detach-current true)
   :handle (fn [wf event]
             (set handlers
                  (E.map (fn [_ handler]
                           (let [{: on-ok : on-err : on-msg} handler]
                             (match event
                               ;; Note: we elect to *not* unwrap the result
                               ;; type as this ensures the reciever handler
                               ;; always gets *all* results by unpacking,
                               ;; otherwise its easy to miss some and saves
                               ;; packing/unpacking ... all the time.
                               ;; We often want to re-wrap errors into the
                               ;; event stack *anyway*.
                               (where ok (R.ok? ok))
                               (on-ok ok)
                               (where err (R.err? err))
                               (on-err err)
                               (where msg (string? msg))
                               (on-msg msg))
                             (if (not detach-current)
                               handler)))
                         handlers))
             wf)})

(fn log [x ...]
  (if (string? x)
    (coroutine.yield (string.format x ...))
    (error "workflow#log requires format string")))

{: new
 : run
 :yield coroutine.yield
 :log log}
