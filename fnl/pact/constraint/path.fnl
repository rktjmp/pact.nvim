(import-macros {: use} :pact.vendor.donut)
(use {: 'typeof : 'defstruct} :pact.struct)

(local (new {:type path-constraint-type})
  (defstruct pact/constraint/path
    [path]
    :describe-by [path]))

(fn eq? [a b]
  (and (= path-constraint-type (typeof a) (typeof b))
       (= a.path b.path)))

(fn satisfies? [base ask]
  (eq? base ask))

{: new : satisfies? : eq? :type path-constraint-type}
