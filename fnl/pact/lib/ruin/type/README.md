# ruin/type

- **[functions](#initfnl)**
- **[macros](#init-macrosfnl)**
- **[tests](#tests)**

# Init.fnl

**Table of contents**

- [`assoc?`](#assoc)
- [`bool?`](#bool)
- [`boolean?`](#boolean)
- [`function?`](#function)
- [`is-any?`](#is-any)
- [`is?`](#is)
- [`nil?`](#nil)
- [`not-nil?`](#not-nil)
- [`number?`](#number)
- [`of`](#of)
- [`seq?`](#seq)
- [`set-type`](#set-type)
- [`string?`](#string)
- [`table?`](#table)
- [`thread?`](#thread)
- [`type-is-any?`](#type-is-any)
- [`type-is?`](#type-is)
- [`type-of`](#type-of)
- [`userdata?`](#userdata)

## `assoc?`
Function signature:

```
(assoc? v)
```

Is `v` an associative table? Does not have t[1] or is {}.

## `bool?`
Function signature:

```
(bool? v)
```

Is `v` a boolean?

## `boolean?`
Function signature:

```
(boolean? v)
```

Is `v` a boolean?

## `function?`
Function signature:

```
(function? v)
```

Is `v` a function?

## `is-any?`
Function signature:

```
(is-any? value valid-types)
```

is the type of value in the list valid-types?

## `is?`
Function signature:

```
(is? value type-id)
```

is the type of value t?

## `nil?`
Function signature:

```
(nil? v)
```

Is `v` nil?

## `not-nil?`
Function signature:

```
(not-nil? v)
```

Is `v` not nil?

## `number?`
Function signature:

```
(number? v)
```

Is `v` a number?

## `of`
Function signature:

```
(of value)
```

ruin-type aware (type x) function

## `seq?`
Function signature:

```
(seq? v)
```

Checks if v is a has at least t[1], is an empty table or {:n 0} (packed table with zero values)

## `set-type`
Function signature:

```
(set-type value type-id)
```

set ruin-type

## `string?`
Function signature:

```
(string? v)
```

Is `v` a string?

## `table?`
Function signature:

```
(table? v)
```

Is `v` a table - sequence or associative?

## `thread?`
Function signature:

```
(thread? v)
```

Is `v` a thread?

## `type-is-any?`
Function signature:

```
(type-is-any? value valid-types)
```

is the type of value in the list valid-types?

## `type-is?`
Function signature:

```
(type-is? value type-id)
```

is the type of value t?

## `type-of`
Function signature:

```
(type-of value)
```

ruin-type aware (type x) function

## `userdata?`
Function signature:

```
(userdata? v)
```

Is `v` userdata?


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->
# Init-macros.fnl



<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ kernel it imports functions
✓ set and check type it throws on missing type
✓ set and check type it can set special type
  of it can get type of normal data
  of it can get type of ruin data
  is-any? it can check data against a list of types
  is? it can check data against type
✓ seq? it passes []
✓ seq? it passes {}
✓ seq? it passes [1 ...]
✓ seq? it passes {1 ... :n n}
✓ seq? it fails {:a 1}
```
