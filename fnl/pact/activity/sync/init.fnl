(import-macros {: raise : expect} :pact.error)
(import-macros {: struct} :pact.struct)
(import-macros {: actor} :pact.actor)

(local {: fmt : inspect : pathify} (require :pact.common))
(local {: subscribe : broadcast : unsubscribe : send} (require :pact.pubsub))
(local uv vim.loop)

(fn maybe-stop-timer [state]
  (let [{: workflows : timer} state]
    (when (accumulate [done true _ [workflow _] (ipairs workflows)]
            (and done (or workflow.result workflow.error)))
      (uv.timer_stop timer))))

(fn start-timer [state]
  (let [started-at (uv.now)]
    (uv.timer_start state.timer 0 16
                    #(do
                       (tset state :elapsed (- (uv.now) started-at))
                       (send state.view :redraw state)))))

(fn update-workflow-state [state target-wf tag data]
  (each [i [workflow _tag [action _data]] (ipairs state.results)]
    (if (= workflow target-wf)
        (tset state.results i [workflow tag [action data]]))))

(fn receive-message [state ...]
  (local {: runtime : view} state)
  (match [...]
    ;; scheduler handlers
    [runtime.scheduler workflow :info event]
    (do
      (update-workflow-state state workflow :incomplete event.message)
      (maybe-stop-timer state)
      (send view :redraw state))
    [runtime.scheduler workflow :error err]
    (do
      (update-workflow-state state workflow :error err)
      (maybe-stop-timer state)
      (send view :redraw state))
    [runtime.scheduler workflow :complete result]
    (do
      (update-workflow-state state workflow :complete result)
      (maybe-stop-timer state)
      (send view :redraw state))
    ;; input handlers
    [:quit]
    (do
      ;; TODO kill any running workflows
      (unsubscribe state)
      (send view :close)
      (broadcast state state :quit))
    any
    (inspect :status-activity-unmatched-event
             (let [{: view} (require :fennel)]
               (view any)))))

(fn new [runtime group actions]
  ;; ensure we have all files compiled (see file)
  (require :pact.vim.hotpot)
  (let [{: plugin-group-dir} (require :pact.runtime)
        workflows (let [{: new} (require :pact.activity.sync.workflow)]
                    (icollect [_ action (ipairs actions)]
                              [(new group.path action) action]))
        activity (actor pact/activity/status
                        ;; HACK for responder subscriptions
                        (attr runtime runtime)
                        (attr group-name group.name)
                        (attr plugins group.plugins)
                        (attr workflows workflows)
                        (attr view nil mutable)
                        (attr results
                              (icollect [i [workflow action] (ipairs workflows)]
                                        [workflow
                                         :incomplete
                                         [action :working]]))
                        (attr elapsed 0 mutable)
                        (attr timer (uv.new_timer))
                        (receive receive-message))
        view (let [{: new} (require :pact.activity.sync.view)]
               view (new {:on-close [activity :quit]
                          :keymap {:normal {:gq [activity :quit]}}}))]
    (tset activity :view view)
    (start-timer activity)
    ;; sub to all workflow events
    (let [{: add-workflow} (require :pact.workflow.scheduler)]
      (each [_ [workflow _] (ipairs activity.workflows)]
        (subscribe activity runtime.scheduler workflow)
        (add-workflow runtime.scheduler workflow)))
    (values activity)))

{: new}
