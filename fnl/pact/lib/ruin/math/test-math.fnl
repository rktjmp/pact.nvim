(import-macros {: view : must : describe : it : rerequire} :test)
(local math (rerequire :math))

(describe "maths with words"
  (it "add"
    (must equal 1 (math.add 1 0))
    (must equal 2 (math.add 1 1))
    (must equal 3 (math.add 1 1 1)))

  (it "sub"
    (must equal 1 (math.sub 1 0))
    (must equal 0 (math.sub 1 1))
    (must equal -1 (math.sub 1 1 1)))

  (it "mul"
    (must equal 0 (math.mul 1 0))
    (must equal 2 (math.mul 1 2))
    (must equal 6 (math.mul 1 2 3)))

  (it "div"
    (must equal 1.5 (math.div 3 2))
    (must equal 2 (math.div 8 2 2))
    (must match inf (math.div 8 0)))

  (it "rem"
    (must match 1 (math.rem 3 2))
    (must match 0 (math.rem 8 2))
    (must match 8 (math.rem 8 0)))

  (it "inc"
    (must equal 1 (math.inc 0))
    (must equal 3 (math.inc 2)))

  (it "even?"
    (must equal true (math.even? 0))
    (must equal false (math.even? 1))
    (must equal true (math.even? 2)))

  (it "odd?"
    (must equal false (math.odd? 0))
    (must equal true (math.odd? 1))
    (must equal false (math.odd? 2)))
)
