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

;; Would love this but any custom seq-iterators will hit identity which might
;; be annoying, and is unfixable as lua always passes the *first* value back to
;; the generator, so even if custom iters returned val index, it would pass val
;; back.
;; Kind of depends on how accurately we really detect seq and
;; assoc, these could be passed to reduce-impl to order the values passed to f.
; (fn r-order-identity [...] (values ...))
; (fn r-order-v-k [i v] (values v i))
; (fn r-order-k-v [k v] (values k v))

(fn reduce-impl [f acc [gen invariant ctrl]]
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
          (match (f acc (M.unpack vals 1 n))
            ;; explicit stop, note this can return more than one value if more
            ;; than one was given to reduced, this allows find to return
            (reduced-marker ?new-acc) ?new-acc
            ;; nil is a valid acc value!
            (?new-acc) (reduce-impl f ?new-acc [gen invariant ctrl])
            _ (error "internal-error: reduce could not match next value"))))))

(fn* M.reduce
  "Reduce `enumerable` by `f` with `?initial` as initial accumulator value if given.

  If `?initial` is not given, the first value from `enumerable` is used. `nil`
  is a valid initial value and distinct from not providing one.

  `f' should accept the accumulator then any arguments as per the iterator.

  `seqs` are automatically iterated with `ipairs`, `assocs` are iterated with `pairs`.

  Reduce may be terminated early by calling `reduced' with the final `acc` value.

  Custom generators can be provided, which may either follow luas stateless-iterator style
  (see lua documentation) or stateful. Returning a single `nil` or no value
  from an iterator terminates iteration."
  (where [f] (function? f))
  #(M.reduce f $1 $2)
  ;; seq/assoc -> ipairs/pairs
  (where [f ?initial t] (and (function? f) (seq? t)))
  (reduce-impl f ?initial (M.pack (ipairs t)))
  (where [f ?initial t] (and (function? f) (assoc? t)))
  (reduce-impl f ?initial (M.pack (pairs t)))
  (where [f ?initial generator] (and (function? f) (function? generator)))
  (reduce-impl f ?initial (M.pack (generator)))
  ;; as above but inital is retrieved from ipairs/pairs
  (where [f t] (and (function? f) (seq? t)))
  (let [[iter a n] (ipairs t)
        (nn initial) (iter a n)]
    (reduce-impl f initial (M.pack iter a nn)))
  (where [f t] (and (function? f) (assoc? t)))
  (let [[iter a n] (pairs t)
        (nn initial) (iter a n)]
    (reduce-impl f initial (M.pack iter a nn)))
  (where [f generator] (and (function? f) (function? generator)))
  (let [[iter a n] (generator)
        (nn initial) (iter a n)]
    (reduce-impl f initial (M.pack iter a nn))))

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
  (let [fx (fn [acc i v]
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
  "Collect every `x` in `t` where `pred` is true into a seq. Only accepts
  seq or assocs, use `map` or `reduce` to drop values from a custom iterator.

  Can accept a stream."
  (where [pred] (function? pred))
  #(M.filter pred $1)
  (where [pred stream] (and (function? pred) (stream? stream)))
  (do
    (table.insert stream.funs #(if (pred $...)
                               (values stream-use-last-value-marker)
                               (values stream-halt-marker)))
    (values stream))
  (where [pred t] (and (function? pred) (enumerable? t)))
  (let [insert (if (or (seq? t) (function? t))
                 #(doto $1 (table.insert $3))
                 #(doto $1 (tset $2 $3)))
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
  "Return first value pair from `t` that `f` returns true for."
  (where [f t] (and (function? f) (enumerable? t)))
  (let [reducer (M.reduce (fn [_ ...] (if (f ...)
                                        ;; track index/key and value, etc
                                        (M.reduced (M.pack ...))
                                        (values nil))))]
    (match (reducer nil t)
      any (M.unpack any)
      nil nil)))

(fn* M.group-by
  "Group values of `enumerable` by the key from `f`.

  May return one value, the `key` to store the enumerable value under, or two
  values, where the first is the `key` and the second is the `value`.

  Function enumerables must always return two values.

  Keys may not be `nil`.

  Returns an assoc of sequences."
  (where [f] (function? f))
  #(M.group-by f $1)
  ;; tables (seq or assoc) always have a k v pair so we can be
  ;; confident in what to pass around
  (where [f e] (and (function? f) (table? e)))
  (M.reduce (fn [acc k v]
              (let [(key val) (f k v)
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
  (M.map #(. t $2) ks))

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

(fn* M.set$
  "Set `t.k` to `v`, return `t`. `k` and `v` may also be functions."
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
                        (#(M.reduce (fn [acc i [oi v]] (M.set$ acc oi i))
                                    {} $1)))]
    ;; recreate new seq by inserting values according to their sorted-index
    (M.reduce (fn [acc i v] (M.set$ acc (. sorted-keys i) v)) [] seq)))

;; x -> tuples

(fn* M.table->pairs
  "Convert a table of `{k v ...}` into `[[k v] ...]`"
  (where [t] (table? t))
  (M.map #[$1 $2] t))

(fn* M.pairs->table
  "Convert `seq` of `[[k, v] ...]` into `{k v ...}`"
  (where [seq] (seq? seq))
  (M.reduce (fn [acc i [k v]] (M.set$ acc k v)) [] seq))

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
              (where [acc n v] (= n (length ^e))) (M.append$ acc v)
              (where [acc i v]) (M.append$ acc v inter))
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
       (enum.map #(* 2 $2)) ;; evaluates (*2 4)
       (enum.filter #(<= 5 $2)) ;; then evaulates (<= 5 8)
       (enum.map #(* 10 $2)) ;; then (* 10 8)
       ;; we must \"resolve\" the stream into a concrete collection
       (enum.stream->seq)) ;; then stores [80], then repeats for 2, 3, etc
  ```"
  (where [t] (enumerable? t))
  {:enum t :funs []})

(fn* M.stream->seq
  "\"resolve\" stream into seq."
  (where [l] (and (stream? l) (or (seq? l.enum) (assoc? l.enum))))
  (M.map (fn [k v]
           (M.reduce (fn [acc i f]
                       (match [(f k acc)]
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
               (M.reduce (fn [acc _ f]
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
