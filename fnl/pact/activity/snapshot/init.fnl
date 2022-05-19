(import-macros {: raise : expect} :pact.error)
(import-macros {: struct} :pact.struct)
(import-macros {: defactor} :pact.actor)

(local {: fmt : inspect : pathify} (require :pact.common))
(local {: subscribe : broadcast : unsubscribe : send} (require :pact.pubsub))
(local uv vim.loop)

(fn receive-message [activity ...]
  (local {: runtime : view} activity)
  (match [...]
    ;; commit actions, write file to cache dir and move to performing the
    ;; actions
    [:commit]
    (let [{: cache-dir : group-name : view} activity
          target-dir (pathify cache-dir group-name)
          _ (vim.fn.mkdir target-dir :p)
          timestamp (vim.fn.strftime "%Y%m%d%H%M%S")
          file-path (pathify target-dir timestamp)
          lines (send view :lines)]
      (with-open [fout (io.open file-path :w)]
                 (each [_ line (ipairs lines)]
                   (fout:write (.. line "\n"))))
      (unsubscribe activity true)
      (send view :close)
      (broadcast activity activity :commit activity.group-name activity.actions))
    ;; quit, dont do anything
    [:quit]
    (do
      (unsubscribe activity true)
      (send view :close)
      (broadcast activity activity :quit))
    any
    (inspect :status-activity-unmatched-event
             (let [{: view} (require :fennel)]
               (view any)))))

(local actor-type (defactor pact/activity/snapshot
               [runtime group-name cache-dir actions snapshot-message workflows view]
               :mutable [snapshot-message view]))

(fn new [runtime group actions]
  ;; ensure we have all files compiled (see file)
  (require :pact.vim.hotpot)
  (let [{:new pact-view} (require :pact.activity.view)
        {: receive} (require :pact.activity.snapshot.view)
        ;; default the snapshot message to a timestamp and group name
        default-message (fmt "%s %s" (vim.fn.strftime "%Y-%m-%d %H:%M:%S") group.name)
        activity (actor-type :runtime runtime
                             :group-name group.name
                             :cache-dir (pathify (vim.fn.stdpath :cache) :pact)
                             :actions actions
                             :snapshot-message default-message
                             :workflows workflows
                             :view nil
                             :receive receive-message)
        view (pact-view receive
                        {:on-close [activity :quit]
                         :keymap {:normal {:gq [activity :quit]
                                           :gc [activity :commit]}}})]
    (print activity view)
    (tset activity :view view)
    (send activity.view :redraw activity)
    (values activity)))

{: new}
