(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     git-tasks :pact.workflow.exec.git
     fs-tasks :pact.workflow.exec.fs
     {:format fmt} string
     {:new new-workflow : yield} :pact.workflow)

(fn absolute-path? [path]
  (not-nil? (string.match path "^/")))

(fn git-dir? [path]
  (= :directory (fs-tasks.what-is-at (.. path "/.git"))))

(fn sync-repo-impl [path sha]
  (result-let [_ (yield "fetching sha")
               _ (git-tasks.fetch-sha path sha)
               _ (yield "checking out sha")
               _ (git-tasks.checkout-sha path sha)]
    (ok)))

(fn sync [path sha]
  (result-> (yield "starting git-sync workflow")
            (or (absolute-path? path)
                (values nil (fmt "plugin path must be absolute, got %s" path)))
            (#(if (git-dir? path)
                (sync-repo-impl path sha)
                (err (fmt "unable to sync, directory %s is not a git repo" path))))))

(fn* new
  (where [id path sha])
  (new-workflow id #(sync path sha)))

{: new}
