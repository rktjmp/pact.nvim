(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     E :pact.lib.ruin.enum
     {:format fmt} string
     {: valid-version-spec?} :pact.valid)

(local Constraint {})

(fn one-of? [coll test]
  (E.any? #(= $ test) coll))

(fn set-tostring [t]
  (setmetatable t {:__tostring
                   (fn [[_ kind spec]]
                     (let [datum (match kind
                                   :head :HEAD
                                   :commit (let [{: abbrev-sha} (require :pact.git.commit)]
                                             (abbrev-sha spec))
                                   any spec)
                           name (match kind
                                  :commit ""
                                  :tag :#
                                  :version ""
                                  :branch ""
                                  :head ""
                                  _ "??")]
                       ;; strip possible spaces from version spec
                       (.. name (string.gsub datum "%s" ""))))}))

(fn Constraint.constraint? [c]
  (match? [:git any-1 any-2] c))

(fn Constraint.equal? [ca cb]
  (match [ca cb]
    [[kind how what] [kind how what]] true
    _ false))

(fn Constraint.commit? [c]
  (match? [:git :commit any] c))

(fn Constraint.tag? [c]
  (match? [:git :tag any] c))

(fn Constraint.branch? [c]
  (match? [:git :branch any] c))

(fn Constraint.version? [c]
  (match? [:git :version any] c))

(fn Constraint.head? [c]
  (match? [:git :head _] c))

(fn Constraint.type [c]
  (match c
    [:git x _] x))

(fn Constraint.value [c]
  (match c
    [:git kind val] val
    _ (error "could not get constraint value!")))

(fn* Constraint.git?
  ;; we don't currently (?) check validity of contents, just shape
  (where [[:git kind spec]] (and (one-of? [:head :commit :branch :tag :version] kind)
                                 (string? spec)))
  true
  (where _)
  false)

(fn* Constraint.git
  "Create a git constraint, which may match against a commit, tag, branch,
  version or head.")

(fn+ Constraint.git [:version ver]
  (match (valid-version-spec? ver)
    true (set-tostring [:git :version ver])
    false (values nil "invalid version spec for version constraint")))

(fn+ Constraint.git [:head]
  (set-tostring [:git :head true]))

(fn valid-sha? [sha]
  ;; we allow 7-40 chars in a commit spec
  (and (string? sha)
       (let [len (or (-?> (string.match sha "^(%x+)$") (length)) 0)]
         (and (<= 7 len) (<= len 40)))))

(fn+ Constraint.git [:commit sha]
  (match (valid-sha? sha)
    true (set-tostring [:git :commit sha])
    false (values nil "invalid sha for commit constraint, must be 7-40 characters")))

(fn+ Constraint.git [kind spec] (one-of? [:branch :tag] kind)
  (match (string? spec)
    true (set-tostring [:git kind spec])
    false (values nil (fmt "invalid spec for %s constraint, must be string" kind))))

(fn+ Constraint.git [...]
  (values nil "must provide `commit|branch|tag|version` and appropriate value" ...))

(fn* Constraint.satisfies?
  (where [[:git :commit sha] commit])
  (not-nil? (string.match commit.sha (fmt "^%s" sha)))
  (where [[:git :tag tag] commit])
  (E.any? #(= tag $) commit.tags)
  (where [[:git :branch branch] commit])
  (E.any? #(= branch $) commit.branches)
  (where [[:git :version version-spec] commit])
  (let [{: satisfies?} (require :pact.plugin.constraint.version)]
    (E.any? #(satisfies? version-spec $) commit.versions))
  (where [[:git :head _] commit])
  (= true commit.HEAD?)
  (where [[:git _ _] {: sha}])
  false
  (where _)
  (error "satisfies? requires constraint and commit"))

(fn* Constraint.solve
  "Given a constraint and list of commits, return *best fitting* commit, where
  this is the latest version for version constraints.")

(fn+ Constraint.solve
  (where [constraint commits] (and (Constraint.version? constraint) (seq? commits)))
  (let [{: solve} (require :pact.plugin.constraint.version)
        spec (Constraint.value constraint)
        ;; version solve can already take n-versions
        possible-versions (-> (E.map #$.versions commits)
                              (E.flatten))
        best-version (-> (solve spec possible-versions)
                         (E.first))]
    (if best-version
      ;; this **should** only give us one commit, as you cant give the same
      ;; tag (so version) to multiple commits - not without trying very hard.
      ;; so the "best version" should only exist on one commit
      (E.reduce (fn [?commit commit]
                  (if (E.any? #(= best-version $) commit.versions)
                    (E.reduced commit)))
                nil commits))))

(fn+ Constraint.solve
  (where [constraint commits] (and (Constraint.constraint? constraint) (seq? commits)))
  (E.find #(Constraint.satisfies? constraint $) commits))

(values Constraint)
