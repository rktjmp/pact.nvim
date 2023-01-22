(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use inspect :pact.inspect
     E :pact.lib.ruin.enum
     FS :pact.fs
     Log :pact.log
     {:format fmt} string)

(local Datastore {})

(set Datastore.Git (require :pact.datastore.git))
(set Datastore.Rock (require :pact.datastore.rock))

(λ Datastore.new [data-path]
  "Create datastore for given paths."
  {:path {:git (FS.join-path data-path :repos)
          :rock (FS.join-path data-path :rocks)}
   :packages {}})

(λ Datastore.package-by-canonical-id [ds canonical-id]
  ; (match (. ds :packages canonical-id)
  ;   (where t (task? t)) (task/await t)
  ;   p p
  ;   nil nil)
  (. ds :packages canonical-id))

Datastore
