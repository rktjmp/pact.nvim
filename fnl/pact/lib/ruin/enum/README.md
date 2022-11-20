# ruin/enum

`enum` functions generally accept a sequence (`[a b]`), an assoc (`{: a : b})`
or a generator - a function which when called returns a lua iterator.

These functions will attempt to call the correct `ipairs` or `pairs` where
appropriate (generators are simply called as given).

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

This behaviour may change in the future.

- **[functions](#initfnl)**
- **[tests](#tests)**
# Init.fnl

**Table of contents**

- [`reduce`](#reduce)
- [`map`](#map)
- [`all?`](#all)
- [`any?`](#any)
- [`append$`](#append)
- [`chunk-every`](#chunk-every)
- [`concat$`](#concat)
- [`copy`](#copy)
- [`each`](#each)
- [`empty?`](#empty)
- [`filter`](#filter)
- [`find`](#find)
- [`first`](#first)
- [`flat-map`](#flat-map)
- [`flatten`](#flatten)
- [`hd`](#hd)
- [`insert$`](#insert)
- [`keys`](#keys)
- [`last`](#last)
- [`pack`](#pack)
- [`pairs->table`](#pairs-table)
- [`reduced`](#reduced)
- [`remove$`](#remove)
- [`set$`](#set)
- [`shuffle$`](#shuffle)
- [`sort`](#sort)
- [`sort$`](#sort-1)
- [`split`](#split)
- [`table->pairs`](#table-pairs)
- [`tl`](#tl)
- [`unpack`](#unpack)
- [`vals`](#vals)

## `reduce`
Function signature:

```
(reduce [ (where [f] (function? f)) | (where [f ?initial t] (and (function? f) (seq? t))) | (where [f ?initial t] (and (function? f) (assoc? t))) | (where [f ?initial generator] (and (function? f) (function? generator))) | (where [f t] (and (function? f) (seq? t))) | (where [f t] (and (function? f) (assoc? t))) | (where [f generator] (and (function? f) (function? generator))) ])
```

Reduce `enumerable` by `f` with `?initial` as initial accumulator value if given.

  If `?initial` is not given, the first value from `enumerable` is used. `nil`
  is a valid initial value and distinct from not providing one.

  `f` should accept the accumulator then any arguments as per the iterator.

  `seqs` are automatically iterated with `ipairs`, `assocs` are iterated with `pairs`.

  Reduce may be terminated early by calling [`reduced`](#reduced) with the final `acc` value.

  Custom generators can be provided, which may either follow luas stateless-iterator style
  (see lua documentation) or stateful. Returning a single `nil` or no value
  from an iterator terminates iteration.

## `map`
Function signature:

```
(map [ (where [f] (function? f)) | (where [f enumerable] (and (function? f) (enumerable? enumerable))) ])
```

Collect `f x` for every `x` in `enumerable` into a seq. If `f x` returns
  `nil`, the value is NOT inserted to avoid creating sparse sequences. If you
  want true map behaviour, use [`reduce`](#reduce) and manually track and return your
  table length.

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

## `copy`
Function signature:

```
(copy t)
```

Shallow copies values from `t` into a new table.

## `each`
Function signature:

```
(each [ (where [f] (function? f)) | (where [f enumerable] (and (function? f) (enumerable? enumerable))) ])
```

See [`map`](#map) but for side effects, returns nil.

## `empty?`
Function signature:

```
(empty? [ (where [t] (table? t)) ])
```

Check if table is empty

## `filter`
Function signature:

```
(filter [ (where [pred] (function? pred)) | (where [pred t] (and (function? pred) (table? t))) ])
```

Collect every `x` in `t` where `pred` is true into a seq. Only accepts
  seq or assocs, use `map` or `reduce` to drop values from a custom iterator.

## `find`
Function signature:

```
(find [ (where [f t] (and (function? f) (enumerable? t))) ])
```

Return first value pair from `t` that `f` returns true for.

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

## `keys`
Function signature:

```
(keys [ (where [enumerable] (table? enumerable)) ])
```

Get values from table as an enumerable, order is undetermined.

## `last`
Function signature:

```
(last [ (where [seq] (seq? seq)) ])
```

Return last element of `seq`

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

## `reduced`
Function signature:

```
(reduced [ (where [value]) | (where _) ])
```

Terminate a reducer with value

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

Set `t.k` to `v`, return `t`. `k` and `v` may also be functions.

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
(vals [ (where [enumerable] (table? enumerable)) | (where [enumerable] (function? enumerable)) ])
```

Get values from table as an enumerable, order is undetermined.


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ reduce it handles seq
✓ reduce it handles assoc
✓ reduce it handles stl-custom iter
✓ reduce it handles custom stateless iterator
✓ reduced it can stop early
✓ map it handles empty tables
✓ map it handles seq
✓ map it handles stl-custom iter
✓ table->pairs it converts
✓ pairs->table it converts
✓ filter it handles seq
✓ filter it handles assoc
✓ filter it errors on inter-fn
✓ any? it finds one
✓ any? it finds none
✓ all? it finds all good
✓ all? it finds one bad
✓ find it returns found value
✓ find it returns nil on no find
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
✓ mixed tables it maps
✓ mixed tables it maps
```
