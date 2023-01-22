(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

;;; Mostly just a proxy interface to other constraints

(local M {})

(set M.version (require :pact.package.version))
(set M.git (require :pact.package.git.constraint))
(set M.luarocks (require :pact.package.luarocks.constraint))

(values M)
