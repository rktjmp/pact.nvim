;;; Open a Pact transaction
;;;
;;; Mostly this entails creating a directory structure then passing back to
;;; another workflow to run the transaction
;;;
;;; Every transaction has its own transaction id (currently a unix timestamp for
;;; monotonically unique values , an associated folder and start/ opt/ folders
;;; inside that folder.

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     fs :pact.workflow.exec.fs
     {:format fmt} string
     {:new new-workflow : yield} :pact.workflow)

(fn open [root-path transaction-id]
  (result-let [_ (or (fs.absolute-path? root-path)
                     (err (fmt "must be absolute path: %s" root-path)))
               path (fmt "%s/%s/" root-path transaction-id)
               _ (or (not (fs.dir-exists? path))
                     (err (fmt "transaction path already exists! %s" path)))
               _ (yield (fmt "opening transaction %s" transaction-id))
               _ (fs.make-path (fmt "%s/%s" root-path transaction-id))
               _ (fs.make-path (fmt "%s/%s/start" root-path transaction-id))
               _ (fs.make-path (fmt "%s/%s/opt" root-path transaction-id))]
    (ok {:id transaction-id :path path})))

(fn* new
  (where [id root-path])
  (new-workflow id #(open root-path id)))

{: new}
