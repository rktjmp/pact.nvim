# ruin/enum

`enum` functions generally accept a sequence (`[a b]`), an assoc (`{: a : b})`
or a generator - a function which when called returns a lua iterator. Some
functions accept a `stream` (see below).

These functions will attempt to call the correct `ipairs` or `pairs` where
appropriate (generators are simply called as given).

When iterating sequences or assocs, **functions are always passed `value
key`**. This is generally more ergonomic when working with sequences (`(E.map
print seq)` vs `(E.map #(print $2) seq)`) and *mostly* ergonomic when working
with assocs - and reduces the potential cognitive guess work by having both
types behave the same instead of assocs acting as `key value`.

As lua does not natively distinguish between sequences (*contiguous* numerically
indexed tables from `1` to  `n`) and tables, the table type is determined by
`seq?` and `assoc?` as defined in the `type` module.

Any table with a value for the key `1` is considered an sequence, as it's
unreasonable to exhaustively check every key in a table. This means mixed-key
tables *with a key for `1`* are iterated by `ipairs`.

```fennel
(map print {:1 :first :color :red}) ; => 1 first
```

To force a mixed-key table to iterate all values, you can pass a generator with
`pairs`.

```fennel
(map print #(pairs {:1 :first :color :red})) ; => 1 first; color red
```

Functions suffixed with `$` modify the given table "in place" and return their
first argument.

```fennel
(enum.set$ t :a 1)
;; equivalent to
(doto t
  (tset :a 1))
```

Streams allow deferred execution of computations against an enumerable. This
can be more performant as intermediary collections are not created.

```fennel
(->> [4 2 3]
     (enum.map #(* 2 $1)) ;; first sequence created => [8 4 6]
     (enum.filter #(<= 5 $1)) ;; second sequence => [8 6]
     (enum.map #(* 10 $1))) ;; third => [80 60]
```

```fennel
(->> [4 2 3]
     (enum.stream) ;; create a stream over sequence
     (enum.map #(* 2 $1)) ;; evaluates (*2 4)
     (enum.filter #(<= 5 $1)) ;; then evaulates (<= 5 8)
     (enum.map #(* 10 $1)) ;; then (* 10 8)
     ;; we must "resolve" the stream into a concrete collection
     (enum.stream->seq)) ;; then stores [80], then repeats for 2, 3, etc
```

- **[functions](#initfnl)**
- **[tests](#tests)**

# Init.fnl

**Table of contents**

- [`reduce`](#reduce)
- [`map`](#map)
- [`all?`](#all)
- [`any?`](#any)
- [`append$`](#append)
- [`breadth-walk`](#breadth-walk)
- [`chunk-every`](#chunk-every)
- [`concat$`](#concat)
- [`depth-walk`](#depth-walk)
- [`dot`](#dot)
- [`each`](#each)
- [`empty?`](#empty)
- [`filter`](#filter)
- [`find`](#find)
- [`first`](#first)
- [`flat-map`](#flat-map)
- [`flatten`](#flatten)
- [`group-by`](#group-by)
- [`hd`](#hd)
- [`insert$`](#insert)
- [`intersperse`](#intersperse)
- [`keys`](#keys)
- [`last`](#last)
- [`merge$`](#merge)
- [`pack`](#pack)
- [`pairs->table`](#pairs-table)
- [`pluck`](#pluck)
- [`reduced`](#reduced)
- [`reject`](#reject)
- [`remove$`](#remove)
- [`set$`](#set)
- [`shuffle$`](#shuffle)
- [`sort`](#sort)
- [`sort$`](#sort-1)
- [`split`](#split)
- [`stream`](#stream)
- [`stream->seq`](#stream-seq)
- [`table->pairs`](#table-pairs)
- [`tl`](#tl)
- [`unique`](#unique)
- [`unpack`](#unpack)
- [`vals`](#vals)

## `reduce`
Function signature:

```
(reduce [ (where [f] (function? f)) | (where [f ?initial t] (and (function? f) (seq? t))) | (where [f ?initial t] (and (function? f) (assoc? t))) | (where [f ?initial generator] (and (function? f) (function? generator))) | (where [f t] (and (function? f) (seq? t))) | (where [f t] (and (function? f) (assoc? t))) | (where [f generator] (and (function? f) (function? generator))) ])
```

Reduce `enumerable` by `f` with `?initial` as initial accumulator value if given.

  If `?initial` is not given, the first value from `enumerable` is used. `nil`
  is a valid initial value and distinct from not providing one. When enumerable is
  a generator function, only the first value from the function is used as the default
  initial value.

  `f` should accept the accumulator then any arguments as per the iterator, be
  aware of the iterator rules outlined above.

  `seqs` are automatically iterated with `ipairs`, `assocs` are iterated with `pairs`.

  Reduce may be terminated early by calling [`reduced`](#reduced) with the final `acc` value.

  Custom generators can be provided, which may either follow luas stateless-iterator style
  (see lua documentation) or stateful. Returning a single `nil` or no value
  from an iterator terminates iteration.

## `map`
Function signature:

```
(map [ (where [f] (function? f)) | (where [f stream] (and (function? f) (stream? stream))) | (where [f enumerable] (and (function? f) (enumerable? enumerable))) ])
```

Collect `f x` for every `x` in `enumerable` into a seq. If `f x` returns
  `nil`, the value is NOT inserted to avoid creating sparse sequences. If you
  want true map behaviour, use [`reduce`](#reduce) and manually track and return your
  table length.

  Can accept a stream.

## `all?`
Function signature:

```
(all? [ (where [f t] (and (function? f) (enumerable? t))) ])
```

Return true if `f` returns true for all member of `t`

## `any?`
Function signature:

```
(any? [ (where [f t] (and (function? f) (enumerable? t))) ])
```

Return true if `f` returns true for any member of `t`

## `append$`
Function signature:

```
(append$ [ (where [seq ...] (and (seq? seq) (< 0 (select "#" ...)))) ])
```

Append `v1 v2 ...` to `seq` and return `seq`

## `breadth-walk`
Function signature:

```
(breadth-walk [ (where [f node next-identity] (and (function? f) (table? node) (function? next-identity))) | (where [f node ?acc next-identity] (and (function? f) (table? node) (function? next-identity))) ])
```

Visit every node in a graph, breadth first. See [`depth-walk`](#depth-walk) for details on arguments.

  `history` currently underconstruction...

  `history` in `breadth-walk` is a seq of seqs where each seq is another depth level.

## `chunk-every`
Function signature:

```
(chunk-every [ (where [seq n] (and (seq? seq) (number? n))) | (where [seq n ?fill] (and (seq? seq) (number? n))) ])
```

Split `seq` by `n` into `[[v1 .. vn] ...]` optionally fill tail with `?fill`

## `concat$`
Function signature:

```
(concat$ [ (where [seq seq-1] (and (seq? seq) (seq? seq-1))) | (where [seq seq-1 seq-2 ...] (and (seq? seq) (seq? seq-1) (seq? seq-2))) ])
```

Concatenate the values of `seq-1` (and any other seqs) into `seq`.

## `depth-walk`
Function signature:

```
(depth-walk [ (where [f node next-identity] (and (function? f) (table? node) (function? next-identity))) | (where [f node ?acc next-identity] (and (function? f) (table? node) (function? next-identity))) ])
```

Visit every node in a graph, depth first.

  Accepts a function `f`, a head `node`, optionally an `acc` value and a
  `next-identity` function.

  If an acc value is provided (may be nil) then `f` is called with `acc node
  history` otherwise its called with `node history` where history is a list of
  visited nodes in the current branch.

  `next-identity` is called with the current `node` and `history` and should
  return the a list of the next nodes to visit, an empty list or nil.

  By default no provisions are taken to avoid loops or optimisations for
  visited nodes, these should be filtered in `next-identity`.

## `dot`
Function signature:

```
(dot [ (where [k]) | (where [k t] (table? t)) ])
```

Get value of `k` from `t`.

## `each`
Function signature:

```
(each [ (where [f] (function? f)) | (where [f stream] (and (function? f) (stream? stream))) | (where [f enumerable] (and (function? f) (enumerable? enumerable))) ])
```

See [`map`](#map) but for side effects, returns nil.

  Can accept a stream.

## `empty?`
Function signature:

```
(empty? [ (where [t] (table? t)) ])
```

Check if table is empty

## `filter`
Function signature:

```
(filter [ (where [pred] (function? pred)) | (where [pred stream] (and (function? pred) (stream? stream))) | (where [pred t] (and (function? pred) (or (seq? t) (assoc? t)))) ])
```

Collect every `x` in `t` where `pred` is true into a seq.

  Only accepts seq or assocs, use `map` or `reduce` to drop values from a
  custom iterator.

  Can accept a stream.

## `find`
Function signature:

```
(find [ (where [f e] (and (function? f) (enumerable? e))) ])
```

Return first value from `e` that `f` returns true for.

  Note this currently means `find` returns `(value index)` or `(value key)` for
  tables

## `first`
Function signature:

```
(first [ (where [seq] (seq? seq)) ])
```

Return first element of `seq`

## `flat-map`
Function signature:

```
(flat-map [ (where [f] (function? f)) | (where [f enumerable] (and (function? f) (enumerable? enumerable))) ])
```

**Undocumented**

## `flatten`
Function signature:

```
(flatten [ (where [seq] (seq? seq)) ])
```

Flatten a sequence of sequences into one sequence.

## `group-by`
Function signature:

```
(group-by [ (where [f] (function? f)) | (where [f e] (and (function? f) (table? e))) | (where [f e] (and (function? f) (function? e))) ])
```

Group values of `enumerable` by the key from `f`.

  May return one value, the `key` to store the enumerable value under, or two
  values, where the first is the `key` and the second is the `value`.

  Function enumerables must always return both the group-key and value.

  Keys may not be `nil`.

  Returns an assoc of sequences.

## `hd`
Function signature:

```
(hd [ (where [seq] (seq? seq)) ])
```

Return first element of `seq`

## `insert$`
Function signature:

```
(insert$ [ (where [seq i v] (and (seq? seq) (number? i))) ])
```

Insert `v` into `seq` at `i` and return `seq`. Accepts negative indexes.

## `intersperse`
Function signature:

```
(intersperse [ (where [e inter] (seq? e)) ])
```

Intersperse `inter` between each value in `e`.

## `keys`
Function signature:

```
(keys [ (where [enumerable] (table? enumerable)) ])
```

Get keys from table, order is undetermined.

## `last`
Function signature:

```
(last [ (where [seq] (seq? seq)) ])
```

Return last element of `seq`

## `merge$`
Function signature:

```
(merge$ [ (where [a b] (and (table? a) (table? b))) | (where [a b f] (and (table? a) (table? b) (function? f))) ])
```

For every key-value pair in b, copy it to a. Optionally accepts f to resolve
  conflicts, called with the key name, `a` value and `b` value, otherwise
  replaces.

## `pack`
Function signature:

```
(pack ...)
```

Insert all given arguments, in order, into a table and define the key :n for
  the number of arguments stored. Backport of < 5.1 `table.pack`.

## `pairs->table`
Function signature:

```
(pairs->table [ (where [seq] (seq? seq)) ])
```

Convert `seq` of `[[k, v] ...]` into `{k v ...}`

## `pluck`
Function signature:

```
(pluck [ (where [t ks] (and (table? t) (seq? ks))) ])
```

For each key in `ks`, get value from `t`, Returns seq.

## `reduced`
Function signature:

```
(reduced [ (where []) | (where [?value]) | (where _) ])
```

Terminate a reducer with value

## `reject`
Function signature:

```
(reject pred ...)
```

Complement of [`filter`](#filter)

## `remove$`
Function signature:

```
(remove$ [ (where [seq i] (and (seq? seq) (number? i))) ])
```

Remove value at index `i` from `seq` and return `seq`. Accepts negative indexes.

## `set$`
Function signature:

```
(set$ [ (where [t k ?v] (table? t)) | (where [t] (table? t)) | (where [t k] (table? t)) ])
```

Set `t.k` to `v`, return `t`.

  This differs from Fennels `set`/`tset` by returning the table `t` and it may
  be used in pipelines.

## `shuffle$`
Function signature:

```
(shuffle$ [ (where [seq] (seq? seq)) ])
```

Shuffle sequence in place

## `sort`
Function signature:

```
(sort [ (where [f] (function? f)) | (where [f seq] (function? f) (seq? seq)) ])
```

Create new seq by sorting seq by `f`.

## `sort$`
Function signature:

```
(sort$ [ (where [f] (function? f)) | (where [seq] (seq? seq)) | (where [f seq] (and (function? f) (seq? seq))) ])
```

Sort seq *in place* by `f`, returns `seq`

## `split`
Function signature:

```
(split [ (where [seq index] (and (seq? seq) (number? index) (<= 1 index))) ])
```

Return `seq` in two parts, split at `index`.

## `stream`
Function signature:

```
(stream [ (where [t] (enumerable? t)) ])
```

Create stream container from given enumerable.

  A stream container can be used do defer computation on an enumerable. Not all
  `enum` function support streams. Streams must be "resolved" by calling
  [`stream->seq`](#stream-seq).

  ```
  (->> [4 2 3]
       (enum.stream) ;; create a stream over sequence
       (enum.map #(* 2 $1)) ;; evaluates (*2 4)
       (enum.filter #(<= 5 $1)) ;; then evaulates (<= 5 8)
       (enum.map #(* 10 $1)) ;; then (* 10 8)
       ;; we must "resolve" the stream into a concrete collection
       (enum.stream->seq)) ;; then stores [80], then repeats for 2, 3, etc
  ```

## `stream->seq`
Function signature:

```
(stream->seq [ (where [l] (and (stream? l) (or (seq? l.enum) (assoc? l.enum)))) | (where [l] (and (stream? l) (function? l.enum))) ])
```

"resolve" stream into seq.

## `table->pairs`
Function signature:

```
(table->pairs [ (where [t] (table? t)) ])
```

Convert a table of `{k v ...}` into `[[k v] ...]`

## `tl`
Function signature:

```
(tl [ (where [seq] (seq? seq)) ])
```

Return all but first element of `seq`

## `unique`
Function signature:

```
(unique [ (where [seq] (seq? seq)) | (where [seq identity] (and (seq? seq) (function? identity))) ])
```

Remove any duplicate values from `seq`. Optionally accepts an `identity`
  function.

  By default all values are compared directly, so different tables that have
  the same content are considered different values. The identity function can
  be used to 'hash' complex value types into an appropriate comparison value.

## `unpack`
Function signature:

```
(unpack [ (where [t] (table? t)) | (where [t i] (and (table? t) (number? i))) | (where [t i j] (and (table? t) (number? i) (number? j))) ])
```

Unpack a packed table, automatically uses `t.n` if present
  (ie. the table was [`pack`](#pack)ed).

## `vals`
Function signature:

```
(vals [ (where [enumerable] (table? enumerable)) ])
```

Get values from table, order is undetermined.


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ pack, unpack it unpacks
✓ reduce it handles seq
✓ reduce it handles assoc
✓ reduce it handles stl-custom iter
✓ reduce it handles custom stateless iterator
✓ reduced it can stop early
✓ map it handles empty tables
✓ map it handles seq
✓ map it handles stl-custom iter
✓ each it works
✓ intersperse it works
✓ table->pairs it converts
✓ pairs->table it converts
✓ filter it handles seq
✓ filter it handles assoc
✓ filter it errors on inter-fn
✓ any? it finds one
✓ any? it finds none
✓ all? it finds all good
✓ all? it finds one bad
✓ find it returns found key, value
✓ find it returns nil on no find
✓ unique it strips uniques
✓ group-by it table groups with just key
✓ group-by it table groups with key, value
✓ group-by it function groups errors with just key
✓ group-by it function groups with key, value
✓ set$ it sets a value in-place
✓ set$ it updates a value in-place
✓ set$ it removes a value in-place without respect to seq or assoc
✓ set$ it partial application
✓ insert$ it inserts in place like table.insert
✓ insert$ it accepts negative indexes
✓ remove$ it removes in place like table.remove
✓ remove$ it accepts negative indexes
✓ append$ it adds to end of seq, in place
✓ append$ it acccepts any number of arguments
✓ append$ it throws on no value
✓ sort$ it sorts in-place
✓ sort it sorts into new table
✓ flatten it flattens a seq
✓ flatten it only flattens one level
✓ flatten it only accepts seq
✓ concat$ it concats seqs
✓ concat$ it only accepts seq
✓ chunk-every it chunk 6 by 2
✓ chunk-every it chunk 6 by 4
✓ chunk-every it chunk 6 by 1
✓ chunk-every it chunk 6 by 4 with fill
✓ chunk-every it chunk [] by 4 with fill
✓ hd, first it gets first element
✓ hd, first it returns nil if no elements
✓ last it gets last element
✓ tl it gets all after first element
✓ tl it returns empty list if no more elements?
✓ split it splits in two
✓ split it splits into [] [...]
✓ split it splits into [...] [6]
✓ split it splits into [...] []
  split it splits via -index
✓ vals it works on seq
✓ vals it works on assoc
  vals it works on function
✓ keys it works on seq
✓ keys it works on assoc
  keys it works on function
✓ empty? it works on seq
✓ empty? it works on assoc
✓ shuffle$ it shuffles a list
✓ mixed tables it maps naturally
✓ mixed tables it maps with iterator
✓ stream it simple map over seq
✓ stream it can map->filter seq
✓ stream it works with each seq
✓ stream it works with assocs?
✓ stream it works with functions?
✓ pluck it works with assocs
✓ pluck it works with tables
✓ merge it merges new keys
✓ merge it replaces old keys
✓ merge it conflict resolves old keys
```
