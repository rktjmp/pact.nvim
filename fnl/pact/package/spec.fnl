;;;
;;; These are the interfaces a user uses to define packages.
;;; They're more liberal in what they accept than the direct package module.
;;;

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(local {: git : github : gitlab : sourcehut} (require :pact.package.git.spec))
(local {: luarocks} (require :pact.package.luarocks.spec))

{: git
 : github
 : gitlab
 : sourcehut :srht sourcehut
 : luarocks :rock luarocks}
