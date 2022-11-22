(fn match? [pattern expr ...]
  "Test `expr` against `pattern`, returns `true` or `false`"
  (assert-compile (= 0 (select :# ...)) "too many expressions" ...)
  `(match ,expr
     ,pattern true
     _# false))

{: match?}
