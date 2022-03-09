;; Internal pipeline provider between "git services" and raw git urls

(import-macros {: raise : expect} :pact.error)
(local {: git} (require :pact.provider.git))
(local {: fmt} (require :pact.common))

(fn e-ctx [host reason]
  {(.. (or host :host-missing) :-provider) reason})

(fn enforce-string-argument [arg-name arg-value ?host]
  (when (or (not arg-value) (= arg-value ""))
    (raise internal (fmt "git-host provider missing %s" arg-name)
                    (e-ctx ?host (fmt "missing-%s" arg-name))))
  (when (not (= (type arg-value) :string))
    (raise internal (fmt "git-host provider expecting string %s, got %q"
                         arg-name (type arg-value))
                    (e-ctx ?host (fmt "bad-%s-type" arg-name)))))

(fn enforce-host [host]
  (enforce-string-argument :host host host))

(fn enforce-prefix [prefix ?host]
  (enforce-string-argument :prefix prefix ?host))

(fn enforce-user-repo [user-repo ?host]
  (enforce-string-argument :user-repo user-repo ?host)
  ;; This is maybe a bit "greedy", as it may fail for some esoteric urls that
  ;; include weird unicode or whatever. In those cases people could use the git
  ;; provider directly.
  (when (not (string.match user-repo "^[%a%d%.-_]+/[%a%d%.-_]+$"))
    ;; argument error instead of internal error as this comes from the user
    (raise argument (fmt "%s provider expects \"user/repo\" but got %q" ?host
                         user-repo)
                    (e-ctx ?host :malformed-user-repo))))

(fn user-repo->id [user-repo]
  (string.match user-repo ".+/(.+)"))

(fn prefix-user-repo->url [prefix user-repo]
  (.. prefix user-repo))

(fn git-host [host prefix user-repo semver-or-opts]
  (enforce-host host)
  (enforce-prefix prefix host)
  (enforce-user-repo user-repo host)
  (local url (prefix-user-repo->url prefix user-repo))
  (let [opts (match (type semver-or-opts)
               :table semver-or-opts
               :string {:version semver-or-opts :id (user-repo->id user-repo)}
               any-other
               (raise argument (fmt "%s %s expected semver string or options table, got %q"
                                    host user-repo any-other)
                               (e-ctx host :bag-argument)))]
    (tset opts :id (or opts.id (user-repo->id user-repo)))
    (tset opts :provided-via :host)
    (git url opts)))

{: git-host}
