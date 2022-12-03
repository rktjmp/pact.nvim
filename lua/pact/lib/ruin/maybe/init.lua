local _local_3_, enum = nil, nil
do
  local _2_
  local function _4_(...)
    local full_mod_path_2_auto = ...
    local _5_ = full_mod_path_2_auto
    local function _6_(...)
      local path_3_auto = _5_
      return ("string" == type(path_3_auto))
    end
    if ((nil ~= _5_) and _6_(...)) then
      local path_3_auto = _5_
      if string.find(full_mod_path_2_auto, "maybe") then
        local _7_ = string.match(full_mod_path_2_auto, ("(.+%.)" .. "maybe"))
        if (_7_ == nil) then
          return ""
        elseif (nil ~= _7_) then
          local root_4_auto = _7_
          return root_4_auto
        else
          return nil
        end
      else
        return error(string.format("relative-root: no match in &from %q for %q", full_mod_path_2_auto, "maybe"))
      end
    elseif (_5_ == nil) then
      return ""
    else
      return nil
    end
  end
  _2_ = require(((_4_(...) or "") .. "enum"))
  local _1_
  local function _11_(...)
    local full_mod_path_2_auto = ...
    local _12_ = full_mod_path_2_auto
    local function _13_(...)
      local path_3_auto = _12_
      return ("string" == type(path_3_auto))
    end
    if ((nil ~= _12_) and _13_(...)) then
      local path_3_auto = _12_
      if string.find(full_mod_path_2_auto, "maybe") then
        local _14_ = string.match(full_mod_path_2_auto, ("(.+%.)" .. "maybe"))
        if (_14_ == nil) then
          return ""
        elseif (nil ~= _14_) then
          local root_4_auto = _14_
          return root_4_auto
        else
          return nil
        end
      else
        return error(string.format("relative-root: no match in &from %q for %q", full_mod_path_2_auto, "maybe"))
      end
    elseif (_12_ == nil) then
      return ""
    else
      return nil
    end
  end
  _1_ = require(((_11_(...) or "") .. "type"))
  _local_3_, enum = _1_, _2_
end
local _local_18_ = _local_3_
local type_of = _local_18_["type-of"]
do local _ = {nil, nil} end
local _local_19_ = require("pact.lib.ruin..type")
local set_type = _local_19_["set-type"]
local type_is_any_3f = _local_19_["type-is-any?"]
local type_is_3f = _local_19_["type-is?"]
local type_of0 = _local_19_["type-of"]
local _local_20_ = require("pact.lib.ruin..enum")
local pack = _local_20_["pack"]
local unpack = _local_20_["unpack"]
local __protect_call = {"password"}
local M = {}
local __M = {}
M["maybe?"] = function(v)
  return type_is_any_3f(v, {"ruin.maybe.NONE_TYPE", "ruin.maybe.SOME_TYPE"})
end
M["none?"] = function(v)
  return type_is_3f(v, "ruin.maybe.NONE_TYPE")
end
M["some?"] = function(v)
  return type_is_3f(v, "ruin.maybe.SOME_TYPE")
end
__M["enforce-type!"] = function(v)
  if M["maybe?"](v) then
    return v
  else
    return error(string.format(("Expected " .. "maybe" .. " but was given %s<%s>"), type_of0(v), tostring(v)))
  end
end
__M["gen-type"] = function(type_name, ...)
  local val_44_auto = pack(...)
  local tos_45_auto
  local function _22_()
    local _let_23_ = require("fennel")
    local view_46_auto = _let_23_["view"]
    local val_str_47_auto
    do
      local tbl_17_auto = {}
      local i_18_auto = #tbl_17_auto
      for i_48_auto = 1, val_44_auto.n do
        local val_19_auto = view_46_auto((val_44_auto)[i_48_auto], {["prefer-colon?"] = true})
        if (nil ~= val_19_auto) then
          i_18_auto = (i_18_auto + 1)
          do end (tbl_17_auto)[i_18_auto] = val_19_auto
        else
        end
      end
      val_str_47_auto = tbl_17_auto
    end
    return ("@" .. type_name .. "<" .. table.concat(val_str_47_auto, ",") .. ">")
  end
  tos_45_auto = _22_
  local type_t_49_auto
  do
    local _25_ = type_name
    if (_25_ == "none") then
      type_t_49_auto = "ruin.maybe.NONE_TYPE"
    elseif (_25_ == "some") then
      type_t_49_auto = "ruin.maybe.SOME_TYPE"
    elseif true then
      local __50_auto = _25_
      type_t_49_auto = error(("maybe" .. " construction: invalid type name " .. type_name))
    else
      type_t_49_auto = nil
    end
  end
  local mt_51_auto
  local function _27_(_241, _242)
    local _28_ = _242
    if (_28_ == __protect_call) then
      return unpack(val_44_auto)
    elseif true then
      local __50_auto = _28_
      return error("nedry.gif")
    else
      return nil
    end
  end
  mt_51_auto = {__call = _27_, __fennelview = tos_45_auto, __tostring = tos_45_auto}
  local _30_ = {type_name, unpack(val_44_auto)}
  _30_["n"] = val_44_auto.n
  setmetatable(_30_, mt_51_auto)
  set_type(_30_, type_t_49_auto)
  return _30_
