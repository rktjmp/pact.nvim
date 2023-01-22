(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

;;; Mostly just a proxy interface to other constraints

(local M {})

(set M.version (require :pact.package.constraint.version))
(set M.git (require :pact.package.constraint.git))
(set M.luarocks (require :pact.package.constraint.luarocks))

(values M)
