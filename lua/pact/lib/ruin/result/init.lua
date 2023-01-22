


 local _local_3_, enum = nil, nil do local _2_ local function _4_(...) local full_mod_path_2_auto = ... local _5_ = full_mod_path_2_auto local function _6_(...) local path_3_auto = _5_ return ("string" == type(path_3_auto)) end if ((nil ~= _5_) and _6_(...)) then local path_3_auto = _5_ if string.find(full_mod_path_2_auto, "result") then local _7_ = string.match(full_mod_path_2_auto, ("(.+%.)" .. "result")) if (_7_ == nil) then return "" elseif (nil ~= _7_) then local root_4_auto = _7_ return root_4_auto else return nil end else return error(string.format("relative-root: no match in &from %q for %q", full_mod_path_2_auto, "result")) end elseif (_5_ == nil) then return "" else return nil end end _2_ = require(((_4_(...) or "") .. "enum")) local _1_ local function _11_(...) local full_mod_path_2_auto = ... local _12_ = full_mod_path_2_auto local function _13_(...) local path_3_auto = _12_ return ("string" == type(path_3_auto)) end if ((nil ~= _12_) and _13_(...)) then local path_3_auto = _12_ if string.find(full_mod_path_2_auto, "result") then local _14_ = string.match(full_mod_path_2_auto, ("(.+%.)" .. "result")) if (_14_ == nil) then return "" elseif (nil ~= _14_) then local root_4_auto = _14_ return root_4_auto else return nil end else return error(string.format("relative-root: no match in &from %q for %q", full_mod_path_2_auto, "result")) end elseif (_12_ == nil) then return "" else return nil end end _1_ = require(((_11_(...) or "") .. "type")) _local_3_, enum = _1_, _2_ end local _local_18_ = _local_3_ local type_of = _local_18_["type-of"] do local _ = {nil, nil} end
















 local M
 do local _local_19_ = require("pact.lib.ruin..type") local set_type = _local_19_["set-type"] local type_is_any_3f = _local_19_["type-is-any?"] local type_is_3f = _local_19_["type-is?"] local type_of0 = _local_19_["type-of"] local _local_20_ = require("pact.lib.ruin..enum") local pack = _local_20_["pack"] local unpack = _local_20_["unpack"] local __protect_call = {"password"} local M0 = {} local __M = {} M0["result?"] = function(v) return type_is_any_3f(v, {"ruin.result.ERR_TYPE", "ruin.result.OK_TYPE"}) end M0["err?"] = function(v) return type_is_3f(v, "ruin.result.ERR_TYPE") end M0["ok?"] = function(v) return type_is_3f(v, "ruin.result.OK_TYPE") end __M["enforce-type!"] = function(v) if M0["result?"](v) then return v else return error(string.format(("Expected " .. "result" .. " but was given %s<%s>"), type_of0(v), tostring(v))) end end __M["gen-type"] = function(type_name, ...) local val_44_auto = pack(...) local tos_45_auto local function _22_() local view_46_auto do local _23_, _24_ = pcall(require, "fennel") if ((_23_ == true) and ((_G.type(_24_) == "table") and (nil ~= (_24_).view))) then local view_46_auto0 = (_24_).view view_46_auto = view_46_auto0 elseif ((_23_ == false) and true) then local __47_auto = _24_ view_46_auto = tostring else view_46_auto = nil end end local val_str_48_auto do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_49_auto = 1, val_44_auto.n do local val_19_auto = view_46_auto((val_44_auto)[i_49_auto], {["prefer-colon?"] = true}) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end val_str_48_auto = tbl_17_auto end return ("@" .. type_name .. "<" .. table.concat(val_str_48_auto, ",") .. ">") end tos_45_auto = _22_ local type_t_50_auto do local _27_ = type_name if (_27_ == "err") then type_t_50_auto = "ruin.result.ERR_TYPE" elseif (_27_ == "ok") then type_t_50_auto = "ruin.result.OK_TYPE" elseif true then local __47_auto = _27_ type_t_50_auto = error(("result" .. " construction: invalid type name " .. type_name)) else type_t_50_auto = nil end end local mt_51_auto local function _29_(_241, _242) local _30_ = _242 if (_30_ == __protect_call) then return unpack(val_44_auto) elseif true then local __47_auto = _30_ return error("nedry.gif") else return nil end end mt_51_auto = {__call = _29_, __fennelview = tos_45_auto, __tostring = tos_45_auto} local _32_ = {type_name, unpack(val_44_auto)} _32_["n"] = val_44_auto.n setmetatable(_32_, mt_51_auto) set_type(_32_, type_t_50_auto) return _32_ end M0.unit = function(...) local arguments = pack(...) local _33_ = arguments local function _34_(...) local either_21_auto = (_33_)[1] return ((1 == arguments.n) and M0["result?"](either_21_auto)) end if (((_G.type(_33_) == "table") and (nil ~= (_33_)[1])) and _34_(...)) then local either_21_auto = (_33_)[1] return either_21_auto else local function _35_(...) return (2 <= arguments.n) end if (((_G.type(_33_) == "table") and ((_33_)[1] == nil)) and _35_(...)) then return M0.err(unpack(arguments, 2)) else local function _36_(...) local _ = _33_ return not ((2 <= arguments.n) and (nil == arguments[1])) end if (true and _36_(...)) then local _ = _33_ return M0.ok(unpack(arguments)) elseif true then local __20_auto = _33_ local view_19_auto do local _37_, _38_ = pcall(require, "fennel") if ((_37_ == true) and ((_G.type(_38_) == "table") and (nil ~= (_38_).view))) then local view_19_auto0 = (_38_).view view_19_auto = view_19_auto0 elseif ((_37_ == false) and (_38_ == __20_auto)) then view_19_auto = tostring else view_19_auto = nil end end return error(string.format("attempted to create %s but did not match any spec (%q)", "result", view_19_auto(arguments))) else return nil end end end end M0["result"] = M0.unit M0.unwrap = function(result) if __M["enforce-type!"](result) then return result(__protect_call) else return nil end end M0.bind = function(x, f) if M0["ok?"](x) then return __M["enforce-type!"](f(M0.unwrap(x))) else return x end end M0.err = function(...) local arguments = pack(...) local _43_ = arguments if (_43_ == arguments) then return __M["gen-type"]("err", unpack(arguments)) elseif (_43_ == arguments) then return error(string.format("attempted to create %s but value matched %s", "err", "ok")) elseif true then local __32_auto = _43_ return error(string.format("attempted to create %s but did not match any spec", "err")) else return nil end end M0.ok = function(...) local arguments = pack(...) local _45_ = arguments if (_45_ == arguments) then return __M["gen-type"]("ok", unpack(arguments)) elseif (_45_ == arguments) then return error(string.format("attempted to create %s but value matched %s", "ok", "err")) elseif true then local __43_auto = _45_ return error(string.format("attempted to create %s but did not match any spec", "ok")) else return nil end end M0.map = function(result, ok_f, _3ferr_f) if M0["ok?"](result) then return M0["map-ok"](result, ok_f) else if _3ferr_f then return M0["map-err"](result, _3ferr_f) else return result end end end M0["map-err"] = function(result, f) if M0["err?"](result) then return M0.unit(f(M0.unwrap(result))) else return result end end M0["map-ok"] = function(result, f) if M0["ok?"](result) then return M0.unit(f(M0.unwrap(result))) else return result end end M = M0 end






























 M.join = function(r1, r2)

 assert((M["result?"](r1) and M["result?"](r2)), string.format("result#join argument was not a result type (join %s %s)", type_of(r1), type_of(r2)))



 local function package(how, a, b)

 local a0 = enum.pack(M.unwrap(a))
 local b0 = enum.pack(M.unwrap(b)) local _
 if (0 < b0.n) then
 for i = 1, b0.n do
 a0[(a0.n + i)] = (b0)[i] end
 a0.n = (a0.n + b0.n) _ = nil else _ = nil end
 return how(enum.unpack(a0, 1, a0.n)) end
 local _52_ = {M["ok?"](r1), M["ok?"](r2)} if ((_G.type(_52_) == "table") and ((_52_)[1] == true) and ((_52_)[2] == true)) then

 return package(M.ok, r1, r2) elseif ((_G.type(_52_) == "table") and ((_52_)[1] == true) and ((_52_)[2] == false)) then

 return r2 elseif ((_G.type(_52_) == "table") and ((_52_)[1] == false) and ((_52_)[2] == true)) then

 return r1 elseif ((_G.type(_52_) == "table") and ((_52_)[1] == false) and ((_52_)[2] == false)) then

 return package(M.err, r1, r2) else return nil end end

 M["unwrap-or-raise"] = function(result)

 if M["err?"](result) then
 return error(M.unwrap(result)) else
 return M.unwrap(result) end end
 M["unwrap!"] = M["unwrap-or-raise"]



















































 return M