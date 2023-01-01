(import-macros {: view : must : describe : it : rerequire} :test)
(import-macros {: match? } :match)

(describe "match?"
  (it "matches"
    (must match true (match? true true))
    (must match true (match? "hello" "hello"))
    (must match true (match? any "hello"))
    (must match true (match? not-nil 1))
    (must match false (match? not-nil nil))
    (must match true (match? {:v 1} {:v 1 :x 2}))
    (must match false (match? {:v 3} {:v 1 :x 2})))
  (it "pins"
    (must match true (let [x 10]
                       (match? {:x x} {:x 10})))
    (must match false (let [x 10]
                       (match? {:x x} {:x 11})))

    (must match true (let [x {:id :correct}]
                       (match? {:id x.id} {:id :correct})))

    (must match true (let [data {:id :correct}
                           given {:id :correct}]
                       (match? {:id data.id} given)))))
