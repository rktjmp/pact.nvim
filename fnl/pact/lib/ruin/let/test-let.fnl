(import-macros {: it : must : describe} :test)
(import-macros {: match-let
                : if-let : when-let
                : if-some-let : when-some-let} :let)

(describe "kernel"
  (it "kernelises"
    (do
      (import-macros {: kernelise} :let.kernel)
      (kernelise)
      (must match 20 (if-let [a true] 20)))))

(describe "match-let without shadowing"
  (it "returns value"
    (local one (match-let [str "10 10"
                           pat "(%d+) (%d+)"
                           (a b) (string.match str pat)
                           x (tonumber a)
                           y (tonumber b)]
                 (+ x y)))
    (must match 20 one)
    (local two (match-let [str "10 10"
                           pat "(%d+) (%d+)"
                           (a b) (string.match str pat)
                           x (tonumber a)
                           y (tonumber b)
                           (where val (and (= 10 x y))) true]
               val))
    (must match true two))

  (it "returns else matches"
    (local one (match-let [:string (type {})]
                 (+ 10 10)
                 (else
                   :table :bad-type)))
    (must match :bad-type one))

  (it "returns catch matches"
    (local one (match-let [:string (type {})]
                 (+ 10 10)
                 (catch
                   :table :bad-type)))
    (must match :bad-type one))

  (it "can have multiple body clauses"
    (local one (match-let [str "10 10"
                           pat "(%d+) (%d+)"
                           (a b) (string.match str pat)
                           x (tonumber a)
                           y (tonumber b)]
                 (.. "this does nothing")
                 (+ x y)))
    (must match 20 one))

  (it "can have multiple body clauses and an else"
    (local one (match-let [:string (type {})]
                 (.. "this does" "nothing")
                 (values 10)
                 (else  :table :bad-type)))
    (must match :bad-type one))

  (it "returns nil err on match fail if that is the value"
      (must match (nil "error")
            (match-let [true (values nil "error")]
                       true)))

  (it "returns all values"
    (must match (nil "fail")
          (match-let [true (values nil "fail")] true))))

(describe "match-let with shadowing locals"
  (it "warns on rebinding (until matchless exists)"
    (must not-compile
          (do
            (import-macros {: match-let} :let)
            (match-let [x 10
                        x :raw-sym]
              (values x))))
    (must not-compile
          (do
            (import-macros {: match-let} :let)
            (match-let [[x y] [10 20]
                        x "in-seq"]
              (values x))))
    (must not-compile
          (do
            (import-macros {: match-let} :let)
            (match-let [{:a x} {:a 10}
                        x "in-assoc"]
              (values x))))
    (must not-compile
          (do
            (import-macros {: match-let} :let)
            (match-let [(x y) (values 10 20)
                        x "in-list"]
              (values x))))
    (must not-compile
          (do
            (import-macros {: match-let} :let)
            (match-let [(x [x]) (values 10 20)
                        x "in-nested-1"]
              (values x))))
    (must not-compile
          (do
            (import-macros {: match-let} :let)
            (match-let [[{:x [z y x]}] [{:x [1 2 3]}]
                        x "in-nested-2"]
              (values x))))

    (must match (10 10) (match-let [x 10
                                    (where y (= x y)) 10]
                          (values x y)))
    (must not-compile
          (do
            (import-macros {: match-let} :let)
            (match-let [x 10
                        (where [y x] (= x y)) [10 10]]
              (values x y)))))

  (it "does allow rescoping _")

  (it "warns when attempting to bind(?)/match a symbol that exists in outerscope not defined by us"
    (must not-compile
          (do
            (import-macros {: match-let} :let)
            (local x 100)
            (match-let [x 200]
              (values x)))))

  (it "returns value"
    ;; TODO: requires matchless in upstream
    ; (local x (match-let [str "10 10"
    ;                      pat "(%d+) (%d+)"
    ;                      (a b) (string.match str pat)
    ;                      ;; this should work but currently a matches against the string above
    ;                      ;; instead of just rebinding
    ;                      a (tonumber a)
    ;                      b (tonumber b)]
    ;            (+ a b)))
    ; (expect (match? 20 x))
    ))

(describe "if-let"
  (it "supports multiple bind values"
      (must match [:hello :bye]
            (if-let [(a b c) (values :hello :bye :xyz)]
              [a b]))
      (must match [:hello :bye]
            (if-let [(nil b c) (values nil :hello :bye :xyz)]
              [b c])))
  (it "works"
    (must match [:hello :bye]
          (if-let [a :hello
                   b :bye]
            [a b]
            :bad))
    (must match :hello (if-let [a :hello] a))
    (must match nil (if-let [a nil] a))
    (must match nil (if-let [a false] a))
    (must match :otherwise (if-let [a false] a :otherwise))))

(describe "when-let"
  (it "works"
    (must match [:hello :bye]
          (when-let [a :hello
                     b :bye]
            (.. a b)
            [a b]))
    (must match :hello (when-let [a :hello] (+ 10 10) (values a)))
    (must match nil (when-let [a nil] a))
    (must match nil (when-let [a false] a))
    (must match nil (when-let [a false] a :otherwise))))

(describe "if-some-let"
  (it "works"
    (must match [:hello :bye]
          (if-some-let [a :hello
                   b :bye]
            [a b]
            :bad))
    (must match :hello (if-some-let [a :hello] a))
    (must match nil (if-some-let [a nil] a))
    (must match nil (if-some-let [a nil] a))
    (must match :otherwise (if-some-let [a nil] a :otherwise))))

(describe "when-some-let"
  (it "works"
    (must match :hello (when-some-let [a :hello] (+ 10 10) (values a)))
    (must match nil (when-some-let [a nil] a))
    (must match nil (when-some-let [a nil] a))
    (must match nil (when-some-let [a nil] a :otherwise))))
