(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     git :pact.workflow.exec.git
     fs :pact.workflow.exec.fs
     enum :pact.lib.ruin.enum
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow
     {: ls-remote->remote-commits
      : show-ref->remote-commits} :pact.git.commit
     git-commit :pact.git.commit
     Constraint :pact.plugin.constraint
     {:solve solve-constraint
      :satisfies? satisfies-constraint?} :pact.plugin.constraint)

;; TODO move these into constraint mod
(fn commit-constraint? [c]
  (match? [:git :commit any] c))

(fn tag-constraint? [c]
  (match? [:git :tag any] c))

(fn branch-constraint? [c]
  (match? [:git :branch any] c))

(fn version-constraint? [c]
  (match? [:git :version any] c))

(fn same-sha? [a b]
  (match [a b]
    [{: sha} {: sha}] true
    _ false))

(fn maybe-latest-version [remote-commits]
  (solve-constraint [:git :version "> 0.0.0"] remote-commits))

(fn maybe-newer-commit [target remote-commits]
  (let [?latest (maybe-latest-version remote-commits)]
    (if (not (same-sha? target ?latest)) ?latest)))

(fn* status-remote
  "Check remote repo against given constraint. Cannot check commit constraints")

(fn+ status-remote (where [repo-url constraint] (commit-constraint? constraint))
  ;; cant check remote shas so just return an ok-commit and hope
  (ok [:clone (git-commit.commit (. constraint 3))]))

(fn+ status-remote (where [repo-url constraint] (or (tag-constraint? constraint)
                                                           (branch-constraint? constraint)
                                                           (version-constraint? constraint)))
  (result-let [_ (yield "fetching remote refs")
               remote-commits (result->> (git.ls-remote repo-url)
                                         (ls-remote->remote-commits))]
    (yield "solving for constraint")
    (if-some-let [target-commit (solve-constraint constraint remote-commits)]
      (ok [:clone target-commit] (maybe-latest-version remote-commits))
      (err (fmt "no commit satisfies %s" constraint)))))

