(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result-let} :pact.lib.ruin.result
     R :pact.lib.ruin.result
     {: trace : async : await} (require :pact.task)
     E :pact.lib.ruin.enum
     Commit :pact.git.commit
     Constraint :pact.package.constraint.git
     {:format fmt} string)

(local Solver {})

(fn* solve-constraint
  ;; We bundle the returns as [[cons-from cons] msg|[commits]] as we join
  ;; all the results into one ok|err and we want to be able to split them
  ;; back out as associated pairs.

  ;; Note we don't solve here, we use satisfies so we can retain "passes but
  ;; not newest" commits to cross-solve with any other constraint.
  (where [constraint commits _] (Constraint.version? constraint))
  (->> (E.filter #(Constraint.satisfies? constraint $) commits)
       (#(if (E.empty? $1)
           (R.err {: constraint
                 :msg (fmt "no version satisfied %s" (Constraint.value constraint))})
           (R.ok {: constraint
                :commits $1}))))

  ;; Commits does not include *every* commit in the repo, just ref'd commits
  ;; so we must check "commit constraints" specifically against the repo if
  ;; it exist on disk.
  ;; If the repo does not exist on disk yet, we just optimistically assume the
  ;; commit exists.
  (where [constraint commits verify-sha] (Constraint.commit? constraint))
  (result-let [sha (Constraint.value constraint)
               full-sha (await (async #(verify-sha sha)))]
    (if full-sha
      (R.ok {: constraint :commits [(Commit.new full-sha)]})
      (R.err {: constraint :msg  (fmt "commit does not exist: %s" sha)})))

  ;; head, branch and tags just fall through to Constraint.solve
  (where [constraint commits _] (or (Constraint.branch? constraint)
                                    (Constraint.tag? constraint)
                                    (Constraint.head? constraint)))
  (match (Constraint.solve constraint commits)
    commit (R.ok {: constraint
                  :commits [commit]})
    nil (R.err {: constraint
                :msg (fmt "%s does not exist: %s"
                          (Constraint.type constraint)
                          (Constraint.value constraint))})))

(fn latest-in-set [constraints-commits]
  (let [all-version? (E.all? #(Constraint.version? $.constraint)
                             constraints-commits)]
    (if all-version?
      ;; All the constraints are versions, so we have a chance to return
      ;; the latest that satisfies all constraints.
      (->> (E.map #$.commit constraints-commits)
           ;; solve will solve n-commits to 1-commit
           (Constraint.solve (Constraint.version "> 0.0.0")))
      ;; otherwise any commit should be as good as any other
      (-> (E.hd constraints-commits)
          (. :commit)))))

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
                      (E.map #(R.unwrap $))
                      ;; unroll commits
                      (E.map (fn [solved-constraint]
                               (E.map #{:constraint solved-constraint.constraint
                                        :commit $}
                                      solved-constraint.commits)))
                      (E.flatten)
                      ;; now group all commit-constraint pairs by sha
                      ;; Note: we group on short-sha so we correctly pair
                      ;; "filled" sha's (see above) for constraints that
                      ;; gave a short sha. This may collide in some
                      ;; *extremely* rare cases ...
                      (E.group-by #(values $.commit.short-sha))
                      ;; now we can consider every sha that does not contain every constraint
                      ;; is actually not usable.
                      (E.filter (fn [ccs _sha] (= (length good) (length ccs))))
                      ;; now un-key as it's a bit simpler to parse out later
                      (E.map #$)
                      (E.flatten))]
    (if (E.empty? x-solved)
      (R.err good)
      (R.ok (latest-in-set x-solved)))))

(fn+ best-commit-or-error [{true good false bad}]
  (R.err (E.concat$ [] good bad)))

(fn+ best-commit-or-error [{true nil false bad}]
  (R.err bad))

;; TODO: need some guard on no constraints and no commits
(λ Solver.solve [constraints commits verify-sha]
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
  (trace "solving %s-way package constraint" (length constraints))
  (->> constraints
       (E.map #(solve-constraint $ commits verify-sha))
       (E.group-by #(R.ok? $))
       (best-commit-or-error)))

Solver
