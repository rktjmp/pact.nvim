;;; Path Plugin Provider
;;;
;;; A "path" plugin is "on disk", when "installing" this plugin, we simply
;;; create a symlink to the target directory.

(import-macros {: use} :pact.lib.ruin.use)

(use {: 'fn*} :pact.lib.ruin.fn
     {: string? : table?} :pact.lib.ruin.type)

(fn path->id [path]
  (-?> path
       (string.reverse)
       ;; TODO not windows safe
       (string.match "([^/]+)/.+")
       (string.reverse)))

(fn* path
  (where [local-path] (string? local-path))
  (do
    (use constraint :pact.constraint.path)
    {:id (path->id local-path)
     :path local-path
     :constraint (constraint.path local-path)})
  (where _)
  (values nil "must be called with `path`"))

{: path}
