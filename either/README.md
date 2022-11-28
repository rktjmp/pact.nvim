# ruin/either

- **[macros](#init-macrosfnl)**
- **[tests](#tests)**

# Init-macros.fnl

**Table of contents**

- [`def-either`](#def-either)

## `def-either`
Function signature:

```
(def-either opts)
```

Generic left-right monad generator. See Maybe and Result for example usage
  and this macros comments


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
✓ either it generates oks
✓ either it generates errs
✓ either it raises on no match
✓ either it correctly unwraps ok
✓ either it correctly unwraps err
✓ either it will not re-wrap
✓ either it captures from function calls
✓ let it returns wrapped ok
✓ let it returns wrapped err
✓ let* it returns unwrapped ok
✓ let* it returns wrapped err
```
