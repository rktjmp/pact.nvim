(import-macros {: describe : it : must : rerequire} :pact.lib.ruin.test)

(local _ (rerequire :pact2.valid))
(local {: satisfies? : solve} (rerequire :pact2.constraint.version))

(describe "version constraint"
  (it "works with strings"
    (must match true (satisfies? "= 1.0.0" "1.0.0"))
    (must match false (satisfies? "> 1.0.0" "1.0.0"))
    (must match true (satisfies? "~ 1.1.0" "1.1.1"))))

(local versions [:1.1.0 :0.9.1 :1.2.0 :1.2.99 :1.2.9 :1.4.0])
(describe "solve constraint"
  (it "works with one spec"
    (must match [:1.4.0 :1.2.99 :1.2.9 :1.2.0]
          (solve ">= 1.2.0" versions)))
  (it "works with many specs"
    (must match [:1.2.99 :1.2.9 :1.2.0]
          (solve [">= 1.2.0" "<= 1.3.0"] versions))))
