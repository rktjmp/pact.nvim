(import-macros {: use} :pact.vendor.donut)
(use {: 'typeof : 'defstruct} :pact.struct)

(local (new {:type hash-constraint-type})
  (defstruct pact/constraint/hash
    [hash]
    :describe-by [hash]))

(fn eq? [a b]
  (and (= hash-constraint-type (typeof a) (typeof b))
       (= a.hash b.hash)))

(fn satisfies? [base ask]
  (eq? base ask))

{: new : satisfies? : eq? :type hash-constraint-type}
