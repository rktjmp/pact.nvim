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

(λ Datastore.package-by-canonical-id [ds canonical-id]
  ; (match (. ds :packages canonical-id)
  ;   (where t (task? t)) (task/await t)
  ;   p p
  ;   nil nil)
  (. ds :packages canonical-id))


Datastore
