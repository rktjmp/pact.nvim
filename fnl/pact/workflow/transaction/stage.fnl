;;; Stage a plugin into a transaction
;;;
;;; This means we clone the repo down if needed and create detatched worktree
;;; a particular sha. We also check if the new repo contains a packspec file
;;; and pass back either the resulting dependencies or none.
;;;
;;; This *does not* leave the package ready for use in neovim, it must be
;;; finalised when committing a transaction.
;;;
;;; A plugin *might* be staged at a particular sha  in a transaction only to be
;;; later removed due to a new constraint appearing.
;;;

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     git :pact.workflow.exec.git
     fs :pact.workflow.exec.fs
     {:format fmt} string
     {:new new-workflow : yield} :pact.workflow)

(fn clone-repo [transaction plugin]
  ;; make package path dir
  ;; clone into HEAD (blank)
  (result-let [{: package-path :source [_ source-url]} plugin
               HEAD-path  (fs.join-path package-path :HEAD)
               _ (yield (fmt "creating %s" package-path))
               _ (fs.make-path package-path)
               _ (yield (fmt "cloning %s -> %s" source-url HEAD-path))
               _ (git.clone source-url HEAD-path)]
    true))

(fn add-worktree [transaction plugin sha]
  (let [worktree-path (fs.join-path plugin.package-path sha)
        HEAD-path (fs.join-path plugin.package-path :HEAD)]
    (match (fs.dir-exists? worktree-path)
      true true
      false (git.add-worktree HEAD-path worktree-path sha))))

(fn stage [transaction plugin sha]
  (result-let [package-path plugin.package-path
               HEAD-path (fs.join-path package-path :HEAD)
               _ (or (fs.absolute-path? package-path)
                     (err (fmt "%s must be absolute path" package-path)))
               _ (match [(fs.dir-exists? package-path) (fs.dir-exists? HEAD-path)]
                   [false false] (clone-repo transaction plugin)
                   [true true] true
                   [a b] (err (fmt (.. "unexpected dir state for %s, "
                                       "exists? %s head-exists? %s, "
                                       "pact is acting cautiously, please remove %s")
                                   package-path a b package-path)))
               ;; TODO check packspec around here
               _ (add-worktree transaction plugin sha)]
    ;; new deps would be added here
    (ok [])))

(fn* new
  (where [id transaction plugin sha])
  (new-workflow id #(stage transaction plugin sha)))

{: new}
