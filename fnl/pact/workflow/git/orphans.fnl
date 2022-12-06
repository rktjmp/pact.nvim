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

(fn dir-exists? [path]
  (= :directory (fs-tasks.what-is-at path)))

(fn clone-repo-impl [repo-url sha path]
  (result-let [_ (yield "init new local repo")
               _ (git-tasks.init path)
               _ (yield "set remote origin")
               _ (git-tasks.set-origin path repo-url)
               _ (yield "fetching sha")
               _ (git-tasks.fetch-sha path sha)
               _ (yield "checking out sha")
               _ (git-tasks.checkout-sha path sha)
               _ (yield "updating submodules")
               _ (git-tasks.update-submodules path)]
    (ok sha)))

(fn clone [repo-url sha path]
  (result-> (yield "starting git-clone workflow")
            (or (absolute-path? path)
                (err (fmt "plugin path must be absolute, got %s" path)))
            (#(if (not (dir-exists? path))
                (clone-repo-impl repo-url sha path)
                (err (fmt "unable to clone, directory %s already exists" path))))))

(fn* new
  (where [id path repo-url sha])
  (new-workflow id #(clone repo-url sha path)))

{: new}
