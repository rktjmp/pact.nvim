# ruin/let

Note: Most of these functions follow their parent expressions, so `if-let`
behaves like `if`, where it accepts two expressions, a true and false branch,
vs `let` which accepts multiple body expressions after the binding table.

- **[macros](#init-macrosfnl)**
- **[tests](#tests)**

# Init-macros.fnl

**Table of contents**

- [`if-let`](#if-let)
- [`if-some-let`](#if-some-let)
- [`let-match`](#let-match)
- [`match-let`](#match-let)
- [`when-let`](#when-let)
- [`when-some-let`](#when-some-let)

## `if-let`
Function signature:

```
(if-let bindings if-expr ?else-expr)
```

Check `bindings` in order, if all are truthy, evaluate `if-expr`, otherwise `?else-expr` or nil.

  ```
  (if-let [a 10
           b 20]
    (+ a b)
    (print :otherwise))
  ```

## `if-some-let`
Function signature:

```
(if-some-let bindings if-expr ?else-expr)
```

Check `bindings` in order, if all are not nil, evaluate `if-expr`, otherwise `?else-expr` or nil.

  ```
  (if-let [a 10
           b 20]
    (+ a b)
    (print :otherwise))
  ```

## `let-match`
Function signature:

```
(let-match bindings body ...)
```

A mix of let-bindings and match-expressions.

  Similar to `match-try`, closer to Elixirs `with` expression in usage.

  `bindings` follows `let` but each left side expression may be a match
  expression, including `where` guards. Note that match has implicit `nil`
  checking, so if a binding may be let it shoud be `?name`.

  `body` may be one or more expressions, where the final expression may be
  `(else)` with a collection of match pattern-value pairs.

  ```
  (let-match [pat val
              (where ...) ...
              ... ...]
    body-expr
    ...
    (else
      pat val
      ... ...))
  ```

## `match-let`
Function signature:

```
(match-let bindings body ...)
```

A mix of let-bindings and match-expressions.

  Similar to `match-try`, closer to Elixirs `with` expression in usage.

  `bindings` follows `let` but each left side expression may be a match
  expression, including `where` guards. Note that match has implicit `nil`
  checking, so if a binding may be let it shoud be `?name`.

  `body` may be one or more expressions, where the final expression may be
  `(else)` with a collection of match pattern-value pairs.

  ```
  (let-match [pat val
              (where ...) ...
              ... ...]
    body-expr
    ...
    (else
      pat val
      ... ...))
  ```

## `when-let`
Function signature:

```
(when-let bindings ...)
```

Check `bindings` in order, if all are truthy, evaluate `...` or nil.

  ```
  (when-let [a 10
             b 20]
    (+ a b)
    (* a b)))
  ```

## `when-some-let`
Function signature:

```
(when-some-let bindings ...)
```

Check `bindings` in order, if all are not nil, evaluate `...` or nil.

  ```
  (when-let [a 10
             b 20]
    (+ a b)
    (* a b)))
  ```


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ kernel it kernelises
✓ match-let without shadowing it returns value
✓ match-let without shadowing it returns else matches
✓ match-let without shadowing it returns catch matches
✓ match-let without shadowing it can have multiple body clauses
✓ match-let without shadowing it can have multiple body clauses and an else
✓ match-let without shadowing it returns nil err on match fail if that is the value
✓ match-let without shadowing it returns all values
✓ match-let with shadowing locals it warns on rebinding (until matchless exists)
  match-let with shadowing locals it does allow rescoping _
✓ match-let with shadowing locals it warns when attempting to bind(?)/match a symbol that exists in outerscope not defined by us
  match-let with shadowing locals it returns value
✕ if-let it supports multiple bind values 
  -->let/test-let.fnl:146: mismatch: 
["hello" "bye"]
[["hello"]]
✓ if-let it works
✓ when-let it works
✓ if-some-let it works
✓ when-some-let it works
```
