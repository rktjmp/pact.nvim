
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, Render, Package, Runtime, Log, FS, inspect, _local_18_, R, _local_19_, _local_20_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil do local _17_ = string local _16_ = vim local _15_ = require("pact.lib.ruin.result") local _14_ = require("pact.pubsub") local _13_ = require("pact.inspect") local _12_ = require("pact.fs") local _11_ = require("pact.log") local _10_ = require("pact.runtime") local _9_ = require("pact.package") local _8_ = require("pact.ui.render") local _7_ = require("pact.lib.ruin.enum") E, Render, Package, Runtime, Log, FS, inspect, _local_18_, R, _local_19_, _local_20_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_, _16_, _17_ end local _local_21_ = _local_19_








 local api = _local_21_["api"] local _local_22_ = _local_20_
 local fmt = _local_22_["format"] local _local_23_ = _local_18_ local subscribe = _local_23_["subscribe"] local unsubscribe = _local_23_["unsubscribe"]

 local M = {}

 local function schedule_redraw(ui)


 local rate = (1000 / 60)
 if ((ui["will-render"] or 0) < vim.loop.now()) then
 ui["will-render"] = (rate + vim.loop.now())
 local function _24_() return Render.output(ui) end return vim.defer_fn(_24_, rate) else return nil end end

 local function cursor__3epackage(ui)
 local _let_26_ = api.nvim_win_get_cursor(ui.win) local line = _let_26_[1] local _ = _let_26_[2]
 local line0 = (line - 1)
 local _27_ = api.nvim_buf_get_extmarks(ui.buf, ui["ns-meta-id"], {line0, 0}, {line0, 0}, {}) if ((_G.type(_27_) == "table") and ((_G.type((_27_)[1]) == "table") and (nil ~= ((_27_)[1])[1]))) then local extmark_id = ((_27_)[1])[1]
 local function _28_(_241) return (_241.uid == ui.extmarks[extmark_id]) end
 local function _29_() return Package.iter(ui.runtime.packages) end return E.find(_28_, _29_) else return nil end end

 local function exec_keymap_cc(ui)

 local buf = api.nvim_create_buf(false, true)
 local win = api.nvim_open_win(buf, false, {relative = "win", win = ui.win, anchor = "SW", row = api.nvim_win_get_height(ui.win), col = 1, width = api.nvim_win_get_width(ui.win), height = 1, style = "minimal", focusable = false})








 local x = {open = true} local update_win
 local function _31_(waiting, running, done, after_waiting, after_running, after_done)
 if x.open then
 if ((done == (waiting + running + done)) and (after_done == (after_waiting + after_running + after_done))) then

 return api.nvim_buf_set_lines(buf, 0, -1, false, {"transaction: finished"}) else
 local text = fmt("transaction: apply %s/%s after %s/%s", done, (waiting + running + done), after_done, (after_waiting + after_running + after_done))


 return api.nvim_buf_set_lines(buf, 0, -1, false, {text}) end else return nil end end update_win = _31_ local _


 local function _34_() x.open = false

 return api.nvim_win_close(win, true) end _ = api.nvim_create_autocmd("BufHidden", {buffer = ui.buf, once = true, callback = _34_})

 local function _35_(_241) return vim.notify(_241, vim.log.levels.ERROR) end return R["map-err"](Runtime.Command["run-transaction"](ui.runtime, update_win), _35_) end

 local function exec_keymap__3ccr_3e(ui)
 local _let_36_ = api.nvim_win_get_cursor(ui.win) local line = _let_36_[1] local _ = _let_36_[2] local meta
 local function _37_(_241) return (line == _241["on-line"]) end meta = E.find(_37_, ui["plugins-meta"])
 local _38_ local function _40_() local t_39_ = meta if (nil ~= t_39_) then t_39_ = (t_39_).plugin else end if (nil ~= t_39_) then t_39_ = (t_39_).path else end if (nil ~= t_39_) then t_39_ = (t_39_).package else end return t_39_ end _38_ = {meta, _40_()} if ((_G.type(_38_) == "table") and (nil ~= (_38_)[1]) and (nil ~= (_38_)[2])) then local any = (_38_)[1] local path = (_38_)[2]

 print(path)
 return vim.cmd(fmt(":new %s", path)) elseif ((_G.type(_38_) == "table") and (nil ~= (_38_)[1]) and ((_38_)[2] == nil)) then local any = (_38_)[1]
 return vim.notify(fmt("%s has no path to open", any.plugin.name)) elseif true then local _0 = _38_
 return nil else return nil end end

 local function exec_keymap_p(ui)
 do local _45_ = cursor__3epackage(ui) if (nil ~= _45_) then local package = _45_
 vim.notify(inspect(package), vim.log.levels.DEBUG) elseif (_45_ == nil) then

 vim.notify("No package under cursor", vim.log.levels.INFO) else end end

 return schedule_redraw(ui) end

 local function exec_keymap_s(ui)
 do local _47_ = cursor__3epackage(ui) if (nil ~= _47_) then local package = _47_
 if Package["aligned?"](package) then
 vim.notify(fmt("%s already aligned", package.name), vim.log.levels.INFO) else


 local function _48_(_241) return vim.notify(_241, vim.log.levels.ERROR) end R["map-err"](Runtime.Command["align-package-tree"](ui.runtime, package), _48_) end elseif (_47_ == nil) then
 vim.notify("No package under cursor", vim.log.levels.INFO) else end end

 return schedule_redraw(ui) end

 local function exec_keymap_u(ui)
 local _51_ = cursor__3epackage(ui) if (nil ~= _51_) then local package = _51_


 local function _52_(_241) return vim.notify(_241, vim.log.levels.ERROR) end R["map-err"](Runtime.Command["unstage-package-tree"](ui.runtime, package), _52_)
 return schedule_redraw(ui) elseif (_51_ == nil) then
 return vim.notify("No package under cursor", vim.log.levels.INFO) else return nil end end


 local function exec_keymap_d(ui)
 local _54_ = cursor__3epackage(ui) if (nil ~= _54_) then local package = _54_


 local function _55_(_241) return vim.notify(_241, vim.log.levels.ERROR) end R["map-err"](Runtime.Command["discard-package-tree"](ui.runtime, package), _55_)
 return schedule_redraw(ui) elseif (_54_ == nil) then
 return vim.notify("No package under cursor", vim.log.levels.INFO) else return nil end end


 local function exec_keymap__3d(ui)
 local _57_ = cursor__3epackage(ui) if (nil ~= _57_) then local package = _57_
 local _58_ do local t_59_ = package if (nil ~= t_59_) then t_59_ = (t_59_).git else end if (nil ~= t_59_) then t_59_ = (t_59_).target else end if (nil ~= t_59_) then t_59_ = (t_59_).logs else end _58_ = t_59_ end if (_58_ == nil) then


 local function _63_(_241) return vim.notify(_241, vim.log.levels.ERROR) end R["map-err"](Runtime.Command["get-logs"](ui.runtime, package), _63_)
 return schedule_redraw(ui) elseif (nil ~= _58_) then local any = _58_

 package["git"]["target"]["logs"] = nil
 return schedule_redraw(ui) else return nil end elseif (_57_ == nil) then
 return vim.notify("No package under cursor", vim.log.levels.INFO) else return nil end end


 local function prepare_interface(ui)
 local function map(buf, mode, key, cb)
 return api.nvim_buf_set_keymap(buf, mode, key, "", {callback = cb, nowait = true}) end

 do local _66_ = ui.win api.nvim_win_set_option(_66_, "wrap", false) api.nvim_win_set_option(_66_, "list", false) end


 do local _67_ = ui.buf api.nvim_buf_set_option(_67_, "modifiable", false) api.nvim_buf_set_option(_67_, "buftype", "nofile") api.nvim_buf_set_option(_67_, "bufhidden", "hide") api.nvim_buf_set_option(_67_, "buflisted", false) api.nvim_buf_set_option(_67_, "swapfile", false) api.nvim_buf_set_option(_67_, "ft", "pact") end






 do local _68_ = ui.buf
 local function _69_() return exec_keymap__3d(ui) end map(_68_, "n", "=", _69_)

 local function _70_() return exec_keymap_cc(ui) end map(_68_, "n", "cc", _70_)
 local function _71_() return exec_keymap_s(ui) end map(_68_, "n", "s", _71_)
 local function _72_() return exec_keymap_p(ui) end map(_68_, "n", "p", _72_)
 local function _73_() return exec_keymap_u(ui) end map(_68_, "n", "u", _73_)
 local function _74_() return exec_keymap_d(ui) end map(_68_, "n", "d", _74_) end
 return ui end

 M.attach = function(win, buf, proxies, opts)

 local opts0 = (opts or {})

 local Runtime0 = require("pact.runtime")
 local config = require("pact.config")
 local runtime = Runtime0["add-proxied-plugins"](Runtime0.new({["concurrency-limit"] = config["concurrency-limit"]}), proxies)

 local ui = prepare_interface({runtime = runtime, win = win, buf = buf, extmarks = {}, ["ns-id"] = api.nvim_create_namespace("pact-ui"), ["ns-meta-id"] = api.nvim_create_namespace("pact-ui-meta"), ["package->line"] = {}, errors = {}})








 Log["new-log-file"](FS["join-path"](config.path.data, "pact.log"))

 do local _let_75_ = require("pact.task.scheduler") local default_scheduler = _let_75_["default-scheduler"]
 local function _76_() return schedule_redraw(ui) end subscribe(default_scheduler, _76_) end
 Runtime0.Command["initial-load"](runtime)
 return schedule_redraw(ui) end

 return M