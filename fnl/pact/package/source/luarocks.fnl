(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'match-let} :pact.lib.ruin.let
     {:format fmt} string)

(λ luarocks [server-url rock-name]
  (-> [:luarocks server-url rock-name]
      (setmetatable {:__tostring #(fmt "luarocks/%s" rock-name)})))

{: luarocks}
