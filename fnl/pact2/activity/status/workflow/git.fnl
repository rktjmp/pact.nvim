(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     git-tasks :pact2.workflow.exec.git
     fs-tasks :pact2.workflow.exec.fs
     enum :pact.lib.ruin.enum
     {:format fmt} string
     {:new new-workflow : yield} :pact2.workflow
     {: ref-line->commit} :pact2.git.commit
     git-commit :pact2.git.commit
     constraint :pact2.plugin.constraint)

(fn absolute-path? [path]
  (not-nil? (string.match path "^/")))

(fn git-dir? [path]
  (= :directory (fs-tasks.what-is-at (.. path "/.git"))))

(fn status-new-repo-impl []
  ;; nothing to check here
  (ok {:actions [:clone]}))

(fn status-existing-repo-impl [plugin]
  (result-let [_ (yield "checking local sha")
               HEAD-sha (git-tasks.HEAD-sha plugin.package-path)
               _ (yield "fetching remote refs")
               remote-commits (result->> (. plugin :source 2) ;; TODO nicer interface
                                         (git-tasks.ls-remote)
                                         (enum.map #(ref-line->commit $2)))
               _ (yield "reticulating splines")
               ;; find extended commit if it exists otherwise make sha-commit.
               HEAD-commit (match (enum.find #(= HEAD-sha $2.sha) remote-commits)
                             (_ c) c
                             _ (git-commit.commit HEAD-sha))]
    (if (constraint.satisfies? plugin.constraint HEAD-commit)
      ;; currently satisfied, so all done
      (ok {:actions []})
      ;; unsatisfied, can we find one to work?
      (if-some-let [target-commit (constraint.solve plugin.constraint remote-commits)]
        (ok {:actions [:sync target-commit]})
        (err (fmt "no commit satisfies %s" plugin.constraint))))))

(fn detect-kind [plugin]
  (result-> (yield "starting git-status workflow")
            (or (absolute-path? plugin.package-path)
                (values nil (fmt "plugin path must be absolute, got %s" plugin.package-path)))
            (#(if (git-dir? plugin.package-path)
                (status-existing-repo-impl plugin)
                (status-new-repo-impl plugin)))))

(fn new [plugin]
  (new-workflow plugin.id #(detect-kind plugin)))

{: new}
