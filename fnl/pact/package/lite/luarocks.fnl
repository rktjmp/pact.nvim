(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)
(use {: ok : err : map-err : 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     inspect (or vim.inspect print)
     {: version-spec-string?} :pact.package.constraint.version
     {:format fmt} string)

(fn make [rock-name opts]
  (error "not done"))

(fn* luarocks)

(fn+ luarocks (where [rock-name] (string? rock-name))
  (luarocks rock-name ">0.0.0"))

(fn+ luarocks (where [rock-name version] (and (string? rock-name)
                                              (version-spec-string? version)))
  (luarocks rock-name {:constraint version}))

(fn+ luarocks (where [rock-name version opts] (and (string? rock-name)
                                                   (version-spec-string? version)
                                                   (table? opts)))
  (luarocks rock-name (E.merge$ opts {:constraint version})))

(fn+ luarocks (where [rock-name opts] (and (string? rock-name)
                                           (table? opts)))
  (set opts.server (or opts.server :https://luarocks.org))
  (match opts.constraint
    (where v (version-spec-string? v)) (make rock-name opts)
    _ (values nil "invalid luarocks constraint, must be version")))

{: luarocks}
