local pact_path = vim.fn.stdpath('data') .. '/site/pack/pact/start/pact.nvim'

if vim.fn.empty(vim.fn.glob(pact_path)) > 0 then
  print("Could not find pact.nvim, cloning new copy to", pact_path)
  vim.fn.system({
    'git',
    'clone',
    '--depth', '1',
    '--branch', 'v0.0.7',
    'https://github.com/rktjmp/pact.nvim',
    pact_path
  })
  vim.cmd("packloadall!")
  vim.cmd("helptags " .. pact_path .. "/doc")
end

vim.opt.termguicolors = true
vim.cmd("colorscheme habamax")

local pact = require("pact")
local github = pact.github

github("rktjmp/pact.nvim", ">= 0.0.0")
github("rktjmp/lush.nvim", {version = "~ 2.0.0"})
github("nvim-treesitter/nvim-treesitter", {
  branch = "master",
  after = function()
    -- because we run off the main loop, we must schedule some vim-specific things back
    vim.schedule(vim.cmd.TSUpdate)
  end
})
github("nvim-lua/plenary.nvim", {
  branch = "master",
  after = function(p)
    p.yield("Fetching something online")
    local exit, out, _err = p.run("curl", {"https://neovim.io"})
    if exit == 0 then
      for i, line in ipairs(out) do
        local neovim = string.match(line, "<h1.->(.+)</h1>")
        if neovim then return "neovim is a " .. neovim end
      end
    end
    return "couldn't work out what neovim.io thinks about neovim"
  end})
github("some/fake-plugin.nvim", {branch = "master"})
github("rktjmp/paperplanes.nvim", {version = ">= 10000.0.0"})
