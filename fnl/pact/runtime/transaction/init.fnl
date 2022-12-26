(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     R :pact.lib.ruin.result
     FS :pact.fs
     Package :pact.package
     {:format fmt} string)

(local Transaction {})

(λ Transaction.new [data-prefix repos-prefix head-prefix]
  "Creates a new transaction. Creating a transaction has no disk effects until
  committed."
  (let [id (vim.loop.gettimeofday)]
    {: id
     :orphans {}
     :packages {
                ; :cid-1 {:action :sync
                ;         :target commit 
                ;         :path :start/some-path.nvim
                ;         :depends-on []}
                ; :cid-2 {:action :sync
                ;         :target commit-2
                ;         :path :starg/some-other.nvim
                ;         :depends-on {:
                }
     :afters {}
     :path {:root (FS.join-path data-prefix id)
            :repos repos-prefix
            :head head-prefix}}))

; (λ Transaction.set-initial-packages [t packages]
;   "bootstrap the initial transaction tree with some packages"
;   (tset t :packages packages)
;   t)

; (λ Transaction.set-package-action [t canonical-id action]
  


; (fn* Transaction.set-package-action
;   (where [t package :sync nil] package.git)
;   (R.err "cannot set package action to %s, no commit target")
;   (where [t package :sync commit] package.git)
;   (if (Package.healthy? package)
;     (do
;       (set t.packages package.canonical-id [:sync commit package.install.path])
;       (R.ok))
;     (R.err "cannot set package action to sync, package is unhealthy"))



; (λ Transaction.set-package-action [t canonical-id action]
;   (tset t canonical-id action)
;   (R.ok))

; (λ Transaction.package-action [t canonical-id]
;   (. t canonical-id))

(fn Transaction.stage-package [transaction package]
  (use StageWorkflow :pact.runtime.transaction.workflow.stage
       Package :pact.package)
  (let [repo-path (FS.join-path transaction.path.repos package.git.repo.path)
        worktree-path (FS.join-path transaction.path.repos
                                    (Package.worktree-path package package.git.target.commit))
        rtp-path (FS.join-path transaction.path.root package.install.path)
        repo-url package.git.remote.origin
        sha package.git.target.commit.short-sha]
    (E.append$ transaction.packages package)
    (StageWorkflow.new package.uid repo-url repo-path worktree-path sha rtp-path)))

(fn Transaction.workflows [transaction]
  (use SetupWorkflow :pact.runtime.transaction.workflow.setup
       CommitWorkflow :pact.runtime.transaction.workflow.commit
       RollbackWorkflow :pact.runtime.transaction.workflow.rollback)
  (let [setup (SetupWorkflow.new transaction.id transaction.path.root)
        commit (CommitWorkflow.new transaction.id transaction.path.root transaction.path.head)
        rollback (RollbackWorkflow.new transaction.id)]
    {: setup : commit : rollback}))


Transaction
