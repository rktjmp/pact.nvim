;;; Path Plugin Provider
;;;
;;; A "path" plugin is "on disk", when "installing" this plugin, we simply
;;; create a symlink to the target directory.

(import-macros {: raise : expect} :pact.error)
(import-macros {: struct} :pact.struct)

(fn path->id [path]
  (-?> path
       (string.reverse)
       (string.match "([^/]+)/.+")
       (string.reverse)))

(fn path [path opts]
  (expect (not (= nil path)) argument "path provider must be given path")
  (let [{: new} (require :pact.constraint.path)
        opts (or opts {})]
    (struct pact/provider/path
            (attr id (or opts.id (path->id path)) show)
            (attr pin (new path) show)
            (attr path path show))))

{: path}
