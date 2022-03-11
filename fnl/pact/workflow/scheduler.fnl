(import-macros {: raise : expect} :pact.error)
(import-macros {: struct} :pact.struct)

(local uv vim.loop)
(local {: inspect} (require :pact.common))
(local {: subscribe : broadcast} (require :pact.pubsub))

(fn make-idle-loop [scheduler]
  (fn tick-workflow [workflow]
    ;; Run the workflow and inspect its return value. It may request to be
    ;; de/re-scheduled and may return an event or final value.
    (let [{: run :const {: reply}} (require :pact.workflow)]
      (match [(run workflow)]
        [nil err] [:halt :error err]
        (where [reply.CONT thread] (= (type thread) :thread)) [:cont]
        [reply.CONT event] [:cont :event event]
        [reply.CONT] [:cont]
        [reply.HALT value] [:halt value]
        other (do
                (inspect :tick-workflow :unhandled other)
                ;; temp? TODO
                (raise internal other)
                [:halt]))))

  (fn []
    ;; can we add an additional task to the active list?
    (while (and (< (length scheduler.active) scheduler.concurrency-limit)
                (< 0 (length scheduler.queue)))
      ;; activate workflow
      (let [workflow (table.remove scheduler.queue 1)]
        (table.insert scheduler.active 1 workflow)))
    ;; tick every running workflow
    (let [updates (collect [_ workflow (ipairs scheduler.active)]
                           (values workflow (tick-workflow workflow)))
          ;; collect anything that wants to be scheduled again, and update the
          ;; currently active list. Do this before dispatching any messaages so
          ;; any error in that occurs in dispatching doesn't leave zombie workflows.
          still-active (icollect [workflow [act & rest] (pairs updates)]
                         (when (= :cont act)
                           (values workflow)))
          ;; replace old active with still active list
          _ (tset scheduler :active still-active)
          ;; dispatch any messages
          _ (each [workflow reply (pairs updates)]
              (match reply
                [:cont :event event] (broadcast scheduler workflow :info event)
                [:halt :error err] (broadcast scheduler workflow :error err)
                [:halt val] (broadcast scheduler workflow :complete val)))]
      ;; stop or nah?
      (when (= 0 (length scheduler.queue) (length scheduler.active))
        (uv.idle_stop scheduler.idle-handle)
        (uv.close scheduler.idle-handle)
        (tset scheduler :idle-handle nil)))))

(fn new [opts]
  "Create a new scheduler.
  Options:
  - concurrency-limit: 10"
  (expect (not (= nil opts))
          argument "scheduler requires opts")
  (let [uv vim.loop]
    (struct pact/scheduler
            (attr concurrency-limit opts.concurrency-limit)
            (attr queue [])
            (attr active [] mutable)
            (attr idle-handle nil mutable))))


(fn add-workflow [scheduler workflow]
  "Enqueue a workflow with on-event and on-complete callbacks.
  Starts scheduler loop if it's not currently running"
  (table.insert scheduler.queue workflow)
  (when (= nil scheduler.idle-handle)
    (let [h (uv.new_idle)]
      (tset scheduler :idle-handle h)
      (uv.idle_start h (make-idle-loop scheduler)))))

(fn stop [scheduler]
  "Force halt a scheduler, in-progress workflows may be lost."
  (uv.idle_stop scheduler.idle-handle))
  ;; TODO decide on whether we close/open the idle handle or if we're ok
  ;; holding one open.
  ;; (uv.close scheduler.idle-handle)
  

{: new : schedule-workflows : add-workflow}
