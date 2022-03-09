(import-macros {: raise : expect} :pact.error)
(local {: fmt : has-all-keys? : has-any-key?} (require :pact.common))
(local is-a-type :provider)

(fn is-a? [given ?provider]
  (if ?provider
      (and (= given.is-a is-a-type) (= given.provider ?provider))
      (= given.is-a is-a-type)))

(fn new [opts]
  (expect (has-all-keys? opts [:id :provider]) argument
          (fmt "provider.new must be given id and provider"))
  (tset opts :is-a is-a-type)
  (values opts))

(fn make-commit-pin [sha]
  (expect (and sha (= 40 (length sha))) argument
          (fmt "make-commit-pin require 40ch sha, got %q" sha))
  (let [{: new} (require :pact.constraint.commit)]
    (new sha)))

(fn make-branch-pin [branch]
  (expect branch argument "make-branch-pin requires branch name")
  (let [{: new} (require :pact.constraint.branch)]
    (new branch)))

(fn make-tag-pin [tag]
  (expect tag argument "make-tag-pin requires tag name")
  (let [{: new} (require :pact.constraint.tag)]
    (new tag)))

(fn make-version-pin [version]
  (expect version argument "make-version-pin requires version")
  (let [{: new} (require :pact.constraint.version)]
    (new version)))


{: new
 : is-a?
 : make-tag-pin
 : make-path-pin
 : make-branch-pin
 : make-commit-pin
 : make-version-pin}
