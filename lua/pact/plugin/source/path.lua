local _local_2_
do
  local _1_ = require("pact.lib.ruin.type")
  _local_2_ = _1_
end
local _local_3_ = _local_2_
local string_3f = _local_3_["string?"]
local table_3f = _local_3_["table?"]
do local _ = {nil, nil} end
local function path__3eid(path)
  local _4_ = path
  if (nil ~= _4_) then
    local _5_ = string.reverse(_4_)
    if (nil ~= _5_) then
      local _6_ = string.match(_5_, "([^/]+)/.+")
      if (nil ~= _6_) then
        return string.reverse(_6_)
      else
        return _6_
      end
    else
      return _5_
    end
  else
    return _4_
  end
end
local __fn_2a_path_dispatch = {bodies = {}, help = {}}
local path
local function _11_(...)
  if (0 == #(__fn_2a_path_dispatch).bodies) then
    error(("multi-arity function " .. "path" .. " has no bodies"))
  else
  end
  local _13_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_path_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _13_ = f_74_auto
  end
  if (nil ~= _13_) then
    local f_74_auto = _13_
    return f_74_auto(...)
  elseif (_13_ == nil) then
    local view_77_auto
    do
      local _14_, _15_ = pcall(require, "fennel")
      if ((_14_ == true) and ((_G.type(_15_) == "table") and (nil ~= (_15_).view))) then
        local view_77_auto0 = (_15_).view
        view_77_auto = view_77_auto0
      elseif ((_14_ == false) and true) then
        local __75_auto = _15_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "path", view_77_auto({...}), table.concat((__fn_2a_path_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
path = _11_
local function _18_()
  local _19_
  do
    table.insert((__fn_2a_path_dispatch).help, "(where [local-path] (string? local-path))")
    local function _20_(...)
      if (1 == select("#", ...)) then
        local _21_ = {...}
        local function _22_(...)
          local local_path_10_ = (_21_)[1]
          return string_3f(local_path_10_)
        end
        if (((_G.type(_21_) == "table") and (nil ~= (_21_)[1])) and _22_(...)) then
          local local_path_10_ = (_21_)[1]
          local function _23_(local_path)
            local constraint
            do
              local _24_ = require("pact.constraint.path")
              constraint = _24_
            end
            return {id = path__3eid(local_path), path = local_path, constraint = constraint.path(local_path)}
          end
          return _23_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_path_dispatch).bodies, _20_)
    _19_ = path
  end
  local function _27_()
    table.insert((__fn_2a_path_dispatch).help, "(where _)")
    local function _28_(...)
      if true then
        local _29_ = {...}
        local function _30_(...)
          return true
        end
        if ((_G.type(_29_) == "table") and _30_(...)) then
          local function _31_(...)
            return nil, "must be called with `path`"
          end
          return _31_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_path_dispatch).bodies, _28_)
    return path
  end
  do local _ = {_19_, _27_()} end
  return path
end
setmetatable({nil, nil}, {__call = _18_})()
return {path = path}