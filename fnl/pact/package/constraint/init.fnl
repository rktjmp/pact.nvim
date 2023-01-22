(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     E :pact.lib.ruin.enum
     {:format fmt} string
     {: valid-version-spec?} :pact.valid)

;;; Mostly just a proxy interface to other constraints

(local M {})

(set M.version (require :pact.package.constraint.version))
(set M.git (require :pact.package.constraint.git))
(set M.luarocks (require :pact.package.constraint.luarocks))

(values M)
