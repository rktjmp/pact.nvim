(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     FS :pact.workflow.exec.fs
     {:format fmt} string)

(local Transaction {})

(fn Transaction.new [data-prefix repos-prefix head-prefix]
  "Creates a new transaction. Creating a transaction has no disk effects until
  committed."
  (let [id (vim.loop.gettimeofday)]
    {: id
     :packages []
     :path {:root (FS.join-path data-prefix id)
            :repos repos-prefix
            :head head-prefix}}))

(fn Transaction.stage-package [transaction package]
  (use StageWorkflow :pact.runtime.transaction.workflow.stage
       Package :pact.package)
  (let [repo-path (FS.join-path transaction.path.repos package.path.head)
        worktree-path (FS.join-path transaction.path.repos
                                    package.path.root
                                    package.solves-to.short-sha)
        rtp-path (FS.join-path transaction.path.root package.path.rtp)
        repo-url (Package.source package)
        sha package.solves-to.short-sha]
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
