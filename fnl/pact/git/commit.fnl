;; A commit in a Git repository
;;
;; Commits are represented as a two element list, the first element is always
;; the hash of the commit, the second element is ethir a branch or tag ref, a
;; version or a hash (for "direct pins to hash", we inclued [hash hash] for
;; QOL).

(local constraint (require :pact.constraint))

(fn new-branch [name sha]
  [(constraint.hash.new sha) (constraint.branch.new name)])

(fn new-tag [name sha]
  [(constraint.hash.new sha) (constraint.tag.new name)])

(fn new-version [semver sha]
  [(constraint.hash.new sha) (constraint.version.new semver)])

(fn new-hash [sha]
  ;; not actually created from ls-remote, as plain commits are not given, but
  ;; we do want a semi-consistent interface to the object, so this is exposed
  ;; for convenience.
  [(constraint.hash.new sha) (constraint.hash.new sha)])

(fn ref-line->commit [ref]
  ;; We want to match "<sha> refs/[head|tag]/name".
  ;; Name can have special characters in it such as othes slashes or dashes, etc
  ;; Some tags will have ^{} which indicates it's a pointer to another sha and
  ;; this should be safe to discard.
  ;; see https://git-scm.com/docs/git-check-ref-format
  ;; Parse *expects* the input to be from `ls-remote --tags --heads --ref url`
  ;; for best results.
  (match (string.match ref "(%x+)%s+refs/(.+)/(.+)")
    (sha :heads name) (new-branch name sha)
    (sha :tags name) (match (string.match name "v?(%d+%.%d+%.%d+)")
                       nil (new-tag name sha)
                       version (new-version (.. "= " version) sha))))

{: ref-line->commit : new-hash : new-tag : new-version : new-branch}
