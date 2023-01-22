;;;
;;; These are the interfaces a user uses to define packages.
;;; They're more liberal in what they accept than the direct package module.
;;;

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)
(use {: ok : err : map-err : 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     inspect (or vim.inspect print)
     {: valid-version-spec?} :pact.valid
     {:format fmt} string)

(fn* git)

(fn+ git (where [url] (string? url))
  (git url {:constraint [:git :HEAD true]}))

(fn+ git (where [url constraint] (and (string? url)
                                      (string? constraint)))
  (git url {:constraint constraint}))

(fn+ git (where [url constraint opts] (and (string? url)
                                           (string? constraint)
                                           (table? opts)))
  (git url (E.merge$ opts {:constraint constraint})))

(fn+ git (where [url opts] (and (string? url)
                                (table? opts)))
  ;; try to set name automatically for forge sources, if not set
  (if (nil? opts.name)
    (let [pats ["github.com/(.+)$" "gitlab.com/(.+)$"  "git.sr.ht/~(.+)$"]
          name (E.reduce (fn [_ pat]
                           (match (string.match url pat)
                             name (E.reduced name)))
                         nil pats)]
      (set opts.name name)))
  (let [{:git make} (require :pact.package.lite.git)]
    (make url opts)))

(fn github [user-repo ...]
  (git (.. :https://github.com/ user-repo) ...))

(fn gitlab [user-repo ...]
  (git (.. :https://gitlab.com/ user-repo) ...))

(fn sourcehut [user-repo ...]
  (git (.. "https://git.sr.ht/~" user-repo) ...))

(fn srht [...]
  (sourcehut ...))

(fn* luarocks)

(fn+ luarocks (where [rock-name] (string? rock-name))
  (luarocks rock-name ">0.0.0"))

(fn+ luarocks (where [rock-name version] (and (string? rock-name)
                                              (valid-version-spec? version)))
  (luarocks rock-name {:constraint version}))

(fn+ luarocks (where [rock-name version opts] (and (string? rock-name)
                                                   (valid-version-spec? version)
                                                   (table? opts)))
  (luarocks rock-name (E.merge$ opts {:constraint version})))

(fn+ luarocks (where [rock-name opts] (and (string? rock-name)
                                           (table? opts)))
  (set opts.server (or opts.server :https://luarocks.org))
  (match opts.constraint
    (where v (version-constraint? v)) (luarocks-spec rock-name opts)
    _ (values nil "invalid luarocks constraint, must be version")))

{: git
 : github
 : gitlab
 : sourcehut :srht sourcehut}
