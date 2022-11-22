# ruin/iter

- **[functions](#initfnl)**
- **[tests](#tests)**
# Init.fnl

**Table of contents**

- [`bward`](#bward)
- [`fward`](#fward)
- [`range`](#range)

## `bward`
Function signature:

```
(bward [ (where [seq] (seq? seq)) | (where [seq step] (and (seq? seq) (number? step) (<= 1 step))) ])
```

Identical to ipairs but runs in reverse and accepts an optional step argument.

## `fward`
Function signature:

```
(fward [ (where [seq] (seq? seq)) | (where [seq step] (and (seq? seq) (number? step) (<= 1 step))) ])
```

Identical to ipairs but accepts an optional step argument.

## `range`
Function signature:

```
(range [ (where [start stop] (and (number? start) (number? stop))) | (where [start stop step] (and (number? start) (number? stop) (number? step) (<= 1 step))) ])
```

Returns an iterator to generate numbers from start to stop, by step. Step is
  always positive, but start and stop may be inverted.


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ range generator it needs start and end
✓ range generator it is a pure iterator
✓ range generator it runs forward
✓ range generator it runs backward
✓ fward it iterates forward
✓ fward it iterates forward with step
✓ fward it is a pure iterator
✓ bward it iterates backward
✓ bward it iterates backward with step
✓ bward it is a pure iterator
```
