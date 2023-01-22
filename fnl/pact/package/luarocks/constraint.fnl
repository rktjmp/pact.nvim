(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     E :pact.lib.ruin.enum
     {:format fmt} string
     {: version-spec-string?} :pact.package.version)

(local M {})

(fn M.version [constraint]
  [:luarocks :version constraint])

(values M)
