(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(import-macros {: use} :pact.lib.ruin.use)
(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     {: string? : table?} :pact.lib.ruin.type
     enum :pact.lib.ruin.enum
     _ :pact.plugin.constraint.version
     {:format fmt} string
     {: valid-sha? : valid-version-spec?} :pact.valid)

(fn one-of? [coll test]
  (enum.any? #(= $2 test) coll))

(fn set-tostring [t]
  (setmetatable t {:__tostring
                   (fn [[_ kind spec]]
                     (.. kind "#" (string.gsub spec "%s" "")))}))

(fn constraint? [c]
  (match? [:git any-1 any-2] c))

(fn commit? [c]
  (match? [:git :commit any] c))

(fn tag? [c]
  (match? [:git :tag any] c))

(fn branch? [c]
  (match? [:git :branch any] c))

(fn version? [c]
  (match? [:git :version any] c))

(fn value [c]
  (match c
    [:git kind val] val
    _ (error "could not get constraint value!")))

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
    true (set-tostring [:git :version ver])
    false (values nil "invalid version spec for version constraint")))

(fn+ git [:commit sha]
  (match (valid-sha? sha)
    true (set-tostring [:git :commit sha])
    false (values nil "invalid sha for commit constraint")))

(fn+ git [kind spec] (one-of? [:branch :tag] kind)
  (match (string? spec)
    true (set-tostring [:git kind spec])
    false (values nil (fmt "invalid spec for %s constraint, must be string" kind))))

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
  (let [{: satisfies?} (require :pact.plugin.constraint.version)]
    (satisfies? version-spec version))
  (where [[:git _ _] {: sha}])
  false
  (where _)
  (error "satisfies? requires constraint and commit"))

(fn* solve
  "Given a constraint and list of commits, return best fitting commit")

(fn+ solve
  (where [[:git :commit sha] commits] (seq? commits))
  (enum.find-value #(= sha $2.sha) commits))

(fn+ solve
  (where [[:git :tag tag] commits] (seq? commits))
  (enum.find-value #(= tag $2.tag) commits))

(fn+ solve
  (where [[:git :branch branch] commits] (seq? commits))
  (enum.find-value #(= branch $2.branch) commits))

(fn+ solve
  (where [[:git :version version] commits] (seq? commits))
  (let [{: solve} (require :pact.plugin.constraint.version)
        possible-versions (enum.map #$2.version commits)
        best-version (-> (solve version possible-versions)
                         (enum.first))]
    (if best-version
      (enum.find-value #(= best-version $2.version) commits))))

{: git : git? : satisfies? : solve
 : constraint? : commit? : branch? : tag? : version?
 : value}
