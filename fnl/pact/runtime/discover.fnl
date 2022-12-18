(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     PubSub :pact.pubsub
     Package :pact.package
     {:format fmt} string)

(local Discover {})

(fn Discover.make-discover-canonical-set-commits-workflow [canonical-set path-prefix]
  (use DiscoverViableCommits :pact.workflow.status.discover-viable-commits)
  (let [;; we only need one packge to work on
        package (E.hd canonical-set)
        ;; but need to propagate results to all in the set
        update-siblings #(E.each (fn [_ p] ($1 p)) canonical-set)
        wf (DiscoverViableCommits.new
             package.canonical-id
             (Package.source package)
             (FS.join-path path-prefix package.path.head))]
    (update-siblings (fn [package]
                       (Package.track-workflow package wf)))
    (wf:attach-handler
      (fn [commits]
        (update-siblings #(-> $
                              (Package.add-event wf commits)
                              (Package.untrack-workflow wf)
                              (Package.update-commits (R.unwrap commits))
                              (E.set$ :state :unstaged)
                              (PubSub.broadcast (R.ok :facts-updated)))))
      (fn [err]
        (update-siblings #(-> $
                              (Package.add-event wf err)
                              (Package.untrack-workflow wf)
                              (Package.update-commits [])
                              (E.set$ :text (tostring err))
                              ;; TODO
                              (Package.update-health
                                (Package.Health.failing (fmt "E-9999")))
                              ;; TODO wrapping not needed anymore
                              (PubSub.broadcast package (R.err :facts-updated)))))
      (fn [msg]
        (update-siblings #(-> $
                              (Package.add-event wf msg)
                              (E.set$ :text msg)
                              (PubSub.broadcast package :events-changed)))))
    wf))

(fn Discover.make-head-commit-workflow [package path-prefix]
    (use DiscoverHeadCommit :pact.workflow.status.discover-head-commit)
    (let [wf (DiscoverHeadCommit.new package.canonical-id
                                     (FS.join-path path-prefix package.install.path))]
      (Package.track-workflow package wf)
      (wf:attach-handler
        (fn [commit]
          ;; may be nil, for no local checkout, maybe change? TODO
          (match (R.unwrap commit)
            c (Package.set-head package c))
          (-> package
              (Package.untrack-workflow wf)
              (Package.add-event wf commit)
              (E.set$ :state :unstaged)
              (PubSub.broadcast (R.ok :head-updated))))
        (fn [err]
          (-> package
              (Package.untrack-workflow wf)
              (Package.add-event wf err)
              (E.set$ :text (tostring err))
              ;; TODO
              (Package.update-health
                (Package.Health.failing (fmt "E-9999")))
              (PubSub.broadcast package (R.err :head-updated))))
        (fn [msg]
          (-> package
              (Package.add-event wf msg)
              (E.set$ :text msg)
              (PubSub.broadcast package :events-changed))))
      wf))

Discover
