(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     {: inspect!} :pact.lib.ruin.debug
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     PubSub :pact.pubsub
     Package :pact.package
     Runtime :pact.runtime
     Commit :pact.git.commit
     Constraint :pact.plugin.constraint
     Git :pact.workflow.exec.git
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(local Solve {})

(fn* solve-constraint
  ;; We bundle the returns as [[cons-from cons] msg|[commits]] as we join
  ;; all the results into one ok|err and we want to be able to split them
  ;; back out as associated pairs.

  ;; Note we don't solve here, we use satisfies so we can retain "passes but
  ;; not newest" commits to x-resovle with any other constraint.
  (where [[package-uid constraint] commits _] (Constraint.version? constraint))
  (->> (E.filter (fn [_ commit] (Constraint.satisfies? constraint commit)) commits)
       (#(if (E.empty? $1)
           (err {: constraint : package-uid
                 :msg (fmt "no version satisfied %s" (Constraint.value constraint))})
           (ok {: constraint : package-uid
                :commits $1}))))

  ;; Commits does not include *every* commit in the repo, just ref'd commits
  ;; so we must check "commit constraints" specifically against the repo if
  ;; it exist on disk.
  ;; If the repo does not exist on disk yet, we just optimistically assume the
  ;; commit exists.
  (where [[package-uid constraint] commits repo-path] (Constraint.commit? constraint))
  (if (FS.dir-exists? repo-path)
    ;; Have a local repo, concretely check for constraint
    (result-let [sha (Constraint.value constraint)
                 full-sha (Git.verify-commit repo-path sha)]
      (if full-sha
        (ok {: constraint : package-uid
             :commits [(Commit.new full-sha)]})
        (err {: constraint : package-uid
              :msg (fmt "commit does not exist: %s" sha)})))
    ;; No local repo, just hope the user typed it in correctly..
    (let [sha (Constraint.value constraint)
          ;;We may have a "short" sha in the constraint, so we need to fill it
          ;;out with dummy data to let commit accept it. This *should* not be
          ;;impactful as the value here is really just used as an optimisic
          ;;placeholder.
          full-sha (.. sha (string.rep "0" (- 40 (length sha))))
          commit (-> (Commit.new full-sha)
                     ;; Flag this is a guess with incomplete sha so we can
                     ;; try to pick a better commit when finding best below.
                     ;;
                     ;; Otherwise we might pich this one which might be lacking
                     ;; branch,head,etc data.
                     (E.set$ :optimistic? true))]
      (ok {: constraint : package-uid
           :commits [commit]})))

  ;; head, branch and tags just fall through to Constraint.solve
  (where [[package-uid constraint] commits _] (or (Constraint.branch? constraint)
                                                  (Constraint.tag? constraint)
                                                  (Constraint.head? constraint)))
  (match (Constraint.solve constraint commits)
    commit (ok {: constraint : package-uid
                :commits [commit]})
    nil (err {: constraint : package-uid
              :msg (fmt "%s does not exist: %s"
                        (Constraint.type constraint)
                        (Constraint.value constraint))})))

(fn err-x-solved [constraints-commits]
  (err constraints-commits))

