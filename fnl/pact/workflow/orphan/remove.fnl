(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     enum :pact.lib.ruin.enum
     git-tasks :pact.workflow.exec.git
     fs-tasks :pact.workflow.exec.fs
     {:format fmt} string
     {:new new-workflow : yield} :pact.workflow)

(fn absolute-path? [path]
  (not-nil? (string.match path "^/")))

(fn dir-exists? [path]
  (= :directory (fs-tasks.what-is-at path)))

(fn remove [path]
  (if (not (absolute-path? path))
    (err (fmt "remove path must be absolute, got %s" path))
    (if (dir-exists? path)
      (do
        (print "remove-path" path)
        (fs-tasks.remove-path path)
        (ok path))
      ;; if the path doesn't exist, it can't have any orphans...
      (err (fmt "cant remove dir, it does not exist! %s" path)))))

(fn* new
  (where [id path])
  (new-workflow id #(remove path)))

{: new}
