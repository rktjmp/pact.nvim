(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     Git :pact.workflow.exec.git
     FS :pact.workflow.exec.fs
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(fn* new
  (where [id transaction-path head-path])
  (new-workflow (fmt "transaction-commit:%s" id)
                #(result-let [_ (yield "swapping transaction head")
                              _ (vim.loop.fs_unlink head-path)
                              _ (FS.symlink transaction-path head-path)]
                   (ok))))

{: new}
