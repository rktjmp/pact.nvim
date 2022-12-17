(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     Git :pact.workflow.exec.git
     FS :pact.workflow.exec.fs
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(fn setup [path]
  (result-let [_ (FS.make-path path)
               _ (FS.make-path (FS.join-path path "start"))
               _ (FS.make-path (FS.join-path path "opt"))]
    (ok path)))

(fn* new
  (where [id path])
  (new-workflow (fmt "transaction-setup:%s" id) #(setup path)))

{: new}
