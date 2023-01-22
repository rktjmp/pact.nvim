<div align="center">
<img src="pact.png" style="width: 100%" alt="pact.nvim logo"/>
</div>

# `pact`

> **pact** *[pækt]*
>
> An agreement, covenant, or compact.

`pact` is a *semver focused*, *pessimistic* plugin manager for Neovim.

`pact` should be considered public-preview, it should function but there may be
breaking changes between versions.

## TOC

- [Preview `pact` in a Container](#preview-pact-in-a-container)
- [Install](#install)
- [Making Pacts](#making-pacts)
- [Limitations](#limitations)
- [TODO](#todo)
- [Articles, clauses, privios](#articles-clauses-privisos)
- [See Also](#see-also)

<div align="center">
<img src="https://user-images.githubusercontent.com/866010/205425753-7a68dfb1-66b5-4c5d-ae16-8ffbca648657.gif"
     style="width: 100%"
     alt="pact.nvim demo"/>
</div>

## Preview Pact in a Container

<details>
<summary>podman</summary>

```sh
curl https://raw.githubusercontent.com/rktjmp/pact.nvim/master/Containerfile | \
  podman build -t pact-nvim -f - . && \
podman run -it pact-nvim
```

</details>

<details>
<summary>docker</summary>

```sh
curl https://raw.githubusercontent.com/rktjmp/pact.nvim/master/Containerfile | \
  docker build -t pact-nvim -f - . && \
docker run -it pact-nvim
```

</details>

## Install

> `pact` is beta, things *might* change, be sure to check for breaking changes
> with `=`!

`pact` requires Neovim 0.8+.

To automatically install `pact`,

```lua
-- in your init.lua
-- Bootstrap pact if its missing, you will be instructed to install pact again
-- the first time you run `:Pact` to finalise installation.
if vim.loop.fs_stat(vim.fn.stdpath("data") .. "/site/pack/pact/start/pact.nvim") == nil then
  vim.notify(
    string.format("Could not find pact.nvim, cloning new copy to %s", check_path)
    vim.log.levels.WARN
  )
  local pactstrap_path = vim.fn.stdpath("data") .. "/site/pack/pactstrap"
  vim.fn.system({
    'git',
    'clone',
    '--depth', '1',
    '--branch', 'v0.0.10',
    'https://github.com/rktjmp/pact.nvim',
    pactstrap_path .. "/opt/pact.nvim"
  })
  vim.cmd("packadd pact.nvim")
  require("pact.bootstrap")(pactstrap_path)
end

```

And somewhere in your configuration,

```lua
local pact = require("pact")
pact.make_pact(
  pact.github("rktjmp/pact.nvim", ">= 0.0.0"),
  pact.github("rktjmp/shenzhen-solitaire.nvim")
)
```

Then run `:Pact` to open `pact` (and probably update `pact`).

## Making Pacts

`pact` currently provides the following forge shortcuts:

- `github`
- `gitlab`
- `sourcehut` (alias: `srht`)

As well as the agnostic `git` function.

These functions should be called with a source argument (generally `user/repo`
for forges, or `https/ssh://...` for `git`) and either a string that describes
a semver constraint (`~ 3.0.1`) or a table containing options such as
`branch`, `tag`, `commit`, `verson`, as well as `after`, etc. See `:h pact-api-git`
for a description of supported options.

<details>
<summary>lua</summary>

```lua
local p = require("pact")
p.github("rktjmp/hotpot.nvim", "~ 0.5.0")
p.github("rktjmp/lush.nvim", {branch = "main",
                              after = "sleep 2"})
p.github("rktjmp/pact.nvim", {version = "> 0.0.0",
                              after = function(p)
                                p.yield("running long command")
                                p.run("sleep", {"2"})
                                return "all ok!"
                              end})
p.git("https://tpope.io/vim/fugitive.git", {name = "fugitive",
                                            tag = "v3.7"})
```

</details>

<details>
<summary>fennel</summary>

```fennel
(let [{: github : git} (require :pact)]
  (github :rktjmp/hotpot.nvim "~ 0.5.0")
  (github :rktjmp/lush.nvim {:branch :main
                             :after "sleep 2"})
  (github :rktjmp/pact.nvim {:version :>0.0.0
                             :after (fn [{: yield : run}]
                                    (yield "running some long command")
                                    (run :sleep [:2])
                                    "all ok!")})
  (git :https://tpope.io/vim/fugitive.git {:name :fugitive :tag :v3.7}))
```

</details>


Running the command `:Pact` will open the `pact` interface, which is losely
familar to `fugitive`. It's usage is detailed at the bottom of the buffer.

You may also open `pact` in your own (non-split) window by passing `win` and
`buf` options to `open`, see `:h pact-api`.


<details>
<summary>lua</summary>

```lua
vim.keymap.set("n", "<leader>P", function()
  require("pact").open({
    win = 0,
    buf = 0,
    concurrency_limit = 10
  })
end)
```

</details>

<details>
<summary>fennel</summary>

```fennel
(vim.keymap.set :n :<leader>P #(let [{: open} (require :pact)]
                                (open {:win 0 :buf 0 :concurrency-limit 10})))
```

</details>

## Limitations

- **`pact` only suports unix systems.**
- `pact` uses git tags to detect plugin versions. Remote repositories must
  correctly tag their releases with as either `v<major>.<minor>.<patch>` or
  `<major>.<minor>.<patch>`, [partial versioning is not
  supported](https://semver.org/#spec-item-2) (i.e `<major>.<minor>`).
- Pinned `commit`s must be given in full, as we are unable to fetch or remotely
  inspect partial hashes.
- `pact` can not guess a repositories "primary branch" (i.e `main` or
  `master`), you must explicitly define it when pinning to a branch.

## TODO

Expect things to mostly improve, sometimes change.

[https://github.com/rktjmp/pact.nvim/issues/1](https://github.com/rktjmp/pact.nvim/issues/1)

## Articles, clauses, privisos

Pact makes the following assumptions:

- semver versions are tagged in the package repo
  - tags are either "vn.n.n" or "n.n.n"
  - version can be any of `>`, `>=`, `=`, `<`, `<=`, `^` and `~`.
  - Ranges and boolean operations are not supported.
  - Pre-release versions (the `alpha` in `v1.2.3-alpha`) are not currently supported.
  - Should be given as `<operator> <version>` or `<operator><version`.

## See Also

- [paq-nvim](https://github.com/savq/paq-nvim), used as a reference for a tiny,
  no-fuss package manager.
