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

(fn set-workflow-action [state target-wf action]
  (each [i [workflow tag data] (ipairs state.results)]
    (if (and (= workflow target-wf) (= tag :complete))
        (let [[plugin [tag result]] data]
          (match [tag result]
            [:git result] (match (. result :actions action)
                            nil (let [opts (icollect [k _ (pairs result.actions)]
                                             k)
                                      warning (fmt "cant %s, only [%s]" action
                                                   (table.concat opts ","))]
                                  (vim.notify warning))
                            any (tset result :action action))
            [tag _] (vim.notify (fmt "cant adjust action for %s" tag)))))))

(fn update-workflow-state [state target-wf tag data]
  (each [i [workflow _tag [plugin _data]] (ipairs state.results)]
    (if (= workflow target-wf)
        (tset state.results i [workflow tag [plugin data]]))))

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
    ;; input handlers, sent directly, no channel+topic
    [:sync]
    (let [workflow (send view :workflow-at-cursor state)]
      (set-workflow-action state workflow :sync)
      (send view :redraw state))
    [:hold]
    (let [workflow (send view :workflow-at-cursor state)]
      (set-workflow-action state workflow :hold)
      (send view :redraw state))
    [:commit]
    (let [actions (icollect [_ [_ tag [_ data]] (ipairs state.results)]
                    (when (= :complete tag)
                      data))]
      ;; TODO kill any running workflows & timers
      (unsubscribe state)
      (send view :close)
      (broadcast state state :commit state.group-name actions))
    [:quit]
    (do
      ;; TODO kill any running workflows & timers
      (unsubscribe state)
      (send view :close)
      (broadcast state state :quit))
    any
    (inspect :status-activity-unmatched-event
             (let [{: view} (require :fennel)]
               (view any)))))

(fn new [runtime group-name]
  ;; Get all plugins in given group, check each plugin against disk to check
  ;; git-sync status or link status.
  ;; Allows user to pick desired action against each plugin (sync, hold, etc)
  ;; where appropriate.
  ;; Passes list of actions to SNAPSHOT.

  ;; ensure we have all files compiled (see file)
  (require :pact.vim.hotpot)
  (let [{: plugin-group-dir} (require :pact.runtime)
        pact (require :pact)
        group (pact.get group-name)
        group-dir (plugin-group-dir runtime group)
        ;; create a status workflow for each plugin
        workflows (let [{: new} (require :pact.activity.status.workflow)]
                    (icollect [_ plugin (ipairs group.plugins)]
                      [(new group-dir plugin) plugin]))
        activity (actor pact/activity/status
                        ;; HACK for responder subscriptions
                        (attr runtime runtime)
                        (attr group-name group.name)
                        (attr plugins group.plugins)
                        (attr workflows workflows)
                        ;; need to set view after actor creation for input target
                        (attr view nil mutable)
                        (attr results
                              (icollect [i [workflow plugin] (ipairs workflows)]
                                        [workflow
                                         :incomplete
                                         [plugin :working]]))
                        (attr elapsed 0 mutable)
                        (attr timer (uv.new_timer))
                        (receive receive-message))
        view (let [{: new} (require :pact.activity.status.view)]
                   view (new {:on-close [activity :quit]
                              :keymap {:normal {:gs [activity :sync]
                                                :gh [activity :hold]
                                                :gq [activity :quit]
                                                :gc [activity :commit]}}}))]
    (tset activity :view view)
    (start-timer activity)
    ;; sub to all workflow events
    (let [{: add-workflow} (require :pact.workflow.scheduler)]
      (each [_ [workflow plugin] (ipairs activity.workflows)]
        (subscribe activity runtime.scheduler workflow)
        (add-workflow runtime.scheduler workflow)))
    (values activity)))

{: new}
