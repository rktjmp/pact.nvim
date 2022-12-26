(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     PubSub :pact.pubsub
     Package :pact.package
     {:format fmt} string
     Constraint :pact.plugin.constraint
     {:new new-workflow : yield : log} :pact.workflow)

(local SolveLatest {})

(fn solve-latest [commits]
  (result-let [_ (log "discovering latest commit")
               ;; just aim high
               constraint (Constraint.git :version "> 0.0.0")
               latest (Constraint.solve constraint commits)]
    (if (not latest)
      (log "no latest commit found"))
    ;; latest might be nil, but that's ok, there may be no versions
    (ok latest)))

(fn* new
  (where [id commits])
  (new-workflow id #(solve-latest commits)))

(fn SolveLatest.solve [runtime package]
  (let [siblings (E.map #(if (= $1.canonical-id package.canonical-id) $1)
                        #(Package.iter runtime.packages))
        update-siblings #(E.each (fn [_ p] ($1 p)) siblings)]
    (let [commits package.git.commits
          wf (new package.canonical-id commits)]
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
                                (Package.set-latest-commit (R.unwrap latest))
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

(fn SolveLatest.solve [runtime package]
  (let [siblings (E.map #(if (= $1.canonical-id package.canonical-id) $1)
                        #(Package.iter runtime.packages))
        update-siblings #(E.each (fn [_ p] ($1 p)) siblings)]
    (let [commits package.git.commits
          wf (new package.canonical-id commits)]
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
                                (Package.set-latest-commit (R.unwrap latest))
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
