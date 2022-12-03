local seen_plugins = {}
local plugin_proxies = {}
local function proxy(name)
  if (vim.fn.has("nvim-0.8") == 0) then
    error("pact.nvim requires nvim-0.8 or later")
  else
  end
  local function id(user_repo)
    return (name .. "/" .. user_repo)
  end
  local function _2_(...)
    if (nil == seen_plugins[id(...)]) then
      local arg_v = {...}
      local arg_c = select("#", ...)
      local real_fn
      local function _3_()
        local mod = require("pact.plugin")
        local f = mod[name]
        return f(unpack(arg_v, 1, arg_c))
      end
      real_fn = _3_
      seen_plugins[id(...)] = true
      return table.insert(plugin_proxies, real_fn)
    else
      return vim.notify("Pact ignored attempt to re-add existing plugin to plugin list and ignored it, restart nvim to apply constraint changes")
    end
  end
  return _2_
end
local providers = {github = proxy("github"), gitlab = proxy("gitlab"), sourcehut = proxy("sourcehut"), srht = proxy("sourcehut"), git = proxy("git")}
local function open(opts)
  if (vim.fn.has("nvim-0.8") == 0) then
    error("pact.nvim requires nvim-0.8 or later")
  else
  end
  local opts0 = (opts or {})
  do
    opts0["concurrency-limit"] = (opts0["concurrency-limit"] or 5)
  end
  local e_str = "must provide both win and buf or neither"
  local win, buf = nil, nil
  do
    local _6_ = opts0
    if ((_G.type(_6_) == "table") and (nil ~= (_6_).buf) and ((_6_).win == nil)) then
      local buf0 = (_6_).buf
      win, buf = error(e_str)
    elseif ((_G.type(_6_) == "table") and ((_6_).buf == nil) and (nil ~= (_6_).win)) then
      local win0 = (_6_).win
      win, buf = error(e_str)
    elseif ((_G.type(_6_) == "table") and (nil ~= (_6_).buf) and (nil ~= (_6_).win)) then
      local buf0 = (_6_).buf
      local win0 = (_6_).win
      win, buf = win0, buf0
    elseif true then
      local _ = _6_
      local api = vim.api
      local _0 = vim.cmd.split()
      local win0 = api.nvim_get_current_win()
      local buf0 = api.nvim_create_buf(false, true)
      do
        api.nvim_win_set_buf(win0, buf0)
        api.nvim_win_set_option(win0, "wrap", false)
      end
      win, buf = win0, buf0
    else
      win, buf = nil
    end
  end
  local ui = require("pact.ui")
  local plugins
  do
    local tbl_17_auto = {}
    local i_18_auto = #tbl_17_auto
    for _, c in ipairs(plugin_proxies) do
      local val_19_auto = c()
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
    plugins = tbl_17_auto
  end
  return ui.attach(win, buf, plugins)
end
return {open = open, git = providers.git, github = providers.github, path = providers.path, srht = providers.sourcehut, sourcehut = providers.sourcehut}