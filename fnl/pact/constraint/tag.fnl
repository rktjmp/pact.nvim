(import-macros {: raise : expect} :pact.error)

(fn eq? [a b]
  (match [a b]
    [{:operator ca :tag ta} {:operator cb :tag tb}] (and (= ca cb)
                                                             (= ta tb))
    _ false))

(fn refuse []
  (raise internal "tags may only be compared for equality"))

(fn satisfies? [base ask]
  (= base ask))

(fn new [str]
  (expect str argument "new tag constraint requires tag name")
  (let [t {:operator "=" :tag str}]
    (setmetatable t {:__tostring #(let [{: fmt} (require :pact.common)]
                                     (fmt "%s" $1.tag))
                     :__eq eq?
                     :__le refuse
                     :__lte refuse})
    (values t)))

{: new : satisfies? : eq?}
