(import-macros {: raise : expect} :pact.error)

(fn eq? [a b]
  (match [a b]
    [{:operator ca :path sa} {:operator cb :path sb}] (and (= ca cb) (= sa sb))
    _ false))

(fn refuse []
  (raise internal "paths may only be compared for equality"))

(fn satisfies? [base ask]
  (= base ask))

(fn new [str]
  (expect str argument "new path constraint requires path")
  (let [t {:operator "=" :path str}]
    (setmetatable t {:__tostring #(values "path")
                     :__eq eq?
                     :__le refuse
                     :__lte refuse})
    (values t)))

{: new : satisfies? : eq?}
