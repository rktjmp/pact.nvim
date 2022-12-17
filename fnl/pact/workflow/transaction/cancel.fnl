(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     fs :pact.workflow.exec.fs
     {:format fmt} string
     {:new new-workflow : yield} :pact.workflow)

(fn maybe-unlink [path]
  (match (fs.what-is-as path)
    :link (fs.remove-path path)
    :directory (err (fmt "%s exists as a directory, refusing to continue. Please remove it"))))

(fn* cancel)

(fn+ cancel [transaction nil]
  ;; unlink everything
  (result-let [_ (yield "unlinking cancelled transaction")
               _ (fs.remove-path transaction.path)]
    (ok true)))

(fn* new
  (where [id transaction])
  (new-workflow id #(cancel transaction)))

{: new}
