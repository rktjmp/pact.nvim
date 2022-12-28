;;; pact.datastore.git

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result-let} :pact.lib.ruin.result
     {: tap} :pact.lib.ruin.fn
     R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.fs
     Git :pact.git
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

(λ get-package [ds canonical-id]
  (match (. ds :packages canonical-id)
    (where t (task? t)) (task/await t)
    p p
    nil nil))

(λ register [ds canonical-id repo-origin]
  "Add git-repo to datastore registry, creates local stub if needed."
  ;; It's simpler to manage git packages via a local clone, so we always create
  ;; a "stub" clone with no data - just commit information when a package is
  ;; registered.
  (match (get-package ds canonical-id)
    p (task/new (fmt :register-%s canonical-id) #p)
    nil (let [f #(-> (result-let [store-path (FS.join-path ds.path.git canonical-id :HEAD)
                                  _ (clone-if-missing repo-origin store-path)]
                       (R.ok {:kind :git
                              :id canonical-id
                              :path store-path
                              :origin repo-origin}))
                     (tap #(tset ds :packages canonical-id $)))
              task (task/new f)]
          (tset ds :packages canonical-id task)
          task)))

(λ fetch-commits [ds canonical-id]
  "Return all 'named' commits for a given registered package"
  (task/new #(result-let [{: path} (get-package ds canonical-id)
                          _ (validate-git-dir path)
                          _ (update-refs path)
                          _ (trace "git ls-local-refs")
                          refs (Git.ls-local path)]
               (R.ok (Commit.local-refs->commits refs)))))

(λ setup-commit [ds canonical-id commit]
  "Create usable copy of a registered package, at given commit, and return the path to package"
  (task/new #(result-let [{:path repo-path} (get-package ds canonical-id)
                          {:short-sha sha} commit
                          _ (validate-git-dir repo-path)
                          worktree-path (string.gsub repo-path "HEAD$" sha)
                          _ (match [(FS.dir-exists? worktree-path) (FS.git-dir? worktree-path)]
                              [true true] (R.ok worktree-path)
                              [true false] (R.err (fmt "%s exists already but is not a git dir" worktree-path))
                              _ (do
                                  (trace "git add-worktree %s %s -> %s" repo-path commit.short worktree-path)
                                  (Git.add-worktree repo-path worktree-path sha)))]
               (R.ok worktree-path))))

(λ verify-commit [ds canonical-id commit]
  "Special support for verifing that a commit-sha is valid"
  (task/new #(result-let [{: path} (get-package ds canonical-id)
                          sha (Git.verify-commit path commit.sha)]
               (R.ok sha))))

(λ commit-at-path [ds path]
  "Support for getting current HEAD commit of path"
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

{: register
 : fetch-commits
 : setup-commit
 : verify-commit
 : commit-at-path}
