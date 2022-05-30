(import-macros {: use} :pact.vendor.donut)
(use {: 'typeof : 'defstruct} :pact.struct)

(local (new {:type tag-constraint-type})
  (defstruct pact/constraint/tag
    [tag]
    :describe-by [tag]))

(fn eq? [a b]
  (and (= tag-constraint-type (typeof a) (typeof b))
       (= a.tag b.tag)))

(fn satisfies? [base ask]
  (eq? base ask))

{: new : satisfies? : eq? :type tag-constraint-type}
