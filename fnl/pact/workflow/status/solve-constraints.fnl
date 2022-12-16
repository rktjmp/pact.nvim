(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     {: inspect! : inspect} :pact.lib.ruin.debug
     R :pact.lib.ruin.result
     Commit :pact.git.commit
     Constraint :pact.plugin.constraint
     Git :pact.workflow.exec.git
     FS :pact.workflow.exec.fs
     E :pact.lib.ruin.enum
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(fn* solve-constraint-type
  ;; We bundle the returns as [[cons-from cons] msg|[commits]] as we join
  ;; all the results into one ok|err and we want to be able to split them
  ;; back out as associated pairs.

  ;; Note we don't solve here, we use satisfies so we can retain "passes but
  ;; not newest" commits to x-resovle with any other constraint.
  (where [[constraint-from constraint] commits _] (Constraint.version? constraint))
  (->> (E.filter (fn [_ commit] (Constraint.satisfies? constraint commit)) commits)
       (#(if (E.empty? $1)
           (err [[constraint constraint-from]
                 (fmt "no version satisfied %s" (Constraint.value constraint))])
           (ok [[constraint constraint-from]
                $1]))))

  ;; Commits does not include *every* commit in the repo, just ref'd commits
  ;; so we must check "commit constraints" specifically against the repo if
  ;; it exist on disk.
  ;; If the repo does not exist on disk yet, we just optimistically assume the
  ;; commit exists.
  (where [[constraint-from constraint] commits repo-path] (Constraint.commit? constraint))
  (if (FS.dir-exists? repo-path)
    ;; Have a local repo, concretely check for constraint
    (result-let [sha (Constraint.value constraint)
                 val (Git.verify-commit repo-path sha)]
      (if val
        (ok [[constraint-from constraint]
             [(Commit.new sha)]])
        (err [[constraint-from constraint]
              (fmt "commit does not exist: %s" sha)])))
    ;; No local repo, just hope the user typed it in correctly..
    (let [sha (Constraint.value constraint)
          ;;We may have a "short" sha in the constraint, so we need to fill it
          ;;out with dummy data to let commit accept it. This *should* not be
          ;;impactful as the value here is really just used as an optimisic
          ;;placeholder.
          full-sha (.. sha (string.rep "0" (- 40 (length sha))))]
      (ok [[constraint-from constraint]
           [(Commit.new full-sha)]])))

  ;; head, branch and tags just fall through to Constraint.solve
  (where [[constraint-from constraint] commits _] (or (Constraint.branch? constraint)
                                                      (Constraint.tag? constraint)
                                                      (Constraint.head? constraint)))
  (match (Constraint.solve constraint commits)
    commit (ok  [[constraint-from constraint]
                 [commit]])
    nil (err [[constraint constraint-from]
              (fmt "%s does not exist: %s"
                   (Constraint.type constraint)
                   (Constraint.value constraint))])))

(fn best-commit-or-err [...]
  ;; Each argument is a table containing
  ;; [[constraint-source constraint] [commit ...]]
  ;; and we need to ensure that at least one commit is common among all
  ;; constraints.
  ;;
  ;; We can do this by grouping all commits by sha, with the constraints
  ;; and then finding any that have all constraints present.
  (let [args (E.pack ...)
        maybe-good (->> args
                        ;; first lets pair every commit with their constraint
                        (E.map (fn [_ [constraint commits]]
                                 (E.map #{:constraint constraint
                                          :commit $2} commits)))
                        (E.flatten)
                        ;; convert to {sha [[constraint commit] ..]}
                        (E.group-by #(values $2.commit.sha))
                        ;; every sha shat does not contain every constraint not usable
                        (E.filter (fn [_sha constraints] (= args.n (length constraints)))))]
    (if (E.empty? maybe-good)
      ;; nothing satisfied all, you could term this "disatisfied".
      (err "no commits matched any constraint") ;; TODO note those that could? return ok/err pairs for ui?
      ;; We found some satisfactory commits, but there is an edge case where
      ;; version constraints have an optimal commit in the set - that is: the
      ;; latest version that satisfies all constraints.
      ;; So we will check each constraint and if they're all versions then we
      ;; resolve for "latest version" constraint.
      (if (E.reduce (fn [all? _sha satisfied-data]
                      (and all? (E.all? #(match? [:git :version] (. $2.constraint 1))
                                        satisfied-data)))
                    true maybe-good)
        ;; find latest version
        (->> (E.map (fn [_sha satisfied-data]
                      (E.map #(. $2 :commit) satisfied-data))
                    maybe-good)
             (E.flatten)
             (#(Constraint.solve (Constraint.git :version "> 0.0.0") $1))
             (ok))
        ;; mixed constraint, so we should actually only have one that satisfed...
        (let [(_sha [{: commit}]) (next maybe-good nil)]
          (ok commit))))))

;; TODO: commits -> flatten? we currently don't give a "up to date" "out of date"
;; response so we don't use any current head-value.
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
               _ (log "solving %s-way package %s" n-constraints (or (= 1 n-constraints)
                                                                    "constraint"
                                                                    "constraints"))]
    ;; We should get back a list of ok|errs where each ok contains a list
    ;; of commits.
    ;; If we got back ane err, we can consider the whole constraint
    ;; set unsolvable and fail.
    (->> constraints
         (E.map #(solve-constraint-type $2 commits repo-path))
         (E.reduce #(R.join $1 $3) (ok))
         (#(R.map-ok $1 best-commit-or-err)))))

(fn* new
  (where [id repo-path constraints commits])
  (new-workflow id #(solve-constraints repo-path constraints commits)))

{: new}
