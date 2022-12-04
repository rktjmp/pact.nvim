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

(fn find-impl [root known-paths]
  (result-let [all-names (->> (fs-tasks.ls-path root)
                              (enum.filter #(match? {:kind :directory} $2))
                              (enum.map #{:path (.. root :/ $2.name) :name $2.name}))
               unknown-names (enum.filter (fn [_ found] (not (enum.any? #(= found.path $2) known-paths))) all-names)]
    (ok unknown-names)))


(fn find [root known-paths]
  (if (not (absolute-path? root))
    (err (fmt "orphan search path must be absolute, got %s" root))
    (if (dir-exists? root)
      (find-impl root known-paths)
      ;; if the root doesn't exist, it can't have any orphans...
      (ok []))))

(fn* new
  (where [id root known-paths])
  (new-workflow id #(find root known-paths)))

{: new}
