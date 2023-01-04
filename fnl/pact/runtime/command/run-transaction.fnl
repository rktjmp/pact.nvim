(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     {: 'result-> : 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.fs
     inspect :pact.inspect
     Datastore :pact.datastore
     Solver :pact.solver
     PubSub :pact.pubsub
     Package :pact.package
     Commit :pact.git.commit
     Constraint :pact.plugin.constraint
     {:format fmt} string
     {:new task/new :run task/run :await task/await
      :trace task/trace
      :await-schedule task/await-schedule} :pact.task
     Transaction :pact.runtime.transaction)

(λ run-afters [t packages]
  ;; run afters if they exist, these may be defined multiple times,
  ;; so we need to collate them somehow TODO (strings can be compared but functions might just be a pick-one)
  ;; run afters for any newly aligned packages
  (->> (E.map #(if (match? {:action :align} $) $)
              #(Package.iter packages))
       (E.filter #$.after)
       (E.group-by #$.canonical-id)
       (E.map (fn [canonical-set canonical-id]
                (let [[canonical-package] canonical-set
                      pre (if canonical-package.opt?
                            #(vim.cmd (fmt "packadd! %s" canonical-package.package-name))
                            #nil)
                      f (match canonical-package.after
                          (where f (function? f)) f
                          (where s (string? s)) #(vim.cmd s)
                          other #(error (fmt "`after` must be function or string, got %s" (type other)))
                          nil #nil)
                      _ (Package.increment-tasks-waiting canonical-package)
                      task #(let [_ (Package.decrement-tasks-waiting canonical-package)
                                  _ (Package.increment-tasks-active canonical-package)
                                  _ (task/trace "Running after")
                                  after-helpers {:trace task/trace
                                                 :path (Transaction.package-path t canonical-package)}
                                  ;; TODO propagate active to can-set
                                  result (task/await-schedule
                                           #(match (pcall (fn [] (pre) (f after-helpers)))
                                              (true _) (R.ok)
                                              (false err)
                                              (do
                                                (vim.notify (fmt "%s.after encountered an error: %s"
                                                                 canonical-package.name
                                                                 err)
                                                            vim.log.levels.ERROR)
                                                (R.err err))))
                                  _ (set canonical-package.transaction :done)
                                  _ (Package.decrement-tasks-active canonical-package)]
                              result)]
                  (task/run task {:traced #(Package.add-event canonical-package :transaction-after $)}))))
       (E.map #(task/await $))))

(λ transact-package-set [transaction canonical-set]
  (let [[canonical-package] canonical-set]
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
    result))

(fn run-transaction [runtime]
  (task/run #(result-let [t (Transaction.new runtime.datastore runtime.path.data)
                          _ (Transaction.prepare t)
                          ;; TODO topological sort these as a combined graph
                          canonical-sets (E.group-by #(values $.canonical-id $)
                                                     #(Package.iter runtime.packages))
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
                          {true ok-results false err-results} (->> (E.map #(task/await $)
                                                                          package-tasks)
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