end
M.unit = function(...)
  local arguments = pack(...)
  local _31_ = arguments
  local function _32_(...)
    local either_20_auto = (_31_)[1]
    return ((1 == arguments.n) and M["maybe?"](either_20_auto))
  end
  if (((_G.type(_31_) == "table") and (nil ~= (_31_)[1])) and _32_(...)) then
    local either_20_auto = (_31_)[1]
    return either_20_auto
  else
    local function _33_(...)
      local _ = _31_
      return ((arguments.n == 0) or ((arguments.n == 1) and (nil == arguments[1])))
    end
    if (true and _33_(...)) then
      local _ = _31_
      return M.none(nil)
    else
      local function _34_(...)
        local _ = _31_
        return ((0 < arguments.n) and (nil ~= arguments[1]))
      end
      if (true and _34_(...)) then
        local _ = _31_
        return M.some(unpack(arguments))
      elseif true then
        local __21_auto = _31_
        local _let_35_ = require("fennel")
        local view_19_auto = _let_35_["view"]
        return error(string.format("attempted to create %s but did not match any spec (%q)", "maybe", view_19_auto(arguments)))
      else
        return nil
      end
    end
  end
end
M["maybe"] = M.unit
M.unwrap = function(maybe)
  if __M["enforce-type!"](maybe) then
    return maybe(__protect_call)
  else
    return nil
  end
end
M.bind = function(x, f)
  if M["some?"](x) then
    return __M["enforce-type!"](f(M.unwrap(x)))
  else
    return x
  end
end
M.none = function(...)
  local arguments = pack(...)
  local _39_ = arguments
  local function _40_(...)
    local _ = _39_
    return ((arguments.n == 0) or ((arguments.n == 1) and (nil == arguments[1])))
  end
  if (true and _40_(...)) then
    local _ = _39_
    return __M["gen-type"]("none", nil)
  else
    local function _41_(...)
      local _ = _39_
      return ((0 < arguments.n) and (nil ~= arguments[1]))
    end
    if (true and _41_(...)) then
      local _ = _39_
      return error(string.format("attempted to create %s but value matched %s", "none", "some"))
    elseif true then
      local __32_auto = _39_
      return error(string.format("attempted to create %s but did not match any spec", "none"))
    else
      return nil
    end
  end
end
M.some = function(...)
  local arguments = pack(...)
  local _43_ = arguments
  local function _44_(...)
    local _ = _43_
    return ((0 < arguments.n) and (nil ~= arguments[1]))
  end
  if (true and _44_(...)) then
    local _ = _43_
    return __M["gen-type"]("some", unpack(arguments))
  else
    local function _45_(...)
      local _ = _43_
      return ((arguments.n == 0) or ((arguments.n == 1) and (nil == arguments[1])))
    end
    if (true and _45_(...)) then
      local _ = _43_
      return error(string.format("attempted to create %s but value matched %s", "some", "none"))
    elseif true then
      local __43_auto = _43_
      return error(string.format("attempted to create %s but did not match any spec", "some"))
    else
      return nil
    end
  end
end
M.map = function(maybe, some_f, _3fnone_f)
  if M["some?"](maybe) then
    return M["map-some"](maybe, some_f)
  else
    if _3fnone_f then
      return M["map-none"](maybe, _3fnone_f)
    else
      return maybe
    end
  end
end
M["map-none"] = function(maybe, f)
  if M["none?"](maybe) then
    return M.unit(f(M.unwrap(maybe)))
  else
    return maybe
  end
end
M["map-some"] = function(maybe, f)
  if M["some?"](maybe) then
    return M.unit(f(M.unwrap(maybe)))
  else
    return maybe
  end
end
return M