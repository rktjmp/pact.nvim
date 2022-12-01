(import-macros {: use} :pact.lib.ruin.use)
(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     result :pact.lib.ruin.result
     {: string? : thread?} :pact.lib.ruin.type
     enum :pact.lib.ruin.enum
     {:format fmt} string
     {:loop uv} vim)

(import-macros {: raise : expect} :pact.error)
(import-macros {: defstruct} :pact.struct)

(local uv vim.loop)
(local {: inspect} (require :pact.common))
(local {: broadcast} (require :pact2.pubsub))

(fn make-idle-loop [scheduler]
  (fn []
    ;; can we add an additional task to the active list?
    (while (and (< (length scheduler.active) scheduler.concurrency-limit)
                (< 0 (length scheduler.queue)))
      ;; activate workflow
      (let [workflow (table.remove scheduler.queue 1)]
        (table.insert scheduler.active 1 workflow)))
    ;; tick every active workflow
    (let [{: run} (require :pact2.workflow)
          {: ok? : err?} (require :pact.lib.ruin.result)
          ;; pair the workflows with the run results so we can drop halted and
          ;; retain continued wfs in the active list.
          {:halt halted :cont continued} (enum.group-by
                                           #(match (run $2)
                                              (action value) (values action [$2 value])
                                              _ (error "workflow.run did not return 2 values"))
                                           scheduler.active)
          ;; collect anything that wants to be scheduled again, and update the
          ;; currently active list. Do this before dispatching any messaages so
          ;; any error in that occurs in dispatching doesn't leave zombie workflows.
          _ (tset scheduler :active (enum.map (fn [_ [wf _result]] wf) (or continued [])))
          ;; dispatch any messages
          ;; TODO broadcast should collate these into one vim.schedule
          _ (enum.map
              #(enum.map (fn [_ [wf result]] (broadcast scheduler wf result)) $2)
              [(or halted []) (or continued [])])]
      ;; stop or nah?
      (when (= 0 (length scheduler.queue) (length scheduler.active))
        (uv.idle_stop scheduler.idle-handle)
        (uv.close scheduler.idle-handle)
        (tset scheduler :idle-handle nil)))))

(fn* new
  (where [])
  (new {})
  (where [{: ?concurrency-limit}])
  {:concurrency-limit (or ?concurrency-limit 2)
   :queue []
   :active []
   :idle-handle nil})

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
  (uv.idle_stop scheduler.idle-handle)
  ;; in-flight workflows may still have open processes, but those processes
  ;; will end, resolve their future, but the scheduler will no longer care
  ;; about the containing thread, so *I think* that wont leak.
  ;; TODO think about memory here when less tired.
  (each [i _ (ipairs scheduler.queue)]
    (tset scheduler.queue i nil))
  (tset scheduler :active nil)
  (uv.close scheduler.idle-handle))

{: new : add-workflow : stop}
