(import-macros {: raise : expect} :pact.error)

(fn eq? [a b]
  (match [a b]
    [{:operator ca :hash sa} {:operator cb :hash sb}]
    (and (= ca cb) (= sa sb))
    _ false))

(fn refuse []
  (raise internal "hashes may only be compared for equality"))

(fn satisfies? [base ask]
  (= base ask))

(fn new [str]
  (expect (and str (= 40 (length str)))
          argument
          (fmt "new hash constraint requires 40ch sha, got %q" str))
  (let [t {:operator "=" :hash str}]
    (setmetatable t {:__tostring #(let [{: fmt} (require :pact.common)]
                                    (fmt "%s" (string.sub $1.hash 1 8)))
                     :__eq eq?
                     :__le refuse
                     :__lte refuse})
    (values t)))

{: new : satisfies? : eq?}
