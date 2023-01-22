-- Bootstrap pact if its missing, you will be instructed to install pact again
-- the first time you run `:Pact` to finalise installation.
if vim.loop.fs_stat(vim.fn.stdpath("data") .. "/site/pack/pact/start/pact.nvim") == nil then
  local pactstrap_path = vim.fn.stdpath("data") .. "/site/pack/pactstrap"
  vim.notify(
    string.format("Could not find pact.nvim, cloning new copy to %s", pactstrap_path),
    vim.log.levels.WARN
  )
  vim.fn.system({
    'git',
    'clone',
    '--depth', '1',
    '--branch', 'master',
    'https://github.com/rktjmp/pact.nvim',
    pactstrap_path .. "/opt/pact.nvim"
  })
  vim.cmd("packadd pact.nvim")
  require("pact.bootstrap")(pactstrap_path)
end

vim.opt.termguicolors = true
vim.cmd("colorscheme habamax")

local pact = require("pact")
local github, make_pact = pact.github, pact.make_pact

make_pact(
  github("rktjmp/pact.nvim", ">= 0.0.0"),
  github("rktjmp/shenzhen-solitaire.nvim"),
  github("rktjmp/lush.nvim", {version = "~ 2.0.0"}),
  github("nvim-treesitter/nvim-treesitter", {
    after = "TSInstallSync! vim lua"
  }),
  github("nvim-lua/plenary.nvim"),
  github("some/fake-plugin.nvim", {branch = "master"}),
  github("rktjmp/paperplanes.nvim", {version = ">= 10000.0.0"})
)
