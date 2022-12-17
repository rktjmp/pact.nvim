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

(local SolveLatest {})

(fn SolveLatest.solve [runtime package]
  (let [{:new solve-latest/new} (require :pact.workflow.status.solve-latest)
        siblings (E.map #(if (= $1.canonical-id package.canonical-id) $1)
                        #(Package.iter runtime.packages))
        update-siblings #(E.each (fn [_ p] ($1 p)) siblings)]
    (let [commits package.commits
          wf (solve-latest/new package.canonical-id commits)]
      (update-siblings #(Package.track-workflow $ wf))
      (wf:attach-handler
        (fn [latest]
          (update-siblings #(-> $
                                (Package.untrack-workflow wf)
                                (Package.add-event wf latest)
                                ;; Latest may actually be empty, which is ok. It
                                ;; just means that the upstream had no semver to
                                ;; actually find a latest version in. As semver
                                ;; isn't super common, it's not an error - just no data.
                                (Package.update-latest (R.unwrap latest))
                                (PubSub.broadcast :solved-latest))))
        (fn [e]
          (update-siblings #(-> $
                                (Package.untrack-workflow wf)
                                (Package.add-event wf e)
                                (PubSub.broadcast :solved-latest)))
          (error (fmt "solve-latest-failed: %s" e)))
        (fn [msg]
          (update-siblings #(-> $
                               (Package.add-event wf msg)
                               (PubSub.broadcast :events-changed)))))
      (runtime.scheduler.local:add-workflow wf))))

SolveLatest
