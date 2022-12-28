(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result-let} :pact.lib.ruin.result
     R :pact.lib.ruin.result
     inspect :pact.inspect
     E :pact.lib.ruin.enum
     FS :pact.fs
     Git :pact.git
     PubSub :pact.pubsub
     Commit :pact.git.commit
     {: trace : async : await} (require :pact.task)
     Log :pact.log
     {:format fmt} string)

(local Datastore {})

(set Datastore.Git (require :pact.datastore.git))

(λ Datastore.new [data-path]
  "Create datastore for given paths."
  {:path {:git (FS.join-path data-path :repos)
          :luarocks (FS.join-path data-path :rocks)}
   :packages {}})

; (λ validate-git-dir [path]
;   "Helper to check if path is git-repo (or worktree)"
;   (if (not (FS.absolute-path? path))
;     (R.err (fmt "repo path must be absolute, got %s" path))
;     (match [(FS.dir-exists? path) (FS.git-dir? path)]
;       [true true] (R.ok path)
;       [true false] (R.err (fmt "%s exists but is not a git dir" path))
;       [false _] (R.err (fmt "%s does not exist" path)))))

; (λ clone-if-missing [repo-origin repo-path]
;   "Clone repo-origin into repo-path unless it already exists"
;   (trace "clone-if-missing %s" repo-origin)
;   (result-let [_ (if (not (FS.absolute-path? repo-path))
;                    (R.err (fmt "repo path must be absolute, got %s" repo-path)))
;                _ (match [(FS.dir-exists? repo-path) (FS.git-dir? repo-path)]
;                    [true true] (R.ok)
;                    [true false] (R.err (fmt "%s exists already but is not a git dir" repo-path))
;                    _ (do
;                        (trace "git clone %s -> %s" repo-origin repo-path)
;                        (R.result (Git.create-stub-clone repo-origin repo-path))))]
;     (R.ok repo-path)))

; (λ create-worktree [repo-path sha worktree-path]
;   ;; TODO need consistent check-repo-path fn
;   (result-let [_ (if (not (FS.absolute-path? worktree-path))
;                    (R.err (fmt "repo path must be absolute, got %s" worktree-path)))
;                _ (match [(FS.dir-exists? worktree-path) (FS.git-dir? worktree-path)]
;                    [true true] (R.ok worktree-path)
;                    [true false] (R.err (fmt "%s exists already but is not a git dir" repo-path))
;                    _ (do
;                        (trace "git add-worktree %s %s -> %s" repo-path sha worktree-path)
;                        (Git.add-worktree repo-path worktree-path sha)))]
;     (R.ok worktree-path)))

; (λ update-refs [repo-path]
;   (result-let [_ (trace "git update refs %s" repo-path)
;                _ (validate-git-dir repo-path)
;                _ (Git.update-refs repo-path)]
;     (R.ok :updated-refs)))

; (λ current-sha-for-path [path]
;   (result-let [_ (if (not (FS.absolute-path? path))
;                    (R.err (fmt "repo path must be absolute, got %s" path)))
;                ?sha (match [(FS.dir-exists? path) (FS.git-dir? path)]
;                       [true true] (Git.HEAD-sha path)
;                       [true false] (R.err (fmt "%s exists already but is not a git dir" path))
;                       [false _] nil)]
;     ;; if no checkout exist, no commit is a valid return value
;     (R.ok ?sha)))

; (λ fetch-commits [repo-path]
;   (result-let [_ (validate-git-dir repo-path)
;                _ (trace "git ls-local-refs")
;                refs (Git.ls-local repo-path)]
;     (R.ok (Commit.local-refs->commits refs))))

; (λ Datastore.verify-commit [ds canonical-id commit]
;   (result-let [sha (match (Datastore.package-by-canonical-id ds canonical-id)
;                       p (Git.verify-commit p.repo.path commit.sha)
;                       nil false)]
;     (R.ok sha)))

; (λ Datastore.ingest-package [ds _kind canonical-id origin rtp-path]
;   (match (Datastore.package-by-canonical-id ds canonical-id)
;     p (R.ok p)
;     nil (let [{: trace : async : await} (require :pact.task)
;               p {:type :git
;                  :id canonical-id
;                  :origin origin
;                  :repo {:path (FS.join-path ds.path.repos canonical-id :HEAD)} ;; user-repo/HEAD
;                  :runtime {:path (FS.join-path ds.path.runtime rtp-path)}
;                  :current {:path nil ;; user-repo/sha, derived from whatever rtp points to
;                            :commit nil}
;                  :target {:commit nil
;                           :distance nil
;                           :logs []
;                           :breaking? false}
;                  :latest {:commit nil}
;                  :commits []
;                  :tasks {:register nil}}]
;           (tset ds.packages canonical-id p)
;           (result-let [_ (trace "registering package %s" canonical-id)
;                        _ (clone-if-missing p.origin p.repo.path)
;                        refs (update-refs p.repo.path)
;                        current-sha-task (async #(current-sha-for-path p.runtime.path))
;                        commits-task (async #(fetch-commits p.repo.path))
;                        (head-sha commits) (R.join (await current-sha-task)
;                                                   (await commits-task))
;                        head-commit (E.find #(match? {:sha head-sha} $)
;                                            commits)]
;             (trace "setting commits and target commit")
;             (set p.commits commits)
;             (set p.current.commit (or head-commit (Commit.new head-sha)))
;             (PubSub.broadcast ds [:package p])
;             (R.ok p)))))

; (λ Datastore.path-for-package [ds canonical-id commit]
;   ;; get checkout path for package x commit, if it does not exist, create it
;   (local {: trace : async : await} (require :pact.task))
;   (result-let [package (match (Datastore.package-by-canonical-id ds canonical-id)
;                          p p
;                          nil (R.err "no package for canonical-id"))
;                path (FS.join-path (string.match package.repo.path "(.+)HEAD$")
;                                   commit.short-sha)
;                _ (trace "create worktree %s %s" canonical-id path)
;                _ (create-worktree package.repo.path commit.sha path)
;                _ (trace "checkout %s" commit.sha)
;                _ (Git.checkout-sha path commit.sha)
;                _ (trace "update submodules")
;                _ (Git.update-submodules path)]
;     (R.ok path)))

; (λ Datastore.package-by-canonical-id [ds canonical-id]
;   (. ds :packages canonical-id))


Datastore
