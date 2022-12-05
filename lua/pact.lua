local _local_1_ = string
local fmt = _local_1_["format"]
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
  local function _3_(...)
    local plugin_id = fmt("%s/%s", name, ({...})[1])
    local _3fexisting = seen_plugins[plugin_id]
    if _3fexisting then
      vim.notify(fmt("Replacing existing plugin %s with new configuration", plugin_id))
      do end (seen_plugins)[plugin_id] = nil
    else
    end
    local arg_v = {...}
    local arg_c = select("#", ...)
    local real_fn
    local function _5_()
      local mod = require("pact.plugin")
      local f = mod[name]
      return f(unpack(arg_v, 1, arg_c))
    end
    real_fn = _5_
    seen_plugins[plugin_id] = true
    return table.insert(plugin_proxies, real_fn)
  end
  return _3_
end
local providers = {github = proxy("github"), gitlab = proxy("gitlab"), sourcehut = proxy("sourcehut"), srht = proxy("sourcehut"), git = proxy("git")}
local function open(opts)
  if (vim.fn.has("nvim-0.8") == 0) then
    error("pact.nvim requires nvim-0.8 or later")
  else
  end
  local opts0 = (opts or {})
  do
    opts0["concurrency-limit"] = (opts0["concurrency-limit"] or opts0.concurrency_limit)
  end
  local e_str = "must provide both win and buf or neither"
  local win, buf = nil, nil
  do
    local _7_ = opts0
    if ((_G.type(_7_) == "table") and (nil ~= (_7_).buf) and ((_7_).win == nil)) then
      local buf0 = (_7_).buf
      win, buf = error(e_str)
    elseif ((_G.type(_7_) == "table") and ((_7_).buf == nil) and (nil ~= (_7_).win)) then
      local win0 = (_7_).win
      win, buf = error(e_str)
    elseif ((_G.type(_7_) == "table") and (nil ~= (_7_).buf) and (nil ~= (_7_).win)) then
      local buf0 = (_7_).buf
      local win0 = (_7_).win
      win, buf = win0, buf0
    elseif true then
      local _ = _7_
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
  return ui.attach(win, buf, plugins, opts0)
end
return {open = open, git = providers.git, github = providers.github, path = providers.path, srht = providers.sourcehut, sourcehut = providers.sourcehut}