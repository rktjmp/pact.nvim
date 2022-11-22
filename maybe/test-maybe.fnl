(import-macros {: view : must : describe : it : rerequire} :test)
(import-macros mm :maybe)
(local m (rerequire :maybe))

(describe "creating some"
  (it "wraps one value"
    [maybe (m.some 1)]
    (must match [:some 1] maybe)
    (must equal 1 (m.unwrap maybe)))
  (it "wont wrap single nil value"
    (must throw (m.some nil)))
  (it "does not wrap multiple values"
    [maybe (m.some 1 2 3)]
    (must match [:some 1] maybe)
    (must match [1] [(m.unwrap maybe)]))
  (it "is some? and not none?"
    [maybe (m.some 1)]
    (must equal true (m.some? maybe))
    (must equal false (m.none? maybe)))
  (it "works from unit"
    [m1 (m.unit 1)
     m3 (m.unit 1 2 3)]
    (must equal true (m.some? m1))
    (must equal true (m.some? m3))))

(describe "creating none"
  (it "wraps nil value"
    [maybe (m.none nil)]
    (must match [:none] maybe)
    (must equal nil (m.unwrap maybe)))
  (it "wraps no value"
    [maybe (m.none)]
    (must match [:none] maybe)
    (must equal nil (m.unwrap maybe)))
  (it "wont wrap non-nil value"
    (must throw (m.none 1))
    (must throw (m.none nil 1)))
  (it "is none? and not some?"
    [maybe (m.none nil)]
    (must equal false (m.some? maybe))
    (must equal true (m.none? maybe)))
  (it "works from unit"
    [m1 (m.unit nil)]
    (must equal true (m.none? m1))))

(describe "let"
  (it "handles one value expressions some"
    [val (mm.maybe-let [x (values 10)
                  y (values 99)]
                 (+ x y))]
    (must equal true (m.some? val))
    (must equal (+ 10 99) (m.unwrap val)))
  (it "does handle multi value expressions"
      (must equal 30 (m.unwrap (mm.maybe-let [(x {:val y}) (values 10 {:val 20})]
                             (+ x y)))))
  (it "can NOT return multiple values"
    [(v1 v2) (mm.maybe-let [x (values 10)
                      y (values 99)]
                     (values (+ x y) (- x y)))]
    (must equal true (m.some? v1))
    (must equal nil v2)
    (must equal 109 (m.unwrap v1)))
  (it "short-circuts on error"
    (let [val (mm.maybe-let [x (values 10)
                       y (values nil)
                       z (error :dont-run-this)]
                     (+ x y))]
      (must equal true (m.none? val))
      (must equal nil (m.unwrap val)))))

(describe "let*"
  (it "handles all success"
    [val (mm.maybe-let* [x (values 10)
                   y (values 99)]
                 (+ x y))]
    (must equal 109 val))
  (it "short-circuts on error and unpacks to `nil reason`"
    [val (mm.maybe-let* [x (values 10)
                   y (values nil)
                   z (error :dont-run-this)]
                 (+ x y))]
    (must equal nil val)))

(describe "map, map-some, map-none"
  [o (m.some 100)
   e (m.none)]
  (it "maps over an some value"
    [no (m.map o #(* 2 $1))]
    (must match 100 (m.unwrap o))
    (must match 200 (m.unwrap no)))
  (it "does not map over an none value by default"
    [ne (m.map e #(* 2 $1))]
    (must match nil (m.unwrap ne)))
  (it "does map over some and none if given none-fn"
    [m-o #(* 2 $1)
     m-e #nil
     no (m.map o m-o m-e)
     ne (m.map e m-o m-e)]
    (must match 200 (m.unwrap no))
    (must match nil (m.unwrap ne)))
  (it "can alter type by return value"
    [ne (m.map o #(values nil))
     no (m.map e #(values $...) #(values :now-some))]
    (must equal true (m.none? ne))
    (must match nil (m.unwrap ne))
    (must equal true (m.some? no))
    (must match :now-some (m.unwrap no))))
