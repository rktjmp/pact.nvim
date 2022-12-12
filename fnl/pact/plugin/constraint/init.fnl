(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     {: string? : table?} :pact.lib.ruin.type
     E :pact.lib.ruin.enum
     {:format fmt} string
     {: valid-sha? : valid-version-spec?} :pact.valid)

(local Constraint {})

(fn one-of? [coll test]
  (E.any? #(= $2 test) coll))

(fn set-tostring [t]
  (setmetatable t {:__tostring
                   (fn [[_ kind spec]]
                     (.. kind "#" (string.gsub spec "%s" "")))}))

(fn Constraint.constraint? [c]
  (match? [:git any-1 any-2] c))

(fn Constraint.commit? [c]
  (match? [:git :commit any] c))

(fn Constraint.tag? [c]
  (match? [:git :tag any] c))

(fn Constraint.branch? [c]
  (match? [:git :branch any] c))

(fn Constraint.version? [c]
  (match? [:git :version any] c))

(fn Constraint.type [c]
  (match c
    [:git x _] x))

(fn Constraint.value [c]
  (match c
    [:git kind val] val
    _ (error "could not get constraint value!")))

(fn* Constraint.git?
  ;; we don't currently (?) check validity of contents, just shape
  (where [[:git kind spec]] (and (one-of? [:commit :branch :tag :version] kind)
                                 (string? spec)))
  true
  (where _)
  false)

(fn* Constraint.git
  "Create a git constraint, which may match against a commit, tag, branch or
  version. A sha may optionally be given, if one is known which realises the
  constraint to an actual git commit for comparing a remote vs local constraint.")

(fn+ Constraint.git [:version ver]
  (match (valid-version-spec? ver)
    true (set-tostring [:git :version ver])
    false (values nil "invalid version spec for version constraint")))

(fn+ Constraint.git [:commit sha]
  (match (valid-sha? sha)
    true (set-tostring [:git :commit sha])
    false (values nil "invalid sha for commit constraint")))

(fn+ Constraint.git [kind spec] (one-of? [:branch :tag] kind)
  (match (string? spec)
    true (set-tostring [:git kind spec])
    false (values nil (fmt "invalid spec for %s constraint, must be string" kind))))

(fn+ Constraint.git [...]
  (values nil "must provide `commit|branch|tag|version` and appropriate value" ...))

(fn* Constraint.satisfies?
  (where [[:git :commit sha] {: sha}])
  true
  (where [[:git :tag tag] commit])
  (E.any? #(= tag $2) commit.tags)
  (where [[:git :branch branch] commit])
  (E.any? #(= branch $2) commit.branches)
  (where [[:git :version version-spec] commit])
  (let [{: satisfies?} (require :pact.plugin.constraint.version)]
    (E.any? #(satisfies? version-spec $2) commit.versions))
  (where [[:git _ _] {: sha}])
  false
  (where _)
  (error "satisfies? requires constraint and commit"))

(fn* Constraint.solve
  "Given a constraint and list of commits, return best fitting commit")

(fn+ Constraint.solve
  (where [constraint commits] (and (Constraint.version? constraint) (seq? commits)))
  (let [{: solve} (require :pact.plugin.constraint.version)
        spec (Constraint.value constraint)
        ;; version solve can already take n-versions
        possible-versions (-> (E.map #$2.versions commits)
                              (E.flatten))
        best-version (-> (solve spec possible-versions)
                         (E.first))]
    (if best-version
      ;; this **should** only give us one commit, as you cant give the same
      ;; tag (so version) to multiple commits - not without trying very hard.
      ;; so the "best version" should only exist on one commit
      (E.reduce (fn [?commit _ commit]
                  (if (E.any? #(= best-version $2) commit.versions)
                    (E.reduced commit)))
                nil commits))))

(fn+ Constraint.solve
  (where [constraint commits] (and (Constraint.constraint? constraint) (seq? commits)))
  (E.find-value #(Constraint.satisfies? constraint $2) commits))

(values Constraint)
