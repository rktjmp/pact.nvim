(import-macros {: view : must : describe : it : rerequire} :test)
(local t (rerequire :type))

(describe "set and check type"
  (it "throws on missing type"
       (must throw (t.set-type {:a 10} nil)))
  (it "can set special type"
      [id :my-type-id
       x (t.set-type {:a 10} id)]
      (must be table x)
      (must match {:a 10} x)
      (must equal id (t.of x id))))

(describe "of"
  (it "can get type of normal data")
  (it "can get type of ruin data"))

(describe "is-any?"
  (it "can check data against a list of types"))

(describe "is?"
  (it "can check data against type"))

(describe "seq?"
  (it "passes []"
    (must equal true (t.seq? [])))
  (it "passes {}"
    (must equal true (t.seq? {})))
  (it "passes [1 ...]"
    (must equal true (t.seq? [1]))
    (must equal true (t.seq? [1 :abc 2 3])))
  (it "passes {1 ... :n n}"
    (must equal true (t.seq? {1 1 2 :abc 3 3 :n 3})))
  (it "fails {:a 1}"
    (must equal false (t.seq? {:a 1}))))