(fn* status-local
  "Check local repo against given constraint. Can check all constraint types, may
  fetch remote data before performing check")

(fn+ status-local (where [repo-path constraint] (commit-constraint? constraint))
  ;; [:hold commit] <- already at it
  ;; [:sync commit] <- exists but not at it
  ;; err <- commit does not exist, cant get
  (result-let [_ (yield "getting local HEAD")
               HEAD-sha (git.HEAD-sha repo-path)
               _ (yield "updating refs")
               _ (git.update-refs repo-path)
               _ (yield "verifying constraint commit")
               _ (or (git.verify-commit repo-path Constraint.value constraint) 
                     (err "constraint commit does not exist"))
               remote-commits (result->> (git.ls-local repo-path)
                                         (show-ref->remote-commits))
               ;; we construct a commit from the sha for ... old times sake
               ;; and to have a consisent path into the constraint checker.
               ;; likely we can revisit this at some point TODO
               HEAD-commit (git-commit.commit HEAD-sha)]
    (if (satisfies-constraint? constraint HEAD-commit)
      (ok [:hold HEAD-commit] (maybe-latest-version remote-commits))
      (ok [:sync (git-commit.commit (. constraint 3))] (maybe-latest-version remote-commits)))))

(fn+ status-local (where [repo-path constraint]
                         (or (tag-constraint? constraint)
                             (branch-constraint? constraint)))
  ;; tags and branches should have only one sha value (as we discard ^{} peeled)
  ;; so we're pretty ok to just fetch remotes, see if our curret head
  ;; matches any and if that matches the constraint, otherwise we need to
  ;; sync.
  (result-let [_ (yield "checking local sha")
               HEAD-sha (git.HEAD-sha repo-path)
               _ (yield "fetching remote refs")
               remote-commits (result->> (git.ls-local repo-path)
                                         (show-ref->remote-commits))
               _ (yield "reticulating splines")
               ;; Get tags and branches from remote commits, see if our current
               ;; head matches any of them and construct a commit if so, then
               ;; see if our current head-commit passes our constraint, otherwise
               ;; check all remotes for one that might.
               ;; Note, we get a plural of commits, as multiple branches and
               ;; tags may point to the same sha.
               HEAD-commits (->> remote-commits
                                 (enum.filter #(and (or (not-nil? $2.branch)
                                                        (not-nil? $2.tag))
                                                (= HEAD-sha $2.sha)))
                                 (enum.filter #(satisfies-constraint? constraint $2)))]
    (if (enum.hd HEAD-commits)
      ;; One of the head commits satisfies the constraint. This *should* only be one-long
      ;; as branches and tags should be unique in name, if not in sha...
      (ok [:hold (enum.hd HEAD-commits)] (maybe-latest-version remote-commits))
      ;; Current head did not satisfy, so we need to see if any remotes *do* satisfy
      (if-some-let [target-commit (solve-constraint constraint remote-commits)]
        ;; TODO: return current head, as per constraint if possible (ver for ver, etc) for UI
        (ok [:sync target-commit] (maybe-latest-version remote-commits))
        (err (fmt "no commit satisfies %s" constraint))))))

(fn+ status-local (where [repo-path constraint] (version-constraint? constraint))
  ;; Version constraints can be checked similar to tags and branches, except that we must 
  ;; watch out for under-eager satisfing constraints. Given a constraint >= 3,
  ;; an on disk check out of 3 and a remote of 5, both 3 and 5 satisfy, but 3
  ;; exists on disk and it's easy to see that and declare no work need be done.
  (result-let [_ (yield "checking local sha")
               HEAD-sha (git.HEAD-sha repo-path)
               _ (yield "fetching remote refs")
               remote-commits (result->> (git.ls-local repo-path)
                                         (show-ref->remote-commits))
               _ (yield "reticulating splines")]
    ;; this will give us the *best* satisaction result (newest version)
    (if-some-let [target-commit (solve-constraint constraint remote-commits)
                  ;; Now we'll find any remote version commits that match our local HEAD
                  HEAD-commits (->> remote-commits
                                    (enum.filter #(and (not-nil? $2.version) (= HEAD-sha $2.sha)))
                                    (enum.filter #(satisfies-constraint? constraint $2)))]
      ;; if HEAD-commits contains the target-commit, then we already have the
      ;; best checkout on disk and dont need to do any sync, otherwise we need to sync
      (if (enum.any? #(= target-commit.sha $2.sha) HEAD-commits)
        ;; TODO: return current head, as per constraint if possible (ver for ver, etc) for UI
        ;; we explictly look for a newer version and only show it *if* its newer
        ;; vs other types where we always show any semver that shows up, to encourage
        ;; its usage.
        (ok [:hold target-commit] (maybe-newer-commit target-commit remote-commits))
        (ok [:sync target-commit]
            ;; may have a newer commit than our current
            (maybe-newer-commit target-commit remote-commits)
            ;; we kind of just have to assume that any version in HEAD-commits, we
            ;; are at the latest. *Probably* HEAD-commits will always only contain
            ;; at most one version commit, but this is a bit safer?
            (solve-constraint [:git :version "> 0.0.0"] HEAD-commits)))
      ;; or we never got a target commit
      (err (fmt "no commit satisfies %s" constraint)))))

(fn detect-kind [repo-url repo-path constraint]
  (result-> (log "starting git-status workflow")
            (or (fs.absolute-path? repo-path)
                (err (fmt "plugin path must be absolute, got %s" repo-path)))
            (#(if (fs.git-dir? repo-path)
                (status-local repo-path constraint)
                (status-remote repo-url constraint)))))

(fn* new
  "Check repo against constraint, returns a possible action if required. The repo
  may or may not exist locally. Existing repos have their local data updated and
  new repos are checked against ls-remote."
  (where [id repo-url repo-path constraint])
  (new-workflow id #(detect-kind repo-url repo-path constraint)))

{: new}
