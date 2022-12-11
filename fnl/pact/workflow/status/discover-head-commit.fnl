(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     Commit :pact.git.commit
     Git :pact.workflow.exec.git
     FS :pact.workflow.exec.fs
     E :pact.lib.ruin.enum
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(fn status-local [repo-path]
  "Fetch commits from local repo, will update repo refs before hand"
  (result-let [_ (log "getting local HEAD")
               HEAD-sha (Git.HEAD-sha repo-path)
               commit (Commit.commit HEAD-sha)]
    (log "retrieved HEAD")
    (ok {:head commit})))

(fn detect-kind [repo-path]
  (result-> (log "discovering HEAD commit")
            (or (FS.absolute-path? repo-path)
                (err (fmt "plugin path must be absolute, got %s" repo-path)))
            (#(if (FS.git-dir? repo-path)
                (status-local repo-path)
                ;; not a git dir, assume its missing, probaly remote at the moment
                ;; so we have no head sha.
                (do
                  (log "no local HEAD")
                  (ok {}))))))

(fn* new
  (where [id repo-path])
  (new-workflow id #(detect-kind repo-path)))

{: new}
