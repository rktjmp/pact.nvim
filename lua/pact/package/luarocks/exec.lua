
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local inspect, _local_11_, _local_12_, _local_13_ = nil, nil, nil, nil do local _10_ = string local _9_ = vim local _8_ = require("pact.exec") local _7_ = require("pact.inspect") inspect, _local_11_, _local_12_, _local_13_ = _7_, _8_, _9_, _10_ end local _local_14_ = _local_11_
 local cb__3eawait = _local_14_["cb->await"] local run = _local_14_["run"] local _local_15_ = _local_12_
 local uv = _local_15_["loop"] local _local_16_ = _local_13_
 local fmt = _local_16_["format"] do local _ = {nil, nil} end

 local M = {}

 local function dump_err(code, err)
 return fmt("luarocks-error: return-code: %s std-err: %s", code, inspect(err)) end

 M.install = function(name, version, prefix_path) _G.assert((nil ~= prefix_path), "Missing argument prefix-path on ./fnl/pact/package/luarocks/exec.fnl:14") _G.assert((nil ~= version), "Missing argument version on ./fnl/pact/package/luarocks/exec.fnl:14") _G.assert((nil ~= name), "Missing argument name on ./fnl/pact/package/luarocks/exec.fnl:14")
 local _17_, _18_, _19_ = cb__3eawait(run, {"luarocks install --tree $prefix-path $name $version", {name = name, version = version, ["prefix-path"] = prefix_path}}) if ((_17_ == 0) and (nil ~= _18_) and (nil ~= _19_)) then local stdout_7_auto = _18_ local stderr_8_auto = _19_ local _20_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_20_) == "table") and true and (nil ~= (_20_)[2]) and (nil ~= (_20_)[3])) then local _ = (_20_)[1] local lines = (_20_)[2] local err = (_20_)[3]

 return vim.pretty_print(lines, err) elseif true then local __13_auto = _20_ return error(string.format("Unhandled success case for %s %s", "luarocks install --tree $prefix-path $name $version", inspect(__13_auto))) else return nil end elseif ((nil ~= _17_) and (nil ~= _18_) and (nil ~= _19_)) then local code_14_auto = _17_ local stdout_7_auto = _18_ local stderr_8_auto = _19_ local _22_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_22_) == "table") and (nil ~= (_22_)[1]) and (nil ~= (_22_)[2]) and (nil ~= (_22_)[3])) then local code = (_22_)[1] local out = (_22_)[2] local err = (_22_)[3]
 return dump_err(code, {out, err}) elseif true then local __19_auto = _22_ return error(string.format("Unhandled success case for %s", "luarocks install --tree $prefix-path $name $version")) else return nil end elseif ((_17_ == nil) and (nil ~= _18_)) then local err_20_auto = _18_ return nil, err_20_auto else return nil end end

 M["search-remote"] = function(name, _3fversion) _G.assert((nil ~= name), "Missing argument name on ./fnl/pact/package/luarocks/exec.fnl:20")
 local _25_, _26_, _27_ = cb__3eawait(run, {"luarocks search --porcelain $name $version", {name = name, version = (_3fversion or "")}}) if ((_25_ == 0) and (nil ~= _26_) and (nil ~= _27_)) then local stdout_7_auto = _26_ local stderr_8_auto = _27_ local _28_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_28_) == "table") and true and (nil ~= (_28_)[2]) and (nil ~= (_28_)[3])) then local _ = (_28_)[1] local lines = (_28_)[2] local err = (_28_)[3]

 return vim.pretty_print(lines, err) elseif true then local __13_auto = _28_ return error(string.format("Unhandled success case for %s %s", "luarocks search --porcelain $name $version", inspect(__13_auto))) else return nil end elseif ((nil ~= _25_) and (nil ~= _26_) and (nil ~= _27_)) then local code_14_auto = _25_ local stdout_7_auto = _26_ local stderr_8_auto = _27_ local _30_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_30_) == "table") and (nil ~= (_30_)[1]) and (nil ~= (_30_)[2]) and (nil ~= (_30_)[3])) then local code = (_30_)[1] local out = (_30_)[2] local err = (_30_)[3]
 return dump_err(code, {out, err}) elseif true then local __19_auto = _30_ return error(string.format("Unhandled success case for %s", "luarocks search --porcelain $name $version")) else return nil end elseif ((_25_ == nil) and (nil ~= _26_)) then local err_20_auto = _26_ return nil, err_20_auto else return nil end end

 return M