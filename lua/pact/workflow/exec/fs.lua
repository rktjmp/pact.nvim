local _local_5_, enum, _local_6_, _local_7_ = nil, nil, nil, nil
do
  local _4_ = vim
  local _3_ = string
  local _2_ = require("pact.lib.ruin.enum")
  local _1_ = require("pact.lib.ruin.type")
  _local_5_, enum, _local_6_, _local_7_ = _1_, _2_, _3_, _4_
end
local _local_8_ = _local_5_
local string_3f = _local_8_["string?"]
local table_3f = _local_8_["table?"]
local _local_9_ = _local_6_
local fmt = _local_9_["format"]
local _local_10_ = _local_7_
local uv = _local_10_["loop"]
do local _ = {nil, nil} end
local function what_is_at(path)
  local _11_, _12_, _13_ = uv.fs_stat(path)
  if ((_G.type(_11_) == "table") and (nil ~= (_11_).type)) then
    local type = (_11_).type
    return type
  elseif ((_11_ == nil) and true and (_13_ == "ENOENT")) then
    local _ = _12_
    return "nothing"
  elseif ((_11_ == nil) and (nil ~= _12_) and true) then
    local err = _12_
    local _ = _13_
    return nil, fmt("uv.fs_stat error %s", err)
  elseif ((_11_ == nil) and (nil ~= _12_)) then
    local err = _12_
    return nil, err
  else
    return nil
  end
end
local function ensure_directory_exists(path)
  local _15_, _16_ = what_is_at(path)
  if (_15_ == "nothing") then
    local _17_
    local function _18_(_241, _242)
      local target = (_241 .. "/" .. _242)
      local _19_, _20_ = what_is_at(target)
      if (_19_ == "nothing") then
        return (uv.fs_mkdir(target, 493) and target)
      elseif (_19_ == "directory") then
        return target
      elseif (nil ~= _19_) then
        local other = _19_
        return enum.reduced({nil, fmt("could not create directory %q exists, already %q", target, other)})
      elseif ((_19_ == nil) and (nil ~= _20_)) then
        local err = _20_
        return enum.reduced({nil, err})
      else
        return nil
      end
    end
    local function _22_()
      return string.gmatch(path, "/([^/]+)")
    end
    _17_ = enum.reduce(_18_, "/", _22_)
    if ((_G.type(_17_) == "table") and ((_17_)[1] == nil) and (nil ~= (_17_)[2])) then
      local err = (_17_)[2]
      return nil, err
    else
      return nil
    end
  elseif (_15_ == "directory") then
    return path
  elseif ((_15_ == nil) and (nil ~= _16_)) then
    local err = _16_
    return nil, fmt("could not ensure %q exists, %q", path, err)
  elseif (nil ~= _15_) then
    local any = _15_
    return nil, fmt("could not ensure directory %q exists, already %q", path, any)
  else
    return nil
  end
end
return {["ensure-directory-exists"] = ensure_directory_exists, ["what-is-at"] = what_is_at}