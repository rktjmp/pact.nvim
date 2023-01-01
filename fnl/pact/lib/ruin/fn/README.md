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

When called, [`fn*`](#fn) functions compare the arguments recieved against the
patterns defined and executes the first matching function body.

[`fn*`](#fn) functions are useful if you want a very strict API (by default they
will raise an error if no pattern matched the arguments recieved), or to
simplify dispatching against different argument types. The `enum` module
uses this macro heavily as an example.

Generally you probably should prefer regular `fn` functions with `match` unless
you know you want very strict argument checks or particular behaviour depending
on the arguments received.

Patterns are checked in the order they are defined and have strict arity
checks (unless `...` is in the argument list, then the arity is
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

Arguments matching follow `(match)` semantics *except `& rest` is unsupported
and `...` is* - this aligns closer to regular function arguments.
Arguments may be symbols or values. Destructuring is supported. Arguments may
not be nil unless defined as nil-able by prefixing with `?` or with the
explicit value (eg: `[a b nil]`).

As with `(match)`, values in patterns may match previously defined in-scope
symbols. This is explicity opt-in for [`fn*`](#fn), and symbols should be prefixed with
`^` to *"pin"* the value and indicate it should match the outer scope.

A default "match all" handler can be defined with `(where _)`, the handler
will receive `...` as an argument.

See also [`fn+`](#fn-1) to add additional patterns to an existing function.

Each call to `fn*` creates 4 local variables (3 if the function is assigned to
a field of an existing table). The function bodies specified with `fn*` do
not allocate additional variables. Lua has a limit of 200 local variables, you
can create new scopes with `(do)`.

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
  (where [a b c ...])
  (do
    (print a b c)
    (print :and-rest (select :### ...)))

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

  Each call to `fn+` creates a local variable (used by fennel to assign the
  function to the dispatcher), which may impact large modules. Lua has a limit
  of 200 local variables, you can create new scopes with `(do)`.


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ fn* { } it {: y}
✓ fn* { } it {: y}
✓ fn* { } it {:x y}
✓ fn* { } it {:x y}
✓ fn* ... and & validation it must have & at the second last position
✓ fn* ... code generation it correctly constructs ... function argument for body
✓ fn* ... code generation it changes clauses to select
✓ fn* ... and & usage it allows for n+ arity
✓ fn* ... and & usage it accepts ... as only argument
✓ fn* scope protection it will compile with shared symbols
✓ fn* scope protection it wont compile with {: ^x}
✓ fn* scope protection it wont compile if a pinned symbol is not in-scope
✓ fn* scope protection it can match pinned in-scope syms
✓ fn* scope protection it can match pinned in-scope multi-syms
✓ fn* scope protection it raises on ^& rest and ^...
✓ fn* it has help
✓ fn* it must have where-expr
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
✓ bugfixes it clauses can use multisyms
✓ bugfixes it can use nil in clause
✓ bugfixes it can use $1
✓ bugfixes it passes ... to default handler
✓ bugfixes it reconstructs the first part of a multisym in clauses with shadow bind
```
