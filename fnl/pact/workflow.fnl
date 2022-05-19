;;; Workflows

;; A workflow is a sequence of tasks, ran in order, then returning a result.
;; Workflow tasks are run inside a coroutine, which allows tasks with asyncronous
;; behaviour to act syncronously. Workflows expect to be ran by a scheduler, which
;; should call (run workflow).

(import-macros {: raise : expect : error->string} :pact.error)
(import-macros {: defstruct} :pact.struct)

(local uv vim.loop)
(local {: inspect : fmt} (require :pact.common))
(local co (require :pact.coroutine))

(local const {:state {;; created but scheduler has not prepared
                      :CREATED :pact.workflow.state.CREATED
                      ;; ready to coroutine.resume
                      :READY :pact.workflow.state.READY
                      ;; resumed
                      :RUNNING :pact.workflow.state.RUNNING
                      ;; has future pending
                      :WAITING :pact.workflow.state.WAITING
                      ;; no more work
                      :FINISHED :pact.workflow.state.FINISHED
                      ;; something broke
                      :ERROR :pact.workflow.state.ERROR}
              :reply {:CONT :pact.workflow.reply.cont
                      :HALT :pact.workflow.reply.halt}})

(fn start-timer [workflow]
  (tset workflow :timer (uv.now)))

(fn stop-timer [workflow]
  (tset workflow :timer (- (uv.now) workflow.timer)))

(fn store-event [workflow event]
  (table.insert workflow.events event))

(fn has-future? [workflow]
  (not (= nil workflow.future)))

(fn future-dead? [workflow]
  (= :dead (coroutine.status workflow.future)))

(fn error->event [err]
  {:is-a :event :type :error :message (error->string err)})

(fn is-a-event? [given]
  ;; TODO could be extended and common'd
  (match given
    {:is-a :event} true
    _ false))

(fn CREATED->READY [workflow thread notify]
  (expect (= workflow.state const.state.CREATED) internal
          "workflow could not transition created->ready")
  (doto workflow
    (store-event {:is-a :event :type :message :message "waiting to start"})
    (tset :state const.state.READY)))

(fn WAITING->READY [workflow]
  (expect (= workflow.state const.state.WAITING) internal
          "workflow could not transition waiting->ready")
  (doto workflow
    (tset :future nil)
    (tset :state const.state.READY)))

(fn READY->RUNNING [workflow]
  (expect (= workflow.state const.state.READY) internal
          "workflow could not transition ready->running")
  (tset workflow :state const.state.RUNNING))

(fn RUNNING->READY [workflow ?event]
  (expect (= workflow.state const.state.RUNNING) internal
          "workflow could not transition running->ready")
  (when ?event
    (store-event workflow ?event))
  (tset workflow :state const.state.READY))

(fn RUNNING->WAITING [workflow future]
  (expect (= workflow.state const.state.RUNNING) internal
          "workflow could not transition running->waiting")
  (doto workflow
    (tset :future future)
    (tset :state const.state.WAITING)))

(fn RUNNING->FINISHED [workflow result]
  (expect (= workflow.state const.state.RUNNING) internal
          "workflow could not transition running->finished")
  (doto workflow
    (stop-timer)
    ;; save one value returns directly, save multi values as a list
    (tset :result (match (select "#" (unpack result))
                    1 (unpack result)
                    _ result))
    (store-event {:is-a :event :type :complete :message :complete})
    (tset :state const.state.FINISHED)))

(fn RUNNING->ERROR [workflow err]
  (expect (= workflow.state const.state.RUNNING) internal
          "workflow could not transition running->error")
  (doto workflow
    (store-event (error->event err))
    (tset :error err)
    (tset :state const.state.ERROR)))

(fn resume [workflow]
  (READY->RUNNING workflow)
  (match [(co.>> workflow.thread)]
    ;; A workflow function may yield the following values:
    ;; [false error] <- not technically yielded, thrown by any internal errors
    ;; [true thread] <- workflow is waiting on another coroutine
    ;; [true :cont info...] <- infomation message (we pass this up)
    ;; [true :halt value...] <- inform scheduler to unschedule us, value is stored
    ;;                          as workflow result.
    ;; We return the following values:
    ;; [:cont value] <- keep us scheduled
    ;; [:halt value] <- unschedule us, we no longer want to progress
    [false err]
    (do
      (RUNNING->ERROR workflow err)
      (values nil err))
    ;; "Awaited" portions of a workflow should yield the future/thread.
    ;; We instruct the scheduler to return to us later.
    (where [true future] (= (type future) :thread))
    (do
      (RUNNING->WAITING workflow future)
      (values const.reply.CONT future))
    (where [true const.reply.CONT event] (is-a-event? event))
    (do
      (RUNNING->READY workflow event)
      (values const.reply.CONT event))
    [true const.reply.CONT]
    (do
      (RUNNING->READY workflow)
      (values const.reply.CONT))
    [true const.reply.HALT & value]
    (do
      (RUNNING->FINISHED workflow value)
      (values const.reply.HALT workflow.result))))

(fn run [workflow]
  (match (type workflow.thread)
    :thread (match (coroutine.status workflow.thread)
              :dead (values nil "attempted to run workflow with dead coroutine")
              _ (do
                  (when (= -1 workflow.timer)
                    (start-timer workflow))
                  (when (and (has-future? workflow) (future-dead? workflow))
                    (WAITING->READY workflow))
                  (match (has-future? workflow)
                    true (values const.reply.CONT)
                    false (resume workflow))))
    any (values nil (fmt "attempted to run workflow with non-coroutine (%s)"
                         any))))

(fn event [message ?tag ?context]
  "Yield continuation with event table. Workflows should call this to demark
  steps or stages that should be communicated to the user"
  (expect (not (= nil message)) argument
          "workflow.event must be given message (with optional tag & context)")
  (co.<< const.reply.CONT {:is-a :event
                           :type :message
                           : message
                           :tag ?tag
                           :context ?context}))

(fn result [value]
  "Yield halt with value. Workflows should call this to end execution and retain the result"
  (expect (not (= nil value)) argument
          "workflow.result must be given at least one non-nil argument")
  (co.<< const.reply.HALT value))

(fn halt [...]
  ;; TODO deprecated, result is a nicer API?
  ;; TODO: or not? result often obscures ... the result var
  (result ...))

(fn new [id work-fn]
  ((defstruct pact/workflow
    [id thread future result error events state timer]
    :mutable [future result error state timer]
    :describe-by [id state result error])
   :id id
   :thread (coroutine.create work-fn)
   :future nil
   :result nil
   :error nil
   :events []
   :state const.state.READY
   :timer -1))

{: new : run : halt : event : result : const}
