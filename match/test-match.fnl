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
    (must match false (match? {:v 3} {:v 1 :x 2}))))