(fn ok-with-latest [constraints-commits]
  (let [all-version? (E.all? #(Constraint.version? $2.constraint)
                             constraints-commits)]
    (if all-version?
      ;; All the constraints are versions, so we have a chance to return
      ;; the latest that satisfies all constraints.
      (->> (E.map #$2.commit constraints-commits)
           ;; solve will solve n-commits to 1-commit
           (Constraint.solve (Constraint.git :version "> 0.0.0"))
           (ok))
      ;; We might have a mix of concrete (from the repo) and optimistic
      ;; (commit constraints with sub-40-char sha's), ideally we'll return a
      ;; concrete commit. All commits in the same category *should* be the same
      ;; so we'll just grab the first one.
      (let [{true optimistic false concrete} (E.group-by #(not-nil? $2.optimisic?)
                                                         constraints-commits)]
        (if concrete
          (ok (. (E.hd concrete) :commit))
          (ok (. (E.hd optimistic) :commit)))))))

(fn* best-commit-or-error
  "Find best commit (latest and passes all constraints) in a set. Is given a table
  of {true good false bad} and each element in those lists matches
  [[constraint-source constraint] [commit ...]].")

(fn+ best-commit-or-error [{true good false nil}]
  ;; This is our best case, where all constraints found a commit, but this does
  ;; not guarantee that they all x-solve. We must find a shared commit between
  ;; all of them and possibly find the latest version if all constraints are
  ;; versions.
  (let [x-solved (->> good
                      (E.map #(R.unwrap $2))
                      ;; unroll commits
                      (E.map (fn [_ solved-constraint]
                               (E.map #{:constraint solved-constraint.constraint
                                        :package-uid solved-constraint.package-uid
                                        :commit $2}
                                      solved-constraint.commits)))
                      (E.flatten)
                      ;; now group all commit-constraint pairs by sha
                      ;; Note: we group on short-sha so we correctly pair
                      ;; "filled" sha's (see above) for constraints that
                      ;; gave a short sha. This may collide in some
                      ;; *extremely* rare cases ...
                      (E.group-by #(values $2.commit.short-sha))
                      ;; now we can consider every sha that does not contain every constraint
                      ;; is actually not usable.
                      (E.filter (fn [_sha ccs] (= (length good) (length ccs))))
                      ;; now un-key as it's a bit simpler to parse out later
                      (E.map #$2)
                      (E.flatten))]
    (if (E.empty? x-solved)
      (err-x-solved good)
      (ok-with-latest x-solved))))

(fn+ best-commit-or-error [{true good false bad}]
  (err (E.concat$ [] good bad)))

(fn+ best-commit-or-error [{true nil false bad}]
  (err bad))

;; TODO: need some guard on no constraints and no commits
(fn solve-constraints [repo-path constraints commits]
  ;; We're given a list if constraints and constraint sources, and some commits.
  ;;
  ;; For each constraint, find the commits that satisfy. For branch/tag/commit
  ;; commits, we should only get one value back - a branch constraint should
  ;; only match one branch - but versions will return a set of all commits that
  ;; satisfy the constraint.
  ;;
  ;; Given ">= 1" and "= 2", we might get back "v1 v2 v3", "v2", and we'll trim
  ;; each list to just the shared versions which will satisfy both constraints
  ;; eg: v2.
  ;;
  ;; We then need to see if the same sha exists in all valid commits and
  ;; return OK-solved or ERR-unsolvable.
  (result-let [n-constraints (length constraints)
               _ (log "solving %s-way package %s"
                      n-constraints
                      (or (= 1 n-constraints)
                          "constraint"
                          "constraints"))]
    (->> constraints
         (E.map #(solve-constraint $2 commits repo-path))
         (E.group-by #(R.ok? $2))
         (best-commit-or-error))))

(fn* new
  (where [id repo-path constraints commits])
  (new-workflow id #(solve-constraints repo-path constraints commits)))

(fn Solve.solve [runtime package]
  (fn rel-path->abs-path [in path]
    (FS.join-path (. runtime :path in) path))

  (let [siblings (E.map #(if (= $1.canonical-id package.canonical-id) $1)
                        #(Package.iter runtime.packages))
        update-siblings #(E.each (fn [_ p] ($1 p)) siblings)]
    ;; Pair each constraint with its package so any targetable errors can be
    ;; propagated back to the correct package.
    (let [constraints (E.map #[$2.uid $2.constraint] siblings)
          s-way-cons (fmt "%s-way constraint%s" (length constraints) (if (= 1 (length constraints))
                                                                       "" "s"))
          commits package.git.commits
          repo (rel-path->abs-path :repos package.path.head) ;; TODO into module
          wf (new package.canonical-id repo constraints commits)]
      (update-siblings #(Package.track-workflow $ wf))
      (wf:attach-handler
        (fn [ok-commit]
          (update-siblings #(-> $
                                (Package.untrack-workflow wf)
                                (Package.add-event wf ok-commit)
                                (Package.solve (R.unwrap ok-commit))
                                (PubSub.broadcast :solved)))
          (use DiscoverLogs :pact.runtime.discover.logs
               Scheduler :pact.workflow.scheduler)
         ; (vim.pretty_print :check package.git)
          (if package.git.checkout.commit
            (let [wf (DiscoverLogs.workflow package runtime.path.repos)]
              (Scheduler.add-workflow runtime.scheduler.local wf))))
        (fn [ok-commits-err-constraints]
          ;; This may be called with a mixture of ok-commit for constraints
          ;; that were solved and err-constraints for constraints that could
          ;; not be solved.
          ;; The workflow is considered a "failure", but we do want to show
          ;; which packages were vaguely ok, and which packages are actually
          ;; borked.
          (let [all-ok? (E.all? #(R.ok? $2) (R.unwrap ok-commits-err-constraints))
                find-result (fn [uid]
                              (E.find-value #(= (. (R.unwrap $2) :package-uid) uid)
                                            (R.unwrap ok-commits-err-constraints)))]
            (update-siblings (fn [p]
                              (Package.untrack-workflow p wf)
                              (let [relevant-result (find-result p.uid)]
                                (Package.add-event p wf relevant-result)
                                (match [all-ok? (R.ok? relevant-result)]
                                  [true _]
                                  (-> p
                                      ;; This is a funny edge case where all
                                      ;; constraints were solved but there was no
                                      ;; shared commit between them, so technically
                                      ;; they fail as a collection.
                                      ;; TODO: E.hd may give "non-latest" for versions
                                      (Package.solve (E.hd (. (R.unwrap relevant-result) :commits)))
                                      (Package.update-health (Package.Health.failing (fmt "no single commit satisfied %s"
                                                                                          s-way-cons))))
                                  [_ true]
                                  (-> p
                                      ;; sibling constraint was actually ok
                                      (Package.solve (R.unwrap relevant-result))
                                      (Package.update-health (Package.Health.degraded
                                                               (fmt "could not solve %s due to error in canonical sibling"
                                                                    s-way-cons))))
                                  [_ false]
                                  (-> p
                                      ;; sibling constraint failed, so we have specific error
                                      (Package.update-health (Package.Health.failing
                                                               (. (R.unwrap relevant-result) :msg))))))
                                (PubSub.broadcast p :error)))))
        (fn [msg]
          (update-siblings #(-> $
                                (Package.add-event wf msg)
                                (PubSub.broadcast :events-changed)))))
      (runtime.scheduler.local:add-workflow wf))))

Solve
