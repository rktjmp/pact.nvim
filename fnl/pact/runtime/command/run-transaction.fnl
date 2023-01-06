(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result-> : 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.fs
     inspect :pact.inspect
     Package :pact.package
     {:format fmt} string
     {:new task/new :run task/run :await task/await
      :trace task/trace
      :await-schedule task/await-schedule} :pact.task
     Transaction :pact.runtime.transaction)

(var __hack-render nil)

(λ run-afters [t packages]
  ;; run afters if they exist, these may be defined multiple times,
  ;; so we need to collate them somehow TODO (strings can be compared but functions might just be a pick-one)
  ;; run afters for any newly aligned packages
  (fn unique-afters [canonical-set]
    (->> (E.map #(match $.after
                   (where f (function? f)) f
                   (where s (string? s)) s
                   other #(error (fmt "`after` must be function or string, got %s" (type other))))
                canonical-set)
         (E.reduce (fn [acc after]
                     ;; string.dump(f, true) doesn't work for us since we're
                     ;; passing in locals, so the best we can do is try to pair
                     ;; f == f together
                     (match (type after)
                       :function (E.set$ acc after after)
                       :string (E.set$ acc after #(vim.cmd after))))
                   {})))

  (->> (E.map #(if (match? {:action :align} $) $)
              #(Package.iter packages))
       (E.filter #$.after)
       (E.group-by #$.canonical-id)
       (E.map (fn [canonical-set canonical-id]
                (let [[canonical-package] canonical-set
                      call-chain []
                      pre (if canonical-package.opt?
                            (table.insert call-chain #(vim.cmd (fmt "packadd! %s" canonical-package.package-name))))
                      afters (unique-afters canonical-set)
                      _ (if (< 1 (length (E.keys afters)))
                          (table.insert call-chain 1 #(vim.notify (fmt "%s.after had multiple different definitions, execution order is not guaranteed."
                                                                       canonical-package.name)
                                                                  vim.log.levels.WARN)))
                      _ (E.each #(table.insert call-chain $)
                                afters)
                      _ (Package.increment-tasks-waiting canonical-package)
                      task #(let [_ (Package.decrement-tasks-waiting canonical-package)
                                  _ (Package.increment-tasks-active canonical-package)
                                  _ (task/trace "Running after")
                                  _ (set t.progress.afters.waiting (- t.progress.afters.waiting 1))
                                  _ (set t.progress.afters.running (+ t.progress.afters.running 1))
                                  _ (__hack-render)
                                  after-helpers {:trace task/trace
                                                 :path (Transaction.package-path t canonical-package)}
                                  ;; TODO propagate active to can-set
                                  result (task/await-schedule
                                           #(match (pcall E.each #($ after-helpers) call-chain)
                                              (true _) (R.ok)
                                              (false err)
                                              (do
                                                (vim.notify (fmt "%s.after encountered an error: %s"
                                                                 canonical-package.name
                                                                 err)
                                                            vim.log.levels.ERROR)
                                                (R.err err))))
                                  _ (set canonical-package.transaction :done)
                                  _ (set t.progress.afters.running (- t.progress.afters.running 1))
                                  _ (set t.progress.afters.done (+ t.progress.afters.done 1))
                                  _ (__hack-render)
                                  _ (Package.decrement-tasks-active canonical-package)]
                              result)]
                  (task/run task {:traced #(Package.add-event canonical-package :transaction-after $)}))))
       (E.map #(task/await $))))

(λ transact-package-set [transaction canonical-set]
  (let [[canonical-package] canonical-set]
    (Transaction.package-waiting->package-running transaction)
    (__hack-render)
    (E.each (fn [p]
              (set p.transaction :start)
              (Package.decrement-tasks-waiting p)
              (Package.increment-tasks-active p))
            canonical-set)
    (local result (match canonical-package.action
                    :discard (Transaction.discard-package transaction canonical-package)
                    :retain (Transaction.retain-package transaction canonical-package)
                    :align (Transaction.align-package transaction canonical-package)
                    _ (R.err [:unhandled canonical-package.action])))
    (E.each (fn [p]
              (if (not p.after)
                (set p.transaction :done))
              (Package.decrement-tasks-active p))
            canonical-set)
    (__hack-render)
    (Transaction.package-running->package-done transaction)
    result))

(λ run-transaction [runtime update-win]
  (task/run #(result-let [t (Transaction.new runtime.datastore runtime.path.data)
                          _ (Transaction.prepare t)
                          ;; TODO topological sort these as a combined graph
                          canonical-sets (E.group-by #(values $.canonical-id $)
                                                     #(Package.iter runtime.packages))
                          _ (Transaction.packages-waiting t (-> (E.keys canonical-sets)
                                                                (length)))
                          _ (set t.progress.afters.waiting (E.reduce (fn [acc [p]]
                                                                       (if (and (= p.action :align) (not-nil? p.after))
                                                                         (+ acc 1) acc))
                                                                     0 canonical-sets))
                          _ (set __hack-render #(vim.schedule #(update-win
                                                                 t.progress.packages.waiting
                                                                 t.progress.packages.running
                                                                 t.progress.packages.done
                                                                 t.progress.afters.waiting
                                                                 t.progress.afters.running
                                                                 t.progress.afters.done)))
                          _ (__hack-render)
                          _ (E.each Package.increment-tasks-waiting
                                    #(Package.iter runtime.packages))
                          package-tasks (E.map (fn [canonical-set canonical-id]
                                                 (let [task (task/new #(transact-package-set t canonical-set))]
                                                   (set task.queued-at (vim.loop.hrtime))
                                                   (task/run task
                                                             {:traced (fn [msg]
                                                                        (E.each #(Package.add-event $ :transaction msg)
                                                                                canonical-set))})))
                                               canonical-sets)
                          ;; TODO we await each task separately until await can handle a seq of tasks
                          ;;      and return a seq of values.
                          {true ok-results false err-results} (->> (task/await package-tasks)
                                                                   (E.group-by R.ok?))]
               (if (not err-results)
                 (do
                   ;; Commit transaction which installs packages into the rtp,
                   ;; then load them, the run any afters. Afters may require
                   ;; acess to the packages so we must have them in the rtp.
                   (Transaction.commit t)
                   (task/await-schedule
                     (fn []
                       (vim.notify (fmt "Committed %s" t.id)
                                   vim.log.levels.INFO)
                       (vim.cmd "packloadall!")
                       (vim.cmd "silent! helptags ALL")))
                   (let [a (vim.loop.hrtime)
                         _ (print :running-afters a)
                         _ (run-afters t runtime.packages)
                         b (vim.loop.hrtime)
                         _ (print :ran-afters (/ (- b a) 1_000_000) :ms)]
                     (vim.schedule #(vim.notify (fmt "Transaction complete %s" t.id)
                                                vim.log.levels.INFO))
                     (R.ok)))
                 (do
                   (E.each #(vim.notify (tostring $) vim.log.levels.error) err-results)
                   (Transaction.cancel t)
                   (R.err "not-committed")))
               {:traced print})))
