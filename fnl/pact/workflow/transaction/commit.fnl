;;; Close a transaction
;;;
;;; This can either perform the final linking in a successful transaction
;;; or remove any cruft from a failed or cancelled transaction

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

(fn* close)

(fn+ close [transaction root-path]
  ;; link the root-path/start|opt to the transaction
  (result-let [_ (or (fs.absolute-path? root-path)
                     (err (fmt "must be absolute path %s" root-path)))
               start-path (fmt "%s/start" root-path)
               opt-path (fmt "%s/opt" root-path)
               _ (yield "unlinking previous start and opt")
               _ (maybe-unlink start-path)
               _ (maybe-unlink opt-path)
               _ (yield "linking new start and opt")
               _ (fs.symlink (fmt "%s/start" transaction.path) start-path)
               _ (fs.symlink (fmt "%s/opt" transaction.path) opt-path)]
    (ok true)))

(fn+ close [transaction nil]
  ;; unlink everything
  (result-let [_ (yield "unlinking cancelled transaction")
               _ (fs.remove-path transaction.path)]
    (ok true)))

(fn* new
  (where [id transaction ?root-path])
  (new-workflow id #(close transaction ?root-path)))

{: new}
