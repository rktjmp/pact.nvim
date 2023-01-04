# Pact

This document is a provisional (read: not 100% implemented, target) description
of `pact.nvim`'s behaviour, options and interface. Struck through content is
not currently implemented.

Code and functions are generally described in "fennel form" where symbols
such as `-` or  `?` may appear in variable or function names. These should have
lua counterparts where `-` becomes `_` or `?` is dropped (or becomes `is_x`
when specified)`.

```fennel
(make-pact
  (github :rktjmp/pact.nvim "~1.0.0")
  (github :rktjmp/shenzhen-solitaire.nvim
          {:opt? true}))
```

# Packages

A *package* is a generalised term describing some *thing* that should be made
available to Neovim.

They generally have some kind of source (eg: a git repo, luarocks, a local
path), some kind of constraint (eg: a version, tag, branch) and some options.

## `make-pact`

In order to register packages with pact, these packages must be passed to the
`make-pact` function.

`make-pact` can be called as many times as desired, from any code. Calls are
cumulative and packages may be included multiple times in different `make-pact`
calls if needed (to define dependencies).

Each call to `make-pact` should include at least one call to a *provider
function* as described below.

```fennel
(make-pact
  ;; providers
  ...)
```

~~`make-pact` optionally accepts a `string` or `table` as its first argument,
which defines the package set as a known meta-package, which has the
distinction of appearing as a group in the UI.~~

## Constraints

Pact is intentionally pessimistic when updating, it wont upgrade (or even
install) packages without the explicit instructions to, and it also constrains
those updates to values passing a given *constraint*.

A package may be defined *multiple* times with *different* constraints and
pact will attempt to find a value that satisfies *all constraints*.

Constraints are given as string values and passed to provider functions as they
are described below.

**`"<op>major.minor.patch"` or `"<op> major.minor.patch"`**

- Constrain to any version that passes the given semver filter.
- The latest satisfactory version is always used.
- `git` and git forge provider "versions" are determined by tag, **not** branch.
- Supported operations: `=` `>` `>=` `<` `<=` `^` `~`.
- ~~"1.2.3-alpha" version support~~
- ~~Multiple version constraints may be combined by ...~~

**`"branch"`**

- Track remote branch by name.
- Only applicable to `git` and git forge providers.

**`"#tag"`**

- Track remote tag by name.
- Only applicable to `git` and git forge providers.

**`"^commit"`**
- Pin to a specific commit sha.
- Must be at least 7 characters long.
- Only applicable to `git` and git forge providers.

**`nil`**
- Track most latest available artefact.
- Applies to `git`, git forge and ~~luarocks~~ provider.

~~**`"*"`**~~
- ~~Defer package constraint to any other canonical sibling.~~

## Providers

Pact packages are defined by calling *provider functions*. Each provider
function returns a opaque value representing the options passed to the
provider. These values may be held and used repeatedly when defining other
packages. (Eg you may define a variable holding a package, then pass that
variable to many other packages as a dependency).

Most providers support some kind of "constraint" which dictates what pact
installs and an options table.

**Git Forge Providers**

Common git forges have shortcut providers. These automatically expand their
first argument into the appropriate full URL.

Supported forges:

- `github`
- `sourcehut` (alias `srht`, note that `user/repo` should *not* include the `~` present in sourcehut urls.)
- `gitlab`

Forges can be called with the following arguments:

```fennel
;; implicity track HEAD
(forge :user/repo)

;; track against given constraint
(forge :user/repo :constraint)

;; track against constraint with options
;; ~~(forge :user/repo :constraint {options})~~

;; implicitly track HEAD or :version, :tag, :branch or :commit if given in options
(forge :user/repo {options})
```

~~**Luarocks**~~

~~Install a package from luarocks. The first argument should be a valid
luarocks package name. Only supports the `version` constraint type.~~

~~*rocks* are installed and symlinked into the runtime path and can be required
normally.~~

```fennel
(luarocks :luasocket ">= 3.0.0")
```

~~luarocks support is super stable and never breaks, it comfortably resolves
cross-constraints between pact-defined luarocks and luarock dependencies
defined by a neovim `packfile` *and* any luarocks dependencies of luarock
dependencies defined in those!~~


**Git**

A "porcelain" git provider. Supports the same constraints and options as the
git forges but the first argument must be a fully qualified url beginning with
`https://`, `ssh://` ~~or `file://` or `git://`~~.

The git provider **must** be given the following options:

- `name` see common options.

