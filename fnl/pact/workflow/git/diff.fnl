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

(fn diff-shas-impl [path sha]
  (result-let [_ (yield "checking clone shallowness")
               shallow? (git-tasks.shallow? path)
               _ (when shallow?
                   (yield "git unshallow")
                   (git-tasks.unshallow path))
               _ (yield "git fetch")
               _ (git-tasks.fetch path)
               _ (yield "git local HEAD")
               HEAD (git-tasks.HEAD-sha path)
               _ (yield (fmt "git log HEAD..%s" (git-tasks.short-sha sha)))
               lines (git-tasks.log-diff path HEAD sha)]
    (ok lines)))

(fn diff [path sha]
  (result-> (yield "starting git-diff workflow")
            (or (absolute-path? path)
                (values nil (fmt "plugin path must be absolute, got %s" path)))
            (#(if (git-dir? path)
                (diff-shas-impl path sha)
                (err (fmt "unable to diff, directory %s is not a git repo" path))))))

(fn* new
  (where [id path sha])
  (new-workflow id #(diff path sha)))

{: new}
