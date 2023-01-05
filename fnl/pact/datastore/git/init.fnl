;;; pact.datastore.git

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result-let} :pact.lib.ruin.result
     {: tap} :pact.lib.ruin.fn
     R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.fs
     Git :pact.exec.git
     Commit :pact.git.commit
     {: trace :new task/new :await task/await : task?} (require :pact.task)
     Log :pact.log
     {:format fmt} string)

(λ validate-git-dir [path]
  "Helper to check if path is git-repo (or worktree)"
  (if (not (FS.absolute-path? path))
    (R.err (fmt "repo path must be absolute, got %s" path))
    (match [(FS.dir-exists? path) (FS.git-dir? path)]
      [true true] (R.ok path)
      [true false] (R.err (fmt "%s exists but is not a git dir" path))
      [false _] (R.err (fmt "%s does not exist" path)))))

(λ clone-if-missing [repo-origin repo-path]
  "Clone repo-origin into repo-path unless it already exists"
  (trace "clone-if-missing %s" repo-origin)
  (result-let [_ (if (not (FS.absolute-path? repo-path))
                   (R.err (fmt "repo path must be absolute, got %s" repo-path)))
               _ (match [(FS.dir-exists? repo-path) (FS.git-dir? repo-path)]
                   [true true] (R.ok)
                   [true false] (R.err (fmt "%s exists already but is not a git dir" repo-path))
                   _ (do
                       (trace "git clone %s -> %s" repo-origin repo-path)
                       (R.result (Git.create-stub-clone repo-origin repo-path))))]
    (R.ok repo-path)))

(λ update-refs [repo-path]
  (result-let [_ (trace "git update refs %s" repo-path)
               _ (validate-git-dir repo-path)
               _ (Git.update-refs repo-path)]
    (R.ok :updated-refs)))

(λ register [ds canonical-id repo-origin]
  "Add git-repo to datastore registry, creates local stub if needed."
  ;; It's simpler to manage git packages via a local clone, so we always create
  ;; a "stub" clone with no data - just commit information when a package is
  ;; registered.
  (local {: package-by-canonical-id} (require :pact.datastore))
  (match (package-by-canonical-id ds canonical-id)
    p (error (fmt "attempt to re-register known package %s" canonical-id))
    nil (let [f #(-> (result-let [store-path (FS.join-path ds.path.git canonical-id :HEAD)
                                  _ (clone-if-missing repo-origin store-path)]
                       (R.ok {:kind :git
                              :id canonical-id
                              :path store-path
                              :origin repo-origin}))
                     (tap #(tset ds :packages canonical-id $)))
              task (task/new (fmt :register-%s canonical-id) f)]
          (tset ds :packages canonical-id task)
          task)))

(λ fetch-commits [ds-package]
  "Return all 'named' commits for a given registered package"
  (task/new #(result-let [{: path} ds-package
                          _ (validate-git-dir path)
                          _ (update-refs path)
                          _ (trace "git ls-local-refs")
                          refs (Git.ls-local path)]
               (R.ok (Commit.local-refs->commits refs)))))

(λ setup-commit [ds-package commit]
  "Create usable copy of a registered package, at given commit, and return the path to package"
  (task/new #(result-let [{:path repo-path} ds-package
                          {:short-sha sha} commit
                          _ (validate-git-dir repo-path)
                          worktree-path (string.gsub repo-path "HEAD$" sha)
                          _ (match [(FS.dir-exists? worktree-path) (FS.git-dir? worktree-path)]
                              [true true] (R.ok worktree-path)
                              [true false] (R.err (fmt "%s exists already but is not a git dir" worktree-path))
                              _ (do
                                  (trace "git add-worktree %s %s -> %s" repo-path commit.short worktree-path)
                                  (Git.add-worktree repo-path worktree-path sha)
                                  (trace "git checkout %s" commit.short-sha)
                                  (Git.checkout-sha worktree-path sha)
                                  (trace "git checked-out %s" commit.short-sha)))]
               (R.ok worktree-path))))

(λ verify-commit [ds-package commit]
  "Special support for verifing that a commit-sha is valid"
  (task/new #(result-let [{: path} ds-package
                          sha (Git.verify-commit path commit.sha)]
               (R.ok sha))))

(λ commit-at-path [ds-package path]
  "Support for getting current HEAD commit of path"
  ;; ds-package technically not needed but kept for interface consistency and
  ;; probably checking that the path belongs to the correct package eventually.
  (task/new #(result-let [_ (if (not (FS.absolute-path? path))
                              (R.err (fmt "repo path must be absolute, got %s" path)))
                          ?sha (match [(FS.dir-exists? path) (FS.git-dir? path)]
                                 [true true] (Git.HEAD-sha path)
                                 [true false] (R.err (fmt "%s exists but is not a git dir" path))
                                 [false _] nil)]
               (if ?sha
                 (R.ok (Commit.new ?sha))
                 ;; if no checkout exist, no commit is a valid return value
                 (R.ok nil)))))

;; TODO this and breaking are obviously unoptimised as they normally run
;; together but must act alone
(λ distance-between [ds-package commit-a commit-b]
  (task/new #(result-let [{: path} ds-package
                          _ (validate-git-dir path)
                          ;; explictly throw result back to result-let
                          ts-a (Git.sha-timestamp path commit-a.sha)
                          ts-b (Git.sha-timestamp path commit-b.sha)
                          ;; then convert if no err
                          commit-a-ts (tonumber ts-a)
                          commit-b-ts (tonumber ts-b)
                          [mod early late] (if (<= commit-a-ts commit-b-ts)
                                        [1 commit-a commit-b]
                                        [-1 commit-b commit-a])
                          logs (Git.log-diff path early.sha late.sha)]
               (* mod (length logs)))))

(λ breaking-between? [ds-package commit-a commit-b]
  (task/new #(result-let [{: path} ds-package
                          _ (validate-git-dir path)
                          ;; explictly throw result back to result-let
                          ts-a (Git.sha-timestamp path commit-a.sha)
                          ts-b (Git.sha-timestamp path commit-b.sha)
                          ;; then convert if no err
                          commit-a-ts (tonumber ts-a)
                          commit-b-ts (tonumber ts-b)
                          [early late] (if (<= commit-a-ts commit-b-ts)
                                        [commit-a commit-b]
                                        [commit-b commit-a])
                          breaking-logs (Git.log-breaking path early.sha late.sha)]
               (<= 1 (length breaking-logs)))))

(λ logs-between [ds-package commit-a commit-b]
  (task/new #(result-let [{: path} ds-package
                          _ (validate-git-dir path)
                          ;; explictly throw result back to result-let
                          ts-a (Git.sha-timestamp path commit-a.sha)
                          ts-b (Git.sha-timestamp path commit-b.sha)
                          ;; then convert if no err
                          commit-a-ts (tonumber ts-a)
                          commit-b-ts (tonumber ts-b)
                          [mod early late] (if (<= commit-a-ts commit-b-ts)
                                        [1 commit-a commit-b]
                                        [-1 commit-b commit-a])
                          logs (Git.log-diff path early.sha late.sha)]
               logs)))
{: register
 : fetch-commits
 : setup-commit
 : verify-commit
 : commit-at-path
 : logs-between
 : distance-between
 : breaking-between?}
