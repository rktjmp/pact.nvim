(import-macros {: use} :pact.lib.ruin.use)
(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     {: string? : table?} :pact.lib.ruin.type
     enum :pact.lib.ruin.enum
     {:format fmt} string
     {: valid-sha? : valid-version-spec?} :pact2.valid)


(fn one-of? [coll test]
  (enum.any? #(= $2 test) coll))

(fn* git?
  ;; we don't currently (?) check validity of contents, just shape
  (where [[:git kind spec]] (and (one-of? [:commit :branch :tag :version] kind)
                                 (string? spec)))
  true
  (where _)
  false)

(fn* git
  "Create a git constraint, which may match against a commit, tag, branch or
  version. A sha may optionally be given, if one is known which realises the
  constraint to an actual git commit for comparing a remote vs local constraint.")

(fn+ git [:version ver]
  (match (valid-version-spec? ver)
    true [:git :version ver]
    false (values nil "invalid version spec for version constraint")))

(fn+ git [:commit sha]
  (match (valid-sha? sha)
    true [:git :commit sha]
    false (values nil "invalid sha for commit constraint")))

(fn+ git [kind spec] (one-of? [:branch :tag] kind)
  (match (string? spec)
    true [:git kind spec]
    false (values nil (fmt "invalid spec for %s constraint" kind))))

(fn+ git [...]
  (values nil "must provide `commit|branch|tag|version` and appropriate value" ...))

(fn* satisfies?
  (where [[:git :commit sha] {: sha}])
  true
  (where [[:git :tag tag] {: tag}])
  true
  (where [[:git :branch branch] {: branch}])
  true
  (where [[:git :version version-spec] {: version}])
  (let [{: satisfies?} (require :pact2.constraint.version)]
    (satisfies? version-spec version))
  (where [[:git _ _] {: sha}])
  false
  (where _)
  (error "satisfies? requires constraint and commit"))

{: git : git? : satisfies?}
