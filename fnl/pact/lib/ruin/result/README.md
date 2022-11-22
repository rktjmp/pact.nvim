# ruin/result

*Note*, between `match`, `match-try`, `match-let`, etc, you can get very
similar behaviour in a more idiomatic style.

- **[functions](#initfnl)**
- **[macros](#init-macrosfnl)**
- **[tests](#tests)**
# Init.fnl

**Table of contents**

- [`result`](#result)
- [`ok`](#ok)
- [`err`](#err)
- [`bind`](#bind)
- [`err?`](#err-1)
- [`join`](#join)
- [`map`](#map)
- [`map-err`](#map-err)
- [`map-ok`](#map-ok)
- [`ok?`](#ok-1)
- [`result?`](#result-1)
- [`unit`](#unit)
- [`unwrap`](#unwrap)
- [`unwrap!`](#unwrap-1)
- [`unwrap-or-raise`](#unwrap-or-raise)

## `result`
Function signature:

```
(result ...)
```

Create an `ok` or `err`.

An [`err`](#err) is strictly matched against `[nil any ...]`, while [`ok`](#ok) is anything else.

This allows for correctly matching *non-error* `nil` values where that is appropriate.

Ex,

`(result nil :broken) -> err`

`(result nil) -> ok`

`(result nil nil) -> ok`



Match signatures:

`(where _ (not (and (<= 2 arguments.n) (= nil (. arguments 1))))) -> ok`

`(where [nil] (<= 2 arguments.n)) -> err`

See also [`ok`](#ok), [`err`](#err) which have different match specs.

## `ok`
Function signature:

```
(ok ...)
```

Create `ok`, if arguments match `arguments`, holds value of `(unpack arguments)`.

May be matched against with `[:ok ...]` or [`ok?`](#ok-1). May also be [`unwrap`](#unwrap)ed into values.

Has `:n` key storing the number of values (after 1, the id).

## `err`
Function signature:

```
(err ...)
```

Create `err`, if arguments match `arguments`, holds value of `(unpack arguments)`.

May be matched against with `[:err ...]` or [`err?`](#err-1). May also be [`unwrap`](#unwrap)ed into values.

Has `:n` key storing the number of values (after 1, the id).

## `bind`
Function signature:

```
(bind x f)
```

If `x` is `ok`, call `f x` otherwise return `x`.

## `err?`
Function signature:

```
(err? v)
```

True if `v` a `err`.

## `join`
Function signature:

```
(join r1 r2)
```

**Undocumented**

## `map`
Function signature:

```
(map result ok-f ?err-f)
```

If result is ok, call `ok-f` with value.
                     If result is err, call `?err-f` if given or return `result`.
                     Called functions *may alter original type* if they return an alternate match value.

## `map-err`
Function signature:

```
(map-err result f)
```

If `result` is `err`, call `f` with value, othewise return `result`.

## `map-ok`
Function signature:

```
(map-ok result f)
```

If `result` is `ok`, call `f` with value, othewise return `result`.

## `ok?`
Function signature:

```
(ok? v)
```

True is `v` a `ok`.

## `result?`
Function signature:

```
(result? v)
```

True if `v` is a `result`.

## `unit`
Function signature:

```
(unit ...)
```

Create an `ok` or `err`.

An [`err`](#err) is strictly matched against `[nil any ...]`, while [`ok`](#ok) is anything else.

This allows for correctly matching *non-error* `nil` values where that is appropriate.

Ex,

`(result nil :broken) -> err`

`(result nil) -> ok`

`(result nil nil) -> ok`



Match signatures:

`(where _ (not (and (<= 2 arguments.n) (= nil (. arguments 1))))) -> ok`

`(where [nil] (<= 2 arguments.n)) -> err`

See also [`ok`](#ok), [`err`](#err) which have different match specs.

## `unwrap`
Function signature:

```
(unwrap result)
```

Unwrap `result` into values.

## `unwrap!`
Function signature:

```
(unwrap! result)
```

Call `(error ...)` if `result` is an `err` otherwise return `(unwrap result)`

## `unwrap-or-raise`
Function signature:

```
(unwrap-or-raise result)
```

Call `(error ...)` if `result` is an `err` otherwise return `(unwrap result)`


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->
# Init-macros.fnl

**Table of contents**

- [`result->`](#result-)
- [`result->*`](#result--1)
- [`result->>`](#result--2)
- [`result->>*`](#result--3)
- [`result-let`](#result-let)
- [`result-let*`](#result-let-1)

## `result->`
Function signature:

```
(result-> ...)
```

**Undocumented**

## `result->*`
Function signature:

```
(result->* ...)
```

**Undocumented**

## `result->>`
Function signature:

```
(result->> ...)
```

**Undocumented**

## `result->>*`
Function signature:

```
(result->>* ...)
```

**Undocumented**

## `result-let`
Function signature:

```
(result-let ...)
```

**Undocumented**

## `result-let*`
Function signature:

```
(result-let* ...)
```

**Undocumented**


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ creating ok it wraps one value
✓ creating ok it wraps one nil value
✓ creating ok it wraps multiple values
✓ creating ok it wraps (nil any) value
✓ creating ok it is ok? and not err?
✓ creating ok it works from unit
✓ creating err it wraps any value
✓ creating err it wraps one value
✓ creating err it wraps nil value
✓ creating err it will wrap multiple values
✓ creating err it is not ok? and is err?
✓ creating err it works from unit
✓ result-let it handles all success
✓ result-let it can NOT return multiple values
✓ result-let it short-circuts on error
✓ result-let* it handles all success
✓ result-let* it can return multiple values
✓ result-let* it short-circuts on error and unpacks to `nil reason`
✓ map, map-ok, map-err it maps over an ok value
✓ map, map-ok, map-err it does not map over an err value by default
✓ map, map-ok, map-err it does map over ok and err if given err-fn
✓ map, map-ok, map-err it can alter type by return value
```
