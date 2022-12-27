(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result-let} :pact.lib.ruin.result
     R :pact.lib.ruin.result
     inspect :pact.inspect
     E :pact.lib.ruin.enum
     FS :pact.fs
     Git :pact.git
     Commit :pact.git.commit
     {: trace : async : await} (require :pact.task)
     Log :pact.log
     {:format fmt} string)

(local Datastore {})

(λ Datastore.new [repos-path runtime-path]
  "Create datastore for given paths.

  repos-path -> where plugins are checked out to for working
  runtime-path -> x/start|opt for discovering current plugins for current commits

  A datastore manages dirty work like looking for folders containing lost
  plugins, interrogating local and remote repositories for commit data,
  discovering packfiles.

  The datastore expects to be told about packages and it is EAGER. It will
  immediately begin creating a stub clone of a remote package for interrogation.

  It *will* find 'orphaned' packages - those that exist in the datapath but
  have no associated package data, if they exist in the root.

  The datastore does not pay attention to package-tree heirachy, everything is
  tracked by its canonical-id.

  The UI can ask for information about a package such as `current` (what the rtp uses)
  and (target-for-constraints ...) which will solve and return one commit."

  {:path {:runtime runtime-path
          :repos repos-path}
   :packages {}
   :orphans {}})

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

(λ current-commit-for-path [path]
  (result-let [_ (if (not (FS.absolute-path? path))
                   (R.err (fmt "repo path must be absolute, got %s" path)))
               ?sha (match [(FS.dir-exists? path) (FS.git-dir? path)]
                      [true true] (Git.HEAD-sha path)
                      [true false] (R.err (fmt "%s exists already but is not a git dir" path))
                      [false _] nil)]
    ;; if no checkout exist, no commit is a valid return value
    (if ?sha
      (R.ok (Commit.new ?sha))
      (R.ok nil))))

(λ fetch-commits [repo-path]
  (result-let [_ (validate-git-dir repo-path)
               _ (trace "git ls-local-refs")
               refs (Git.ls-local repo-path)]
    (R.ok (Commit.local-refs->commits refs))))

(λ Datastore.ingest-package [ds _kind canonical-id origin rtp-path ?callbacks]
  (match (Datastore.package-by-canonical-id ds canonical-id)
    p (R.ok p)
    nil (let [{: trace : async : await} (require :pact.task)
              p {:type :git
                 :remote {:origin origin}
                 :repo {:path (FS.join-path ds.path.repos canonical-id :HEAD)} ;; user-repo/HEAD
                 :runtime {:path (FS.join-path ds.path.runtime rtp-path)}
                 :current {:path nil ;; user-repo/sha, derived from whatever rtp points to
                           :commit nil}
                 :target {:commit nil
                          :distance nil
                          :logs []
                          :breaking? false}
                 :latest {:commit nil}
                 :commits []
                 :tasks {:register nil}}]
          (result-let [_ (trace "registering package %s" canonical-id)
                       _ (clone-if-missing p.remote.origin p.repo.path)
                       refs (update-refs p.repo.path)
                       cc-task (async #(current-commit-for-path p.runtime.path))
                       commits-task (async #(fetch-commits p.repo.path))
                       (local-head commits) (R.join (await cc-task) (await commits-task))]
            (trace "setting commits and target commit")
            (set p.commits commits)
            (set p.target.commit local-head)
            (tset ds.packages canonical-id p)
            (R.ok p)))))

(λ Datastore.verify-sha [ds canonical-id sha]
  (result-let [p (Datastore.package-by-canonical-id ds canonical-id)
               sha (Git.verify-commit p.repo.path sha)]
    (R.ok sha)))

(λ Datastore.package-by-canonical-id [ds canonical-id]
  (. ds :packages canonical-id))

(λ Datastore.commits-by-canonical-id [ds canonical-id]
  (?. (Datastore.package-by-canonical-id ds canonical-id) :commits))

Datastore
