# ruin/math

- **[functions](#initfnl)**
- **[tests](#tests)**

# Init.fnl

**Table of contents**

- [`add`](#add)
- [`dec`](#dec)
- [`div`](#div)
- [`divides-into?`](#divides-into)
- [`even?`](#even)
- [`inc`](#inc)
- [`mul`](#mul)
- [`odd?`](#odd)
- [`rem`](#rem)
- [`sub`](#sub)

## `add`
Function signature:

```
(add [ (where [a b] (and (number? a) (number? b))) | (where [a b c ...] (and (number? a) (number? b) (number? c))) ])
```

**Undocumented**

## `dec`
Function signature:

```
(dec x)
```

**Undocumented**

## `div`
Function signature:

```
(div [ (where [a b] (and (number? a) (number? b))) | (where [a b c ...] (and (number? a) (number? b) (number? c))) ])
```

**Undocumented**

## `divides-into?`
Function signature:

```
(divides-into? x n)
```

**Undocumented**

## `even?`
Function signature:

```
(even? x)
```

**Undocumented**

## `inc`
Function signature:

```
(inc x)
```

**Undocumented**

## `mul`
Function signature:

```
(mul [ (where [a b] (and (number? a) (number? b))) | (where [a b c ...] (and (number? a) (number? b) (number? c))) ])
```

**Undocumented**

## `odd?`
Function signature:

```
(odd? x)
```

**Undocumented**

## `rem`
Function signature:

```
(rem [ (where [x 0]) | (where [x n]) ])
```

**Undocumented**

## `sub`
Function signature:

```
(sub [ (where [a b] (and (number? a) (number? b))) | (where [a b c ...] (and (number? a) (number? b) (number? c))) ])
```

**Undocumented**


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ maths with words it add
✓ maths with words it sub
✓ maths with words it mul
✓ maths with words it div
✓ maths with words it rem
✓ maths with words it inc
✓ maths with words it even?
✓ maths with words it odd?
```
