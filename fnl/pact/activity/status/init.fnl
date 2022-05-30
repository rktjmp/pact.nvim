(import-macros {: use : do-use} :pact.vendor.donut)
(import-macros {: raise : expect} :pact.error)

(use {: fmt : inspect : pathify} :pact.common
     {: subscribe : broadcast : unsubscribe : send} :pact.pubsub
     {: 'defactor} :pact.actor
     {: 'typeof : 'defstruct} :pact.struct
     {:loop uv} vim)

(local actor-type (defactor pact/activity/status
                    [runtime group-name plugins workflows view results elapsed timer]
                    :mutable [view elapsed]))

(local path-actions ((defstruct pact/activity/status/path-actions
                       [HOLD LINK])
                     :HOLD :pact.activity.status.path-actions.HOLD
                     :LINK :path.activity.status.path-actions.LINK))

(local git-actions ((defstruct path/activity/status/git-actions
                      [HOLD UPDATE CLONE])
                    :HOLD :pact.activity.status.git-actions.HOLD
                    :UPDATE :pact.activity.status.git-actions.UPDATE
                    :CLONE :pact.activity.status.git-actions.CLONE))

(fn stop-timer-when-all-finished [state]
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
  (each [i [workflow _tag plugin action _data] (ipairs state.results)]
    (when (= workflow target-wf)
        (tset state.results i [workflow tag plugin action data]))))

(fn receive-message [activity ...]
  (local {: runtime : view} activity)
  (match [...]
    ;; scheduler handlers
    [runtime.scheduler workflow :info event]
    (do
      (update-workflow-state activity workflow :incomplete event.message)
      (stop-timer-when-all-finished activity)
      (send view :redraw activity))
    [runtime.scheduler workflow :error err]
    (do
      (update-workflow-state activity workflow :error err.reason)
      (stop-timer-when-all-finished activity)
      (send view :redraw activity))
    [runtime.scheduler workflow :complete result]
    (do
      (print result)
      (update-workflow-state activity workflow :complete result)
      (stop-timer-when-all-finished activity)
      (send view :redraw activity))
    ;; input handlers, messages sent directly from the view
    ;; Try to update or create, etc
    [:sync]
    (let [workflow (send view :workflow-at-cursor activity)]
      (set-workflow-action activity workflow :sync)
      (send view :redraw activity))
    ;; Do nothing
    [:hold]
    (let [workflow (send view :workflow-at-cursor activity)]
      (set-workflow-action activity workflow :hold)
      (send view :redraw activity))
    ;; Confirm changes
    [:commit]
    (let [actions (icollect [_ [_ tag [_ data]] (ipairs activity.results)]
                    (when (= :complete tag)
                      data))]
      ;; TODO kill any running workflows & timers
      (unsubscribe activity true)
      (send view :close)
      (broadcast activity activity :commit activity.group-name actions))
    ;; cancel and exit
    [:quit]
    (do
      ;; TODO kill any running workflows & timers
      (unsubscribe activity true)
      (send view :close)
      (broadcast activity activity :quit))
    any
    (inspect :status-activity-unmatched-event
             (let [{: view} (require :fennel)]
               (view any)))))

(fn new [runtime group]
  ;; Get all plugins in given group, check each plugin against disk to check
  ;; git-sync status or link status.
  ;; Allows user to pick desired action against each plugin (sync, hold, etc)
  ;; where appropriate.
  ;; Passes list of actions to SNAPSHOT.
  (use {: fwd } :pact.vendor.donut.gen
       {: type} :pact.provider.path :as path
       {: type} :pact.provider.git :as git)
  ;; ensure we have all files compiled (see file)
  (require :pact.vim.hotpot)
  (let [{:new pact-view} (require :pact.activity.view)
        {: receive} (require :pact.activity.status.view)
        group-dir group.path
        ;; Create a status workflow for each plugin. We use a list instead of a
        ;; map because we want to show the report in the same order we're
        ;; given.
        workflows (do-use [{: new} :pact.activity.status.git-workflow :as git
                           {: new} :pact.activity.status.path-workflow :as path]
                    (let [type->f {path/type path/new git/type git/new}]
                      (icollect [plugin (fwd group.plugins)]
                        (match (. type->f (typeof plugin))
                          f [(f group-dir plugin) plugin]
                          nil (error (fmt "unknown plugin type %s" (typeof plugin)))))))
        activity (actor-type
                   ;; attach runtime so we can match on it to be sure we're getting
                   ;; messages from the correct scheduler. this can probably be done cleaner.
                   :runtime runtime
                   :group-name group.name
                   :plugins group.plugins
                   :workflows workflows
                   ;; need to set view after actor creation for input target
                   :view nil
                   :results (icollect [i [workflow plugin] (ipairs workflows)]
                              (match (typeof plugin)
                                path/type [workflow :incomplete plugin path-actions.HOLD "awaiting scheduler"]
                                git/type [workflow :incomplete plugin git-actions.HOLD "awaiting scheduler"]))
                   :elapsed 0
                   :timer (uv.new_timer)
                   :receive receive-message)
        view (pact-view receive
                        {:on-close [activity :quit]
                         :keymap {:normal {:gs [activity :sync]
                                           :gh [activity :hold]
                                           :gq [activity :quit]
                                           :gc [activity :commit]}}})]
    (doto activity
          (tset :view view)
          (start-timer)
          (subscribe runtime.scheduler))
    (let [{: add-workflow} (require :pact.workflow.scheduler)]
      (each [_ [workflow plugin] (ipairs activity.workflows)]
        (add-workflow runtime.scheduler workflow)))
    (values activity)))

{: new : path-actions : git-actions}
