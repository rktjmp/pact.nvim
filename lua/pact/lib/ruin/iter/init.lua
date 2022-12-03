local _local_2_
do
  local _1_
  local function _3_(...)
    local full_mod_path_2_auto = ...
    local _4_ = full_mod_path_2_auto
    local function _5_(...)
      local path_3_auto = _4_
      return ("string" == type(path_3_auto))
    end
    if ((nil ~= _4_) and _5_(...)) then
      local path_3_auto = _4_
      if string.find(full_mod_path_2_auto, "iter") then
        local _6_ = string.match(full_mod_path_2_auto, ("(.+%.)" .. "iter"))
        if (_6_ == nil) then
          return ""
        elseif (nil ~= _6_) then
          local root_4_auto = _6_
          return root_4_auto
        else
          return nil
        end
      else
        return error(string.format("relative-root: no match in &from %q for %q", full_mod_path_2_auto, "iter"))
      end
    elseif (_4_ == nil) then
      return ""
    else
      return nil
    end
  end
  _1_ = require(((_3_(...) or "") .. "type"))
  _local_2_ = _1_
end
local _local_10_ = _local_2_
local number_3f = _local_10_["number?"]
local seq_3f = _local_10_["seq?"]
do local _ = {nil, nil} end
local M = {}
local __fn_2a_M__range_dispatch = {bodies = {}, help = {}}
local function _16_(...)
  if (0 == #(__fn_2a_M__range_dispatch).bodies) then
    error(("multi-arity function " .. "M.range" .. " has no bodies"))
  else
  end
  local _18_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__range_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _18_ = f_74_auto
  end
  if (nil ~= _18_) then
    local f_74_auto = _18_
    return f_74_auto(...)
  elseif (_18_ == nil) then
    local view_77_auto
    do
      local _19_, _20_ = pcall(require, "fennel")
      if ((_19_ == true) and ((_G.type(_20_) == "table") and (nil ~= (_20_).view))) then
        local view_77_auto0 = (_20_).view
        view_77_auto = view_77_auto0
      elseif ((_19_ == false) and true) then
        local __75_auto = _20_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.range", view_77_auto({...}), table.concat((__fn_2a_M__range_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.range = _16_
local function _23_()
  local _24_
  do
    table.insert((__fn_2a_M__range_dispatch).help, "(where [start stop] (and (number? start) (number? stop)))")
    local function _25_(...)
      if (2 == select("#", ...)) then
        local _26_ = {...}
        local function _27_(...)
          local start_11_ = (_26_)[1]
          local stop_12_ = (_26_)[2]
          return (number_3f(start_11_) and number_3f(stop_12_))
        end
        if (((_G.type(_26_) == "table") and (nil ~= (_26_)[1]) and (nil ~= (_26_)[2])) and _27_(...)) then
          local start_11_ = (_26_)[1]
          local stop_12_ = (_26_)[2]
          local function _28_(start, stop)
            return M.range(start, stop, 1)
          end
          return _28_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__range_dispatch).bodies, _25_)
    _24_ = M.range
  end
  local function _31_()
    table.insert((__fn_2a_M__range_dispatch).help, "(where [start stop step] (and (number? start) (number? stop) (number? step) (<= 1 step)))")
    local function _32_(...)
      if (3 == select("#", ...)) then
        local _33_ = {...}
        local function _34_(...)
          local start_13_ = (_33_)[1]
          local stop_14_ = (_33_)[2]
          local step_15_ = (_33_)[3]
          return (number_3f(start_13_) and number_3f(stop_14_) and number_3f(step_15_) and (1 <= step_15_))
        end
        if (((_G.type(_33_) == "table") and (nil ~= (_33_)[1]) and (nil ~= (_33_)[2]) and (nil ~= (_33_)[3])) and _34_(...)) then
          local start_13_ = (_33_)[1]
          local stop_14_ = (_33_)[2]
          local step_15_ = (_33_)[3]
          local function _35_(start, stop, step)
            local function _43_()
              if (start <= stop) then
                local function _37_(_241, _242)
                  return (_241 + _242)
                end
                local function _38_(_241, _242)
                  return (_241 - _242)
                end
                local function _39_(_241, _242)
                  return (_241 <= _242)
                end
                return {_37_, _38_, _39_}
              else
                local function _40_(_241, _242)
                  return (_241 - _242)
                end
                local function _41_(_241, _242)
                  return (_241 + _242)
                end
                local function _42_(_241, _242)
                  return (_242 <= _241)
                end
                return {_40_, _41_, _42_}
              end
            end
            local _local_36_ = _43_()
            local op = _local_36_[1]
            local inv_op = _local_36_[2]
            local check = _local_36_[3]
            local function gen(_44_, last)
              local _arg_45_ = _44_
              local start0 = _arg_45_[1]
              local stop0 = _arg_45_[2]
              local step0 = _arg_45_[3]
              local maybe = op(last, step0)
              if check(maybe, stop0) then
                return maybe
              else
                return nil
              end
            end
            return gen, {start, stop, step}, inv_op(start, step)
          end
          return _35_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__range_dispatch).bodies, _32_)
    return M.range
  end
  do local _ = {_24_, _31_()} end
  return M.range
end
setmetatable({nil, nil}, {__call = _23_})()
local function ward_impl(seq, step, step_flip, initial_state)
  local step0 = (step_flip * step)
  local function gen(seq0, last)
    local next_i = (last + step0)
    local _49_ = (seq0)[next_i]
    if (nil ~= _49_) then
      local val = _49_
      return next_i, val
    else
      return nil
    end
  end
  return gen, seq, initial_state
