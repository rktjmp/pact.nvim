(import-macros {: view : must : describe : it : rerequire} :test)
(local enum (rerequire :enum))

(describe "reduce"
  (it "handles seq"
    (must match
          [[1 :a] [2 :b] [3 :c]]
          (enum.reduce #(doto $1 (table.insert [$2 $3])) [] [:a :b :c]))
    (let [sum (enum.reduce #(+ $1 $3))]
      (must match 8 (sum 0 [5 2 1]))))
  (it "handles assoc"
    (must match
          [[1 :a] [2 :b] [3 :c]]
          (doto (enum.reduce #(doto $1 (table.insert [$3 $2])) [] {:a 1 :b 2 :c 3})
            (table.sort (fn [[i _] [ii _]] (< i ii))))))
  (it "handles stl-custom iter"
    (must match :abc (enum.reduce #(.. $1 $2) "" #(string.gmatch "abc" "[%a]"))))
  (it "handles custom stateless iterator"
    (fn iter []
      (fn gen [invar state]
        (if (< 3 state)
          (values nil)
          (values (+ state 1))))
      (values gen 0 0))
    (must equal (+ 1 2 3 4) (enum.reduce #(+ $1 $2) 0 iter))))

(describe "reduced"
  (it "can stop early"
    (must match 6 (enum.reduce #(if (<= 5 $1) (enum.reduced $1) (+ $1 $3))
                               0 [1 2 3 100 100]))))

(describe "map"
  (it "handles empty tables"
    (must equal 0 (length (enum.map #10 []))))
  (it "handles seq"
    (must match [:aa :bb :cc] (enum.map #(.. $2 $2) [:a :b :c])))
  (it "handles stl-custom iter"
    (must match [:a :b :c] (enum.map #$1 #(string.gmatch "abc" "[%a]")))))

(describe "table->pairs"
  (it "converts"
    (must match
          [[:a :ay] [:b :bee]]
          (-> (enum.table->pairs {:a :ay :b :bee})
              (#(doto $1 (table.sort (fn [[k1 _] [k2 _]] (< k1 k2)))))))))

(describe "pairs->table"
  (it "converts"
    (must match
          {:a :ay :b :bee}
          (enum.pairs->table [[:a :ay] [:b :bee]]))))

(describe "filter"
  (it "handles seq"
    (must match [2 4 6] (enum.filter #(= 0 (% $2 2)) [1 2 3 4 5 6] )))
  (it "handles assoc"
    (must match {:a 1 :b nil :c 3} (enum.filter #(= 1 (% $2 2)) {:a 1 :b 2 :c 3})))
  (it "errors on inter-fn"
    (must throw (enum.filter  #(= 1 (% $2 2)) #nil))))

(describe "any?"
  (it "finds one"
    (must match true (enum.any? #(<= 5 $2) [1 2 3 5 3 2 1])))
  (it "finds none"
    (must match false (enum.any? #(<= 50 $2) [1 2 3 5 3 2 1]))))

(describe "all?"
  (it "finds all good"
    (must match true (enum.all? #(<= 5 $2) [6 10 7 9])))
  (it "finds one bad"
    (must match false (enum.all? #(<= 50 $2) [6 10 7 1 91]))))

(describe "find"
  (it "returns found value"
    (must match (4 6) (enum.find #(<= 5 $2) [1 -1 3 6 10 7 9])))
  (it "returns nil on no find"
    (must match nil (enum.find #(<= 50 $2) [6 10 7 1 39]))))

(fn fixture []
  (values [1 2 3]
          {:a 1 :b 2 :c 3}))

(describe "set$"
  (it "sets a value in-place"
    (let [(seq assoc) (fixture)]
      (must match {:a 1 :z nil} assoc)
      (enum.set$ assoc :z 100)
      (must match {:a 1 :z 100} assoc)
      (must match [1 2 3 nil] seq)
      (enum.set$ seq 4 100)
      (must match [1 2 3 100] seq)))
  (it "updates a value in-place"
    (let [(seq assoc) (fixture)]
      (must match {:a 1} assoc)
      (enum.set$ assoc :a 100)
      (must match {:a 100} assoc)
      (must match [1 2 3] seq)
      (enum.set$ seq 2 100)
      (must match [1 100 3] seq)))
  (it "removes a value in-place without respect to seq or assoc"
    (let [(seq assoc) (fixture)]
      (must match {:a 1} assoc)
      (enum.set$ assoc :a nil)
      (must match {:a nil} assoc)
      (must match [1 2 3] seq)
      (enum.set$ seq 2 nil)
      (must match [1 nil 3] seq)))
  (it "partial application"
    (let [(seq assoc) (fixture)
          update (enum.set$ assoc)
          update-key (enum.set$ assoc :key)]
      (must be :function update)
      (update :one 1)
      (must match 1 (. assoc :one))
      (must be :function update-key)
      (update-key 2)
      (must match 2 (. assoc :key)))))

(describe "insert$"
  (it "inserts in place like table.insert"
    (let [t [1 2 3]
          nt (enum.insert$ t 2 100)]
      (must match [1 100 2 3] t)
      (must equal nt t)))
  (it "accepts negative indexes"
    (let [t [1 2 3]]
      (enum.insert$ t -1 100)
      (must match [1 2 3 100] t)
      (enum.insert$ t -5 400)
      (must match [400 1 2 3 100] t))))

(describe "remove$"
  (it "removes in place like table.remove"
    (let [t [1 2 3]
          nt (enum.remove$ t 2)]
      (must match [1 3] t)
      (must equal nt t)))
  (it "accepts negative indexes"
    (let [t [1 2 3 4 5]]
      (enum.remove$ t -1)
      (must match [1 2 3 4] t)
      (enum.remove$ t -3)
      (must match [1 3 4] t))))

(describe "append$"
  (it "adds to end of seq, in place"
    (let [t [1 2 3]
          nt (enum.append$ t 100)]
      (must match [1 2 3 100] t)
      (must equal nt t)))
  (it "acccepts any number of arguments"
    (let [t [1 2 3]
          nt (enum.append$ t 100 200 300)]
      (must match [1 2 3 100 200 300] t)
      (must equal nt t)))
  (it "throws on no value"
    (must throw (enum.append$ []))))

(describe "sort$"
  (it "sorts in-place"
    (let [t [3 2 1]
          nt (enum.sort$ #(< $1 $2) t)]
      (must match [1 2 3] t)
      (must equal nt t))))

(describe "sort"
  (it "sorts into new table"
    (let [t [3 2 1]
          nt (enum.sort #(< $1 $2) t)]
      (must match [3 2 1] t)
      (must match [1 2 3] nt)
      (must not equal nt t))))

(describe "flatten"
  (it "flattens a seq"
    (must match [1 2 3] (enum.flatten [[1] [2] [3]])))
  (it "only flattens one level"
    (must match [1 2 [3]] (enum.flatten [[1] [2] [[3]]])))
  (it "only accepts seq"
    (must throw (enum.flatten {:a 1}))))

(describe "concat$"
  (it "concats seqs"
    (must match [1 2 3 4] (enum.concat$ [1 2] [3 4]))
    (must match [1 2 3 4] (enum.concat$ [1 2] [3] [4]))
    (must match [1 2 3 4] (enum.concat$ [] [1 2 3 4]))
    (must match [1 2 3 4] (enum.concat$ {} [1 2 3 4])))
  (it "only accepts seq"
    (must throw (enum.concat$))
    (must throw (enum.concat$ [] nil))
    (must throw (enum.concat$ [1 2] :abc))
    (must throw (enum.concat$ [1 2] [1] :abc))))

(local six-seq [1 2 3 4 5 6])
(local five-seq [1 2 3 4 5])

(describe "chunk-every"
  (it "chunk 6 by 2"
    (let [c (enum.chunk-every six-seq 2)]
      (must match [[1 2] [3 4] [5 6]] c)))
  (it "chunk 6 by 4"
    (let [c (enum.chunk-every six-seq 4)]
      (must match [[1 2 3 4] [5 6]] c)))
  (it "chunk 6 by 1"
    (let [c (enum.chunk-every six-seq 1)]
      (must match [[1] [2] [3] [4] [5] [6]] c)))
  (it "chunk 6 by 4 with fill"
    (let [c (enum.chunk-every six-seq 4 :fill)]
      (must match [[1 2 3 4] [5 6 :fill :fill]] c)))
  (it "chunk [] by 4 with fill"
    (let [c (enum.chunk-every [] 4 :fill)]
      (must match [] c))))

(describe "hd, first"
  (it "gets first element"
    (must match 1 (enum.hd [1 2 3]))
    (must match 1 (enum.first [1 2 3])))
  (it "returns nil if no elements"
    (must match nil (enum.first []))))

(describe "last"
 (it "gets last element"
   (must match f (enum.last [1 2 3]))))

(describe "tl"
  (it "gets all after first element"
    (must match [2 3] (enum.tl [1 2 3])))
  (it "returns empty list if no more elements?"
    (must match [] (enum.tl [1]))))

(describe "split"
  (it "splits in two"
    (must match ([1 2 3] [4 5 6]) (enum.split [1 2 3 4 5 6] 4)))
  (it "splits into [] [...]"
    (must match ([] [1 2 3 4 5 6]) (enum.split [1 2 3 4 5 6] 1)))
  (it "splits into [...] [6]"
    (must match ([1 2 3 4 5] [6]) (enum.split [1 2 3 4 5 6] 6)))
  (it "splits into [...] []"
    (must match ([1 2 3 4 5 6] []) (enum.split [1 2 3 4 5 6] 7)))
  (it "splits via -index"))

(describe "vals"
  (it "works on seq"
    (must match [:a :b :c] (enum.vals [:a :b :c])))
  (it "works on assoc"
    (let [vals (enum.vals {:a 1 :b 2 :c 3})]
      (enum.sort$ vals)
      (must match [1 2 3] vals)))
  (it "works on function"
    ; (fn iter [a i]
    ;   (print i)
    ;   (let [ii (+ i 1)]
    ;     (if (<= ii 3)
    ;       (values ii ii))))
    ; (must match [1 2 3] (enum.vals iter))
    ))

(describe "keys"
  (it "works on seq"
    (must match [1 2 3] (enum.keys [:a :b :c])))
  (it "works on assoc"
    (let [keys (enum.keys {:a 1 :b 2 :c 3})]
      (enum.sort$ keys)
      (must match [:a :b :c] keys)))
  (it "works on function"
    ; (fn iter [a i]
    ;   (print i)
    ;   (let [ii (+ i 1)]
    ;     (if (<= ii 3)
    ;       (values ii ii))))
    ; (must match [1 2 3] (enum.vals iter))
    ))

(describe "empty?"
  (it "works on seq"
    (must match true (enum.empty? []))
    (must match false (enum.empty? [1])))
  (it "works on assoc"
    (must match true (enum.empty? {}))
    (must match false (enum.empty? {:a 1}))))

(describe "shuffle$"
  (it "shuffles a list"
    [l [1 2 3]]
    (math.randomseed 101)
    (must match [1 2 3] l)
    (must not match [1 2 3] (enum.shuffle$ l))))

(describe "mixed tables"
  (it "maps"
    [t {1 :first :greet :hello}]
    (must match [[1 :first]] (enum.map #[$1 $2] t)))

  (it "maps"
    [t {1 :first :greet :hello}]
    (must match [[1 :first] [:greet :hello]] (enum.map #[$1 $2] #(pairs t)))))
