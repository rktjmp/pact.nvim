(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     Git :pact.workflow.exec.git
     FS :pact.workflow.exec.fs
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(fn* new
  (where [id])
  (new-workflow (fmt "transaction-rollback:%s" id) #(print :rollback)))

{: new}
