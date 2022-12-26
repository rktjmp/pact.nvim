(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     {: inspect!} :pact.lib.ruin.debug
     E :pact.lib.ruin.enum
     T :pact.task
     FS :pact.workflow.exec.fs
     PubSub :pact.pubsub
     Package :pact.package
     Commit :pact.git.commit
     Constraint :pact.plugin.constraint
     Git :pact.workflow.exec.git
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(local Solver {})

(fn* solve-constraint
  ;; We bundle the returns as [[cons-from cons] msg|[commits]] as we join
  ;; all the results into one ok|err and we want to be able to split them
  ;; back out as associated pairs.

  ;; Note we don't solve here, we use satisfies so we can retain "passes but
  ;; not newest" commits to x-resovle with any other constraint.
  (where [constraint commits _] (Constraint.version? constraint))
  (->> (E.filter (fn [_ commit] (Constraint.satisfies? constraint commit)) commits)
       (#(if (E.empty? $1)
           (err {: constraint
                 :msg (fmt "no version satisfied %s" (Constraint.value constraint))})
           (ok {: constraint
                :commits $1}))))

  ;; Commits does not include *every* commit in the repo, just ref'd commits
  ;; so we must check "commit constraints" specifically against the repo if
  ;; it exist on disk.
  ;; If the repo does not exist on disk yet, we just optimistically assume the
  ;; commit exists.
  (where [constraint commits verify-sha] (Constraint.commit? constraint))
  (result-let [sha (Constraint.value constraint)
               full-sha (verify-sha sha)]
    (if full-sha
      (ok {: constraint :commits [(Commit.new full-sha)]})
      (err {: constraint :msg  (fmt "commit does not exist: %s" sha)})))

  ;; head, branch and tags just fall through to Constraint.solve
  (where [constraint commits _] (or (Constraint.branch? constraint)
                                    (Constraint.tag? constraint)
                                    (Constraint.head? constraint)))
  (match (Constraint.solve constraint commits)
    commit (ok {: constraint
                :commits [commit]})
    nil (err {: constraint
              :msg (fmt "%s does not exist: %s"
                        (Constraint.type constraint)
                        (Constraint.value constraint))})))

(fn err-x-solved [constraints-commits]
  (err constraints-commits))

(fn ok-with-latest-in-set [constraints-commits]
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
      (ok-with-latest-in-set x-solved))))

(fn+ best-commit-or-error [{true good false bad}]
  (err (E.concat$ [] good bad)))

(fn+ best-commit-or-error [{true nil false bad}]
  (err bad))

;; TODO: need some guard on no constraints and no commits
(λ Solver.solve-constraints [constraints commits verify-sha]
  ;; We're given a list of constraints and commits to test against, and a
  ;; function that can be used to verify a sha-constraint commit exists.
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
  (let [f (fn [{: await : log}]
            (log "solving %s-way package constraint" (length constraints))
            (->> constraints
                        (E.map #(solve-constraint $2 commits verify-sha))
                        (E.group-by #(R.ok? $2))
                        (best-commit-or-error)))]
    (T.new :solver-solve f)))

Solver
