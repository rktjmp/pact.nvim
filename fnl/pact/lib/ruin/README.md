<div align="center">
<img src="logo.png" style="width: 100%" alt="Ruin Logo"/>
</div>

# ruin.fnl

A collection of maybe useful, maybe harmful fennel functions and macros.

Each directory has its own readme documenting its usage.

Should be usable inside other projects when dropped into a subtree (eg: `my-tool/lib/ruin`)
or cloned into Neovims RTP (eg: `(require :ruin...)`).

## ruin! macro

```fennel
(import-macros {: ruin!} :ruin)
(ruin!)
```

The `ruin!` macro automatically a selection of functions and macros into a
module.

These include:

- let
  - The macros `match-let`, `if-let`, `if-some-let`, `when-let`, `when-some-let`
- fn
  - The macros `fn*`, `fn+`
- match
  - The macro `match?`
- type
  - The functions `nil?`, `not-nil?`, `seq?`, `assoc?`, `table?`, `number?`, `boolean?`,
  `string?`, `function?`, `userdata?`, `thread?`
- use
  - The macro `use`

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

(fn+ y [:message msg]
  (print msg))
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

Do maths with words, `add`, `even?`, etc.

**[type](type/README.md)**

Generic type functions, `seq?`, `string?`, etc.
