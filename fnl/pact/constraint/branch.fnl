(import-macros {: use} :pact.vendor.donut)
(use {: 'typeof : 'defstruct} :pact.struct)

(local (new {:type branch-constraint-type})
  (defstruct pact/constraint/branch
    [branch]
    :describe-by [branch]))

(fn eq? [a b]
  (and (= branch-constraint-type (typeof a) (typeof b))
       (= a.branch b.branch)))

(fn satisfies? [base ask]
  (eq? base ask))

{: new : satisfies? : eq? :type branch-constraint-type}
