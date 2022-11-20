(import-macros {: function? : throws-error? : ok? : match?
                : describe : it : expect} :test)

(local iter (require :iter))

(describe "range generator"
  (it "needs start and end"
    (expect (throws-error? (iter.range)))
    (expect (throws-error? (iter.range 1)))
    (expect (ok? (iter.range 1 2))))
  (it "is a pure iterator"
    [(gen param state) (iter.range 1 10 2)]
    (expect (function? gen))
    (expect (match? [1 10 2] param))
    (expect (= state (- 1 2))))
  (it "runs forward"
    (expect (match? [1 2 3 4 nil] (icollect [v (iter.range 1 4)] v)))
    (expect (match? [1 3 5 7 9 nil] (icollect [v (iter.range 1 10 2)] v))))
  (it "runs backward"
    (expect (match? [10 9 8 7 nil] (icollect [v (iter.range 10 7 1)] v)))
    (expect (match? [10 8 6 4 2 nil] (icollect [v (iter.range 10 1 2)] v)))))

(describe "fward"
  (it "iterates forward"
    (expect (match? [:a :b :c :d] (icollect [_ v (iter.fward [:a :b :c :d])] v))))
  (it "iterates forward with step"
    (expect (match? [:a :c] (icollect [_ v (iter.fward [:a :b :c :d] 2)] v))))
  (it "is a pure iterator"
    [(gen param state) (iter.fward [:a :b :c])]
    (expect (function? gen))
    (expect (match? [:a :b :c] param))
    (expect (= state 0))))

(describe "bward"
  (it "iterates backward"
    (expect (match? [:d :c :b :a] (icollect [_ v (iter.bward [:a :b :c :d])] v))))
  (it "iterates backward with step"
    (expect (match? [:d :b] (icollect [_ v (iter.bward [:a :b :c :d] 2)] v))))
  (it "is a pure iterator"
    [(gen param state) (iter.bward [:a :b :c])]
    (expect (function? gen))
    (expect (match? [:a :b :c] param))
    (expect (= state 4))))

