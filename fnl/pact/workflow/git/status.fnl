(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     git-tasks :pact.workflow.exec.git
     fs-tasks :pact.workflow.exec.fs
     enum :pact.lib.ruin.enum
     {:format fmt} string
     {:new new-workflow : yield} :pact.workflow
     {: ref-line->commit} :pact.git.commit
     git-commit :pact.git.commit
     {:solve solve-constraint} :pact.plugin.constraint)

(fn absolute-path? [path]
  (not-nil? (string.match path "^/")))

(fn git-dir? [path]
  (= :directory (fs-tasks.what-is-at (.. path "/.git"))))

(fn status-new-repo-impl [repo-url constraint]
  ;; we have no local repo but we can still check if the remote + constraint is
  ;; valid.
  (result-let [_ (yield "fetching remote refs")
               remote-commits (result->> (git-tasks.ls-remote repo-url)
                                         (enum.map #(ref-line->commit $2)))]
    (yield "solving for constraint")
    (if-some-let [target-commit (solve-constraint constraint remote-commits)]
      (ok {:actions [:clone target-commit]})
      (err (fmt "no commit satisfies %s" constraint)))))


(fn status-existing-repo-impl [path repo-url constraint]
  ;; TODO check that current repo origin matches given repo-url
  (result-let [_ (yield "checking local sha")
               HEAD-sha (git-tasks.HEAD-sha path)
               _ (yield "fetching remote refs")
               remote-commits (result->> (git-tasks.ls-remote repo-url)
                                         (enum.map #(ref-line->commit $2)))
               _ (yield "reticulating splines")
               ;; find extended commit if it exists otherwise make sha-commit.
               HEAD-commit (match (enum.find #(= HEAD-sha $2.sha) remote-commits)
                             (_ c) c
                             _ (git-commit.commit HEAD-sha))]
    (if (constraint.satisfies? constraint HEAD-commit)
      ;; currently satisfied, so all done
      (ok {:actions []})
      ;; unsatisfied, can we find one to work?
      (if-some-let [target-commit (solve-constraint constraint remote-commits)]
        (ok {:actions [:sync target-commit]})
        (err (fmt "no commit satisfies %s" constraint))))))

(fn detect-kind [repo-url path constraint]
  (result-> (yield "starting git-status workflow")
            (or (absolute-path? path)
                (values nil (fmt "plugin path must be absolute, got %s" path)))
            (#(if (git-dir? path)
                (status-existing-repo-impl path constraint)
                (status-new-repo-impl repo-url constraint)))))

(fn* new
  (where [id [:git repo-url] path constraint])
  (new-workflow id #(detect-kind repo-url path constraint)))

{: new}
