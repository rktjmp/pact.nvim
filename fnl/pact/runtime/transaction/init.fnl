(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     R :pact.lib.ruin.result
     {: 'result-let} :pact.lib.ruin.result
     FS :pact.fs
     Package :pact.package
     Datastore :pact.datastore
     {: trace :run task/run :await task/await} :pact.task
     {:format fmt} string)

(local Transaction {})

(λ new-transaction [id datastore prefix]
  {: id
   : datastore
   :progress {:packages {:waiting 0
                         :running 0
                         :done 0}
              :afters {:waiting 0
                       :running 0
                       :done 0}}
   :path {:root (FS.join-path prefix id)
          :head (FS.join-path prefix :HEAD)}})

(λ Transaction.packages-waiting [t n]
  (set t.progress.packages.waiting n)
  t)

(λ Transaction.package-waiting->package-running [t]
  (set t.progress.packages.waiting (- t.progress.packages.waiting 1))
  (set t.progress.packages.running (+ t.progress.packages.running 1))
  t)

(λ Transaction.package-running->package-done [t]
  (set t.progress.packages.running (- t.progress.packages.running 1))
  (set t.progress.packages.done (+ t.progress.packages.done 1))
  t)

(λ Transaction.new [datastore transactions-prefix]
  "Creates a new transaction. Creating a transaction has no disk effects until
  committed."
  (new-transaction (vim.loop.gettimeofday) datastore transactions-prefix))

(λ Transaction.latest [datastore transactions-prefix]
  (let [existing (->> (FS.ls-path transactions-prefix)
                      (E.map #(if (and (= :directory $.kind)
                                       (string.match $.name "^%d+$"))
                                (tonumber $.name)))
                      (E.sort$)
                      (E.last))]
    (if existing
      (new-transaction existing datastore transactions-prefix)
      nil)))

(λ Transaction.prepare [t]
  (result-let [_ (FS.make-path t.path.root)
               _ (FS.make-path (FS.join-path t.path.root "start"))
               _ (FS.make-path (FS.join-path t.path.root "opt"))]
    (trace "created transaction %s paths: %s/start|opt" t.id t.path.root)
    (R.ok t)))

(λ Transaction.package-path [t package]
  (FS.join-path t.path.root package.install.path))

(λ use-package [t package commit]
  (result-let [canonical-id package.canonical-id
               dsp (Datastore.package-by-canonical-id t.datastore canonical-id)
               _ (Package.decrement-tasks-waiting package)
               _ (Package.increment-tasks-active package)
               files-path (-> (Datastore.Git.setup-commit dsp commit)
                              (task/run)
                              (task/await))
               link-path (FS.join-path t.path.root package.install.path)
               _ (FS.symlink files-path link-path)
               _ (Package.decrement-tasks-active package)]
    (R.ok)))

(λ Transaction.retain-package [t package]
  (if package.git.current.commit
    (use-package t package package.git.current.commit)
    (Transaction.discard-package t package)))
    ;; TODO? return to this behaviour? ; (R.err (fmt "package %s had no current commit to retain" package.canonical-id))))

(λ Transaction.align-package [t package]
  (if package.git.target.commit
    (use-package t package package.git.target.commit)
    (R.err (fmt "package %s had no target commit to sync" package.canonical-id))))

(λ Transaction.discard-package [t package]
  (Package.decrement-tasks-waiting package)
  (R.ok))

(λ Transaction.commit [t]
  ;; re-link HEAD to current commit
  (vim.loop.fs_unlink t.path.head)
  (FS.symlink t.path.root t.path.head))

(λ Transaction.cancel [t]
  (FS.remove-path t.path.root))

Transaction
