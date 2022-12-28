(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     R :pact.lib.ruin.result
     {: 'result-let} :pact.lib.ruin.result
     FS :pact.fs
     Package :pact.package
     Datastore :pact.datastore
     {: trace} :pact.task
     {:format fmt} string)

(local Transaction {})

(λ Transaction.new [datastore transactions-prefix rtp-prefix]
  "Creates a new transaction. Creating a transaction has no disk effects until
  committed."
  (let [id (vim.loop.gettimeofday)]
    {: id
     : datastore
     :path {:root (FS.join-path transactions-prefix id) ;; eg data/pact/transactions/1234
            :runtime rtp-prefix}})) ;; eg nvim/rtp/

(λ Transaction.prepare [t]
  (result-let [_ (FS.make-path t.path.root)
               _ (FS.make-path (FS.join-path t.path.root "start"))
               _ (FS.make-path (FS.join-path t.path.root "opt"))]
    (trace "created transaction %s paths: %s/start|opt" t.id t.path.root)
    (R.ok t)))

(λ use-package [t package commit]
  (result-let [canonical-id package.canonical-id
               files-path (Datastore.path-for-package t.datastore canonical-id commit)
               link-path (FS.join-path t.path.root package.install.path)
               _ (FS.symlink files-path link-path)]
    (R.ok)))

(λ Transaction.retain-package [t package]
  (if package.git.current.commit
    (use-package t package package.git.current.commit)
    (R.err (fmt "package %s had no current commit to retain" package.canonical-id))))

(λ Transaction.sync-package [t package]
  (if package.git.target.commit
    (use-package t package package.git.target.commit)
    (R.err (fmt "package %s had no target commit to sync" package.canonical-id))))

Transaction
