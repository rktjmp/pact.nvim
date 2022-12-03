local enum_path
local function _1_(...)
  local full_mod_path_2_auto = ...
  local _2_ = full_mod_path_2_auto
  local function _3_(...)
    local path_3_auto = _2_
    return ("string" == type(path_3_auto))
  end
  if ((nil ~= _2_) and _3_(...)) then
    local path_3_auto = _2_
    if string.find(full_mod_path_2_auto, "debug") then
      local _4_ = string.match(full_mod_path_2_auto, ("(.+%.)" .. "debug"))
      if (_4_ == nil) then
        return ""
      elseif (nil ~= _4_) then
        local root_4_auto = _4_
        return root_4_auto
      else
        return nil
      end
    else
      return error(string.format("relative-root: no match in &from %q for %q", full_mod_path_2_auto, "debug"))
    end
  elseif (_2_ == nil) then
    return ""
  else
    return nil
  end
end
enum_path = ((_1_(...) or "") .. "enum")
local M = {}
M.inspect = function(...)
  local _local_9_
  do
    local _8_ = require(enum_path)
    _local_9_ = _8_
  end
  local _local_10_ = _local_9_
  local pack = _local_10_["pack"]
  local unpack = _local_10_["unpack"]
  local _let_11_ = require("fennel")
  local view = _let_11_["view"]
  local args = pack(...)
  local viewed = {}
  for n = 1, args.n do
    table.insert(viewed, view(args[n]))
  end
  return unpack(viewed)
end
M["inspect!"] = function(...)
  print(M.inspect(...))
  return ...
end
return M