end
local __fn_2a_M__fward_dispatch = {bodies = {}, help = {}}
local function _54_(...)
  if (0 == #(__fn_2a_M__fward_dispatch).bodies) then
    error(("multi-arity function " .. "M.fward" .. " has no bodies"))
  else
  end
  local _56_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__fward_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _56_ = f_74_auto
  end
  if (nil ~= _56_) then
    local f_74_auto = _56_
    return f_74_auto(...)
  elseif (_56_ == nil) then
    local view_77_auto
    do
      local _57_, _58_ = pcall(require, "fennel")
      if ((_57_ == true) and ((_G.type(_58_) == "table") and (nil ~= (_58_).view))) then
        local view_77_auto0 = (_58_).view
        view_77_auto = view_77_auto0
      elseif ((_57_ == false) and true) then
        local __75_auto = _58_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.fward", view_77_auto({...}), table.concat((__fn_2a_M__fward_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.fward = _54_
local function _61_()
  local _62_
  do
    table.insert((__fn_2a_M__fward_dispatch).help, "(where [seq] (seq? seq))")
    local function _63_(...)
      if (1 == select("#", ...)) then
        local _64_ = {...}
        local function _65_(...)
          local seq_51_ = (_64_)[1]
          return seq_3f(seq_51_)
        end
        if (((_G.type(_64_) == "table") and (nil ~= (_64_)[1])) and _65_(...)) then
          local seq_51_ = (_64_)[1]
          local function _66_(seq)
            return M.fward(seq, 1)
          end
          return _66_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__fward_dispatch).bodies, _63_)
    _62_ = M.fward
  end
  local function _69_()
    table.insert((__fn_2a_M__fward_dispatch).help, "(where [seq step] (and (seq? seq) (number? step) (<= 1 step)))")
    local function _70_(...)
      if (2 == select("#", ...)) then
        local _71_ = {...}
        local function _72_(...)
          local seq_52_ = (_71_)[1]
          local step_53_ = (_71_)[2]
          return (seq_3f(seq_52_) and number_3f(step_53_) and (1 <= step_53_))
        end
        if (((_G.type(_71_) == "table") and (nil ~= (_71_)[1]) and (nil ~= (_71_)[2])) and _72_(...)) then
          local seq_52_ = (_71_)[1]
          local step_53_ = (_71_)[2]
          local function _73_(seq, step)
            return ward_impl(seq, step, 1, (1 - step))
          end
          return _73_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__fward_dispatch).bodies, _70_)
    return M.fward
  end
  do local _ = {_62_, _69_()} end
  return M.fward
end
setmetatable({nil, nil}, {__call = _61_})()
local __fn_2a_M__bward_dispatch = {bodies = {}, help = {}}
local function _79_(...)
  if (0 == #(__fn_2a_M__bward_dispatch).bodies) then
    error(("multi-arity function " .. "M.bward" .. " has no bodies"))
  else
  end
  local _81_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__bward_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _81_ = f_74_auto
  end
  if (nil ~= _81_) then
    local f_74_auto = _81_
    return f_74_auto(...)
  elseif (_81_ == nil) then
    local view_77_auto
    do
      local _82_, _83_ = pcall(require, "fennel")
      if ((_82_ == true) and ((_G.type(_83_) == "table") and (nil ~= (_83_).view))) then
        local view_77_auto0 = (_83_).view
        view_77_auto = view_77_auto0
      elseif ((_82_ == false) and true) then
        local __75_auto = _83_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.bward", view_77_auto({...}), table.concat((__fn_2a_M__bward_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.bward = _79_
local function _86_()
  local _87_
  do
    table.insert((__fn_2a_M__bward_dispatch).help, "(where [seq] (seq? seq))")
    local function _88_(...)
      if (1 == select("#", ...)) then
        local _89_ = {...}
        local function _90_(...)
          local seq_76_ = (_89_)[1]
          return seq_3f(seq_76_)
        end
        if (((_G.type(_89_) == "table") and (nil ~= (_89_)[1])) and _90_(...)) then
          local seq_76_ = (_89_)[1]
          local function _91_(seq)
            return M.bward(seq, 1)
          end
          return _91_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__bward_dispatch).bodies, _88_)
    _87_ = M.bward
  end
  local function _94_()
    table.insert((__fn_2a_M__bward_dispatch).help, "(where [seq step] (and (seq? seq) (number? step) (<= 1 step)))")
    local function _95_(...)
      if (2 == select("#", ...)) then
        local _96_ = {...}
        local function _97_(...)
          local seq_77_ = (_96_)[1]
          local step_78_ = (_96_)[2]
          return (seq_3f(seq_77_) and number_3f(step_78_) and (1 <= step_78_))
        end
        if (((_G.type(_96_) == "table") and (nil ~= (_96_)[1]) and (nil ~= (_96_)[2])) and _97_(...)) then
          local seq_77_ = (_96_)[1]
          local step_78_ = (_96_)[2]
          local function _98_(seq, step)
            return ward_impl(seq, step, -1, (#seq + step))
          end
          return _98_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__bward_dispatch).bodies, _95_)
    return M.bward
  end
  do local _ = {_87_, _94_()} end
  return M.bward
end
setmetatable({nil, nil}, {__call = _86_})()
return M