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

(fn group-commits [commits]
  ;; Commits may share the multiple properties so filter each separately vs
  ;; using group-by.
  {:tags (E.filter #(match? {:tag t} $2) commits)
   :branches (E.filter #(match? {:branch t} $2) commits)
   :versions (E.filter #(match? {:version t} $2) commits)})

(fn status-remote [repo-url]
  "Fetch commits from remote and convert into commit datum."
  (result-let [_ (log "querying remote refs from %s" repo-url)
               commits (result->> (Git.ls-remote repo-url)
                                  (Commit.remote-refs->commits)
                                  (group-commits))]
    (log "retrieved facts")
    (ok commits)))

(fn status-local [repo-path]
  "Fetch commits from local repo, will update repo refs before hand."
  (result-let [_ (log "updating repository refs")
               _ (Git.update-refs repo-path)
               commits (result->> (Git.ls-local repo-path)
                                  (Commit.local-refs->commits)
                                  (group-commits))]
    (log "retrieved facts")
    (ok commits)))


(fn detect-kind [repo-url repo-path]
  (result-> (log "discovering viable commits")
            (or (FS.absolute-path? repo-path)
                (err (fmt "plugin path must be absolute, got %s" repo-path)))
            (#(if (FS.git-dir? repo-path)
                (status-local repo-path)
                (status-remote repo-url)))))

(fn* new
  "Discover git facts about a package. This includes all branches and tags as
  well as the current HEAD. A full list of commits is not returned for
  performance reasons. Packages depending on commit facts must access them
  individually.

  If a package does not exist locally, the remote endpoint is queried instead."
  (where [id repo-url repo-path])
  (new-workflow id #(detect-kind repo-url repo-path)))

{: new}
