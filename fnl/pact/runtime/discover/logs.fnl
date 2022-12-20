(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     Commit :pact.git.commit
     Git :pact.workflow.exec.git
     FS :pact.workflow.exec.fs
     R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     PubSub :pact.pubsub
     Package :pact.package
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(local Logs {})

(λ get-logs [repo-path from-sha to-sha]
  (if (= from-sha to-sha)
    (ok [] [] :static)
    (result-let [_ (log "discovering logs between %s..%s" from-sha to-sha)
                 _ (or (FS.absolute-path? repo-path)
                       (err (fmt "plugin path must be absolute, got %s" repo-path)))
                 _ (or (FS.git-dir? repo-path)
                       (err (fmt "unable to diff, directory %s is not a git repo" repo-path)))
                 ahead (Git.log-diff repo-path from-sha to-sha)
                 backward (Git.log-diff repo-path to-sha from-sha)
                 ahead-breaking (Git.log-breaking repo-path from-sha to-sha)
                 backward-breaking (Git.log-breaking repo-path to-sha from-sha)]
      (match [(E.empty? ahead) (E.empty? backward)]
        [false true] (ok ahead ahead-breaking :ahead)
        [true false] (ok backward backward-breaking :backward)
        [true true] (err (fmt "logs returned no results in both directions but sha's were not equal?? %s..%s" from-sha to-sha))
        [false false] (err (fmt "logs returned results in both directions?? %s..%s" from-sha to-sha))))))

(λ Logs.workflow [package path-prefix]
  (let [wf (new-workflow (fmt "discover-logs:%s" package.canonical-id)
                         #(get-logs (FS.join-path path-prefix
                                                  package.git.repo.path)
                                    package.git.checkout.HEAD.sha
                                    package.git.target.commit.sha))]
      (Package.track-workflow package wf)
      (wf:attach-handler
        (fn [log-details]
          (let [(oneline breaking direction) (R.unwrap log-details)
                logs (E.map #(let [(sha log) (string.match $2 "^(%x+) (.+)$")
                                   breaking? (E.any? #(= sha $2) breaking)]
                               {: sha : log : breaking?})
                            oneline)]
          (-> package
              (Package.update-target-logs logs)
              (Package.update-target-direction direction)
              (Package.untrack-workflow wf)
              (Package.add-event wf log-details)
              (PubSub.broadcast :logs-updated))))
        (fn [err]
          (-> package
              (Package.untrack-workflow wf)
              (Package.add-event wf err)
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

Logs
