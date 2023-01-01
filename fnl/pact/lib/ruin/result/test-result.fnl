(import-macros {: view : must : describe : it : rerequire} :test)
(import-macros m :result)
(local r (rerequire :result))

(describe "creating ok"
  (it "wraps one value"
    [result (r.ok 1)]
    (must match [:ok 1] result)
    (must equal 1 (r.unwrap result)))
  (it "wraps one nil value"
    [result (r.ok nil)]
    (must match [:ok nil] result)
    (must equal nil (r.unwrap result)))
  (it "wraps multiple values"
    [result (r.ok 1 2 3)]
    (must match [:ok 1 2 3] result)
    (must match [1 2 3] [(r.unwrap result)]))
  (it "wraps (nil any) value"
    (must match (nil :some-value) (r.unwrap (r.ok nil :some-value))))
  (it "is ok? and not err?"
    [result (r.ok 1)]
    (must equal true (r.ok? result))
    (must equal false (r.err? result)))
  (it "works from unit"
    [r1 (r.unit 1)
     r2 (r.unit nil)
     r3 (r.unit 1 2 3)]
    (must equal true (r.ok? r1))
    (must match 1 (r.unwrap r1))
    (must equal true (r.ok? r2))
    (must equal nil (r.unwrap r2))
    (must equal true (r.ok? r3))
    (must match (1 2 3) (r.unwrap r3))))

(describe "creating err"
  (it "wraps any value"
    [r1 (r.err :an-error)
     r2 (r.err nil)]
    (must match [:err :an-error] r1)
    (must match :an-error (r.unwrap r1))
    (must match [:err nil] r2)
    (must match nil (r.unwrap r2)))
  (it "wraps one value"
    (must match 1 (r.unwrap (r.err 1))))
  (it "wraps nil value"
    ;; undecided on this being a good or bad idea
    (must match nil (r.unwrap (r.err nil))))
  (it "will wrap multiple values"
    (must match [1 2 3] [(r.unwrap (r.err 1 2 3))]))
  (it "is not ok? and is err?"
    [result (r.err :bad)]
    (must equal false (r.ok? result))
    (must equal true (r.err? result)))
  (it "works from unit"
    [r1 (r.unit nil 1)
     r2 (r.unit nil nil)
     r3 (r.unit nil 1 2 3)]
    (must equal true (r.err? r1))
    (must equal true (r.err? r2))
    (must equal true (r.err? r3))))

(describe "result-let"
  (it "handles all success"
    (let [val (m.result-let [x (values 10)
                             y (values 99)]
                            (+ x y))]
      (must equal true (r.ok? val))
      (must equal (+ 10 99) (r.unwrap val)))
    (let [val (m.result-let [x (values 10 :ignored)
                      (y {:val z}) (values 99 {:val 2})]
                    (+ x y z))]
      (must equal true (r.ok? val))
      (must equal (+ 10 99 2) (r.unwrap val))))
  (it "can NOT return multiple values"
    [(v1 v2) (m.result-let [x (values 10 :ignored)
                     (y {:val z}) (values 99 {:val 2})]
                    (values (+ x y z) (- x y z)))]
    (must equal true (r.ok? v1))
    (must equal nil v2)
    (must match [111 -91] [(r.unwrap v1)]))
  (it "short-circuts on error"
    [val (m.result-let [x (values 10)
                 y (values nil "my error")
                 z (error :dont-run-this)]
                (+ x y))]
    (must equal true (r.err? val))
    (must match ("my error") (r.unwrap val))))

(describe "result-let*"
  (it "handles all success"
    [val (m.result-let* [x (values 10)
                  y (values 99)]
                 (+ x y))]
    (must equal 109 val))
  (it "can return multiple values"
    (let [val (m.result-let* [x (values 10 :ignored)
                       (y {:val z}) (values 99 {:val 2})]
                      (+ x y z))]
      (must equal (+ 10 99 2) val))
    (let [(v1 v2) (m.result-let* [x (values 10 :ignored)
                           (y {:val z}) (values 99 {:val 2})]
                          (values (+ x y z) (- x y z)))]
      (must equal (+ 10 99 2) v1)
      (must equal (- 10 99 2) v2)))
  (it "short-circuts on error and unpacks to `nil reason`"
    [(val err) (m.result-let* [x (values 10)
                        y (values nil "my error")
                        z (error :dont-run-this)]
                       (+ x y))]
    (must equal nil val)
    (must equal "my error" err)))

(describe "map, map-ok, map-err"
  [o (r.ok 100)
   e (r.err :whoops)]
  (it "maps over an ok value"
    [no (r.map o #(* 2 $1))]
    (must match 100 (r.unwrap o))
    (must match 200 (r.unwrap no)))
  (it "maps over an ok<nil> value"
    [o-nil (r.ok nil)
     no (r.map o-nil #:was-nil)]
    (must match :was-nil (r.unwrap no)))
  (it "maps over an ok<> value"
    [o-nothing (r.ok)
     no (r.map o-nothing #:was-nothing)]
    (must match :was-nothing (r.unwrap no)))
  (it "does not map over an err value by default"
    [ne (r.map e #(* 2 $1))]
    (must match :whoops (r.unwrap ne)))
  (it "does map over ok and err if given err-fn"
    [m-o #(* 2 $1)
     m-e #(values nil (.. :also- $1))
     no (r.map o m-o m-e)
     ne (r.map e m-o m-e)]
    (must match 200 (r.unwrap no))
    (must match :also-whoops (r.unwrap ne)))
  (it "can alter type by return value"
    [ne (r.map o #(values nil :now-error))
     no (r.map e #(values $...) #(values :now-ok))]
    (must equal true (r.err? ne))
    (must match :now-error (r.unwrap ne))
    (must equal true (r.ok? no))
    (must match :now-ok (r.unwrap no))))

(describe "join"
  (it "joins two ok with no value, returns ok"
    (must match [:ok nil] (r.join (r.ok) (r.ok))))

  (it "joins two ok with values, returns ok"
    (must match [:ok 1 2 nil] (r.join (r.ok 1) (r.ok 2))))

  (it "joins two ok with values, returns ok"
    (must match [:ok 1 [11 nil] 2 22 nil]
          (r.join (r.ok 1 [11]) (r.ok 2 22))))

  (it "joins two ok with some value, returns ok"
    (must match [:ok :all-good] (r.join (r.ok) (r.ok :all-good)))
    (must match [:ok :all-good] (r.join (r.ok :all-good) (r.ok))))

  (it "joins two ok with nil and some value, returns ok"
    (must match [:ok nil :all-good] (r.join (r.ok nil) (r.ok :all-good)))
    (must match [:ok :all-good nil] (r.join (r.ok :all-good) (r.ok nil))))

  (it "keeps joining values"
    (must match [:ok 1 2 3 4 nil] (r.join (r.join
                                            (r.join (r.ok 1)
                                                    (r.ok 2))
                                            (r.ok 3))
                                          (r.ok 4))))
  (it "joins two err with values, returns err"
    (must match [:err 1 2] (r.join (r.err 1) (r.err 2)))))
