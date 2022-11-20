(import-macros {: view : must : describe : it : rerequire} :test)

(describe "testing framework"
  [outer {:a 10}]
  (it "test one"
      [one 1]
      (must equal 10 outer.a)
      (must equal 1 one)
      ;; must not leak
      (tset outer :a 99)
      (must equal 99 outer.a))
  (it "test two"
      [two 2]
      (must equal 10 outer.a)
      (must equal 2 two)))

