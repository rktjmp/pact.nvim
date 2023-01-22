 local _local_1_ = string local fmt = _local_1_["format"]


 do local data_path = (vim.fn.stdpath("data") .. "/pact")
 local runtime_path = (vim.fn.stdpath("data") .. "/site/pack/pact")
 local head_path = (data_path .. "/HEAD")
 local config = {lang = "en", path = {data = data_path, runtime = runtime_path, head = head_path}}



 local function _2_() return config end package["preload"]["pact.config"] = _2_ end




 local plugin_proxies = {}
 local function proxy(name)
 if (vim.fn.has("nvim-0.8") == 0) then
 error("pact.nvim requires nvim-0.8 or later") else end
 local function _4_(...)
 local plugin_id = fmt("%s/%s", name, ({...})[1])
 local arg_v = {...}
 local arg_c = select("#", ...) local unproxy_fn
 local function _5_() local mod = require("pact.package.spec")
 local f = mod[name]
 return f(unpack(arg_v, 1, arg_c)) end unproxy_fn = _5_
 return unproxy_fn end return _4_ end

 local providers = {github = proxy("github"), gitlab = proxy("gitlab"), sourcehut = proxy("sourcehut"), git = proxy("git"), luarocks = proxy("luarocks")}





 local function open(opts)








 if (vim.fn.has("nvim-0.8") == 0) then
 error("pact.nvim requires nvim-0.8 or later") else end
 local opts0 = (opts or {})


 do local config = require("pact.config")
 do end (config)["concurrency-limit"] = (opts0["concurrency-limit"] or opts0.concurrency_limit or 10)



 do end (opts0)["concurrency-limit"] = nil end local e_str = "must provide both win and buf or neither"

 local win, buf = nil, nil
 do local _7_ = opts0 if ((_G.type(_7_) == "table") and (nil ~= (_7_).buf) and ((_7_).win == nil)) then local buf0 = (_7_).buf
 win, buf = error(e_str) elseif ((_G.type(_7_) == "table") and ((_7_).buf == nil) and (nil ~= (_7_).win)) then local win0 = (_7_).win
 win, buf = error(e_str) elseif ((_G.type(_7_) == "table") and (nil ~= (_7_).buf) and (nil ~= (_7_).win)) then local buf0 = (_7_).buf local win0 = (_7_).win
 win, buf = win0, buf0 elseif true then local _ = _7_
 local api = vim.api
 local _0 = vim.cmd.split()
 local win0 = api.nvim_get_current_win()
 local buf0 = api.nvim_create_buf(false, true)
 do api.nvim_win_set_buf(win0, buf0) api.nvim_win_set_option(win0, "wrap", false) end


 win, buf = win0, buf0 else win, buf = nil end end
 local ui = require("pact.ui")
 return ui.attach(win, buf, plugin_proxies, opts0) end

 local function make_pact(...)
 return table.insert(plugin_proxies, {...}) end

 return {open = open, ["make-pact"] = make_pact, make_pact = make_pact, git = providers.git, github = providers.github, path = providers.path, srht = providers.sourcehut, sourcehut = providers.sourcehut, luarocks = providers.luarocks, rock = providers.luarocks}