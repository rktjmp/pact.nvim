;;; Workflows

;; A workflow is a sequence of tasks, ran in order, then returning a result.
;; Workflow tasks are run inside a coroutine, which allows tasks with asyncronous
;; behaviour to act syncronously. Workflows expect to be ran by a scheduler, which
;; should call (run workflow).

(import-macros {: use} :pact.lib.ruin.use)
(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     result :pact.lib.ruin.result
     {: string? : table? : thread? : function?} :pact.lib.ruin.type
     enum :pact.lib.ruin.enum
     {:format fmt} string
     {:loop uv} vim)

(macro enforce-transition [wf be]
  `(assert (= (. ,wf :state) ,be)
           (string.format "workflow could not transition from %s -> %s"
                          (. ,wf :state) ,be)))

(macro match? [pattern expr]
  `(match ,expr
     ,pattern true
     _# false))

(local co (require :pact.coroutine))

(local const {:state {;; created but scheduler has not prepared
                      :CREATED :pact.workflow.state.CREATED
                      ;; ready to coroutine.resume
                      :READY :pact.workflow.state.READY
                      ;; has future pending
                      :WAITING :pact.workflow.state.WAITING
                      ;; executing in-lua code
                      :RUNNING :pact.workflow.state.RUNNING
                      ;; no more work
                      :FINISHED :pact.workflow.state.FINISHED
                      ;; something broke
                      :ERROR :pact.workflow.state.ERROR}
              :reply {;; reply with message and await continuation
                      :CONT :pact.workflow.reply.cont
                      ;; reply with message and remove from scheduler
                      :HALT :pact.workflow.reply.halt}})

(fn start-timer [workflow]
  (enum.set$ workflow :timer (uv.now)))

(fn stop-timer [workflow]
  (enum.set$ workflow :timer (- (uv.now) workflow.timer)))

(fn store-event [workflow event]
  (table.insert workflow.events event))

(fn has-future? [workflow]
  (not (= nil workflow.future)))

(fn future-dead? [workflow]
  (= :dead (coroutine.status workflow.future)))

(fn CREATED->READY [workflow thread notify]
  (enforce-transition workflow const.state.CREATED)
  (doto workflow
    (start-timer)
    (store-event [:message "waiting to start"])
    (tset :state const.state.READY)))

(fn WAITING->READY [workflow]
  (enforce-transition workflow const.state.WAITING)
  (doto workflow
    (tset :future nil)
    (tset :state const.state.READY)))

(fn READY->RUNNING [workflow msg]
  (enforce-transition workflow const.state.READY)
  (tset workflow :state const.state.RUNNING))

(fn RUNNING->READY [workflow ?event]
  (enforce-transition workflow const.state.RUNNING)
  (when ?event
    (store-event workflow ?event))
  (tset workflow :state const.state.READY))

(fn RUNNING->WAITING [workflow future]
  (enforce-transition workflow const.state.RUNNING)
  (doto workflow
    (store-event [:waiting])
    (tset :future future)
    (tset :state const.state.WAITING)))

(fn RUNNING->FINISHED [workflow ok]
  (enforce-transition workflow const.state.RUNNING)
  (doto workflow
    (stop-timer)
    (store-event [:result ok])
    (tset :result ok)
    (tset :state const.state.FINISHED)))

(fn RUNNING->ERROR [workflow err]
  (enforce-transition workflow const.state.RUNNING)
  (doto workflow
    (stop-timer)
    (store-event [:result err])
    (tset :result err)
    (tset :state const.state.ERROR)))

(fn resume [workflow]
  "Called by the scheduler, workflow should yield or return a value"
  (READY->RUNNING workflow)
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
      (RUNNING->READY workflow msg)
      (values const.reply.CONT msg))

    ;; "Awaited" portions of a workflow should yield the future/thread.
    ;; We instruct the scheduler to return to us later.
    (where [true future] (thread? future))
    (do
      (RUNNING->WAITING workflow future)
      (values const.reply.CONT future))

    ;; result.ok signals that the workflow has terminated
    (where [true ok] (result.ok? ok))
    (do
      (RUNNING->FINISHED workflow ok)
      (values const.reply.HALT ok))

    ;; result.err signals we had a detected error, probably disk in poor state
    ;; or remote not responding, etc.
    (where [true err] (result.err? err))
    (do
      (RUNNING->ERROR workflow err)
      (values const.reply.HALT err))

    ;; This is an actual *crash* inside the coroutine, so we're matching on
    ;; pcall return.
    [false err]
    (let [err (result.err err)]
      (RUNNING->ERROR workflow err)
      (values const.reply.HALT err))

    ;; Shouldn't get here ...
    any (error any)))

(fn run [workflow]
  ;; not started ever, so start it
  (when (= const.state.CREATED workflow.state)
    (CREATED->READY workflow))
  ;; have a future but its finished, so we are ready to continue
  (when (and (has-future? workflow) (future-dead? workflow))
    (enforce-transition workflow const.state.WAITING)
    (doto workflow
      (tset :future nil)
      (tset :state const.state.READY)))
  ;; 
  (if (has-future? workflow)
    (values const.reply.CONT)
    (resume workflow))




(fn* run
  (where [workflow] (not (thread? workflow.thread)))
  false
  (where [workflow] (= ^const.state.CREATED workflow.state))
  (doto workflow
    (CREATED->READY)
    (resume))
  (where [workflow] (= ^const.state.WAITING workflow.state))
  (do
    (when (and (has-future? workflow) (future-dead? workflow))
      (WAITING->READY workflow))
    (if (= workflow.state const.state.READY)
      (values const.reply.CONT)
      (resume workflow))))

; (fn run [workflow]
;   (match (type workflow.thread)
;     :thread (match (coroutine.status workflow.thread)
;               :dead (values nil "attempted to run workflow with dead coroutine")
;               _ (do
;                   (when (= -1 workflow.timer)
;                     (start-timer workflow))
;                   (when (and (has-future? workflow) (future-dead? workflow))
;                     (WAITING->READY workflow))
;                   (match (has-future? workflow)
;                     true (values const.reply.CONT)
;                     false (resume workflow))))
;     any (values nil (fmt "attempted to run workflow with non-coroutine (%s)"
;                          any))))

(fn* new
  (where [id f] (and (string? id) (function? f)))
  {:id id
   :thread (coroutine.create f)
   :events []
   :state const.state.CREATED
   :timer -1
   :future nil})

{: new : run}
