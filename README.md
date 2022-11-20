<div align="center">
<img src="logo.png" style="width: 100%" alt="Ruin Logo"/>
</div>

# ruin.fnl

A collection of maybe useful, maybe harmful fennel functions and macros.

Each directory has its own readme documenting its usage.

Should be usable inside other projects when dropped into a subtree (eg: `my-tool/lib/ruin`)
or cloned into Neovims RTP (eg: `(require :ruin...)`).

## modules

**[use](use/README.md)**

Import modules and macros in one block with support for relative requires.

```fennel
(use {:head hd : tail : 'over} :lib.list
     enum :lib.enum
     {: 'pipe} :some.pipe.macro
     {:format fmt} string)
```

**[fn](fn/README.md)**

Multi-arity/pattern-dispatch functions.

```fennel
(fn* x
  (where [a])
  (print :one-argument a)
  (where [100 name] (= :string (type name)))
  (print :100-hello name)
  (where _)
  (print :otherwise))
```

**[let](let/README.md)**

`match-let`, `if-let`, etc.

```fennel
(match-let [a 50
            (where b (<= 100)) (+ a 51)]
  (* a b)
  (else
    _ (error :something)))
```

**[enum](enum/README.md)**

Functions for working with enumerables (`[...]`, `{...}` and iterator functions), `map`, `reduce` `any?`, etc.

**[maybe](maybe/README.md)**

A `some` or `none` monad.

**[result](result/README.md)**

A `ok` or `err` monad.

**[math](math/README.md)**

Generic maths functions, `add`, `even?`, etc.

**[type](type/README.md)**

Generic type functions, `seq?`, `string?`, etc.
