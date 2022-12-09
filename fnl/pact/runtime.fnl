(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     PubSub :pact.pubsub
     Package :pact.package)

(local Runtime {})

(fn Runtime.add-plugin [runtime plugin]
  "Adds plugin from user-spec and returns (ok) or (err reason)"
  ;; TODO duplicate id/source/something flagging
  (match plugin
    (where plugin (R.ok? plugin))
    (let [spec (R.unwrap plugin)
          ;; TODO this *will* collide for git+ssh+http with same endpoint
          canonical-id (-> (. spec.source 2)
                             (string.gsub "%W" "-")
                             (string.gsub "-+" "-"))
          root (FS.join-path runtime.path.repos canonical-id)
          package-name (string.match spec.name ".+/([^/]-)$")
          package-path (FS.join-path runtime.path.root
                                     (if spec.opt? :opt :start)
                                     package-name)
          package {:id canonical-id
                   :canonical-id canonical-id
                   :spec spec
                   :name spec.name
                   ;; we always need at least our own constraint but
                   ;; dependencies may add extras here.
                   :constraints {canonical-id spec.constraints}
                   :path {:root root
                          :package package-path
                          :head (FS.join-path root :HEAD)}
                   :order (E.reduce #(+ $1 1) 1 runtime.packages)
                   :events []
                   :state :waiting
                   :text "waiting for scheduler"}]
      (tset runtime.packages spec.id package)
      (R.ok package))
    (where plugin (R.err? plugin))
    (values plugin)))

(fn Runtime.has-plugins? [runtime]
  ;; TODO
  true)

(fn Runtime.discover-facts [runtime]
  (use DiscoverFacts :pact.workflow.status.discover-facts
       Scheduler :pact.workflow.scheduler)

  (fn make-wf [package]
    (let [wf (DiscoverFacts.new package.id
                                (. package :spec :source 2)
                                package.path.head)
          handler (fn handler [event]
                    (match event
                      (where e (R.ok? e))
                      (do
                        (tset package :facts (R.unwrap e))
                        (tset package :state :unstaged)
                        (PubSub.broadcast package :facts-changed)
                        (PubSub.unsubscribe wf handler))
                      (where e (R.err? e))
                      (do
                        ;; TODO attach this somewhere
                        (print e)
                        (PubSub.unsubscribe wf handler))
                      (where msg (string? msg))
                      (do
                        (E.append$ package.events msg)
                        (set package.text msg)
                        (PubSub.broadcast package :events-changed))))]
      (PubSub.subscribe wf handler)
      wf))

  (->> (E.map #$2 runtime.packages)
       (E.sort #(<= $1.order $2.order))
       (E.map #(let [wf (make-wf $2)]
                 (Scheduler.add-workflow runtime.scheduler wf)))))

;; TODO
(fn Runtime.exec-discover-orphans [runtime])

(fn Runtime.new [opts]
  (let [Scheduler (require :pact.workflow.scheduler)
        FS (require :pact.workflow.exec.fs)
        scheduler (Scheduler.new {:concurrency-limit opts.concurrency-limit})]
    {:packages {}
     :path {:root (FS.join-path (vim.fn.stdpath :data) :site/pack/pact)
            :data (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/data)
            :repos (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/repos)}
     :scheduler scheduler}))

(values Runtime)
