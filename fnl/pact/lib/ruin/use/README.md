# ruin/use

- **[macros](#init-macrosfnl)**
- **[tests](#tests)**
# Init-macros.fnl

**Table of contents**

- [`relative-mod`](#relative-mod)
- [`relative-root`](#relative-root)
- [`use`](#use)

## `relative-mod`
Function signature:

```
(relative-mod mod-name ...)
```

Returns mod-path for `mod-name`, relative to [`relative-root`](#relative-root). 

  See [`relative-root`](#relative-root) for details, usage and warnings.

  ```
  (require (relative-mod :enum &from :nested.module))
  ```

## `relative-root`
Function signature:

```
(relative-root ...)
```

Returns relative root modpath. Relative requires are complicated, generally
  you must run this macro in a module root, though the returned value can be
  passed around.

  ```
  (relative-root &from :current.modname)
  ```

  The `&from` option value should be the mod-path of the current module, from
  the "relative root".

  Given `/my/module/a`, `/my` is considered our "root", 

  ```
  (local root (relative-root &from :my.module.a)) ;; => ""
  (require (.. root :. :my.module.b)) ;; my.module.b
  ```

  Which can be concated into `(.. (relative-root &from :my.module-a) :my.module.b)`
  to require correctly.

  Now if embedded in `/project/libs/my/module/a`, 

  ```
  (local root (relative-root &from :my.module.a)) ;; => "libs"
  (require (.. root :. :my.module.b)) ;; libs.my.module.b
  ```

## `use`
Function signature:

```
(use ...)
```

Multi `require`/`import-macros` macro.

  ```
  (use {:head hd : tail : 'over} :lib.list
       enum :lib.enum
       {: 'pipe} :some.pipe.macro
       {:format fmt} string)
  ```

  Accepts a table of module keys to user symbol names, a module name as a
  string or expression, and a collection of options.

  Bind names prefixed by `'` are treated as macro imports.

  Options:

  `&from :mod.path` -> use relative requires, see [`relative-root`](#relative-root) [`relative-mod`](#relative-mod)


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->

# tests
```
```
