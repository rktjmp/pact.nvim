(import-macros {: must : describe : it : view} :test)
(import-macros {: monad-let : monad-let*} :monad)
(local {: maybe-m : identity-m : state-m} (require :monad))

(local {: unpack : pack} (require :enum))

;; make simple monad for testing
(fn unit [...]
  (match [...]
    [{:is :monad}] ...
    _ {:is :monad
       :val [...]
       :n (select :# ...)}))

(fn unwrap [mon]
  (let [{: val : n} mon]
    (unpack val 1 n)))

(fn bind [x f]
  (f (unwrap x)))

(describe "let"
  (it "returns a wrapped value"
      (local val (monad-let {: bind : unit}
                        [a 10
                         b 20]
                        (+ a b)))
      (must match {:is :monad} val)
      (must equal 30 (unwrap val)))
  (it "can bind multiple values in the expression"
      (local val (monad-let {: bind : unit}
                        [(a b) (values 10 20)
                         c 10]
                        (+ a b c)))
      (must match {:is :monad} val)
      (must equal 40 (unwrap val)))
  (it "can NOT bind multiple values from the body"
      ;; because the final value is wrapped for us, any values returned by the
      ;; body will be encapsulated and so we cannot return multiple values.
      (local (v1 v2) (monad-let {: bind : unit}
                            [a 10
                             b 20]
                            (values a b)))
      (must match {:is :monad :n 2} v1)
      (must match nil v2)
      (must match [10 20] [(unwrap v1)])))

(describe "let*"
  (it "returns an unwrapped value"
      (local val (monad-let* {: bind : unit : unwrap}
                        [a 10
                         b 20]
                        (+ a b)))
      (must match 30 val))
  (it "can bind multiple values in the expression"
      (local val (monad-let* {: bind : unit : unwrap}
                        [(a b) (values 10 20)
                         c 10]
                        (+ a b c)))
      (must equal 40 val))
  (it "can bind multiple values from the body if monad supports it"
      ;; since the final encapsulated us automatically unwrapped, this
      ;; form can support multiple return values if the monad is built
      ;; to unwrap into multiple values.
      (local (v1 v2) (monad-let* {: bind : unit : unwrap}
                            [a 10
                             b 20]
                            (values a b)))
      (must match v1 10)
      (must match v2 20)))

(describe "identity-m"
  (it "works"
    (let [id (identity-m.bind 10 identity-m.result)]
      (must match 10 id))))

(describe "maybe-m"
  (it "works"
    (let [mm (maybe-m.bind 10 maybe-m.result)]
      (must match 10 mm))
    (let [mm (maybe-m.bind nil maybe-m.result)]
      (must match maybe-m.zero mm))
    (let [mm (maybe-m.bind 10 (maybe-m.plus #(+ $1 10)))]
      (must match 20 (maybe-m.result mm)))
    (let [mm (maybe-m.bind 10 (maybe-m.plus #nil))]
      (must match maybe-m.zero (maybe-m.result mm))))
  (it "lets"
      (let [v (monad-let {:bind maybe-m.bind :unit maybe-m.plus}
                [a 10
                 b 20
                 c 30]
                (+ a b c))]
        (must match 60 v))

      (let [v (monad-let {:bind maybe-m.bind :unit maybe-m.plus}
                [a 10
                 b nil
                 c 30]
                (+ a b c))]
        (must match nil v))))

(describe "state-m"
  (it "works"
      (let [compute (state-m.bind
                      (state-m.get :b)
                      #(state-m.bind
                         (state-m.set :a $1)
                         #(state-m.result $1)))
            (old-val new-state) (compute {:a :original :b :updated})]
        (must match :original old-val)
        (must match {:a :updated :b :updated} new-state))))
