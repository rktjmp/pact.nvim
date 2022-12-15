(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: '*dout*} :pact.log
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
                       (tset package.workflows wf true)))
    (wf:attach-handler
      (fn [commits]
        (update-siblings (fn [package]
                           (tset package.workflows wf nil)
                           (set package.commits commits)
                           (set package.state :unstaged)))
        (PubSub.broadcast package (R.ok :facts-updated)))
      (fn [err]
        (update-siblings (fn [package]
                           (tset package.workflows wf nil)
                           (set package.text err)
                           (set package.commits [])
                           (set package.state :error)))
        (PubSub.broadcast package (R.err :facts-updated)))
      (fn [msg]
        (update-siblings (fn [package]
                           (E.append$ package.events msg)
                           (set package.text msg)
                           (PubSub.broadcast package :events-changed)))))
    wf))

(fn Discover.make-head-commit-workflow [package path-prefix]
    (use DiscoverHeadCommit :pact.workflow.status.discover-head-commit)
    (let [wf (DiscoverHeadCommit.new package.canonical-id
                                     (FS.join-path path-prefix package.path.rtp))]
      (tset package.workflows wf true)
      (wf:attach-handler
        (fn [commit]
          (tset package.workflows wf nil)
          (set package.head commit)
          (set package.state :unstaged)
          (PubSub.broadcast package (R.ok :head-updated)))
        (fn [err]
          (tset package.workflows wf nil)
          (set package.text err)
          (set package.state :error)
          (PubSub.broadcast package (R.err :head-updated)))
        (fn [msg]
          (E.append$ package.events msg)
          (set package.text msg)
          (PubSub.broadcast package :events-changed)))
      wf))

Discover
