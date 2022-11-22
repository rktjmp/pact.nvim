(import-macros {: use} :pact.lib.ruin.use)
(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     {: string? : table?} :pact.lib.ruin.type
     {: 'match-let} :pact.lib.ruin.let
     enum :pact.lib.ruin.enum
     {: git} :pact.provider.git
     {:format fmt} string
     {: valid-sha? : valid-version-spec?} :pact2.valid
     {:git git-constraint} :pact2.constraint.git)

(fn* make-provider
  (where [source version] (string? version))
  (make-provider source {: version})
  ;; opts should be validated by the time we call this.
  (where [source opts] (and (string? source) (table? opts)))
  (let [[key] (enum.keys opts)
        constraint (git-constraint key (. opts key))]
    {:id source
     :source [:git source]
     :constraint constraint}))

(fn* url-ok?
  (where [url] (string? url))
  (if (and (or (string.match url "^https?:") (string.match url "^ssh:"))
           (string.match url ".+://.+%..+"))
    (values true)
    (values nil (fmt "expected https or ssh url, got %s" url)))
  (where _)
  (values nil "expected https or ssh url string"))

(fn* options-ok?
  (where [version] (string? version))
  (options-ok? {: version})
  (where [opts] (table? opts))
  (match-let [keys (enum.keys opts)
              true (or (= 1 (length keys))
                       (values nil "options table must contain at most one key"))
              true (or (enum.any? #(or (= :branch $2) (= :tag $2) (= :commit $2) (= :version $2))
                                  (enum.keys opts))
                       (values nil "options table must contain branch, tag, commit or version"))]
    (match opts
      (where {: version} (valid-version-spec? version)) true
      {: version} (values nil "invalid version spec")
      (where {: commit} (valid-sha? commit)) true
      {: commit} (values nil "invalid commit sha, must be full 40 characters")
      (where {: branch} (and (string? branch) (<= 1 (length branch)))) true
      {: branch} (values nil "invalid branch, must be non-empty string")
      (where {: tag} (and (string? tag) (<= 1 (length tag)))) true
      {: tag} (values nil "invalid tag, must be non-empty string")))
  (where _)
  (values nil "expected semver constraint string or table with branch, tag, commit or version"))

(fn* user-repo-ok?
  (where [user-repo] (and (string? user-repo) (string.match user-repo ".+/.+")))
  (values true)
  (where _)
  (values nil "expected user-name/repo-name"))

;; user facing functions

(fn git [url opts]
  "Create a provider from arbitrary https or ssh url. Returns provider or nil, err"
  (match-let [true (url-ok? url)
              true (options-ok? opts)]
    (make-provider url opts)))

(fn github [user-repo opts]
  "Create github provider with user/repo. Returns provider or nil, err"
  (match-let [true (user-repo-ok? user-repo)]
    (git (.. "https://github.com/" user-repo) opts)))

(fn gitlab [user-repo opts]
  "Create gitlab provider with user/repo. Returns provider or nil, err"
  (match-let [true (user-repo-ok? user-repo)]
    (git (.. "https://gitlab.com/" user-repo) opts)))

(fn sourcehut [user-repo opts]
  "Create sourcehut provider with user/repo. Returns provider or nil, err"
  (match-let [true (user-repo-ok? user-repo)]
    (git (.. "https://git.sr.ht.com/~" user-repo) opts)))

{: github
 : gitlab
 : sourcehut :srht sourcehut
 : git}