```fennel
(git :https://tpope.io/vim/fugitive.git "~3.7.0"
     {:name :fugitive})
```


~~**Link**~~

~~Link paths that should be symlinked into neovims runtime path. This is useful
for plugin development.~~

~~The first argument must be a path, which may be absolute or `~` prefixed.
Relative paths are not supported.~~

~~The link provider **must** be given the following options:~~

~~- `name` see common options.~~

~~The link provider option does not support any constraints.~~

## Common Provider Options

The following options are common to all providers

**`dependencies` | `deps`**

- a `table` nested packages.

**`opt?` | `opt`**

- `true` install package into `opt/`
- `false` install package into `start/`

**`after`**

- a `string`: passed to `vim.cmd`
- a `function`: called with a table containing the following keys:
  - `path` absolute path to the plugin.
  - `trace` a function that accepts a single line string to render next to a
    package, as a status message. May be called multiple times.
- ~~a `table` passed to `uv.spawn` (eg: `[:gcc :some.c]`)~~

**`name`**

- `string` Neovim appropriate name to install as, (eg: `pact.nvim` &rarr; `:packadd pact.nvim`, etc)

**`version` `branch` `tag` `commit`**

- Constraints may also be included in the options table. Tags and commits
  should not include their symbol prefixes.

~~**`force`**~~

- ~~`true` force the package to skip any constraint resolution and use
  whatever constraint was specified.~~
- ~~Can be used to force colliding dependencies to use a fixed version.~~
- ~~Does not support any version constraint besides `=`?~~

~~**`replaces` `masquerades` `acts-as` `provides`**~~

- ~~`package` mark a package as a synonym for another, used to reroute
  dependencies from one package to another.~~
- ~~Most likely requires `:force true` also, unless the two packages are close
  enough for constraints to still make sense.~~

```fennel
(link "~/projects/nvim-treesitter"
      {:masquerades (github :nvim-treesitter/nvim-treesitter)})
```

# Workflow

## Transactions

> terminology: the term transaction could/may change to snapshot, though
> neither term accurately describes the whole concept.

Pact manages each set of operations under a transaction. The current package
state is presented, alterations to that state are queued (upgrades, downgrades,
installs and discards), then the changes are committed.

Pact then performs the queued operations. If any errors occur during
installation, the transaction is cancelled and **no updates are applied**.

If no error is encountered, the transaction is committed and any associated
`after` options are executed.

Any failures when running `after` do not cancel the transaction
~~(currently?)~~ as the transaction must be committed in order to load packages
and use their code to run commands (eg: treesitters `:TSUpdate` must have
`nvim-treesitter` in the rtp).

Transactions can be rolled back by ~~using the transaction interface.~~
manually adjusting the current `HEAD` symlink to a previous transaction.

> Why transactions?
>
> ~~Pact supports the `packfile` specification which means packages may define
> additional dependencies that can only be found while applying state changes.~~
>
> These additional dependencies may cause a transaction to fail if they add an
> unreconcilable constraint or incompatibility.
>
> They also need a workspace to clone and examine packages.

**Transactions are not intended as a replacement to a lockfile, just a side
effect.**

## Interface

Pact's interface is loosely similar to the Fugitive package and borrows
some of the key bindings and terminology (from git).

The interface lists all packages pact knows about in a tree, including explicit
dependencies (from the `dependencies` option) ~~as well as implicit
dependencies discovered in sub-packages.~~

The packages are grouped into three broad sections, "unstaged", "staged" and
"up to date". When reasoning on the interface, generally consider "stage" as
"change state" and "unstage" as "keep state". Note that shared dependencies may
move unexpected packages into the "staged" section, though the parents will not
be changed.

- Unstaged - changes possible but wont be applied.
- Staged - changes will be applied.
- Up-to-date - no changes needed.

The interface intends to be colorblind friendly, ~~and should employ symbols
where possible, using the symbol gutter.~~

- `⍑` indicates that a package will not undergo any changes.
- `⍙` indicates that a package will change.

> This can feel superfluous but can differentiate between a package that is in
> the staged section because a child is staged, but it itself is not.
>
> Without color information, both packages show the "install" action even
> though one is "(can) sync" the other is "(will) sync".
>
> The action hint could just be changed to include the verb, which is probably
> simpler to understand, if a bit wider.

<!-- The interface only provides a limited set of actions the user may perform on a -->
<!-- package: -->

<!-- - `install` - if staged, package will be installed -->
<!-- - `sync` - if staged, package will be synced with constraint -->
<!-- - `hold` - if staged, no change will be applied -->
<!-- - `discard` - if staged, package will not carry into next transaction -->

