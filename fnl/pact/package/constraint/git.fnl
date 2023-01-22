(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     E :pact.lib.ruin.enum
     {:format fmt} string
     {: version-spec-string?} :pact.package.constraint.version)

(local M {})

(fn make [kind val]
  (let [tos (fn [[a b c]] (fmt "(constraint %s %s %s)" a b c))]
    (setmetatable [:git kind val] {:__tostring tos
                                   :__fennelview tos
                                   :__eq M.equal?
                                   :__index {:git? true
                                             :type kind
                                             :value val}})))

(fn M.head [] [:git :head true])

(fn M.version [ver]
  (if (version-spec-string? ver)
    (make :version ver)
    (values nil "invalid version spec for version constraint")))

(fn M.version? [c]
  (match? [:git :version any] c))

(fn M.head []
  (make :head true))

(fn M.head? [c]
  (match? [:git :head any] c))

(fn M.commit [sha]
  (let [{: valid-sha?} (require :pact.git.commit)]
    (if (valid-sha? sha)
      (make :commit sha)
      (values nil "invalid sha for commit constraint, must be 7-40 characters"))))

(fn M.commit? [c]
  (match? [:git :commit any] c))

(fn tag-or-branch [what v]
  (if (and (string? v) (string.match v "^[^%s]+$"))
    (make what v)
    (values nil (fmt "invalid %s, must be string and contain no whitespace" what))))

(fn M.tag [tag]
  (tag-or-branch :tag tag))

(fn M.tag? [c]
  (match? [:git :tag any] c))

(fn M.branch [branch]
  (tag-or-branch :branch branch))

(fn M.branch? [c]
  (match? [:git :branch any] c))

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

(fn M.constraint? [c]
  (match? [:git any-1 any-2] c))

(fn M.equal? [a b]
  (match [a b]
    [[kind how what] [kind how what]] true
    _ false))

(fn M.git? [c]
  (match c
    (where (or [:git :head any]
               [:git :commit any]
               [:git :version any]
               [:git :tag any]
               [:git :branch any])) true
    _ false))

(fn M.type [c]
  (match c
    [:git x _] x))

(fn M.value [c]
  (match c
    [:git kind val] val
    _ (error "could not get constraint value!")))

(fn* M.satisfies?
  (where [[:git :commit sha] commit])
  (not-nil? (string.match commit.sha (fmt "^%s" sha)))
  (where [[:git :tag tag] commit])
  (E.any? #(= tag $) commit.tags)
  (where [[:git :branch branch] commit])
  (E.any? #(= branch $) commit.branches)
  (where [[:git :version version-spec] commit])
  (let [{: satisfies?} (require :pact.package.constraint.version)]
    (E.any? #(satisfies? version-spec $) commit.versions))
  (where [[:git :head _] commit])
  (= true commit.HEAD?)
  (where [[:git _ _] {: sha}])
  false
  (where _)
  (error "satisfies? requires constraint and commit"))

(fn* M.solve
  "Given a constraint and list of commits, return *best fitting* commit, where
  this is the latest version for version constraints.")

(fn+ M.solve
  (where [constraint commits] (and (M.version? constraint) (seq? commits)))
  (let [{: solve} (require :pact.package.constraint.version)
        spec (M.value constraint)
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

(fn+ M.solve
  (where [constraint commits] (and (M.constraint? constraint) (seq? commits)))
  (E.find #(M.satisfies? constraint $) commits))

(values M)
