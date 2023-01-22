;;;
;;; These are the interfaces a user uses to define packages.
;;; They're more liberal in what they accept than the direct package module.
;;;

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)
(use {: ok : err : map-err : 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     inspect (or vim.inspect print)
     {: version-spec-string?} :pact.package.constraint.version
     {:format fmt} string)

(local {: git : github : gitlab : sourcehut} (require :pact.package.lite.git))
(local {: luarocks} (require :pact.package.lite.luarocks))

{: git
 : github
 : gitlab
 : sourcehut :srht sourcehut}
