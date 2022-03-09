<div align="center">
<img src="pact.png" style="width: 100%" alt="pact.nvim logo"/>
</div>

# pact

> **pact** *[pakt]*
>
> An agreement, covenant, or compact.

`pact` is a *semver focused*, *pessimistic* plugin manager for Neovim.

**You probably shouldn't use `pact` (ever? yet?), you will probably enjoy
`paq`, `packer`, `mini-pac`, `vim-plug`, etc more.**

## Goals

- `pact` aims to avoid updates :drum: & heartbreak :broken_heart: when managing
  Neovim plugins.

- `pact` focuses on [SemVer](https://semver.org) constraints as the primary
  target specification with support for (most of) Mix/NPMs notation.

- `pact` will never update any plugins without explicit instructions to do so
  via a `status -> snapshot -> sync` workflow, with an interface vaguely
  inspired by `git rebase -i`.

- `pact` will snapshot your plugin versions before any operation, ~~allowing
  you to rollback if an undate has unfortunate side effects.~~ (Automatic
  rollback interface TODO.)

- Maybe make semver and semver dependencies more normal in the Neovim
  community, *maybe*.

## Anti Goals

- Becoming the next packer.nvim


## Limitations

- `pact` uses git tags to detect plugin versions. Remote repositories must
  correctly tag their releases with as either `v<major>.<minor>.<patch>` or
  `<major>.<minor>.<patch>`, [partial versioning is not
  supported](https://semver.org/#spec-item-2) (i.e `<major>.<minor>`).
- Pinned `hash`es must be given in full, as we are unable to fetch or remotely
  inspect partial hashes.
- `pact` can not guess a repositories "primary branch" (i.e `main` or
  `master`), you must explicitly define it when pinning to a branch.

## TODO

[https://github.com/rktjmp/pact.nvim/issues/1](https://github.com/rktjmp/pact.nvim/issues/1)

## Configuration

```fennel
(let [{: setup : define : github : gitlab : srht : git} (require :pact)]
  (setup {:concurrency-limit 5}) ;; number of jobs to run in parallel
                                 ;; or just call (setup). You do not
                                 ;; have to call setup at the same place
                                 ;; you define groups.
  (define :base
    (github :feline-nvim/feline.nvim "~ 0.4.0")               ;; defaults to semver spec
    (github :rktjmp/hotpot.nvim {:branch :master})            ;; but you can specify a branch
    (github :ggandor/lightspeed.nvim {:tag :warp-drive})      ;; or a tag
    (gitlab :a-plugin/hosted-elsewhere {:hash "DEADBEEF..."}) ;; or hash
    (srht   :sourcehut/support {:version "~ 1.0.0"}))

  (define :lsp
    ;; You can define separate groups to operate independently, perhaps some groups
    ;; are "low impact" and you're quite happy to just update them all, often, to
    ;; the edge, or maybe you have a core set of plugins you *never* want to accidentally
    ;; update.
    (git :https://my-host.net/secret-plugin.nvim, {:branch :develop}))

  (when (= os :haiku)
    ;; or maybe you only want some groups to conditionally exist
    (define :haiku-only
      (github :some-platform/plugin.nvim ">= 0.0.0"))) ;; version can be any of
                                                       ;; >, >=, =, <, <=, ^ and ~.

  (let [plugins []]
    ;; or you can get your hands real dirty
    (table.insert plugins (github :a/b "= 1.0.0"))
    (if (<= 0.6 nvim-version)
      (table.insert plugins (github :your/plugin ">= 1.2.0")) ;; 0.6+ compat
      (table.insert plugins (github :your/plugin "= 1.1.0"))) ;; last 0.5 compat version
    (define :conditional (unpack plugins))))
```

## Usage (estimated)

**Defining Pacts**

See above.

**Installing and Updating**

Run `Pact st[atus] <group-name>`.

`pact` will examine your local repository against the remote and show if you
are able to update. **`pact` will not set any plugin to `update` default.**
`pact` *will* set *new* plugins to `get` and *will* also set removed plugins to
`delete` by default.

Given the following:

```fnl
(define :default
  (github :rktjmp/hotpot.nvim {:branch :master})
  (github :feline-nvim/feline.nvim {:version "~ 0.4.0"})
  (github :ggandor/lightspeed.nvim {:branch :main}))
```

You will see the following UI:

```sh
# pact: default
# elapsed: 0.73s

hold    hotpot.nvim     (master)  up to date master 
hold    feline.nvim     (~ 0.4.0) can update v0.4.3 (latest: = 1.0.0)
hold    lightspeed.nvim (main)    can update main 

# commands:
# h, hold   = take no action
# u, update = update to latest valid pin
# d, delete = remove from package dir, shown when plugin is
#             no longer in pact definition, no effect if
#             plugin still exists (delete from pact config first)
# g, get    = clone from remote, shown when plugin is newly
#             added to pact definition
#
# bindings:
# gu        = set command to update (under cursor)
# gh        = set command to hold (under cursor)
# gd        = set command to delete (under cursor)
# gg        = set command to get (under cursor)
# ga        = set any hold to update,
#             get remains get,
#             delete remains delete
# gq        = close, cancel, give up, dispair
# gc        = commit commands
```

Each line follows the format:

```
<command> <plugin> (<pin-to>) <comment> (<latest remote known> if any semver tags exist)
```

From this we can see:

- `hotpot.nvim` is tracking `master` and is in sync with the remote.
- `feline.nvim` can update to `0.4.3`, the latest remote tag is `1.0.0`. `pact`
  wont update to `1.0.0` because of the version restriction imposed by `~
  0.4.0`.
- `lightspeed.nvim` is tracking `main` but is out of sync.

Move your cursor to each `feline.nvim` and `lightspeed.nvim` line and press
`gu` to mark these plugins for `updates`.

Press `gc` to commit your commands.

You will now see the snapshot interface, by default the message is prefilled
with a timestamp.

```sh
2022-02-28 23:59:45 default

# Provide a one line snapshot message or leave as given.
# All other lines are ignored.
#
# update feline.nvim     (v0.4.3)
# update lightspeed.nvim (main)
#
# gq        = close, cancel, give up, dispair
# gc        = commit commands
```

Press `gc` to commit snapshot.

You will now see the sync interface, which shows sync operations and progress.

```sh
# pact: default
# elapsed: 1.17s

update  feline.nvim     (v0.4.3) checked out "e54e0cc5338b44d97dcaab83dd67d5a522656774"
update  lightspeed.nvim (main)   checked out "23565bcdd45afea0c899c71a367b14fc121dbe13"

# bindings:
# gq = close, cancel, give up, dispair
```

**Articles, clauses, privisos**

Pact makes the following assumptions:

- semver versions are tagged in the package repo
  - tags are either "vn.n.n" or "n.n.n"
  - version can be any of `>`, `>=`, `=`, `<`, `<=`, `^` and `~`.
  - Ranges and boolean operations are not supported.
  - Should be given as `<operator> <version>` with one space

```
# build
fd -tf "fnl$" | entr -sc "nvim --headless -c 'Fnl' -c 'q' build.fnl"
# test
fd -tf "moon$|lua$" | entr -sc "busted --suppress-pending"
```
