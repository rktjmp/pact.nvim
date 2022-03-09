(import-macros {: raise : expect} :pact.error)
(import-macros {: struct} :pact.struct)
(import-macros {: actor} :pact.actor)

(local uv vim.loop)
(local is-a-type :pact.runtime)
(local states (struct pact/runtime/states
                      (attr READY :pact.runtime.state.READY)
                      (attr STATUS :pact.runtime.state.STATUS)
                      (attr SNAPSHOT :pact.runtime.state.SNAPSHOT)
                      (attr SYNC :pact.runtime.state.SYNC)))

(local {: fmt : inspect : pathify} (require :pact.common))
(local {: subscribe : unsubscribe : send : broadcast} (require :pact.pubsub))

;; The Pact runtime manages transitions between activities and some glue
;; components. Most of the actual work (view, workflow creation, etc) is done
;; in each separate activity.
;;
;; The runtime also maintains the plugin table.

;;; Plugin and Plugin Accessories

(fn get-plugin-group [runtime group-name]
  "Get defined group from runtime"
  (. runtime :groups group-name))

(fn define-plugin-group [runtime group-name ...]
  "Collect given providers (under ...) under a group name"
  (expect (= :string (type group-name))
          argument "must provide group name")
  (expect (= nil (get-plugin-group runtime group-name))
          argument (fmt "%s group already defined" group-name))
  (let [duplcate-check {}
        plugins (icollect [_ plugin (ipairs [...])]
                          (do
                            ;; TODO type check this is an valid provider
                            (expect (= nil (. duplcate-check plugin.id))
                                    argument (fmt "%s group has duplicate plugin %s"
                                                  group-name plugin.id))
                            (tset duplcate-check plugin.id true)
                            (values plugin)))
        package-root runtime.config.package-root
        group (struct plugin-group
                      (attr path (pathify package-root group-name :start) show)
                      (attr name group-name show)
                      (attr plugins plugins show))]
    (tset runtime.groups group-name group)))

;;; UI control

(fn READY->STATUS [runtime group-name]
  (expect (= runtime.state states.READY) internal
          "Could not transition runtime %s->%s, in %s" states.READY
          states.STATUS runtime.state)
  (let [{: new} (require :pact.activity.status)
        group (get-plugin-group runtime group-name)
        _ (expect (not (= nil group))
                  argument (fmt "could not status group %q, not found" group-name))
        activity (new runtime group)]
    (doto runtime
      (tset :active-activity activity)
      (subscribe activity activity)
      (tset :state states.STATUS))))

(fn STATUS->SNAPSHOT [runtime group-name actions]
  (expect (= runtime.state states.STATUS) internal
          "Could not transition runtime %s->%s, in %s" states.STATUS
          states.SNAPSHOT runtime.state)
  (let [{: new} (require :pact.activity.snapshot)
        activity (new runtime group-name actions)]
    (doto runtime
      (tset :active-activity activity)
      (subscribe activity activity)
      (tset :state states.SNAPSHOT))))

(fn SNAPSHOT->SYNC [runtime group-name actions]
  (expect (= runtime.state states.SNAPSHOT) internal
          "Could not transition runtime %s->%s, in %s" states.SNAPSHOT
          states.SYNC runtime.state)
  (let [{: new} (require :pact.activity.sync)
        activity (new runtime group-name actions)]
    (doto runtime
      (tset :active-activity activity)
      (subscribe activity activity)
      (tset :state states.SYNC))))

(fn *->READY [runtime]
  (doto runtime
    (tset :active-activity nil)
    (tset :state states.READY)))


;;; Message responder

(fn receive [runtime ...]
  (match [runtime.state [...]]
    ;; user ViM cOmMaNdS
    [states.READY [:command :status group-name]]
    (READY->STATUS runtime group-name)
    ;; commit status, collect actions and transition to snapshot
    [states.STATUS [activity _ :commit & args]]
    (let [[group-name actions] args
          ;; status will return all actions but we will elect to only 
          ;; pass on any sync actions.
          actions (icollect [_ [tag result] (ipairs actions)]
                    (match result
                      ;; strip result down to useful data
                      {:action :sync}
                      (struct pact/action
                              (attr plugin result.plugin show)
                              (attr method tag show)
                              ;; TODO naming this action means you do a lot of
                              ;; action.action destructuring, so better name?
                              (attr action :sync show)
                              (attr args result.actions.sync show)
                              ;; TODO: this is used with :sync to work out if we
                              ;; want to clone or update. Would be better to have
                              ;; unique actions but they should apply to git and path,
                              ;; so :sync, :create?
                              (attr current-checkout result.current-checkout show))
                      _
                      nil))]
      (unsubscribe runtime activity)
      (STATUS->SNAPSHOT runtime group-name actions)
      )
    [states.SNAPSHOT [activity _ :commit & args]]
    (let [[group-name actions] args]
      (unsubscribe runtime activity)
      (SNAPSHOT->SYNC runtime group-name actions))
    ;; any state may quit, for now
    [_ [activity _ :quit & args]]
    (do
      (unsubscribe runtime activity)
      (*->READY runtime))))

;;; ... New

(fn new [config]
  (actor pact/runtime
         (attr groups [] show)
         (attr scheduler (let [{: new} (require :pact.workflow.scheduler)]
                           (new config)))
         (attr config config)
         (attr active-activity nil mutable)
         (attr state states.READY mutable show) (receive receive)))

{: new : define-plugin-group : plugin-group-dir : get-plugin-group}
