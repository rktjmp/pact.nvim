(import-macros {: must : describe : it} :test)
(import-macros {: def-either} :either)
(import-macros {: monad-let : monad-let*} :monad)

(local pr
  (def-either {:name :p-result
                :left {:id :p-result-err
                       :name :err
                       :unit {:match [false]
                              :value (unpack arguments 2 arguments.n)}
                       :cons {:match arguments
                              :value (unpack arguments)}}
                :right {:id :p-result-ok
                        :name :ok
                        :unit {:match [true _]
                               :value (unpack arguments 2 arguments.n)}
                        :cons {:match arguments
                               :value (unpack arguments)}}}))

(fn sketchy [x]
  (if x true (error "failure" 0)))

(describe "either"
  (it "generates oks"
    [o (pr.p-result true :abc nil 1)]
    (must match true (pr.ok? o))
    (must match false (pr.err? o)))
  (it "generates errs"
    [e (pr.p-result false :bad)]
    (must match false (pr.ok? e))
    (must match true (pr.err? e)))
  (it "raises on no match"
    (must throw (pr.p-result :invalid :stuff)))
  (it "correctly unwraps ok"
    [o (pr.p-result true :abc nil 1)]
    (must match (:abc nil 1) (pr.unwrap o)))
  (it "correctly unwraps err"
    [e (pr.p-result false :bad)]
    (must match (:bad) (pr.unwrap e)))
  (it "will not re-wrap"
    [o (pr.p-result true :cool)
     e (pr.p-result false :bad)]
    (must match [:ok :cool] (pr.p-result o))
    (must match [:err :bad] (pr.p-result e)))
  (it "captures from function calls"
    (must match (true) (pr.unwrap (pr.p-result (pcall sketchy true))))
    (must match (:failure) (pr.unwrap (pr.p-result (pcall sketchy false))))))

(describe "let"
  (it "returns wrapped ok"
    (must match [:ok 10 true]
          (monad-let {:bind pr.bind :unit pr.unit}
                 [a (values true 10)
                  b (pcall sketchy true)]
                 (values true a b))))
  (it "returns wrapped err"
    (must match [:err :failure]
          (monad-let {:bind pr.bind :unit pr.unit}
                 [a (values true 10)
                  b (pcall sketchy false)]
                 (values true a b)))))

(describe "let*"
  (it "returns unwrapped ok"
    (must match (10 true)
          (monad-let* {:bind pr.bind :unit pr.unit :unwrap pr.unwrap}
                 [a (values true 10)
                  b (pcall sketchy true)]
                 (values true a b))))
  (it "returns wrapped err"
    (must match (:failure)
          (monad-let* {:bind pr.bind :unit pr.unit :unwrap pr.unwrap}
                 [a (values true 10)
                  b (pcall sketchy false)]
                 (values true a b)))))
