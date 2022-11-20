(import-macros {: view : must : describe : it : rerequire} :test)
(import-macros {: fn* : fn+} :fn)

(describe "fn* ... and & validation"
  (it "must have ... at last position"
    (must not-compile
          (fn* x (where [a b ... y]) true))
    (must not-compile
          (fn* x (where [a b [y ...]]) true))
    (fn* x (where [a b y ...]) true)
    (fn* x (where [...]) true))
  (it "must have & at the second last position"
    (must not-compile
          (fn* x (where [a b &]) true))
    (must not-compile
          (fn* x (where [a b & ...]) true))
    (must not-compile
          (fn* x (where [a b & rest also]) true))
    (fn* x (where [& rest]) true)
    (fn* x (where [a b & rest]) true)))

(describe "fn* ... code generation"
  (it "correctly constructs ... function argument for body"
    (fn* sel
      (where [a ...])
      ;; ... should be arg-c - 1
      (+ a (select :# ...)))
    (must match 3 (sel 1 :a :b))
    (must match 5 (sel 1 :a nil nil :b)))

  (it "changes clauses to select"
    ;; could/should be done in a way to check ast?
    (local rawselect _G.select)
    (var args nil)
    (set _G.select (fn [i ...]
                     (set args [i (table.pack ...)])
                     (rawselect i ...)))
    (fn* sel
      (where [a ...])
      (+ a (select :# ...)))
    (must match 3 (sel 1 :a :b))
    (set _G.select rawselect)
    (must match [:# [:a :b]] args)))

(describe "fn* ... and & usage"
  (it "allows for n+ arity"
    (fn* x
      (where [a b c]) :3
      (where [a b ...]) :2+)
    (must match :3 (x 1 1 1))
    (must match :2+ (x 1 1))
    (must match :2+ (x 1 1 1 1))

    (fn* y
      (where [a b c]) :3
      (where [a b & rest]) :2+)
    (must match :3 (y 1 1 1))
    (must match :2+ (y 1 1))
    (must match :2+ (y 1 1 1 1)))

  (it "accepts ... as only argument"
    (fn* y
      (where [...]) true
      (where _) false)
    (must match true (y))
    (must match true (y 1 2 nil 2 3))
    (must match true (y nil))))

(describe "fn* scope protection"
  (it "wont compile if in-scope symbols are not pinned"
    (must not-compile (do
                        (import-macros {: fn* : fn+} :fn)
                        (local y 10)
                        (fn* x (where [y]) true)))
    (local y 10)
    (fn* x (where [^y]) true))

  (it "wont compile if a pinned symbol is not in-scope"
    (must not-compile (do
                        (import-macros {: fn* : fn+} :fn)
                        (fn* x (where [^y]) true))))

  (it "can match pinned in-scope syms"
    (fn* x
      (where [y]) true
      (where _) false)
    (must match true (x 1))
    (must match false (x))
    ;; adding a would-be-scoped var after the fact is fine
    (local y 100)
    (must match true (x 1))
    (must match false (x))
    ;; but y must now be pinned
    (fn* x2
      (where [^y]) true
      (where _) false)
    (must match false (x2 1))
    (must match true (x2 100))
    (must match false (x2))
    ;; & ^rest is no different
    (local rest [1 2 3])
    (fn* x (where [& ^rest]) true)
    (must match true (x 1 2 3)))

  (it "can match pinned in-scope multi-syms"
    (local y {:val 10})
    (fn* x
      (where [^y.val]) true
      (where _) false)

    (must match true (x 10))
    (must match true (x y.val))
    (must match false (x 1000)))

  (it "raises on ^& rest and ^..."
    ;; wont even parse
    ; (must not-compile (do
    ;                     (import-macros {: fn* : fn+} :fn)
    ;                     (fn* x (where [^...]) true)))
    (must not-compile (do
                        (import-macros {: fn* : fn+} :fn)
                        (fn* x (where [a ^& rest]) true)))
    (must not-compile (do
                        (import-macros {: fn* : fn+} :fn)
                        (fn* x (where [a ^]) true)))))

(describe "fn*"
  (it "has help"
    (must throw (do
                  (fn* x
                    (where [a] (= :string (type a)))
                    (values a)
                    (where [a b])
                    (values a b))
                  (x 1 1 1))))

  (it "must have where-expr"
    (must not-compile
          (do
            (import-macros {: fn* : fn+} :fn)
            (fn* x (where [a]))))

    (must not-compile
          (do
            (import-macros {: fn* : fn+} :fn)
            (fn* x
              (where [a]) true
              (where) true))))

  (it "accepts docstring"
    (fn* x
      "does something with x")

    (fn* y
      "does something with y"
      (where [a])
      (print a)))

  (it "accepts [a & rest]"
    (fn* x
      (where [a & rest])
      (accumulate [sum a _ v (ipairs rest)]
        (+ sum v)))
    ;; can call with n arguments
    (must match 10 (x 1 4 5))
    ;; an call with no "rest"
    (must match 1 (x 1)))

  (it "handles nils in [a & rest]"
    (fn* x
      (where [a ...])
      (let [vargs [...]
            ns (fcollect [i 1 (select :# ...)] (. vargs i))]
        (accumulate [sum a _ v (ipairs ns)]
          (if v (+ sum v) sum))))
    ;; can call with n arguments
    (must match 6 (x 1 nil 5))
    ;; an call with no "rest"
    (must match 1 (x 1)))

  (it "all in one with no bodies"
    (fn* map))

  (it "all in one"
    (fn* map
      (where [1 1])
      {:one 1}
      (where [a b])
      (+ a b))
    (must match {:one 1} (map 1 1))
    (must match 5 (map 2 3)))

  (it "raises error if called with no bodies"
    (fn* map)
    (must throw (map :abc)))

  (it "raises when called with no default body"
    (fn* map)
    (fn+ map [a b 1]
         (+ a b))
    (must throw (map :abc)))

  (it "can define a default with _"
    (fn* map)
    (fn+ map _ :error)
    (must match :error (map 1)))

  (it "can define a default with (where _)"
    (fn* map)
    (fn+ map (where _) :error)
    (must match :error (map 1)))

  (it "can recieve nil in ?sym form"
    (fn* map
      (where [a ?b])
      (values [(type a) (type ?b)]))
    (must match [:number :nil] (map 1 nil)))

  (it "can recieve nil when explicitly in head"
    (fn* x
      (where [a]) false
      (where [a nil]) true)
    (must match false (x 1))
    (must match true (x 1 nil)))

  (it "can differentiate between (f x) and (f x nil)"
    (fn* f
      (where [a])
      (values :f-x)
      (where [a ?b])
      (values :f-x-nil))
    (must match :f-x (f 1))
    (must match :f-x-nil (f 1 nil)))


(it "can be defined multisym"
  (local M {})
  (fn* M.map
    (where _)
    (values :ok))
  (must match :ok (M.map)))

(it "can recurse"
  (fn* n!
    (where [0])
    (values 1)
    (where [n])
    (* n (n! (- n 1))))
  (must match 120 (n! 5)))

(it "works when returned or embedded in something"
  (fn make []
    (fn* made
      (where [a])
      (+ a a)
      (where [a b])
      (+ a b)))
  (let [f (make)]
    (must match 10 (f 5)))

  (let [t [(fn* (where [a]) (+ a))
           (fn* (where [a b]) (+ a b))]]
    (must match 5 ((. t 1) 5))
    (must match 10 ((. t 2) 4 6))))

(it "can be anonymous (but fn+ wont work)"
  ;; must provide at least one body thats it.
  (local x (fn*
             (where [a]) (+ a a)
             (where [a b]) (+ a b)))
  (must match 20 (x 10))
  (must match 10 (x 4 6)))

(it "can match on nil"
  (fn* with-nil
    (where [nil]) (values true)
    (where _) (values false))
  (must match true (with-nil nil))
  (must match false (with-nil 1)))

(it "can match on mixed nils via nil or ?arg"
  (fn* mixed
    (where [a nil]) (values [1 0])
    (where [a ?b c]) (values [1 -1 1]))
  (must match [1 0] (mixed true nil))
  (must match [1 -1] (mixed true true true))
  (must match [1 -1] (mixed true nil true))
  (must throw (mixed true nil nil)))


(it "can build progressively"
  (let [f (fn* f)
        _ (fn+ f [10] true)
        _ (if true (fn+ f [100] true))]
    (must match true (f 10))
    (must match true (f 100)))))

(describe "fn+"
  (it "can attach to fn* with existing bodies"
    (fn* map
      (where [a])
      (values a))
    (fn+ map [a b] (+ a b))

    (must match 10 (map 10))
    (must match 15 (map 10 5)))

  (it "can attach to fn* head"
    (fn* map)
    (fn+ map (where [f] (= :function (type f)))
         #(icollect [_ v (ipairs $1)] (f v)))
    (fn+ map (where [f t] (and (= :function (type f)) (= :table (type t))))
         (let [fx (map f)]
           (fx t)))
    (fn+ map [a b 1]
         (+ a b))
    (fn+ map _
         :error)

    (must match :function (type map))
    (must match :function (type (map #(* $1 2))))
    (must match [2 4 6] (map #(* $1 2) [1 2 3]))
    (must match 10 (map 5 5 1))
    (must match :error (map 5 5 2)))

  (it "will not compile without fn*"
    (must not-compile
          (do
            (import-macros {: fn* : fn+} :fn)
            (fn+ x [a]
                 (+ a a)))))

  (it "must have args"
    (must not-compile
          (do
            (import-macros {: fn* : fn+} :fn)
            (fn* x)
            (fn+)))

    (must not-compile
          (do
            (import-macros {: fn* : fn+} :fn)
            (fn* x)
            (fn+ x)))

    (must not-compile
          (do
            (import-macros {: fn* : fn+} :fn)
            (fn* x)
            (fn+ x [])))))
