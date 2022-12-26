(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result-let : 'result->} :pact.lib.ruin.result
     R :pact.lib.ruin.result
     {: 'maybe-let} :pact.lib.ruin.maybe
     inspect :pact.inspect
     T :pact.task
     M :pact.lib.ruin.maybe
     E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     Git :pact.workflow.exec.git
     Commit :pact.git.commit
     Workflow :pact.workflow
     Scheduler :pact.workflow.scheduler
     Constraint :pact.plugin.constraint
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
   :orphans {}
   :scheduler (Scheduler.new {:concurrency-limit 10})})


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
  (print "clone-if-missing-called returning fn %s" repo-origin)
  (fn f [{: await : log}]
    (print :clone-if-missing repo-origin)
    (log "clone-if-missing %s" repo-origin)
    (result-let [_ (if (not (FS.absolute-path? repo-path))
                     (R.err (fmt "repo path must be absolute, got %s" repo-path)))
                 _ (match [(FS.dir-exists? repo-path) (FS.git-dir? repo-path)]
                     [true true] (R.ok)
                     [true false] (R.err (fmt "%s exists already but is not a git dir" repo-path))
                     _ (do
                         (log "git clone %s -> %s" repo-origin repo-path)
                         (R.result (Git.create-stub-clone repo-origin repo-path))))]
      (R.ok repo-path))))

(λ update-refs-task [repo-path]
  (fn f [{: await : log}]
    (result-let [_ (log "git update refs %s" repo-path)
                 _ (validate-git-dir repo-path)
                 _ (Git.update-refs repo-path)]
      (R.ok :updated-refs))))

(λ current-commit-for-path [path]
  (fn f [{: await : log}]
    (result-let [_ (if (not (FS.absolute-path? path))
                     (R.err (fmt "repo path must be absolute, got %s" path)))
                 ?sha (match [(FS.dir-exists? path) (FS.git-dir? path)]
                        [true true] (Git.HEAD-sha path)
                        [true false] (R.err (fmt "%s exists already but is not a git dir" path))
                        [false _] nil)]
      ;; if no checkout exist, no commit is a valid return value
      (if ?sha
        (R.ok (Commit.new ?sha))
        (R.ok nil)))))

(λ fetch-commits [repo-path]
  (fn f [{: await : log}]
    (result-let [_ (validate-git-dir repo-path)
                 _ (log "git ls-local-refs")
                 refs (Git.ls-local repo-path)]
      (R.ok (Commit.local-refs->commits refs)))))

(λ Datastore.ingest-package [ds _kind canonical-id origin rtp-path ?callbacks]
  ;; TODO dont re-register known canonical-id
  (let [callbacks (E.merge$ {:resolved #nil :rejected #nil :message #nil}
                            (or ?callbacks {}))
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
           :tasks {:register nil}}
        {:run task/run} (require :pact.task)
        f (fn [{: await : log}]
            ;; what if await in a task implicitly created a task for the given function, if given a function
            ;; otherwise assume its a task?
            ; (await #(clone-if-missing p.repo.path p.remote.origin))
            (print :running-f canonical-id)
            (result-let [_ (log "registering package %s" canonical-id)
                         _ (-> (task/run (clone-if-missing p.remote.origin p.repo.path)
                                         {:message log})
                                (await))
                         refs (-> (task/run (update-refs-task p.repo.path)
                                            {:message log})
                                  (await))
                         cc-task (task/run (current-commit-for-path p.runtime.path)
                                          {:message log})
                         commits-task (task/run (fetch-commits p.repo.path)
                                          {:message log})
                         (local-head commits) (R.join (await cc-task) (await commits-task))]
              (log "setting commits and target commit")
              (set p.commits commits)
              (set p.target.commit local-head)
              (tset ds.packages canonical-id p)
              (R.ok p)))]
    (T.new (fmt "ds-inject-%s" canonical-id) f)))

(λ Datastore.verify-sha [ds canonical-id sha]
  (let [f (fn [{: await : log}]
            (result-let [p (Datastore.package-by-canonical-id ds canonical-id)
                         sha (Git.verify-commit p.repo.path sha)]
              (R.ok sha)))]
    (T.new (fmt "ds-verify-sha-%s" canonical-id) f)))

(λ Datastore.package-by-canonical-id [ds canonical-id]
  (. ds :packages canonical-id))

(λ Datastore.commits-by-canonical-id [ds canonical-id]
  (?. (Datastore.package-by-canonical-id ds canonical-id) :commits))

Datastore

