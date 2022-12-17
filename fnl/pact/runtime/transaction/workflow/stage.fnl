(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     Git :pact.workflow.exec.git
     FS :pact.workflow.exec.fs
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(fn maybe-clone [repo-url repo-path]
  (match [(FS.dir-exists? repo-path) (FS.git-dir? repo-path)]
    [true true] (ok :already-cloned)
    [true false] (err (fmt "%s exists already but is not a git dir" repo-path))
    _ (result-let [_ (log "clone %s -> %s" repo-url repo-path)
                   _ (Git.create-stub-clone repo-url repo-path)]
        (ok :clone))))

(fn update-refs [repo-path]
  (result-let [_ (log "update refs")
               _ (Git.update-refs repo-path)]
    (ok :refs)))

(fn create-worktree [repo-path worktree-path sha]
  (match [(FS.dir-exists? worktree-path) (FS.git-dir? worktree-path)]
    [true true] (ok :already-worktreed)
    [true false] (err (fmt "%s exists already but is not a git dir" worktree-path))
    _ (result-let [_ (log "creating worktree %s -> %s @ %s" repo-path worktree-path sha)
                   _ (Git.add-worktree repo-path worktree-path sha)
                   _ (log "checking out")
                   _ (Git.checkout-sha worktree-path sha)]
        (ok :worktree))))

(fn create-links [source-path link-name]
  (log "linking %s -> %s" source-path link-name)
  (FS.symlink source-path link-name))

(fn stage [repo-url repo-path worktree-path sha rtp-path]
  (result-let [_ (yield "starting stage workflow")
               _ (if (not (FS.absolute-path? repo-path))
                   (err (fmt "repo path must be absolute, got %s" repo-path)))
               _ (if (not (FS.absolute-path? worktree-path))
                   (err (fmt "worktree-path must be absolute, got %s" worktree-path)))
               _ (maybe-clone repo-url repo-path)
               _ (update-refs repo-path)
               _ (create-worktree repo-path worktree-path sha)
               _ (create-links worktree-path rtp-path)]
    (ok :staged)))

(fn* new
  (where [id repo-url repo-path worktree-path sha rtp-path])
  (new-workflow (fmt "transaction-stage:%s" id)
                #(stage repo-url repo-path worktree-path sha rtp-path)))

{: new}
