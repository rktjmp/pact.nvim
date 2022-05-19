(import-macros {: raise : expect} :pact.error)
(import-macros {: defstruct} :pact.struct)
(local constraint (require :pact.constraint))
(local {: fmt : has-any-key?} (require :pact.common))

(local struct-type (defstruct
                     pact/provider/git
                     [id pin url]
                     :describe-by [id pin url]))

(fn e-ctx [reason]
  {:git-provider reason})

(fn url->id [url]
  (-?> url
       (string.gsub ".+://" "") ; dont catch the protocol
       (string.reverse) ; try to get anything trailing the last /
       (string.match "([^/]+)/.+")
       (string.reverse)))

(fn new [url opts]
  ;; assumes all arguments are correct
  (struct-type :id opts.id
               :url url
               :pin (match opts
                      {: hash} (constraint.hash.new hash)
                      {: tag} (constraint.tag.new tag)
                      {: branch} (constraint.branch.new branch)
                      {: version} (constraint.version.new version))))

(fn enforce-url [url]
  (when (or (not url) (= url ""))
    (raise argument (fmt "git provider missing url") (e-ctx :missing-url)))
  (when (not (= (type url) :string))
    (raise argument (fmt "git provider expecting string, got %q" (type url))
           (e-ctx :bad-url-type))))

(fn enforce-opts [opts url]
  (when (not (has-any-key? opts [:version :branch :tag :hash]))
    (raise argument (fmt "%q did not specify version, branch, tag or hash"
                         url)
           (e-ctx :missing-required-opt-key))))

(fn enforce-id [id url]
  (when (not (= (type id) :string))
    (raise argument (fmt (.. "git provider was given invalid id type (got %q) or "
                             "was unable to infer from url %q")
                         (type id) url)
           (e-ctx :invalid-id-type)))
  (when (= id "")
    (raise argument (fmt "git provider got empty id") (e-ctx :missing-id))))

(fn enforce-pinnable [opts]
  (when (not (has-any-key? opts [:hash :tag :branch :version]))
    (raise argument (fmt "must provide one of hash, tag, branch or version")
           (e-ctx :missing-pinnable)))
  (when (or (and opts.hash (has-any-key? opts [:tag :branch :version]))
            (and opts.tag (has-any-key? opts [:hash :branch :version]))
            (and opts.branch (has-any-key? opts [:hash :tag :version]))
            (and opts.version (has-any-key? opts [:hash :tag :branch])))
    (raise argument
           (fmt "must provide only one of hash, tag, branch or version")
           (e-ctx :multiple-pinnable))))

(fn git [url semver-or-opts]
  ;; The git provider will manage a git clone.
  ;; It must be given a url, and either a version spec or options table.
  ;; If no options table is given, the provider id is extracted from anything
  ;; after the last / in the url.
  (let [opts (match (type semver-or-opts)
               :string {:version semver-or-opts}
               :table semver-or-opts
               other-type (raise argument
                                 (fmt "%q expected semver string or options table, got %q"
                                      url other-type)
                                 (e-ctx :bad-arguments)))]
    ;; we may be given an id, or we will try to infer one from the url
    (tset opts :id (or opts.id (url->id url)))
    (enforce-url url)
    (enforce-opts opts url)
    (enforce-id opts.id url)
    (enforce-pinnable opts)
    (new url opts)))

{: git : is-a? :type struct-type}
