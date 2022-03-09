(import-macros {: raise : expect} :pact.error)
(local types {:branch (require :pact.constraint.branch)
              :tag (require :pact.constraint.tag)
              :hash (require :pact.constraint.hash)
              :path (require :pact.constraint.path)
              :version (require :pact.constraint.version)})

(fn type [constraint]
  (match constraint
    {: tag} :tag
    {: branch} :branch
    {: major : minor : patch} :version
    {: hash} :hash
    _ (let [{: fmt} (require :pact.common)]
        (raise argument
               (fmt "unknown-constraint-type %s" (tostring constraint))))))

(fn satisfies? [base ask]
  (if (= (type base) (type ask))
    (match base
      {: branch} (types.branch.satisfies? base ask)
      {: tag} (types.tag.satisfies? base ask)
      {: hash} (types.hash.satisfies? base ask)
      {: major : minor : patch} (types.version.satisfies? base ask)
      {: path} (types.path.satisfies? base ask)
      _ (let [{: fmt} (require :pact.common)]
          (raise internal (fmt "unknown constraint: %q %q" base (type base)))))
    (values false)))

{: satisfies?
 : type
 :branch types.branch
 :tag types.tag
 :hash types.hash
 :path types.path
 :version types.version}