## Sections

> Notation, in this document, state described as `~section#action`, user input
> described as `>action`.

The `pact` interface groups packages into the following sections:

**Unstaged**

These packages have changes that *could* be applied, meaning:

- the package is not installed but could be.
- the package is installed but there is an upgrade, downgrade or the package is
  otherwise not synced with its constraint.

Packages that are unstaged may be:

- staged, which moves the package to staged with an appropriate action.
- discarded, which moves the package to staged with the discard action.
  - only applicable to installed packages.

Formal transitions:

- `>stage + #install -> ~staged#install`
- `>stage + #sync -> ~staged#sync`
- `>discard + #sync -> ~staged#discard`

**Staged**

These packages have changes in their tree that *will* be applied when the
transaction is committed, meaning:

- the package, or sub-package will be installed, marked with the action `install`.
- the package, or sub-package will be aligned with its constraint, marked with
  the action `sync`.
- the package will be discarded, marked with the action `discard`.
  - discarded packages are not carried into the next transaction.
- ~~the package is an orphan and will be retained, marked with the action `retain`.~~
  - ~~Orphan packages are packages pact discovered in Neovims runtime path that
    have not been explicitly defined. Following the principal of least change,
    by default **these packages are carried through into the next
    transaction.**~~
- ~~staging a package may cause additional tasks to be created while pact
  discovers downstream dependencies.~~

Packages that are staged may be:

- unstaged, which will return the package to its unmodified-state group: staged or up-to-date.
- discarded, which has different behaviour depending on the packages natural state,
  - `install` (new packages) are moved to unstaged
  - `sync` actions become `discard`
  - ~~`retain` becomes `discard`~~
- ~~staged, which has different behaviour depending on the packages current state,~~
  - ~~existing packages with a possible state change, change from `discard` to `sync`~~
  - ~~orphan packages change from if `discard` to `retain`~~

Formal transitions:

- `>unstage + #install -> ~unstaged#install`
- `>unstage + #sync -> ~unstaged#sync`
- `>unstage + #discard -> ~unstaged#sync | ~up-to-date#retain`
- `>discard + #install -> ~unstaged#install`
- `>discard + #sync -> ~stage#discard`
- ~~`>discard + #retain -> ~stage#discard`~~
- ~~`>unstage + #retain -> ~stage#discard`~~

**Up To Date**

These packages are in alignment with their constraint.

Packages that are up to date may be:

- discarded, which will move the package to staged with the action `discard`

Formal transitions:

- `>discard + #retain -> ~staged#discard`

## Staging Behaviour

**Section Determination**

As packages are nested trees, what group a package is placed in determined by
the holistic state of its tree.

Given `A depends on B`, if `B` is staged to update, the *entire tree* will be
listed in the "staged" section. Additionally, if `X depends on Y depends on B`,
`X` would *also* be listed in the staged section.

Because "something in the tree is changing", the entire tree is flagged as
changing.

**Application Logic**

Actions are propagated *down* a package tree. 

Given `A depends on B`, staging `A` will stage `B` if required, with either
`sync` or `install`. Staging `B` will only stage `B`.

If `A` is unhealthy, `B` may be staged.

If `B` is unhealthy, `A` may *not* be staged.

> This may change in the future, and be relaxed. Neovims plugin culture is
> currently chaotic and does not enjoy wide adoption of semver or strict
> dependency tracking - it's possible this behaviour will be more frustrating
> than useful.

It *is* possible to specifically stage or unstage sub-packages. This *may*
result in an unusable or broken system if dependencies are intentionally not
installed, but the ability is provided in good faith where it's assumed a user
performing targeted actions for a good reason.

> Reasoning:
>
>`A depends on B`, `A` has no strict upstream release cycle and `B`
follows semver.
>
> `A` and `B` both have an update, but the user knows they do
*not* want to update `A` but *do* want to update `B`.
>
> In this case the user may specifically only stage `B` for sync. 

If `A depends on B` and `X depends on Y depends on B`, staging `A` will stage
`B` which will put both `A` and `X` in the staged section, though `X` will have
the action ~~`retain`~~.

# Commands

`:Pact`

Open the pact Interface.

~~`:Pact install`~~

~~Installs all packages if they can be resolved or crashes terribly. For automated bootstrapping~~

~~`:Pact transactions`~~

~~Show previous transactions and rollback options~~

~~`:Pact cleanup`~~

~~Clean up any stale packages or transactions~~
