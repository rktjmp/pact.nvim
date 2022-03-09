(import-macros {: raise : expect} :pact.error)

(fn eq? [a b]
  (match [a b]
    [{:operator ca :branch ba} {:operator cb :branch bb}] (and (= ca cb)
                                                             (= ba bb))
    _ false))

(fn refuse []
  (raise internal "branches may only be compared for equality"))

(fn satisfies? [base ask]
  (= base ask))

(fn new [str]
  (expect str argument "new branch constraint requires branch name")
  (let [t {:operator "=" :branch str}]
    (setmetatable t {:__tostring #(let [{: fmt} (require :pact.common)]
                                     (fmt "%s" $1.branch))
                     :__eq eq?
                     :__le refuse
                     :__lte refuse})
    (values t)))

{: new : satisfies? : eq?}
