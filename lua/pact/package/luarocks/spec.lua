
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
 local _local_12_, E, inspect, _local_13_, _local_14_ = nil, nil, nil, nil, nil do local _11_ = string local _10_ = require("pact.package.version")

 local _9_ = (vim.inspect or print) local _8_ = require("pact.lib.ruin.enum") local _7_ = require("pact.lib.ruin.result") _local_12_, E, inspect, _local_13_, _local_14_ = _7_, _8_, _9_, _10_, _11_ end local _local_15_ = _local_12_ local err = _local_15_["err"] local map_err = _local_15_["map-err"] local ok = _local_15_["ok"] local _local_16_ = _local_13_
 local version_spec_string_3f = _local_16_["version-spec-string?"] local _local_17_ = _local_14_
 local fmt = _local_17_["format"] do local _ = {nil, nil} end

 local function make_canonical_id(server, rock)
 local s = string.gsub(server, "[^%w]+", "-")
 local r = string.gsub(server, "[^%w]+", "-")
 return ("rock-" .. s .. "-" .. r) end

 local function validate_name(rock_name)
 local _18_ = string.match(rock_name, "[%a%d]+") if (nil ~= _18_) then local any = _18_ return "ok" elseif (_18_ == nil) then

 return {"error", "invalid rock name"} else return nil end end

 local function validate_constraint(opts)
 local _20_ = version_spec_string_3f((opts.constraint or opts.version or "")) if (_20_ == true) then return "ok" elseif (_20_ == false) then

 return {"error", "constraint must be version"} else return nil end end

 local __fn_2a_luarocks_dispatch = {bodies = {}, help = {}} local luarocks local function _22_(...) if (0 == #(__fn_2a_luarocks_dispatch).bodies) then error(("multi-arity function " .. "luarocks" .. " has no bodies")) else end local _24_ do local f_78_auto = nil for __79_auto, match_3f_80_auto in ipairs((__fn_2a_luarocks_dispatch).bodies) do if f_78_auto then break end f_78_auto = match_3f_80_auto(...) end _24_ = f_78_auto end if (nil ~= _24_) then local f_78_auto = _24_ return f_78_auto(...) elseif (_24_ == nil) then local view_81_auto do local _25_, _26_ = pcall(require, "fennel") if ((_25_ == true) and ((_G.type(_26_) == "table") and (nil ~= (_26_).view))) then local view_81_auto0 = (_26_).view view_81_auto = view_81_auto0 elseif ((_25_ == false) and true) then local __79_auto = _26_ view_81_auto = (_G.vim.inspect or print) else view_81_auto = nil end end local msg_82_auto local _28_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_83_auto = 1, select("#", ...) do local val_19_auto = view_81_auto(({...})[i_83_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _28_ = tbl_17_auto end msg_82_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "luarocks", table.concat(_28_, ", "), table.concat((__fn_2a_luarocks_dispatch).help, "\n")) return error(msg_82_auto) else return nil end end luarocks = _22_ local function _31_() do local _ = {} end return luarocks end setmetatable({nil, nil}, {__call = _31_})()

 do table.insert((__fn_2a_luarocks_dispatch).help, "(where [rock-name] (string? rock-name))") local function _33_(...) if (1 == select("#", ...)) then local _34_ = {...} local function _35_(...) local rock_name_32_ = (_34_)[1] return string_3f(rock_name_32_) end if (((_G.type(_34_) == "table") and (nil ~= (_34_)[1])) and _35_(...)) then local rock_name_32_ = (_34_)[1] local function _36_(rock_name)
 return luarocks(rock_name, ">0.0.0") end return _36_ else return nil end else return nil end end table.insert((__fn_2a_luarocks_dispatch).bodies, _33_) end

 do table.insert((__fn_2a_luarocks_dispatch).help, "(where [rock-name version] (and (string? rock-name) (version-spec-string? version)))") local function _41_(...) if (2 == select("#", ...)) then local _42_ = {...} local function _43_(...) local rock_name_39_ = (_42_)[1] local version_40_ = (_42_)[2] return (string_3f(rock_name_39_) and version_spec_string_3f(version_40_)) end if (((_G.type(_42_) == "table") and (nil ~= (_42_)[1]) and (nil ~= (_42_)[2])) and _43_(...)) then local rock_name_39_ = (_42_)[1] local version_40_ = (_42_)[2] local function _44_(rock_name, version)

 return luarocks(rock_name, {constraint = version}) end return _44_ else return nil end else return nil end end table.insert((__fn_2a_luarocks_dispatch).bodies, _41_) end

 do table.insert((__fn_2a_luarocks_dispatch).help, "(where [rock-name version opts] (and (string? rock-name) (version-spec-string? version) (table? opts)))") local function _50_(...) if (3 == select("#", ...)) then local _51_ = {...} local function _52_(...) local rock_name_47_ = (_51_)[1] local version_48_ = (_51_)[2] local opts_49_ = (_51_)[3] return (string_3f(rock_name_47_) and version_spec_string_3f(version_48_) and table_3f(opts_49_)) end if (((_G.type(_51_) == "table") and (nil ~= (_51_)[1]) and (nil ~= (_51_)[2]) and (nil ~= (_51_)[3])) and _52_(...)) then local rock_name_47_ = (_51_)[1] local version_48_ = (_51_)[2] local opts_49_ = (_51_)[3] local function _53_(rock_name, version, opts)


 return luarocks(rock_name, E["merge$"](opts, {constraint = version})) end return _53_ else return nil end else return nil end end table.insert((__fn_2a_luarocks_dispatch).bodies, _50_) end

 do table.insert((__fn_2a_luarocks_dispatch).help, "(where [rock-name opts] (and (string? rock-name) (table? opts)))") local function _58_(...) if (2 == select("#", ...)) then local _59_ = {...} local function _60_(...) local rock_name_56_ = (_59_)[1] local opts_57_ = (_59_)[2] return (string_3f(rock_name_56_) and table_3f(opts_57_)) end if (((_G.type(_59_) == "table") and (nil ~= (_59_)[1]) and (nil ~= (_59_)[2])) and _60_(...)) then local rock_name_56_ = (_59_)[1] local opts_57_ = (_59_)[2] local function _61_(rock_name, opts)

 local function _62_(...) local _63_ = ... if (_63_ == "ok") then local function _64_(...) local _65_ = ... if (_65_ == "ok") then



 opts.server = (opts.server or "https://luarocks.org")
 opts["rock-name"] = rock_name
 opts.name = (opts.name or ("luarocks/" .. rock_name))
 opts["canonical-id"] = make_canonical_id(opts.server, rock_name)
 opts.constraint = (opts.constraint or opts.version)
 return ok({"rock", opts}) elseif ((_G.type(_65_) == "table") and ((_65_)[1] == "error") and (nil ~= (_65_)[2])) then local e = (_65_)[2]

 return err(fmt("%s %s", (rock_name or "unknown-rock"), e)) elseif true then local _ = _65_


 return err(fmt("%s %s", (rock_name or "unknown-rock"), "invalid rock plugin spec")) else return nil end end return _64_(validate_constraint(opts)) elseif ((_G.type(_63_) == "table") and ((_63_)[1] == "error") and (nil ~= (_63_)[2])) then local e = (_63_)[2] return err(fmt("%s %s", (rock_name or "unknown-rock"), e)) elseif true then local _ = _63_ return err(fmt("%s %s", (rock_name or "unknown-rock"), "invalid rock plugin spec")) else return nil end end return _62_(validate_name(rock_name)) end return _61_ else return nil end else return nil end end table.insert((__fn_2a_luarocks_dispatch).bodies, _58_) end



 return {luarocks = luarocks}