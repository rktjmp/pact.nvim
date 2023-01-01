(import-macros {: use} (.. (or (-?> ... (string.match "(.+%.)enum")) "") :use))

(use {:seq? t-seq? :assoc? t-assoc? :table? t-table?
      : number? : function? : nil?} :type &from :enum
     {: 'fn*} :fn &from :enum
     {:format fmt} string)

(local M {})

(fn stream? [s]
  (match s
    {:enum enum :funs funs} true
    _ false))

;; we want to shadow the normal seq? and assoc? functions to make sure we were
;; not getting a stream-container.
(fn seq? [t] (and (t-seq? t) (not (stream? t))))
(fn assoc? [t] (and (t-assoc? t) (not (stream? t))))
(fn table? [t] (and (t-table? t) (not (stream? t))))

(fn enumerable? [v]
  ;; stream is a table, so it will look enumerable but really its not.
  (or (and (or (seq? v)
               (assoc? v))
           (not (stream? v)))
      (function? v)))

;; stream iter internal behaviour markers
(local stream-halt-marker {})
(local stream-use-last-value-marker {})
(local stream-use-new-value-marker {})
(local reduced-marker {})

;; Generic helpers

(fn M.pack [...]
  "Insert all given arguments, in order, into a table and define the key :n for
  the number of arguments stored. Backport of < 5.1 `table.pack`."
  (doto [...] (tset :n (select :# ...))))

(local rawunpack (or _G.unpack table.unpack))
(fn* M.unpack
  "Unpack a packed table, automatically uses `t.n` if present
  (ie. the table was `pack'ed)."
  ;; note this is table, not seq as the first value may be nil but we still
  ;; want to accept it and unpack it
  (where [t] (table? t))
  (rawunpack t 1 t.n)
  (where [t i] (and (table? t) (number? i)))
  (rawunpack t i t.n)
  (where [t i j] (and (table? t) (number? i) (number? j)))
  (rawunpack t i j))

;; Reduce

(fn* M.reduced
  "Terminate a reducer with value"
  (where [])
  (values reduced-marker)
  (where [?value])
  (values reduced-marker ?value)
  (where _)
  (error "reduced accepts only a single value"))

(fn reduce-order-identity [...] (values ...))
(fn reduce-order-v-k [i v] (values v i))
(fn reduce-order-k-v [k v] (values k v))

(fn reduce-impl [f acc [gen invariant ctrl] order-values]
  (let [{: n &as vals} (M.pack (gen invariant ctrl))]
    (match [n vals]
      ;; pairs returns nil for its final value, this is also a reasonable
      ;; default for other iterators so we don't discriminate.
      [1 [nil]] (values acc)
      ;; ipairs returns "no value", which is also apropriate
      ;; for any other iterator.
      ;; we could add a "stop on" value arg but you can't pass in 'nothing'
      ;; to flag that it's a "stop" value, TODO: I guess you could pass n and a value?
      [0 _] (values acc)
      ;; otherwise we're ok to keep stepping
      _ (let [[ctrl & _] vals]
          (match (f acc (order-values (M.unpack vals 1 n)))
            ;; explicit stop, note this can return more than one value if more
            ;; than one was given to reduced, this allows find to return
            (reduced-marker ?new-acc) ?new-acc
            ;; nil is a valid acc value!
            (?new-acc) (reduce-impl f ?new-acc [gen invariant ctrl] order-values)
            _ (error "internal-error: reduce could not match next value"))))))

(fn* M.reduce
  "Reduce `enumerable` by `f` with `?initial` as initial accumulator value if given.

  If `?initial` is not given, the first value from `enumerable` is used. `nil`
  is a valid initial value and distinct from not providing one. When enumerable is
  a generator function, only the first value from the function is used as the default
  initial value.

  `f' should accept the accumulator then any arguments as per the iterator, be
  aware of the iterator rules outlined above.

  `seqs` are automatically iterated with `ipairs`, `assocs` are iterated with `pairs`.

  Reduce may be terminated early by calling `reduced' with the final `acc` value.

  Custom generators can be provided, which may either follow luas stateless-iterator style
  (see lua documentation) or stateful. Returning a single `nil` or no value
  from an iterator terminates iteration."
  (where [f] (function? f))
  #(M.reduce f $1 $2)
  ;; seq/assoc -> ipairs/pairs
  (where [f ?initial t] (and (function? f) (seq? t)))
  (reduce-impl f ?initial (M.pack (ipairs t)) reduce-order-v-k)
  (where [f ?initial t] (and (function? f) (assoc? t)))
  (reduce-impl f ?initial (M.pack (pairs t)) reduce-order-v-k)
  (where [f ?initial generator] (and (function? f) (function? generator)))
  (reduce-impl f ?initial (M.pack (generator)) reduce-order-identity)
  ;; as above but inital is retrieved from ipairs/pairs
  (where [f t] (and (function? f) (seq? t)))
  (let [(iter a n) (ipairs t)
        (nn initial) (iter a n)]
    (reduce-impl f initial (M.pack iter a nn) reduce-order-v-k))
  (where [f t] (and (function? f) (assoc? t)))
  (let [(iter a n) (pairs t)
        (nn initial) (iter a n)]
    (reduce-impl f initial (M.pack iter a nn) reduce-order-v-k))
  (where [f generator] (and (function? f) (function? generator)))
  (let [(iter a n) (generator)
        initial (iter a n)]
    (reduce-impl f initial (M.pack iter a initial) reduce-order-identity)))

(fn* depth-walk-impl
  ;; TODO seq? restricted?
  ;; termnator, no more down
  (where [f node ?list ?acc history next-id] (or (= nil ?list) (= nil (. ?list 1))))
  (f ?acc node history)

  (where [f node list ?acc history next-id])
  ;; fresh history so we dont sully other branches
  (let [branch-history (M.concat$ [] history [node])]
    (M.reduce #(depth-walk-impl f $2 (next-id $2 branch-history) $1 branch-history next-id)
              (f ?acc node history) list)))

(fn* breadth-walk-impl
  ;; TODO seq? restricted?
  (where [f ?list ?acc history next-id] (or (= nil ?list) (= nil (. ?list 1))))
  ?acc

  (where [f list ?acc history next-id])
  (let [next-list (M.flat-map #(next-id $1) list)
        history (M.append$ history [])]
    (breadth-walk-impl f
                       next-list
                       (M.reduce #(let [acc (f $1 $2 history)]
                                    (doto (M.last history)
                                          (M.append$ $2))
                                    acc) ?acc list)
                       history
                       next-id)))

(fn* M.depth-walk
  "Visit every node in a graph, depth first.

  Accepts a function `f`, a head `node`, optionally an `acc` value and a
  `next-identity` function.

  If an acc value is provided (may be nil) then `f` is called with `acc node
  history` otherwise its called with `node history` where history is a list of
  visited nodes in the current branch.

  `next-identity` is called with the current `node` and `history` and should
  return the a list of the next nodes to visit, an empty list or nil.

  By default no provisions are taken to avoid loops or optimisations for
  visited nodes, these should be filtered in `next-identity`."
  (where [f node next-identity] (and (function? f) (table? node) (function? next-identity)))
  (depth-walk-impl #(f $2 $3) node (next-identity node []) nil [] next-identity)
  (where [f node ?acc next-identity] (and (function? f) (table? node) (function? next-identity)))
  (depth-walk-impl f node (next-identity node []) ?acc [] next-identity))

(fn* M.breadth-walk
  "Visit every node in a graph, breadth first. See `depth-walk' for details on arguments.

  `history` currently underconstruction...

  `history` in `breadth-walk` is a seq of seqs where each seq is another depth level."
  ;; TODO better history without blanks
  (where [f node next-identity] (and (function? f) (table? node) (function? next-identity)))
  (breadth-walk-impl #(f $2 $3) [node] nil [] next-identity)
  (where [f node ?acc next-identity] (and (function? f) (table? node) (function? next-identity)))
  (breadth-walk-impl f [node] ?acc [] next-identity))

;; Map

(fn* M.map
  "Collect `f x` for every `x` in `enumerable` into a seq. If `f x` returns
  `nil`, the value is NOT inserted to avoid creating sparse sequences. If you
  want true map behaviour, use `reduce' and manually track and return your
  table length.

  Can accept a stream."
  (where [f] (function? f))
  #(M.map f $1)
  (where [f stream] (and (function? f) (stream? stream)))
  (do
    (table.insert stream.funs #(values stream-use-new-value-marker (f $...)))
    (values stream))
  (where [f enumerable] (and (function? f) (enumerable? enumerable)))
  (let [fx (fn [acc ...]
             (match (f ...)
               val (M.insert$ acc -1 val)
               nil acc))]
    (M.reduce fx [] enumerable)))

(fn* M.each
  "See `map' but for side effects, returns nil.

  Can accept a stream."
  (where [f] (function? f))
  #(M.each f $1)
  (where [f stream] (and (function? f) (stream? stream)))
  (do
    (table.insert stream.funs #(values stream-use-last-value-marker (f $...)))
    (values stream))
  (where [f enumerable] (and (function? f) (enumerable? enumerable)))
  (let [fx (fn [acc ...]
             (f ...)
             (values nil))]
    (M.reduce fx nil enumerable)))

(fn* M.flatten
  "Flatten a sequence of sequences into one sequence."
  (where [seq] (seq? seq))
  (let [fx (fn [acc v i]
             (if (seq? v)
               (-> (icollect [_ vv (ipairs v) :into acc] vv))
               (M.append$ acc v)))]
    (M.reduce fx [] seq)))

(fn* M.flat-map
  (where [f] (function? f))
  #(M.flat-map f $1)
  (where [f enumerable] (and (function? f) (enumerable? enumerable)))
  (-> (M.map f enumerable)
      (M.flatten)))

;; Predicators

(fn* M.filter
  "Collect every `x` in `t` where `pred` is true into a seq.

  Only accepts seq or assocs, use `map` or `reduce` to drop values from a
  custom iterator.

  Can accept a stream."
  (where [pred] (function? pred))
  #(M.filter pred $1)
  (where [pred stream] (and (function? pred) (stream? stream)))
  (do
    (table.insert stream.funs #(if (pred $...)
                               (values stream-use-last-value-marker)
                               (values stream-halt-marker)))
    (values stream))
  (where [pred t] (and (function? pred) (or (seq? t) (assoc? t))))
  (let [insert (if (seq? t)
                 #(doto $1 (table.insert $2))
                 #(doto $1 (tset $3 $2)))
        insert? (fn [acc k v]
                  (if (pred k v)
                    (insert acc k v)
                    (values acc)))]
    (M.reduce insert? {} t)))

(fn M.reject [pred ...]
  "Complement of `filter'"
  (M.filter #(not (pred $...)) ...))

(fn* M.any?
  "Return true if `f` returns true for any member of `t`"
  (where [f t] (and (function? f) (enumerable? t)))
  (M.reduce (fn [_acc ...] (if (f ...)
                             (M.reduced true)
                             (values false)))
            false t))

(fn* M.all?
  "Return true if `f` returns true for all member of `t`"
  (where [f t] (and (function? f) (enumerable? t)))
  (M.reduce (fn [acc ...] (if (and acc (f ...))
                            (values true)
                            (M.reduced false)))
            true t))

(fn* M.find
  "Return first value from `e` that `f` returns true for.

  Note this currently means `find` returns `(value index)` or `(value key)` for
  tables"
  (where [f e] (and (function? f) (enumerable? e)))
  (let [reducer (M.reduce (fn [_ ...]
                            (if (f ...)
                              ;; track index/key and value, etc
                              (M.reduced (M.pack ...))
                              (values nil))))]
    (match (reducer nil e)
      any (M.unpack any)
      nil nil)))

;; deprecated? find now returns val key so finding values is the same with find
;; or find-values and keys is just (_ key).
; (fn* M.find-key
;   "See `find', but returns key only. Does not support function-enumerables. - use `Find'."
;   (where [f t] (and (function? f) (table? t)))
;   (match (M.find f t)
;     (k _) (values k)
;     _ (values nil)))

; (fn* M.find-value
;   "See `find', but returns value only. Does not support function-enumerables - use `Find'."
;   (where [f t] (and (function? f) (table? t)))
;   (match (M.find f t)
;     (_ v) (values v)
;     _ (values nil)))

(fn* M.group-by
  "Group values of `enumerable` by the key from `f`.

  May return one value, the `key` to store the enumerable value under, or two
  values, where the first is the `key` and the second is the `value`.

  Function enumerables must always return both the group-key and value.

  Keys may not be `nil`.

  Returns an assoc of sequences."
  (where [f] (function? f))
  #(M.group-by f $1)
  ;; tables (seq or assoc) always have a k v pair so we can be
  ;; confident in what to pass around
  (where [f e] (and (function? f) (table? e)))
  (M.reduce (fn [acc v k]
              (let [(key val) (f v k)
                    _ (assert (not= nil key) "group-by key may not be nil")
                    val (or val v)
                    group (or (. acc key) [])]
                (M.set$ acc key (M.append$ group val))))
            {} e)
  ;; we can't know how many values a function returns, so we don't know what
  ;; suits as a default value, so the user must return one.
  (where [f e] (and (function? f) (function? e)))
  (M.reduce (fn [acc ...]
              (let [(key val) (f ...)
                    _ (assert (not= nil key) "group-by key may not be nil")
                    _ (assert (not= nil val)
                              "group-by on function must return (key value)")
                    group (or (. acc key) [])]
                (M.set$ acc key (M.append$ group val))))
            {} e))

(fn* take
  (where [e n] (and (seq? e) (number? n)))
  (error "todo")
  (where [e n] (and (function? e) (number? n)))
  (error "todo"))

(fn* M.pluck
  ;; TODO: accept keys table or table keys?
  "For each key in `ks`, get value from `t`, Returns seq."
  (where [t ks] (and (table? t) (seq? ks)))
  (M.map #(. t $1) ks))

(fn* M.dot
  "Get value of `k` from `t`."
  (where [k])
  #(M.dot k $1)
  (where [k t] (table? t))
  (. t k))

;; Seq-only alterations

(fn negable-seq-index [seq i ctx]
  ;; 0 length means -1 -> 1 (after the end, at 0),
  ;; -2 is undefined intent and an error.
  ;; 1+ lengths means we want to insert *after* what the -index resolves to:
  ;; -1 -> "end" so len+1
  ;; -2 -> "before last" so len
  ;; -len -> first
  ;; -len-1 -> undefined intent and an error
  (assert ctx "ind-mod requires :insert or :remove ctx")
  (match [i (length seq) ctx]
    (where [i n] (< 0 i (+ n 1))) (values i)
    [-1 0] (values 1)
    ;; negative indexes run from -1 (end) to -length-1 (beginning)
    (where [i n :insert] (<= (- (* -1 n) 1) i -1)) (+ n 2 i)
    (where [i n :remove] (<= (* -1 n) i -1)) (+ n 1 i)
    (where [i n] (< n i)) (error (string.format "index %d overbounds" i n))
    (where [i n] (< i 0)) (error (string.format "index %d underbounds" i n))
    [0 n] (error (string.format "index 0 invalid, use 1 or %d" (- (* -1 n) 1)))))

(fn* M.insert$
  "Insert `v` into `seq` at `i` and return `seq`. Accepts negative indexes."
  (where [seq i v] (and (seq? seq) (number? i)))
  (doto seq
    (table.insert (negable-seq-index seq i :insert) v)))

(fn* M.remove$
  "Remove value at index `i` from `seq` and return `seq`. Accepts negative indexes."
  (where [seq i] (and (seq? seq) (number? i)))
  (doto seq
    (table.remove (negable-seq-index seq i :remove))))

(fn* M.append$
  "Append `v1 v2 ...` to `seq` and return `seq`"
  (where [seq ...] (and (seq? seq) (< 0 (select :# ...))))
  (let [{: n &as vals} (M.pack ...)]
    (for [i 1 n]
      (M.insert$ seq -1 (. vals i)))
    (values seq)))

(fn* M.concat$
  "Concatenate the values of `seq-1` (and any other seqs) into `seq`."
  (where [seq seq-1] (and (seq? seq) (seq? seq-1)))
  (icollect [_ v (ipairs seq-1) &into seq] (values v))
  (where [seq seq-1 seq-2 ...] (and (seq? seq) (seq? seq-1) (seq? seq-2)))
  (M.concat$ (M.concat$ seq seq-1) seq-2 ...))

; (fn* M.concat
;   "Concatenate the values of `seq-1` and any other seqs onto a new seq."
;   (where [seq ...] (seq? seq))
;   (M.concat$ [] seq ...))

(fn* M.shuffle$
  "Shuffle sequence in place"
  (where [seq] (seq? seq))
  (do
    (for [i (length seq) 1 -1]
      (let [j (math.random 1 i)
            hold (. seq j)]
        (tset seq j (. seq i))
        (tset seq i hold)))
    (values seq)))

(fn* M.hd
  "Return first element of `seq`"
  (where [seq] (seq? seq))
  (let [[h] seq]
    (values h)))

(fn* M.tl
  "Return all but first element of `seq`"
  (where [seq] (seq? seq))
  (let [[_ & tail] seq]
    (values tail)))

(fn* M.first
  "Return first element of `seq`"
  (where [seq] (seq? seq))
  (M.hd seq))

(fn* M.last
  "Return last element of `seq`"
  (where [seq] (seq? seq))
  (. seq (length seq)))

(fn* M.unique
  "Remove any duplicate values from `seq`. Optionally accepts an `identity`
  function.

  By default all values are compared directly, so different tables that have
  the same content are considered different values. The identity function can
  be used to 'hash' complex value types into an appropriate comparison value."
  (where [seq] (seq? seq))
  (M.unique seq #$1)
  (where [seq identity] (and (seq? seq) (function? identity)))
  (-> (M.reduce (fn [[new-seq seen] value _index]
                  (let [id-key (identity value)]
                    (if (nil? (. seen id-key))
                      (do
                        (tset seen id-key true)
                        (table.insert new-seq value)
                        (values [new-seq seen]))
                      (values [new-seq seen]))))
                [[] {}] seq)
      (M.first)))

(fn* M.split
  "Return `seq` in two parts, split at `index`."
  ;; TODO: -index for enum.split?
  (where [seq index] (and (seq? seq) (number? index) (<= 1 index)))
  (accumulate [(left right) (values [] []) i v (ipairs seq)]
    (if (< i index)
      (values (M.insert$ left -1 v) right)
      (values left (M.insert$ right -1 v)))))

(fn* M.chunk-every
  "Split `seq` by `n` into `[[v1 .. vn] ...]` optionally fill tail with `?fill`"
  (where [seq n] (and (seq? seq) (number? n)))
  (M.chunk-every seq n nil)
  (where [seq n ?fill] (and (seq? seq) (number? n)))
  (let [l (length seq)]
    (if (< 0 l)
      (fcollect [i 1 (length seq) n]
        (fcollect [ii 0 (- n 1)]
          (match (. seq (+ i ii))
            nil ?fill
            any any)))
      (values []))))

;; General table alterations

(fn* M.merge$
  "For every key-value pair in b, copy it to a. Optionally accepts f to resolve
  conflicts, called with the key name, `a` value and `b` value, otherwise
  replaces."
  (where [a b] (and (table? a) (table? b)))
  (M.merge$ a b #$3)
  (where [a b f] (and (table? a) (table? b) (function? f)))
  (M.reduce (fn [acc val key]
              (if (not= nil (. a key) )
                (M.set$ acc key (f key (. a key) (. b key)))
                (M.set$ acc key val)))
            a b))

(fn* M.set$
  "Set `t.k` to `v`, return `t`.

  This differs from Fennels `set`/`tset` by returning the table `t` and it may
  be used in pipelines."
  (where [t k ?v] (table? t))
  (doto t (tset k ?v))
  (where [t] (table? t))
  #(doto t (tset $1 $2))
  (where [t k] (table? t))
  #(doto t (tset k $1)))

;; Sort

(fn* M.sort$
  "Sort seq *in place* by `f`, returns `seq`"
  (where [f] (function? f))
  #(M.sort$ f $1)
  (where [seq] (seq? seq))
  (doto seq (table.sort))
  (where [f seq] (and (function? f) (seq? seq)))
  (doto seq (table.sort f)))

(fn* M.sort
  "Create new seq by sorting seq by `f`."
  (where [f] (function? f))
  #(M.sort f $1)
  (where [f seq] (function? f) (seq? seq))
  ;; convert seq to [i v] seq
  ;; sort [i v] pairs by (f v)
  ;; convert [i v] pairs back into i = sorted-index
  (let [sorted-keys (-> (M.table->pairs seq)
                        (#(doto $1
                            (table.sort (fn [[_ a] [_ b]] (f a b)))))
                        (#(M.reduce (fn [acc [oi v] i] (M.set$ acc oi i))
                                    {} $1)))]
    ;; recreate new seq by inserting values according to their sorted-index
    (M.reduce (fn [acc v i] (M.set$ acc (. sorted-keys i) v)) [] seq)))

;; x -> tuples

(fn* M.table->pairs
  "Convert a table of `{k v ...}` into `[[k v] ...]`"
  (where [t] (table? t))
  (M.map #[$2 $1] t))

(fn* M.pairs->table
  "Convert `seq` of `[[k, v] ...]` into `{k v ...}`"
  (where [seq] (seq? seq))
  (M.reduce (fn [acc [k v]] (M.set$ acc k v)) [] seq))

(fn* M.keys
  "Get keys from table, order is undetermined."
  (where [enumerable] (table? enumerable))
  ;; specify pairs iterators to be sure we get everything
  (M.map #(values $1) #(pairs enumerable)))

(fn* M.vals
  "Get values from table, order is undetermined."
  (where [enumerable] (table? enumerable))
  ;; specify pairs iterators to be sure we get everything
  (M.map #(values $2) #(pairs enumerable)))

(fn* M.intersperse
  "Intersperse `inter` between each value in `e`."
  ;; assocs obviously make no sense, functions are unclear which iter-args will
  ;; be a value and which is a key.
  (where [e inter] (seq? e))
  (M.reduce (fn*
              (where [acc v n] (= n (length ^e))) (M.append$ acc v)
              (where [acc v i]) (M.append$ acc v inter))
            [] e))

(fn* M.empty?
  "Check if table is empty"
  (where [t] (table? t))
  (= nil (next t)))

(fn* M.stream
  "Create stream container from given enumerable.

  A stream container can be used do defer computation on an enumerable. Not all
  `enum` function support streams. Streams must be \"resolved\" by calling
  `stream->seq'.

  ```
  (->> [4 2 3]
       (enum.stream) ;; create a stream over sequence
       (enum.map #(* 2 $1)) ;; evaluates (*2 4)
       (enum.filter #(<= 5 $1)) ;; then evaulates (<= 5 8)
       (enum.map #(* 10 $1)) ;; then (* 10 8)
       ;; we must \"resolve\" the stream into a concrete collection
       (enum.stream->seq)) ;; then stores [80], then repeats for 2, 3, etc
  ```"
  (where [t] (enumerable? t))
  {:enum t :funs []})

(fn* M.stream->seq
  "\"resolve\" stream into seq."
  (where [l] (and (stream? l) (or (seq? l.enum) (assoc? l.enum))))
  (M.map (fn [v k]
           (M.reduce (fn [acc f]
                       (match [(f acc k)]
                         ;; halt processing and drop from resulting seq
                         [stream-halt-marker] (M.reduced nil)
                         ;; keep processing but actually ignore the result
                         [stream-use-last-value-marker] (values acc)
                         ;; pass ahead
                         [stream-use-new-value-marker ?new-acc] (values ?new-acc)))
                     v l.funs))
         l.enum)
  ;; Functions must be juggled as they have unspecified behaviour.
  ;; We need to capture all return values and pack/unpack as we go.
  (where [l] (and (stream? l) (function? l.enum)))
  (->> (M.map (fn [...]
               (M.reduce (fn [acc f]
                           (let [new (M.pack (f (M.unpack acc)))]
                             (match new
                               [stream-halt-marker] (M.reduced nil)
                               [stream-use-last-value-marker] (values acc)
                               ;; drop the marker from our packed value
                               [stream-use-new-value-marker] (M.pack (M.unpack new 2)))))
                         (M.pack ...) l.funs))
             l.enum)
      ;; the above gives us [{1 :a :n 1} {1 :b :n 1} ...] so we have to flatten
      ;; that back out.
      (M.flatten)))

; (fn M.copy [t]
;   "Shallow copies values from `t` into a new table."
;   (collect [k v (pairs t)] (values k v)))

(values M)
