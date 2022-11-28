# ruin/maybe

- **[functions](#initfnl)**
- **[macros](#init-macrosfnl)**
- **[tests](#tests)**

# Init.fnl

**Table of contents**

- [`maybe`](#maybe)
- [`some`](#some)
- [`none`](#none)
- [`bind`](#bind)
- [`map`](#map)
- [`map-none`](#map-none)
- [`map-some`](#map-some)
- [`maybe?`](#maybe-1)
- [`none?`](#none-1)
- [`some?`](#some-1)
- [`unit`](#unit)
- [`unwrap`](#unwrap)

## `maybe`
Function signature:

```
(maybe ...)
```

Create an `some` or `none`.

A [`none`](#none) holds a `nil` value and only matches when called with at most 1 `nil` or no arguments.

[`some`](#some) may hold as many values as given.

Ex,

`(maybe nil) -> none`

`(maybe) -> none`

`(maybe 1) -> some`

`(maybe 1 2 3) -> some`



Match signatures:

`(where _ (and (< 0 arguments.n) (not= nil (. arguments 1)))) -> some`

`(where _ (or (= arguments.n 0) (and (= arguments.n 1) (= nil (. arguments 1))))) -> none`

See also [`some`](#some), [`none`](#none).

## `some`
Function signature:

```
(some ...)
```

Create `some`, if arguments match `(where _ (and (< 0 arguments.n) (not= nil (. arguments 1))))`, holds value of `(unpack arguments)`.

May be matched against with `[:some ...]` or [`some?`](#some-1). May also be [`unwrap`](#unwrap)ed into values.

Has `:n` key storing the number of values (after 1, the id).

## `none`
Function signature:

```
(none ...)
```

Create `none`, if arguments match `(where _ (or (= arguments.n 0) (and (= arguments.n 1) (= nil (. arguments 1)))))`, holds value of `nil`.

May be matched against with `[:none ...]` or [`none?`](#none-1). May also be [`unwrap`](#unwrap)ed into values.

Has `:n` key storing the number of values (after 1, the id).

## `bind`
Function signature:

```
(bind x f)
```

If `x` is `some`, call `f x` otherwise return `x`.

## `map`
Function signature:

```
(map maybe some-f ?none-f)
```

If maybe is some, call `some-f` with value.
                     If maybe is none, call `?none-f` if given or return `maybe`.
                     Called functions *may alter original type* if they return an alternate match value.

## `map-none`
Function signature:

```
(map-none maybe f)
```

If `maybe` is `none`, call `f` with value, othewise return `maybe`.

## `map-some`
Function signature:

```
(map-some maybe f)
```

If `maybe` is `some`, call `f` with value, othewise return `maybe`.

## `maybe?`
Function signature:

```
(maybe? v)
```

True if `v` is a `maybe`.

## `none?`
Function signature:

```
(none? v)
```

True if `v` a `none`.

## `some?`
Function signature:

```
(some? v)
```

True is `v` a `some`.

## `unit`
Function signature:

```
(unit ...)
```

Create an `some` or `none`.

A [`none`](#none) holds a `nil` value and only matches when called with at most 1 `nil` or no arguments.

[`some`](#some) may hold as many values as given.

Ex,

`(maybe nil) -> none`

`(maybe) -> none`

`(maybe 1) -> some`

`(maybe 1 2 3) -> some`



Match signatures:

`(where _ (and (< 0 arguments.n) (not= nil (. arguments 1)))) -> some`

`(where _ (or (= arguments.n 0) (and (= arguments.n 1) (= nil (. arguments 1))))) -> none`

See also [`some`](#some), [`none`](#none).

## `unwrap`
Function signature:

```
(unwrap maybe)
```

Unwrap `maybe` into values.


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->
# Init-macros.fnl

**Table of contents**

- [`maybe->`](#maybe-)
- [`maybe->*`](#maybe--1)
- [`maybe->>`](#maybe--2)
- [`maybe->>*`](#maybe--3)
- [`maybe-let`](#maybe-let)
- [`maybe-let*`](#maybe-let-1)

## `maybe->`
Function signature:

```
(maybe-> ...)
```

**Undocumented**

## `maybe->*`
Function signature:

```
(maybe->* ...)
```

**Undocumented**

## `maybe->>`
Function signature:

```
(maybe->> ...)
```

**Undocumented**

## `maybe->>*`
Function signature:

```
(maybe->>* ...)
```

**Undocumented**

## `maybe-let`
Function signature:

```
(maybe-let ...)
```

**Undocumented**

## `maybe-let*`
Function signature:

```
(maybe-let* ...)
```

**Undocumented**


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ creating some it wraps one value
✓ creating some it wont wrap single nil value
✓ creating some it does not wrap multiple values
✓ creating some it is some? and not none?
✓ creating some it works from unit
✓ creating none it wraps nil value
✓ creating none it wraps no value
✓ creating none it wont wrap non-nil value
✓ creating none it is none? and not some?
✓ creating none it works from unit
✓ let it handles one value expressions some
✓ let it does handle multi value expressions
✓ let it can NOT return multiple values
✓ let it short-circuts on error
✓ let* it handles all success
✓ let* it short-circuts on error and unpacks to `nil reason`
✓ map, map-some, map-none it maps over an some value
✓ map, map-some, map-none it does not map over an none value by default
✓ map, map-some, map-none it does map over some and none if given none-fn
✓ map, map-some, map-none it can alter type by return value
```
