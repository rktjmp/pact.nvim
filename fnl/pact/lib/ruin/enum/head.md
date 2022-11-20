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
