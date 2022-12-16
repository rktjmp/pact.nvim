(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     {: valid-sha?} :pact.valid
     {:format fmt} string)

(local Commit {})

(fn Commit.abbrev-sha [sha]
  "Git abbreviate a sha differently between repos, shortest possible, so we
  manually enforce our own style"
  (string.sub sha 1 7))

(fn* expand-version
  "Convert partial versions into major.minor.patch"
  (where [v] (string.match v "^(%d+)$"))
  (.. v ".0.0")
  (where [v] (string.match v "^(%d+%.%d+)$"))
  (.. v ".0")
  (where [v] (string.match v "^(%d+%.%d+%.%d+)$"))
  (.. v)
  (where _)
  (values nil))

(fn ref->types [ref]
  ;; (.-) to minimally match inside / / but we want
  ;; (.+) to catch branches and tags with slashes in them.
  ;; note this does not distinguish "version tags"
  ;; as we need to process all tags for deref's first
  (if (= ref :HEAD)
    [:HEAD true]
    (match (string.match ref "refs/(.-)/(.+)")
      (:heads name) [:branch name]
      (:tags name) [:tag name]
      _ (error (string.format "unexpected ref format: %s" ref)))))

(fn match-relaxed-version? [str]
  ;; match vM.m.p M.m.p vM.m M.m vM and expand to full version
  (let [patterns ["^v?(%d+%.%d+%.%d+)$" "^v?(%d+%.%d+)$" "^v(%d+)$"]]
    (E.reduce #(match (string.match str $3)
                 any (E.reduced any))
              nil patterns)))

(fn to-string [c]
  (let [join (fn [prefix list]
               (if (not (E.empty? list))
                 (fmt "(%s)"
                      (-> (E.map (fn [_  name] (fmt "%s%s" prefix name)) list)
                          (table.concat " ")
                          ))
                 ""))]
    (E.reduce #(.. $1 (join (match $3
                              :versions :v
                              :branches ""
                              :tags :#)
                            (. c $3)))
              (fmt "%s@" (if c.HEAD? "HEAD" c.short-sha))
              [:versions :branches :tags])))

(fn* Commit.new
  (where [sha] (valid-sha? sha))
  (Commit.new sha [])
  (where [sha data] (and (valid-sha? sha)))
  (->> data
       (E.map #(match $2
                 [:tag t] [:tags t]
                 [:branch b] [:branches b]
                 [:version v] [:versions (expand-version v)]
                 ;; HACK: when we look for ^{} deref's we convert
                 ;; to head@true for the lookup key (simpler find
                 ;; by string instead of compare table values), this is
                 ;; fine for other types as they just have strings anyway
                 ;; but here we need to match true (which is what should be
                 ;; passed for construction normally) and "true" for that
                 ;; specific internal edge case.
                 (where [:HEAD h] (or (= h true) (= h :true))) [:HEAD true]
                 ;; todo: reimplement validation of version numbers?
                 ; (where [:version v] (not (match-relaxed-version? v)))
                 ; (error (fmt "invalid version specification %s" v))
                 _ (error (fmt "unknown commit data: %s" (vim.inspect $2)))))
       (E.reduce #(match $3
                    [:HEAD true] (E.set$ $1 :HEAD? true)
                    [where what] (do (E.append$ (. $1 where) what) $1)
                    _ (error (fmt "unsuported data %s" $3)))
                 {:sha sha :short-sha (Commit.abbrev-sha sha)
                  :tags []
                  :branches []
                  :versions []})
       ;; need function as ->> -> misbehaves or at least does no function as expected
       (#(setmetatable $1 {:__tostring to-string})))
  (where _)
  (values nil "commit requires a valid sha and optional list of tags, branches or versions"))

