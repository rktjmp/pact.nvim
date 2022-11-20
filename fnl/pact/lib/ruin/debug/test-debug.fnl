(import-macros {: view : must : describe : it : rerequire} :test)
(local d (rerequire :debug))

(describe "inspect"
  (it "views things"
    (must match "[1 2 3]" (d.inspect [1 2 3]))
    (must match ("[1 2 3]" "1" "2" "{:a 1}") (d.inspect [1 2 3] 1 2 {:a 1}))))

