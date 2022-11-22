# ruin/monad

- **[functions](#initfnl)**
- **[macros](#init-macrosfnl)**
- **[tests](#tests)**
# Init.fnl

**Table of contents**

- [`identity-m.bind`](#identity-mbind)
- [`identity-m.result`](#identity-mresult)
- [`m->`](#m-)
- [`maybe-m.bind`](#maybe-mbind)
- [`maybe-m.plus`](#maybe-mplus)
- [`maybe-m.result`](#maybe-mresult)
- [`state-m.bind`](#state-mbind)
- [`state-m.get`](#state-mget)
- [`state-m.result`](#state-mresult)
- [`state-m.set`](#state-mset)

## `identity-m.bind`
Function signature:

```
(identity-m.bind val fun)
```

**Undocumented**

## `identity-m.result`
Function signature:

```
(identity-m.result val)
```

**Undocumented**

## `m->`
Function signature:

```
(m-> monad-t ival ...)
```

**Undocumented**

## `maybe-m.bind`
Function signature:

```
(maybe-m.bind val fun)
```

**Undocumented**

## `maybe-m.plus`
Function signature:

```
(maybe-m.plus ...)
```

**Undocumented**

## `maybe-m.result`
Function signature:

```
(maybe-m.result val)
```

**Undocumented**

## `state-m.bind`
Function signature:

```
(state-m.bind mv f)
```

**Undocumented**

## `state-m.get`
Function signature:

```
(state-m.get key)
```

**Undocumented**

## `state-m.result`
Function signature:

```
(state-m.result v)
```

**Undocumented**

## `state-m.set`
Function signature:

```
(state-m.set key val)
```

**Undocumented**


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->
# Init-macros.fnl

**Table of contents**

- [`monad->`](#monad-)
- [`monad->>`](#monad--1)
- [`monad-let`](#monad-let)
- [`monad-let*`](#monad-let-1)

## `monad->`
Function signature:

```
(monad-> opts ...)
```

**Undocumented**

## `monad->>`
Function signature:

```
(monad->> opts ...)
```

**Undocumented**

## `monad-let`
Function signature:

```
(monad-let {:bind bind :unit unit} bindings ...)
```

Looks like a (let) but automatically wrap results in the given monad,
  returns a monad. Each 'right-side' of the let binding is wrapped by `unit`.

## `monad-let*`
Function signature:

```
(monad-let* monad ...)
```

Same as [`monad-let`](#monad-let) but unwraps the final result into the monad value.


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ let it returns a wrapped value
✓ let it can bind multiple values in the expression
✓ let it can NOT bind multiple values from the body
✓ let* it returns an unwrapped value
✓ let* it can bind multiple values in the expression
✓ let* it can bind multiple values from the body if monad supports it
✓ identity-m it works
✓ maybe-m it works
✓ maybe-m it lets
✓ state-m it works
```
