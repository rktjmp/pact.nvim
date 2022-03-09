;;; Path Plugin Provider
;;;
;;; A "path" plugin is "on disk", when "installing" this plugin, we simply
;;; create a symlink to the target directory.

(import-macros {: raise : expect} :pact.error)
(local provider (require :pact.provider.base))
(local {: fmt : has-any-key?} (require :pact.common))
(local provider-type :path)

(fn path->id [path]
  (-?> path
       (string.reverse)
       (string.match "([^/]+)/.+")
       (string.reverse)))

(fn is-a? [given]
  (provider.is-a? given provider-type))

(fn path [path opts]
  (expect (not (= nil path)) argument "path provider must be given path")
  (let [{: new} (require :pact.constraint.path)
        opts (or opts {})]
    (provider.new {:id (or opts.id (path->id path))
                   :pin (new path)
                   : path
                   :provider provider-type})))

{: path : is-a?}
