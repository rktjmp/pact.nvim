# ruin/fn

- **[functions](#initfnl)**
- **[macros](#init-macrosfnl)**
- **[tests](#tests)**
# Init.fnl

**Table of contents**

- [`tap`](#tap)
- [`then`](#then)

## `tap`
Function signature:

```
(tap x f)
```

Call (f x) then return (values x)

## `then`
Function signature:

```
(then x f)
```

Return value of (f x)


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->
# Init-macros.fnl

**Table of contents**

- [`fn*`](#fn)
- [`fn+`](#fn-1)

## `fn*`
Function signature:

```
(fn* ?name ?docstring (?where ...) (?expr ...) ...)
```

Create a new pattern-matched & arity-matched function.

```
(fn* x
  (where [a])
  (print :one-argument a)
  (where [100 name] (= :string (type name)))
  (print :100-hello name)
  (where _)
  (print :otherwise))
```

When called, [`fn*`](#fn) functions (termed *matched functions*) compare the arguments
recieved against the patterns defined and executes the matching function body.

Patterns are checked in the order they are defined and have strict arity
checks (unless `...` or `& x` are in the argument list, then the arity is
defined as *at least n* where *n* is the number of other arguments).

Matched functions may be anonymous, which requires all match heads and bodies
to be defined at once, or they may be named. Named functions may have zero
match heads and body pairs, able to be defined later by [`fn+`](#fn-1).

`?name` may be a symbol or multisym to attach to existing tables.

After `name`, sequential pairs of `(where [arg arg ...] (?clauses ...))
(expression)` can be provided. The `where` clauses define the function pattern
match and the expression is the function body.

Matches are checked in the order given, so higher specificity patterns should
be first.

Arguments follow `(match)` semantics and may be symbols or values, or
destructing expressions. Arguments may not be nil unless defined as nil-able by
prefixing with `?` or with the explicit value (eg: `[a b nil]`).

As with `(match)`, values in clauses may match previously defined in-scope
symbols. This is explicity opt-in for [`fn*`](#fn), if a symbol name matches an
existing symbol, an error is raised. If the match is intentional the symbol may
be prefixed with `^` to *pin* the value.

See also [`fn+`](#fn-1) to add additional patterns to an existing function.

```
(local var 10)
(fn* x
  ;;    (x 100)
  ;; => matches-var
  (where [^var])
  (print :matches-var)

  ;;    (x 10)
  ;; => one-argument 10
  (where [a])
  (print :one-argument a)

  ;;    (x 100 :fen)
  ;; => 100-hello fen
  ;; note we define this before the next as the pattern ahead would also match
  (where [100 name] (= :string (type name)))
  (print :100-hello name)

  ;;   (x 10 20)
  ;;=> two-arguments 10 20
  (where [a b])
  (print :two-arguments a b)

  ;;    (x 1 2 3)
  ;; => 1 2 3
  ;; => and-rest 0
  ;;    (x 1 2 3 10 11 12)
  ;; => 1 2 3
  ;; => and-rest 3
  (where [a b c & rest])
  (do
    (print a b c)
    (print :and-rest (length rest)))

  ;; anything else that does not match will call this
  (where _)
  (print :no-match ...))
  ```

## `fn+`
Function signature:

```
(fn+ name pattern expr ...)
```

Attach new function body to `name`. `name` must have been defined via [`fn*`](#fn)
  before calling.

  Functions similarly to [`fn*`](#fn) except:

  - `pattern` may ommit `(where)` if desired.
  - all expressions after the guard are included into the function body.

  ```fennel
  (fn* map)
  (fn+ map [a]
    (print a)
    (* a a))
  ```

  See also [`fn*`](#fn).


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ fn* ... code generation it correctly constructs ... function argument for body
✓ fn* ... code generation it changes clauses to select
✓ fn* ... and & usage it allows for n+ arity
✓ fn* ... and & usage it accepts ... as only argument
✓ fn* scope protection it wont compile if a pinned symbol is not in-scope
✓ fn* scope protection it can match pinned in-scope syms
✓ fn* scope protection it can match pinned in-scope multi-syms
✓ fn* scope protection it raises on ^& rest and ^...
✓ fn* it has help
✓ fn* it must have where-expr
✓ fn* it accepts [a & rest]
✓ fn* it handles nils in [a & rest]
✓ fn* it all in one
✓ fn* it raises error if called with no bodies
✓ fn* it raises when called with no default body
✓ fn* it can define a default with _
✓ fn* it can define a default with (where _)
✓ fn* it can recieve nil in ?sym form
✓ fn* it can recieve nil when explicitly in head
✓ fn* it can differentiate between (f x) and (f x nil)
✓ fn* it can be defined multisym
✓ fn* it can recurse
✓ fn* it works when returned or embedded in something
✓ fn* it can be anonymous (but fn+ wont work)
✓ fn* it can match on nil
✓ fn* it can match on mixed nils via nil or ?arg
✓ fn* it can build progressively
✓ fn+ it can attach to fn* with existing bodies
✓ fn+ it can attach to fn* head
✓ fn+ it will not compile without fn*
✓ fn+ it must have args
```