(fn Commit.remote-refs->commits [refs]
  "Convert list of ref lines into list of commits. When tag and peeled tag
  (one with ^{} suffix) are present, the peeled tag is retained and the plain
  tag is discarded."
  ;; We want to match "<sha> refs/[head|tags]/name".
  ;; Name can have special characters in it such as othes slashes or dashes, etc
  ;;
  ;; Some tags will have ^{} appended, AFAIK these always come in pairs, with a
  ;; "tag" and "peeled tag" (with ^{}). Not all repos/tags have these pairs.
  ;;
  ;; Peeled tags's SHAs match the actual commit object for that tag, where as
  ;; the plain tag may point to an annotation object that routes to the commit.
  ;;
  ;; When checking out a tag, we always checkout the peeled one (AFAICT), so we
  ;; generally only want to operate with peeled tags/direct commits
  ;; (when finding tags/versions etc)
  ;;
  ;; see https://git-scm.com/docs/git-check-ref-format
  ;; Parse *expects* the input to be from `ls-remote <origin|http> tags/* heads* HEAD`.
  (->> refs
       ;; group by sha -> [refs] (sha may point to n-refs)
       (E.group-by #(string.match $2 "(%x+)%s+(.+)"))
       ;; flip to [:branch|tag|ver ..] -> sha
       (E.reduce (fn [acc sha refs]
                   ;; Change type name to type@name for simpler searching since
                   ;; we will need to lookup on (.. name "^{}").
                   ;; This gives us
                   ;; branch@main sha1
                   ;; tag@t-1     sha1
                   ;; tag@t-1^{}  sha2
                   ;; We can then easily lookfor / resolve ^{} tag pairs by
                   ;; just looking for the tag + ^{}.
                   (->> (E.map #(fmt "%s@%s" (unpack (ref->types $2))) refs)
                        (E.reduce #(E.set$ $1 $3 sha) acc)))
                 {})
       ;; Now drop any tags that have a deref'd name as we dont need them.
       ;; When checking out a tag git will automatically dereference it, so
       ;; later when we ask about the checkout state we will get the deref'd
       ;; version back anyway.
       ((fn [data]
          (E.reduce (fn [acc ref sha]
                      (match ref
                        ;; only need to touch tags
                        (where name (string.match name "^tag@"))
                        (if (not (. data (.. name "^{}")))
                          (E.set$ acc ref sha)
                          acc)
                        ;; otherwise just keep
                        _ (E.set$ acc ref sha)))
                    {} data)))
       ;; strip off ^{} deref marker as we're done looking at it
       (E.reduce #(E.set$ $1 (string.gsub $2 "%^{}$" "") $3) {})
       ;; now un-munge the types ...
       (E.reduce #(E.set$ $1 [(string.match $2 "(.+)@(.+)")] $3) {})
       ;; and duplicate any tags that look like versions
       (E.reduce #(do
                    (match $2
                      [:tag t] (match (match-relaxed-version? t)
                                 ver (E.set$ $1 [:version (expand-version ver)] $3)))
                    (E.set$ $1 $2 $3))
                 {})
       ;; now collate refs under shas
       (E.group-by #(values $2 $1))
       ;; and construct actual commits
       (E.map (fn [sha data] (Commit.new sha data)))))

(fn Commit.local-refs->commits [refs]
  ;; git show-ref wont collate local and remote branches, but generally we only
  ;; want to look at the remote ones, which we'll call "remote commits".
  ;; tags are shown the same regardless of origin.
  ;; strip out any local heads
  (->> refs
       ;; drop any local heads, they should not matter
       (E.filter #(not (string.match $2 "%srefs/heads.+$")))
       ;; rename remote heads to local, which is actually what ls-remote views remotes as
       (E.map #(string.gsub $2 "%srefs/remotes/origin" " refs/heads"))
       ;; also rename refs/heads/HEAD to HEAD
       (E.map #(string.gsub $2 "%srefs/heads/HEAD$" " HEAD"))
       ;; now just act as remotes
       (Commit.remote-refs->commits)))

Commit
