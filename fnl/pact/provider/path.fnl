;;; Path Plugin Provider
;;;
;;; A "path" plugin is "on disk", when "installing" this plugin, we simply
;;; create a symlink to the target directory.

(import-macros {: raise : expect} :pact.error)
(import-macros {: defstruct} :pact.struct)

(fn path->id [path]
  (-?> path
       (string.reverse)
       (string.match "([^/]+)/.+")
       (string.reverse)))

(local (struct {:type struct-type})
  (defstruct pact/provider/path
    [id pin path]
    :describe-by [id pin path]))

(fn path [path opts]
  (expect (not (= nil path)) argument "path provider must be given path")
  (let [{: new} (require :pact.constraint.path)
        opts (or opts {})]
    (struct :id (or opts.id (path->id path))
            :pin (new path)
            :path path)))

{: path :type struct-type}
