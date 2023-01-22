(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)
(use {: ok : err : map-err : 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     inspect (or vim.inspect print)
     {: version-spec-string?} :pact.package.version
     {:format fmt} string)

(fn make-canonical-id [server rock]
  (let [s (string.gsub server "[^%w]+" "-")
        r (string.gsub server "[^%w]+" "-")]
    (.. :rock- s :- r)))

(fn validate-name [rock-name]
  (match (string.match rock-name "[%a%d]+")
    any :ok
    nil [:error "invalid rock name"]))

(fn validate-constraint [opts]
  (match (version-spec-string? (or opts.constraint opts.version ""))
    true :ok
    false [:error "constraint must be version"]))

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
     (match-try
       (validate-name rock-name) :ok
       (validate-constraint opts) :ok
       (do
         (set opts.server (or opts.server :https://luarocks.org))
         (set opts.rock-name rock-name)
         (set opts.name (or opts.name (.. "luarocks/" rock-name)))
         (set opts.canonical-id (make-canonical-id opts.server rock-name))
         (set opts.constraint (or opts.constraint opts.version))
         (ok [:rock opts]))
       (catch
         [:error e] (err (fmt "%s %s"
                              (or rock-name "unknown-rock")
                              e))
         _ (err (fmt "%s %s"
                     (or rock-name "unknown-rock")
                     "invalid rock plugin spec")))))

{: luarocks}
