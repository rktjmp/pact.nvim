local _local_3_, _local_4_ = nil, nil
do
  local _2_ = string
  local _1_
  local function _5_(...)
    local full_mod_path_2_auto = ...
    local _6_ = full_mod_path_2_auto
    local function _7_(...)
      local path_3_auto = _6_
      return ("string" == type(path_3_auto))
    end
    if ((nil ~= _6_) and _7_(...)) then
      local path_3_auto = _6_
      if string.find(full_mod_path_2_auto, "enum") then
        local _8_ = string.match(full_mod_path_2_auto, ("(.+%.)" .. "enum"))
        if (_8_ == nil) then
          return ""
        elseif (nil ~= _8_) then
          local root_4_auto = _8_
          return root_4_auto
        else
          return nil
        end
      else
        return error(string.format("relative-root: no match in &from %q for %q", full_mod_path_2_auto, "enum"))
      end
    elseif (_6_ == nil) then
      return ""
    else
      return nil
    end
  end
  _1_ = require(((_5_(...) or "") .. "type"))
  _local_3_, _local_4_ = _1_, _2_
end
local _local_12_ = _local_3_
local t_assoc_3f = _local_12_["assoc?"]
local function_3f = _local_12_["function?"]
local nil_3f = _local_12_["nil?"]
local number_3f = _local_12_["number?"]
local t_seq_3f = _local_12_["seq?"]
local t_table_3f = _local_12_["table?"]
local _local_13_ = _local_4_
local fmt = _local_13_["format"]
do local _ = {nil, nil} end
local M = {}
local function stream_3f(s)
  local _14_ = s
  if ((_G.type(_14_) == "table") and (nil ~= (_14_).enum) and (nil ~= (_14_).funs)) then
    local enum = (_14_).enum
    local funs = (_14_).funs
    return true
  elseif true then
    local _ = _14_
    return false
  else
    return nil
  end
end
local function seq_3f(t)
  return (t_seq_3f(t) and not stream_3f(t))
end
local function assoc_3f(t)
  return (t_assoc_3f(t) and not stream_3f(t))
end
local function table_3f(t)
  return (t_table_3f(t) and not stream_3f(t))
end
local function enumerable_3f(v)
  return (((seq_3f(v) or assoc_3f(v)) and not stream_3f(v)) or function_3f(v))
end
local stream_halt_marker = {}
local stream_use_last_value_marker = {}
local stream_use_new_value_marker = {}
local reduced_marker = {}
M.pack = function(...)
  local _16_ = {...}
  _16_["n"] = select("#", ...)
  return _16_
end
local rawunpack = (_G.unpack or table.unpack)
local __fn_2a_M__unpack_dispatch = {bodies = {}, help = {}}
local function _23_(...)
  if (0 == #(__fn_2a_M__unpack_dispatch).bodies) then
    error(("multi-arity function " .. "M.unpack" .. " has no bodies"))
  else
  end
  local _25_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__unpack_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _25_ = f_74_auto
  end
  if (nil ~= _25_) then
    local f_74_auto = _25_
    return f_74_auto(...)
  elseif (_25_ == nil) then
    local view_77_auto
    do
      local _26_, _27_ = pcall(require, "fennel")
      if ((_26_ == true) and ((_G.type(_27_) == "table") and (nil ~= (_27_).view))) then
        local view_77_auto0 = (_27_).view
        view_77_auto = view_77_auto0
      elseif ((_26_ == false) and true) then
        local __75_auto = _27_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.unpack", view_77_auto({...}), table.concat((__fn_2a_M__unpack_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.unpack = _23_
local function _30_()
  local _31_
  do
    table.insert((__fn_2a_M__unpack_dispatch).help, "(where [t] (table? t))")
    local function _32_(...)
      if (1 == select("#", ...)) then
        local _33_ = {...}
        local function _34_(...)
          local t_17_ = (_33_)[1]
          return table_3f(t_17_)
        end
        if (((_G.type(_33_) == "table") and (nil ~= (_33_)[1])) and _34_(...)) then
          local t_17_ = (_33_)[1]
          local function _35_(t)
            return rawunpack(t, 1, t.n)
          end
          return _35_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__unpack_dispatch).bodies, _32_)
    _31_ = M.unpack
  end
  local _38_
  do
    table.insert((__fn_2a_M__unpack_dispatch).help, "(where [t i] (and (table? t) (number? i)))")
    local function _39_(...)
      if (2 == select("#", ...)) then
        local _40_ = {...}
        local function _41_(...)
          local t_18_ = (_40_)[1]
          local i_19_ = (_40_)[2]
          return (table_3f(t_18_) and number_3f(i_19_))
        end
        if (((_G.type(_40_) == "table") and (nil ~= (_40_)[1]) and (nil ~= (_40_)[2])) and _41_(...)) then
          local t_18_ = (_40_)[1]
          local i_19_ = (_40_)[2]
          local function _42_(t, i)
            return rawunpack(t, i, t.n)
          end
          return _42_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__unpack_dispatch).bodies, _39_)
    _38_ = M.unpack
  end
  local function _45_()
    table.insert((__fn_2a_M__unpack_dispatch).help, "(where [t i j] (and (table? t) (number? i) (number? j)))")
    local function _46_(...)
      if (3 == select("#", ...)) then
        local _47_ = {...}
        local function _48_(...)
          local t_20_ = (_47_)[1]
          local i_21_ = (_47_)[2]
          local j_22_ = (_47_)[3]
          return (table_3f(t_20_) and number_3f(i_21_) and number_3f(j_22_))
        end
        if (((_G.type(_47_) == "table") and (nil ~= (_47_)[1]) and (nil ~= (_47_)[2]) and (nil ~= (_47_)[3])) and _48_(...)) then
          local t_20_ = (_47_)[1]
          local i_21_ = (_47_)[2]
          local j_22_ = (_47_)[3]
          local function _49_(t, i, j)
            return rawunpack(t, i, j)
          end
          return _49_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__unpack_dispatch).bodies, _46_)
    return M.unpack
  end
  do local _ = {_31_, _38_, _45_()} end
  return M.unpack
end
setmetatable({nil, nil}, {__call = _30_})()
local __fn_2a_M__reduced_dispatch = {bodies = {}, help = {}}
local function _53_(...)
  if (0 == #(__fn_2a_M__reduced_dispatch).bodies) then
    error(("multi-arity function " .. "M.reduced" .. " has no bodies"))
  else
  end
  local _55_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__reduced_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _55_ = f_74_auto
  end
  if (nil ~= _55_) then
    local f_74_auto = _55_
    return f_74_auto(...)
  elseif (_55_ == nil) then
    local view_77_auto
    do
      local _56_, _57_ = pcall(require, "fennel")
      if ((_56_ == true) and ((_G.type(_57_) == "table") and (nil ~= (_57_).view))) then
        local view_77_auto0 = (_57_).view
        view_77_auto = view_77_auto0
      elseif ((_56_ == false) and true) then
        local __75_auto = _57_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.reduced", view_77_auto({...}), table.concat((__fn_2a_M__reduced_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.reduced = _53_
local function _60_()
  local _61_
  do
    table.insert((__fn_2a_M__reduced_dispatch).help, "(where {})")
    local function _62_(...)
      if (0 == select("#", ...)) then
        local _63_ = {...}
        local function _64_(...)
          return true
        end
        if ((_G.type(_63_) == "table") and _64_(...)) then
          local function _65_()
            return reduced_marker
          end
          return _65_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduced_dispatch).bodies, _62_)
    _61_ = M.reduced
  end
  local _68_
  do
    table.insert((__fn_2a_M__reduced_dispatch).help, "(where [?value])")
    local function _69_(...)
      if (1 == select("#", ...)) then
        local _70_ = {...}
        local function _71_(...)
          local _3fvalue_52_ = (_70_)[1]
          return true
        end
        if (((_G.type(_70_) == "table") and true) and _71_(...)) then
          local _3fvalue_52_ = (_70_)[1]
          local function _72_(_3fvalue)
            return reduced_marker, _3fvalue
          end
          return _72_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduced_dispatch).bodies, _69_)
    _68_ = M.reduced
  end
  local function _75_()
    table.insert((__fn_2a_M__reduced_dispatch).help, "(where _)")
    local function _76_(...)
      if true then
        local _77_ = {...}
        local function _78_(...)
          return true
        end
        if ((_G.type(_77_) == "table") and _78_(...)) then
          local function _79_(...)
            return error("reduced accepts only a single value")
          end
          return _79_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduced_dispatch).bodies, _76_)
    return M.reduced
  end
  do local _ = {_61_, _68_, _75_()} end
  return M.reduced
end
setmetatable({nil, nil}, {__call = _60_})()
local function reduce_impl(f, acc, _82_)
  local _arg_83_ = _82_
  local gen = _arg_83_[1]
  local invariant = _arg_83_[2]
  local ctrl = _arg_83_[3]
  local _let_84_ = M.pack(gen(invariant, ctrl))
  local n = _let_84_["n"]
  local vals = _let_84_
  local _85_ = {n, vals}
  if ((_G.type(_85_) == "table") and ((_85_)[1] == 1) and ((_G.type((_85_)[2]) == "table") and (((_85_)[2])[1] == nil))) then
    return acc
  elseif ((_G.type(_85_) == "table") and ((_85_)[1] == 0) and true) then
    local _ = (_85_)[2]
    return acc
  elseif true then
    local _ = _85_
    local _let_86_ = vals
    local ctrl0 = _let_86_[1]
    local _0 = (function (t, k, e) local mt = getmetatable(t) if 'table' == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) elseif e then local rest = {} for k, v in pairs(t) do if not e[k] then rest[k] = v end end return rest else return {(table.unpack or unpack)(t, k)} end end)(_let_86_, 2)
    local _87_, _88_ = f(acc, M.unpack(vals, 1, n))
    if ((_87_ == reduced_marker) and true) then
      local _3fnew_acc = _88_
      return _3fnew_acc
    elseif true then
      local _3fnew_acc = _87_
      return reduce_impl(f, _3fnew_acc, {gen, invariant, ctrl0})
    elseif true then
      local _1 = _87_
      return error("internal-error: reduce could not match next value")
    else
      return nil
    end
  else
    return nil
  end
end
local __fn_2a_M__reduce_dispatch = {bodies = {}, help = {}}
local function _107_(...)
  if (0 == #(__fn_2a_M__reduce_dispatch).bodies) then
    error(("multi-arity function " .. "M.reduce" .. " has no bodies"))
  else
  end
  local _109_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__reduce_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _109_ = f_74_auto
  end
  if (nil ~= _109_) then
    local f_74_auto = _109_
    return f_74_auto(...)
  elseif (_109_ == nil) then
    local view_77_auto
    do
      local _110_, _111_ = pcall(require, "fennel")
      if ((_110_ == true) and ((_G.type(_111_) == "table") and (nil ~= (_111_).view))) then
        local view_77_auto0 = (_111_).view
        view_77_auto = view_77_auto0
      elseif ((_110_ == false) and true) then
        local __75_auto = _111_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.reduce", view_77_auto({...}), table.concat((__fn_2a_M__reduce_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.reduce = _107_
local function _114_()
  local _115_
  do
    table.insert((__fn_2a_M__reduce_dispatch).help, "(where [f] (function? f))")
    local function _116_(...)
      if (1 == select("#", ...)) then
        local _117_ = {...}
        local function _118_(...)
          local f_91_ = (_117_)[1]
          return function_3f(f_91_)
        end
        if (((_G.type(_117_) == "table") and (nil ~= (_117_)[1])) and _118_(...)) then
          local f_91_ = (_117_)[1]
          local function _119_(f)
            local function _120_(_241, _242)
              return M.reduce(f, _241, _242)
            end
            return _120_
          end
          return _119_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduce_dispatch).bodies, _116_)
    _115_ = M.reduce
  end
  local _123_
  do
    table.insert((__fn_2a_M__reduce_dispatch).help, "(where [f ?initial t] (and (function? f) (seq? t)))")
    local function _124_(...)
      if (3 == select("#", ...)) then
        local _125_ = {...}
        local function _126_(...)
          local f_92_ = (_125_)[1]
          local _3finitial_93_ = (_125_)[2]
          local t_94_ = (_125_)[3]
          return (function_3f(f_92_) and seq_3f(t_94_))
        end
        if (((_G.type(_125_) == "table") and (nil ~= (_125_)[1]) and true and (nil ~= (_125_)[3])) and _126_(...)) then
          local f_92_ = (_125_)[1]
          local _3finitial_93_ = (_125_)[2]
          local t_94_ = (_125_)[3]
          local function _127_(f, _3finitial, t)
            return reduce_impl(f, _3finitial, M.pack(ipairs(t)))
          end
          return _127_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduce_dispatch).bodies, _124_)
    _123_ = M.reduce
  end
  local _130_
  do
    table.insert((__fn_2a_M__reduce_dispatch).help, "(where [f ?initial t] (and (function? f) (assoc? t)))")
    local function _131_(...)
      if (3 == select("#", ...)) then
        local _132_ = {...}
        local function _133_(...)
          local f_95_ = (_132_)[1]
          local _3finitial_96_ = (_132_)[2]
          local t_97_ = (_132_)[3]
          return (function_3f(f_95_) and assoc_3f(t_97_))
        end
        if (((_G.type(_132_) == "table") and (nil ~= (_132_)[1]) and true and (nil ~= (_132_)[3])) and _133_(...)) then
          local f_95_ = (_132_)[1]
          local _3finitial_96_ = (_132_)[2]
          local t_97_ = (_132_)[3]
          local function _134_(f, _3finitial, t)
            return reduce_impl(f, _3finitial, M.pack(pairs(t)))
          end
          return _134_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduce_dispatch).bodies, _131_)
    _130_ = M.reduce
  end
  local _137_
  do
    table.insert((__fn_2a_M__reduce_dispatch).help, "(where [f ?initial generator] (and (function? f) (function? generator)))")
    local function _138_(...)
      if (3 == select("#", ...)) then
        local _139_ = {...}
        local function _140_(...)
          local f_98_ = (_139_)[1]
          local _3finitial_99_ = (_139_)[2]
          local generator_100_ = (_139_)[3]
          return (function_3f(f_98_) and function_3f(generator_100_))
        end
        if (((_G.type(_139_) == "table") and (nil ~= (_139_)[1]) and true and (nil ~= (_139_)[3])) and _140_(...)) then
          local f_98_ = (_139_)[1]
          local _3finitial_99_ = (_139_)[2]
          local generator_100_ = (_139_)[3]
          local function _141_(f, _3finitial, generator)
            return reduce_impl(f, _3finitial, M.pack(generator()))
          end
          return _141_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduce_dispatch).bodies, _138_)
    _137_ = M.reduce
  end
  local _144_
  do
    table.insert((__fn_2a_M__reduce_dispatch).help, "(where [f t] (and (function? f) (seq? t)))")
    local function _145_(...)
      if (2 == select("#", ...)) then
        local _146_ = {...}
        local function _147_(...)
          local f_101_ = (_146_)[1]
          local t_102_ = (_146_)[2]
          return (function_3f(f_101_) and seq_3f(t_102_))
        end
        if (((_G.type(_146_) == "table") and (nil ~= (_146_)[1]) and (nil ~= (_146_)[2])) and _147_(...)) then
          local f_101_ = (_146_)[1]
          local t_102_ = (_146_)[2]
          local function _148_(f, t)
            local _let_149_ = ipairs(t)
            local iter = _let_149_[1]
            local a = _let_149_[2]
            local n = _let_149_[3]
            local nn, initial = iter(a, n)
            return reduce_impl(f, initial, M.pack(iter, a, nn))
          end
          return _148_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduce_dispatch).bodies, _145_)
    _144_ = M.reduce
  end
  local _152_
  do
    table.insert((__fn_2a_M__reduce_dispatch).help, "(where [f t] (and (function? f) (assoc? t)))")
    local function _153_(...)
      if (2 == select("#", ...)) then
        local _154_ = {...}
        local function _155_(...)
          local f_103_ = (_154_)[1]
          local t_104_ = (_154_)[2]
          return (function_3f(f_103_) and assoc_3f(t_104_))
        end
        if (((_G.type(_154_) == "table") and (nil ~= (_154_)[1]) and (nil ~= (_154_)[2])) and _155_(...)) then
          local f_103_ = (_154_)[1]
          local t_104_ = (_154_)[2]
          local function _156_(f, t)
            local _let_157_ = pairs(t)
            local iter = _let_157_[1]
            local a = _let_157_[2]
            local n = _let_157_[3]
            local nn, initial = iter(a, n)
            return reduce_impl(f, initial, M.pack(iter, a, nn))
          end
          return _156_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduce_dispatch).bodies, _153_)
    _152_ = M.reduce
  end
  local function _160_()
    table.insert((__fn_2a_M__reduce_dispatch).help, "(where [f generator] (and (function? f) (function? generator)))")
    local function _161_(...)
      if (2 == select("#", ...)) then
        local _162_ = {...}
        local function _163_(...)
          local f_105_ = (_162_)[1]
          local generator_106_ = (_162_)[2]
          return (function_3f(f_105_) and function_3f(generator_106_))
        end
        if (((_G.type(_162_) == "table") and (nil ~= (_162_)[1]) and (nil ~= (_162_)[2])) and _163_(...)) then
          local f_105_ = (_162_)[1]
          local generator_106_ = (_162_)[2]
          local function _164_(f, generator)
            local _let_165_ = generator()
            local iter = _let_165_[1]
            local a = _let_165_[2]
            local n = _let_165_[3]
            local nn, initial = iter(a, n)
            return reduce_impl(f, initial, M.pack(iter, a, nn))
          end
          return _164_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__reduce_dispatch).bodies, _161_)
    return M.reduce
  end
  do local _ = {_115_, _123_, _130_, _137_, _144_, _152_, _160_()} end
  return M.reduce
end
setmetatable({nil, nil}, {__call = _114_})()
local __fn_2a_M__map_dispatch = {bodies = {}, help = {}}
local function _173_(...)
  if (0 == #(__fn_2a_M__map_dispatch).bodies) then
    error(("multi-arity function " .. "M.map" .. " has no bodies"))
  else
  end
  local _175_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__map_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _175_ = f_74_auto
  end
  if (nil ~= _175_) then
    local f_74_auto = _175_
    return f_74_auto(...)
  elseif (_175_ == nil) then
    local view_77_auto
    do
      local _176_, _177_ = pcall(require, "fennel")
      if ((_176_ == true) and ((_G.type(_177_) == "table") and (nil ~= (_177_).view))) then
        local view_77_auto0 = (_177_).view
        view_77_auto = view_77_auto0
      elseif ((_176_ == false) and true) then
        local __75_auto = _177_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.map", view_77_auto({...}), table.concat((__fn_2a_M__map_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.map = _173_
local function _180_()
  local _181_
  do
    table.insert((__fn_2a_M__map_dispatch).help, "(where [f] (function? f))")
    local function _182_(...)
      if (1 == select("#", ...)) then
        local _183_ = {...}
        local function _184_(...)
          local f_168_ = (_183_)[1]
          return function_3f(f_168_)
        end
        if (((_G.type(_183_) == "table") and (nil ~= (_183_)[1])) and _184_(...)) then
          local f_168_ = (_183_)[1]
          local function _185_(f)
            local function _186_(_241)
              return M.map(f, _241)
            end
            return _186_
          end
          return _185_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__map_dispatch).bodies, _182_)
    _181_ = M.map
  end
  local _189_
  do
    table.insert((__fn_2a_M__map_dispatch).help, "(where [f stream] (and (function? f) (stream? stream)))")
    local function _190_(...)
      if (2 == select("#", ...)) then
        local _191_ = {...}
        local function _192_(...)
          local f_169_ = (_191_)[1]
          local stream_170_ = (_191_)[2]
          return (function_3f(f_169_) and stream_3f(stream_170_))
        end
        if (((_G.type(_191_) == "table") and (nil ~= (_191_)[1]) and (nil ~= (_191_)[2])) and _192_(...)) then
          local f_169_ = (_191_)[1]
          local stream_170_ = (_191_)[2]
          local function _193_(f, stream)
            local function _194_(...)
              return stream_use_new_value_marker, f(...)
            end
            table.insert(stream.funs, _194_)
            return stream
          end
          return _193_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__map_dispatch).bodies, _190_)
    _189_ = M.map
  end
  local function _197_()
    table.insert((__fn_2a_M__map_dispatch).help, "(where [f enumerable] (and (function? f) (enumerable? enumerable)))")
    local function _198_(...)
      if (2 == select("#", ...)) then
        local _199_ = {...}
        local function _200_(...)
          local f_171_ = (_199_)[1]
          local enumerable_172_ = (_199_)[2]
          return (function_3f(f_171_) and enumerable_3f(enumerable_172_))
        end
        if (((_G.type(_199_) == "table") and (nil ~= (_199_)[1]) and (nil ~= (_199_)[2])) and _200_(...)) then
          local f_171_ = (_199_)[1]
          local enumerable_172_ = (_199_)[2]
          local function _201_(f, enumerable)
            local fx
            local function _202_(acc, ...)
              local _203_ = f(...)
              if (nil ~= _203_) then
                local val = _203_
                return M["insert$"](acc, -1, val)
              elseif (_203_ == nil) then
                return acc
              else
                return nil
              end
            end
            fx = _202_
            return M.reduce(fx, {}, enumerable)
          end
          return _201_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__map_dispatch).bodies, _198_)
    return M.map
  end
  do local _ = {_181_, _189_, _197_()} end
  return M.map
end
setmetatable({nil, nil}, {__call = _180_})()
local __fn_2a_M__each_dispatch = {bodies = {}, help = {}}
local function _212_(...)
  if (0 == #(__fn_2a_M__each_dispatch).bodies) then
    error(("multi-arity function " .. "M.each" .. " has no bodies"))
  else
  end
  local _214_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__each_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _214_ = f_74_auto
  end
  if (nil ~= _214_) then
    local f_74_auto = _214_
    return f_74_auto(...)
  elseif (_214_ == nil) then
    local view_77_auto
    do
      local _215_, _216_ = pcall(require, "fennel")
      if ((_215_ == true) and ((_G.type(_216_) == "table") and (nil ~= (_216_).view))) then
        local view_77_auto0 = (_216_).view
        view_77_auto = view_77_auto0
      elseif ((_215_ == false) and true) then
        local __75_auto = _216_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.each", view_77_auto({...}), table.concat((__fn_2a_M__each_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.each = _212_
local function _219_()
  local _220_
  do
    table.insert((__fn_2a_M__each_dispatch).help, "(where [f] (function? f))")
    local function _221_(...)
      if (1 == select("#", ...)) then
        local _222_ = {...}
        local function _223_(...)
          local f_207_ = (_222_)[1]
          return function_3f(f_207_)
        end
        if (((_G.type(_222_) == "table") and (nil ~= (_222_)[1])) and _223_(...)) then
          local f_207_ = (_222_)[1]
          local function _224_(f)
            local function _225_(_241)
              return M.each(f, _241)
            end
            return _225_
          end
          return _224_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__each_dispatch).bodies, _221_)
    _220_ = M.each
  end
  local _228_
  do
    table.insert((__fn_2a_M__each_dispatch).help, "(where [f stream] (and (function? f) (stream? stream)))")
    local function _229_(...)
      if (2 == select("#", ...)) then
        local _230_ = {...}
        local function _231_(...)
          local f_208_ = (_230_)[1]
          local stream_209_ = (_230_)[2]
          return (function_3f(f_208_) and stream_3f(stream_209_))
        end
        if (((_G.type(_230_) == "table") and (nil ~= (_230_)[1]) and (nil ~= (_230_)[2])) and _231_(...)) then
          local f_208_ = (_230_)[1]
          local stream_209_ = (_230_)[2]
          local function _232_(f, stream)
            local function _233_(...)
              return stream_use_last_value_marker, f(...)
            end
            table.insert(stream.funs, _233_)
            return stream
          end
          return _232_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__each_dispatch).bodies, _229_)
    _228_ = M.each
  end
  local function _236_()
    table.insert((__fn_2a_M__each_dispatch).help, "(where [f enumerable] (and (function? f) (enumerable? enumerable)))")
    local function _237_(...)
      if (2 == select("#", ...)) then
        local _238_ = {...}
        local function _239_(...)
          local f_210_ = (_238_)[1]
          local enumerable_211_ = (_238_)[2]
          return (function_3f(f_210_) and enumerable_3f(enumerable_211_))
        end
        if (((_G.type(_238_) == "table") and (nil ~= (_238_)[1]) and (nil ~= (_238_)[2])) and _239_(...)) then
          local f_210_ = (_238_)[1]
          local enumerable_211_ = (_238_)[2]
          local function _240_(f, enumerable)
            local fx
            local function _241_(acc, ...)
              f(...)
              return nil
            end
            fx = _241_
            return M.reduce(fx, nil, enumerable)
          end
          return _240_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__each_dispatch).bodies, _237_)
    return M.each
  end
  do local _ = {_220_, _228_, _236_()} end
  return M.each
end
setmetatable({nil, nil}, {__call = _219_})()
local __fn_2a_M__flatten_dispatch = {bodies = {}, help = {}}
local function _245_(...)
  if (0 == #(__fn_2a_M__flatten_dispatch).bodies) then
    error(("multi-arity function " .. "M.flatten" .. " has no bodies"))
  else
  end
  local _247_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__flatten_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _247_ = f_74_auto
  end
  if (nil ~= _247_) then
    local f_74_auto = _247_
    return f_74_auto(...)
  elseif (_247_ == nil) then
    local view_77_auto
    do
      local _248_, _249_ = pcall(require, "fennel")
      if ((_248_ == true) and ((_G.type(_249_) == "table") and (nil ~= (_249_).view))) then
        local view_77_auto0 = (_249_).view
        view_77_auto = view_77_auto0
      elseif ((_248_ == false) and true) then
        local __75_auto = _249_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.flatten", view_77_auto({...}), table.concat((__fn_2a_M__flatten_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.flatten = _245_
local function _252_()
  local function _253_()
    table.insert((__fn_2a_M__flatten_dispatch).help, "(where [seq] (seq? seq))")
    local function _254_(...)
      if (1 == select("#", ...)) then
        local _255_ = {...}
        local function _256_(...)
          local seq_244_ = (_255_)[1]
          return seq_3f(seq_244_)
        end
        if (((_G.type(_255_) == "table") and (nil ~= (_255_)[1])) and _256_(...)) then
          local seq_244_ = (_255_)[1]
          local function _257_(seq)
            local fx
            local function _258_(acc, i, v)
              if seq_3f(v) then
                local tbl_17_auto = acc
                local i_18_auto = #tbl_17_auto
                for _, vv in ipairs(v) do
                  local val_19_auto = vv
                  if (nil ~= val_19_auto) then
                    i_18_auto = (i_18_auto + 1)
                    do end (tbl_17_auto)[i_18_auto] = val_19_auto
                  else
                  end
                end
                return tbl_17_auto
              else
                return M["append$"](acc, v)
              end
            end
            fx = _258_
            return M.reduce(fx, {}, seq)
          end
          return _257_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__flatten_dispatch).bodies, _254_)
    return M.flatten
  end
  do local _ = {_253_()} end
  return M.flatten
end
setmetatable({nil, nil}, {__call = _252_})()
local __fn_2a_M__flat_map_dispatch = {bodies = {}, help = {}}
local function _266_(...)
  if (0 == #(__fn_2a_M__flat_map_dispatch).bodies) then
    error(("multi-arity function " .. "M.flat-map" .. " has no bodies"))
  else
  end
  local _268_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__flat_map_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _268_ = f_74_auto
  end
  if (nil ~= _268_) then
    local f_74_auto = _268_
    return f_74_auto(...)
  elseif (_268_ == nil) then
    local view_77_auto
    do
      local _269_, _270_ = pcall(require, "fennel")
      if ((_269_ == true) and ((_G.type(_270_) == "table") and (nil ~= (_270_).view))) then
        local view_77_auto0 = (_270_).view
        view_77_auto = view_77_auto0
      elseif ((_269_ == false) and true) then
        local __75_auto = _270_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.flat-map", view_77_auto({...}), table.concat((__fn_2a_M__flat_map_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["flat-map"] = _266_
local function _273_()
  local _274_
  do
    table.insert((__fn_2a_M__flat_map_dispatch).help, "(where [f] (function? f))")
    local function _275_(...)
      if (1 == select("#", ...)) then
        local _276_ = {...}
        local function _277_(...)
          local f_263_ = (_276_)[1]
          return function_3f(f_263_)
        end
        if (((_G.type(_276_) == "table") and (nil ~= (_276_)[1])) and _277_(...)) then
          local f_263_ = (_276_)[1]
          local function _278_(f)
            local function _279_(_241)
              return M["flat-map"](f, _241)
            end
            return _279_
          end
          return _278_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__flat_map_dispatch).bodies, _275_)
    _274_ = M["flat-map"]
  end
  local function _282_()
    table.insert((__fn_2a_M__flat_map_dispatch).help, "(where [f enumerable] (and (function? f) (enumerable? enumerable)))")
    local function _283_(...)
      if (2 == select("#", ...)) then
        local _284_ = {...}
        local function _285_(...)
          local f_264_ = (_284_)[1]
          local enumerable_265_ = (_284_)[2]
          return (function_3f(f_264_) and enumerable_3f(enumerable_265_))
        end
        if (((_G.type(_284_) == "table") and (nil ~= (_284_)[1]) and (nil ~= (_284_)[2])) and _285_(...)) then
          local f_264_ = (_284_)[1]
          local enumerable_265_ = (_284_)[2]
          local function _286_(f, enumerable)
            return M.flatten(M.map(f, enumerable))
          end
          return _286_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__flat_map_dispatch).bodies, _283_)
    return M["flat-map"]
  end
  do local _ = {_274_, _282_()} end
  return M["flat-map"]
end
setmetatable({nil, nil}, {__call = _273_})()
local __fn_2a_M__filter_dispatch = {bodies = {}, help = {}}
local function _294_(...)
  if (0 == #(__fn_2a_M__filter_dispatch).bodies) then
    error(("multi-arity function " .. "M.filter" .. " has no bodies"))
  else
  end
  local _296_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__filter_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _296_ = f_74_auto
  end
  if (nil ~= _296_) then
    local f_74_auto = _296_
    return f_74_auto(...)
  elseif (_296_ == nil) then
    local view_77_auto
    do
      local _297_, _298_ = pcall(require, "fennel")
      if ((_297_ == true) and ((_G.type(_298_) == "table") and (nil ~= (_298_).view))) then
        local view_77_auto0 = (_298_).view
        view_77_auto = view_77_auto0
      elseif ((_297_ == false) and true) then
        local __75_auto = _298_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.filter", view_77_auto({...}), table.concat((__fn_2a_M__filter_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.filter = _294_
local function _301_()
  local _302_
  do
    table.insert((__fn_2a_M__filter_dispatch).help, "(where [pred] (function? pred))")
    local function _303_(...)
      if (1 == select("#", ...)) then
        local _304_ = {...}
        local function _305_(...)
          local pred_289_ = (_304_)[1]
          return function_3f(pred_289_)
        end
        if (((_G.type(_304_) == "table") and (nil ~= (_304_)[1])) and _305_(...)) then
          local pred_289_ = (_304_)[1]
          local function _306_(pred)
            local function _307_(_241)
              return M.filter(pred, _241)
            end
            return _307_
          end
          return _306_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__filter_dispatch).bodies, _303_)
    _302_ = M.filter
  end
  local _310_
  do
    table.insert((__fn_2a_M__filter_dispatch).help, "(where [pred stream] (and (function? pred) (stream? stream)))")
    local function _311_(...)
      if (2 == select("#", ...)) then
        local _312_ = {...}
        local function _313_(...)
          local pred_290_ = (_312_)[1]
          local stream_291_ = (_312_)[2]
          return (function_3f(pred_290_) and stream_3f(stream_291_))
        end
        if (((_G.type(_312_) == "table") and (nil ~= (_312_)[1]) and (nil ~= (_312_)[2])) and _313_(...)) then
          local pred_290_ = (_312_)[1]
          local stream_291_ = (_312_)[2]
          local function _314_(pred, stream)
            local function _315_(...)
              if pred(...) then
                return stream_use_last_value_marker
              else
                return stream_halt_marker
              end
            end
            table.insert(stream.funs, _315_)
            return stream
          end
          return _314_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__filter_dispatch).bodies, _311_)
    _310_ = M.filter
  end
  local function _319_()
    table.insert((__fn_2a_M__filter_dispatch).help, "(where [pred t] (and (function? pred) (enumerable? t)))")
    local function _320_(...)
      if (2 == select("#", ...)) then
        local _321_ = {...}
        local function _322_(...)
          local pred_292_ = (_321_)[1]
          local t_293_ = (_321_)[2]
          return (function_3f(pred_292_) and enumerable_3f(t_293_))
        end
        if (((_G.type(_321_) == "table") and (nil ~= (_321_)[1]) and (nil ~= (_321_)[2])) and _322_(...)) then
          local pred_292_ = (_321_)[1]
          local t_293_ = (_321_)[2]
          local function _323_(pred, t)
            local insert
            if (seq_3f(t) or function_3f(t)) then
              local function _324_(_241, _242, _243)
                table.insert(_241, _243)
                return _241
              end
              insert = _324_
            else
              local function _325_(_241, _242, _243)
                _241[_242] = _243
                return _241
              end
              insert = _325_
            end
            local insert_3f
            local function _327_(acc, k, v)
              if pred(k, v) then
                return insert(acc, k, v)
              else
                return acc
              end
            end
            insert_3f = _327_
            return M.reduce(insert_3f, {}, t)
          end
          return _323_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__filter_dispatch).bodies, _320_)
    return M.filter
  end
  do local _ = {_302_, _310_, _319_()} end
  return M.filter
end
setmetatable({nil, nil}, {__call = _301_})()
M.reject = function(pred, ...)
  local function _331_(...)
    return not pred(...)
  end
  return M.filter(_331_, ...)
end
local __fn_2a_M__any_3f_dispatch = {bodies = {}, help = {}}
local function _334_(...)
  if (0 == #(__fn_2a_M__any_3f_dispatch).bodies) then
    error(("multi-arity function " .. "M.any?" .. " has no bodies"))
  else
  end
  local _336_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__any_3f_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _336_ = f_74_auto
  end
  if (nil ~= _336_) then
    local f_74_auto = _336_
    return f_74_auto(...)
  elseif (_336_ == nil) then
    local view_77_auto
    do
      local _337_, _338_ = pcall(require, "fennel")
      if ((_337_ == true) and ((_G.type(_338_) == "table") and (nil ~= (_338_).view))) then
        local view_77_auto0 = (_338_).view
        view_77_auto = view_77_auto0
      elseif ((_337_ == false) and true) then
        local __75_auto = _338_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.any?", view_77_auto({...}), table.concat((__fn_2a_M__any_3f_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["any?"] = _334_
local function _341_()
  local function _342_()
    table.insert((__fn_2a_M__any_3f_dispatch).help, "(where [f t] (and (function? f) (enumerable? t)))")
    local function _343_(...)
      if (2 == select("#", ...)) then
        local _344_ = {...}
        local function _345_(...)
          local f_332_ = (_344_)[1]
          local t_333_ = (_344_)[2]
          return (function_3f(f_332_) and enumerable_3f(t_333_))
        end
        if (((_G.type(_344_) == "table") and (nil ~= (_344_)[1]) and (nil ~= (_344_)[2])) and _345_(...)) then
          local f_332_ = (_344_)[1]
          local t_333_ = (_344_)[2]
          local function _346_(f, t)
            local function _347_(_acc, ...)
              if f(...) then
                return M.reduced(true)
              else
                return false
              end
            end
            return M.reduce(_347_, false, t)
          end
          return _346_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__any_3f_dispatch).bodies, _343_)
    return M["any?"]
  end
  do local _ = {_342_()} end
  return M["any?"]
end
setmetatable({nil, nil}, {__call = _341_})()
local __fn_2a_M__all_3f_dispatch = {bodies = {}, help = {}}
local function _353_(...)
  if (0 == #(__fn_2a_M__all_3f_dispatch).bodies) then
    error(("multi-arity function " .. "M.all?" .. " has no bodies"))
  else
  end
  local _355_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__all_3f_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _355_ = f_74_auto
  end
  if (nil ~= _355_) then
    local f_74_auto = _355_
    return f_74_auto(...)
  elseif (_355_ == nil) then
    local view_77_auto
    do
      local _356_, _357_ = pcall(require, "fennel")
      if ((_356_ == true) and ((_G.type(_357_) == "table") and (nil ~= (_357_).view))) then
        local view_77_auto0 = (_357_).view
        view_77_auto = view_77_auto0
      elseif ((_356_ == false) and true) then
        local __75_auto = _357_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.all?", view_77_auto({...}), table.concat((__fn_2a_M__all_3f_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["all?"] = _353_
local function _360_()
  local function _361_()
    table.insert((__fn_2a_M__all_3f_dispatch).help, "(where [f t] (and (function? f) (enumerable? t)))")
    local function _362_(...)
      if (2 == select("#", ...)) then
        local _363_ = {...}
        local function _364_(...)
          local f_351_ = (_363_)[1]
          local t_352_ = (_363_)[2]
          return (function_3f(f_351_) and enumerable_3f(t_352_))
        end
        if (((_G.type(_363_) == "table") and (nil ~= (_363_)[1]) and (nil ~= (_363_)[2])) and _364_(...)) then
          local f_351_ = (_363_)[1]
          local t_352_ = (_363_)[2]
          local function _365_(f, t)
            local function _366_(acc, ...)
              if (acc and f(...)) then
                return true
              else
                return M.reduced(false)
              end
            end
            return M.reduce(_366_, true, t)
          end
          return _365_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__all_3f_dispatch).bodies, _362_)
    return M["all?"]
  end
  do local _ = {_361_()} end
  return M["all?"]
end
setmetatable({nil, nil}, {__call = _360_})()
local __fn_2a_M__find_dispatch = {bodies = {}, help = {}}
local function _372_(...)
  if (0 == #(__fn_2a_M__find_dispatch).bodies) then
    error(("multi-arity function " .. "M.find" .. " has no bodies"))
  else
  end
  local _374_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__find_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _374_ = f_74_auto
  end
  if (nil ~= _374_) then
    local f_74_auto = _374_
    return f_74_auto(...)
  elseif (_374_ == nil) then
    local view_77_auto
    do
      local _375_, _376_ = pcall(require, "fennel")
      if ((_375_ == true) and ((_G.type(_376_) == "table") and (nil ~= (_376_).view))) then
        local view_77_auto0 = (_376_).view
        view_77_auto = view_77_auto0
      elseif ((_375_ == false) and true) then
        local __75_auto = _376_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.find", view_77_auto({...}), table.concat((__fn_2a_M__find_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.find = _372_
local function _379_()
  local function _380_()
    table.insert((__fn_2a_M__find_dispatch).help, "(where [f e] (and (function? f) (enumerable? e)))")
    local function _381_(...)
      if (2 == select("#", ...)) then
        local _382_ = {...}
        local function _383_(...)
          local f_370_ = (_382_)[1]
          local e_371_ = (_382_)[2]
          return (function_3f(f_370_) and enumerable_3f(e_371_))
        end
        if (((_G.type(_382_) == "table") and (nil ~= (_382_)[1]) and (nil ~= (_382_)[2])) and _383_(...)) then
          local f_370_ = (_382_)[1]
          local e_371_ = (_382_)[2]
          local function _384_(f, e)
            local reducer
            local function _385_(_, ...)
              if f(...) then
                return M.reduced(M.pack(...))
              else
                return nil
              end
            end
            reducer = M.reduce(_385_)
            local _387_ = reducer(nil, e)
            if (nil ~= _387_) then
              local any = _387_
              return M.unpack(any)
            elseif (_387_ == nil) then
              return nil
            else
              return nil
            end
          end
          return _384_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__find_dispatch).bodies, _381_)
    return M.find
  end
  do local _ = {_380_()} end
  return M.find
end
setmetatable({nil, nil}, {__call = _379_})()
local __fn_2a_M__find_key_dispatch = {bodies = {}, help = {}}
local function _393_(...)
  if (0 == #(__fn_2a_M__find_key_dispatch).bodies) then
    error(("multi-arity function " .. "M.find-key" .. " has no bodies"))
  else
  end
  local _395_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__find_key_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _395_ = f_74_auto
  end
  if (nil ~= _395_) then
    local f_74_auto = _395_
    return f_74_auto(...)
  elseif (_395_ == nil) then
    local view_77_auto
    do
      local _396_, _397_ = pcall(require, "fennel")
      if ((_396_ == true) and ((_G.type(_397_) == "table") and (nil ~= (_397_).view))) then
        local view_77_auto0 = (_397_).view
        view_77_auto = view_77_auto0
      elseif ((_396_ == false) and true) then
        local __75_auto = _397_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.find-key", view_77_auto({...}), table.concat((__fn_2a_M__find_key_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["find-key"] = _393_
local function _400_()
  local function _401_()
    table.insert((__fn_2a_M__find_key_dispatch).help, "(where [f t] (and (function? f) (table? t)))")
    local function _402_(...)
      if (2 == select("#", ...)) then
        local _403_ = {...}
        local function _404_(...)
          local f_391_ = (_403_)[1]
          local t_392_ = (_403_)[2]
          return (function_3f(f_391_) and table_3f(t_392_))
        end
        if (((_G.type(_403_) == "table") and (nil ~= (_403_)[1]) and (nil ~= (_403_)[2])) and _404_(...)) then
          local f_391_ = (_403_)[1]
          local t_392_ = (_403_)[2]
          local function _405_(f, t)
            local _406_, _407_ = M.find(f, t)
            if ((nil ~= _406_) and true) then
              local k = _406_
              local _ = _407_
              return k
            elseif true then
              local _ = _406_
              return nil
            else
              return nil
            end
          end
          return _405_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__find_key_dispatch).bodies, _402_)
    return M["find-key"]
  end
  do local _ = {_401_()} end
  return M["find-key"]
end
setmetatable({nil, nil}, {__call = _400_})()
local __fn_2a_M__find_value_dispatch = {bodies = {}, help = {}}
local function _413_(...)
  if (0 == #(__fn_2a_M__find_value_dispatch).bodies) then
    error(("multi-arity function " .. "M.find-value" .. " has no bodies"))
  else
  end
  local _415_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__find_value_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _415_ = f_74_auto
  end
  if (nil ~= _415_) then
    local f_74_auto = _415_
    return f_74_auto(...)
  elseif (_415_ == nil) then
    local view_77_auto
    do
      local _416_, _417_ = pcall(require, "fennel")
      if ((_416_ == true) and ((_G.type(_417_) == "table") and (nil ~= (_417_).view))) then
        local view_77_auto0 = (_417_).view
        view_77_auto = view_77_auto0
      elseif ((_416_ == false) and true) then
        local __75_auto = _417_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.find-value", view_77_auto({...}), table.concat((__fn_2a_M__find_value_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["find-value"] = _413_
local function _420_()
  local function _421_()
    table.insert((__fn_2a_M__find_value_dispatch).help, "(where [f t] (and (function? f) (table? t)))")
    local function _422_(...)
      if (2 == select("#", ...)) then
        local _423_ = {...}
        local function _424_(...)
          local f_411_ = (_423_)[1]
          local t_412_ = (_423_)[2]
          return (function_3f(f_411_) and table_3f(t_412_))
        end
        if (((_G.type(_423_) == "table") and (nil ~= (_423_)[1]) and (nil ~= (_423_)[2])) and _424_(...)) then
          local f_411_ = (_423_)[1]
          local t_412_ = (_423_)[2]
          local function _425_(f, t)
            local _426_, _427_ = M.find(f, t)
            if (true and (nil ~= _427_)) then
              local _ = _426_
              local v = _427_
              return v
            elseif true then
              local _ = _426_
              return nil
            else
              return nil
            end
          end
          return _425_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__find_value_dispatch).bodies, _422_)
    return M["find-value"]
  end
  do local _ = {_421_()} end
  return M["find-value"]
end
setmetatable({nil, nil}, {__call = _420_})()
local __fn_2a_M__group_by_dispatch = {bodies = {}, help = {}}
local function _436_(...)
  if (0 == #(__fn_2a_M__group_by_dispatch).bodies) then
    error(("multi-arity function " .. "M.group-by" .. " has no bodies"))
  else
  end
  local _438_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__group_by_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _438_ = f_74_auto
  end
  if (nil ~= _438_) then
    local f_74_auto = _438_
    return f_74_auto(...)
  elseif (_438_ == nil) then
    local view_77_auto
    do
      local _439_, _440_ = pcall(require, "fennel")
      if ((_439_ == true) and ((_G.type(_440_) == "table") and (nil ~= (_440_).view))) then
        local view_77_auto0 = (_440_).view
        view_77_auto = view_77_auto0
      elseif ((_439_ == false) and true) then
        local __75_auto = _440_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.group-by", view_77_auto({...}), table.concat((__fn_2a_M__group_by_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["group-by"] = _436_
local function _443_()
  local _444_
  do
    table.insert((__fn_2a_M__group_by_dispatch).help, "(where [f] (function? f))")
    local function _445_(...)
      if (1 == select("#", ...)) then
        local _446_ = {...}
        local function _447_(...)
          local f_431_ = (_446_)[1]
          return function_3f(f_431_)
        end
        if (((_G.type(_446_) == "table") and (nil ~= (_446_)[1])) and _447_(...)) then
          local f_431_ = (_446_)[1]
          local function _448_(f)
            local function _449_(_241)
              return M["group-by"](f, _241)
            end
            return _449_
          end
          return _448_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__group_by_dispatch).bodies, _445_)
    _444_ = M["group-by"]
  end
  local _452_
  do
    table.insert((__fn_2a_M__group_by_dispatch).help, "(where [f e] (and (function? f) (table? e)))")
    local function _453_(...)
      if (2 == select("#", ...)) then
        local _454_ = {...}
        local function _455_(...)
          local f_432_ = (_454_)[1]
          local e_433_ = (_454_)[2]
          return (function_3f(f_432_) and table_3f(e_433_))
        end
        if (((_G.type(_454_) == "table") and (nil ~= (_454_)[1]) and (nil ~= (_454_)[2])) and _455_(...)) then
          local f_432_ = (_454_)[1]
          local e_433_ = (_454_)[2]
          local function _456_(f, e)
            local function _457_(acc, k, v)
              local key, val = f(k, v)
              local _ = assert((nil ~= key), "group-by key may not be nil")
              local val0 = (val or v)
              local group = (acc[key] or {})
              return M["set$"](acc, key, M["append$"](group, val0))
            end
            return M.reduce(_457_, {}, e)
          end
          return _456_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__group_by_dispatch).bodies, _453_)
    _452_ = M["group-by"]
  end
  local function _460_()
    table.insert((__fn_2a_M__group_by_dispatch).help, "(where [f e] (and (function? f) (function? e)))")
    local function _461_(...)
      if (2 == select("#", ...)) then
        local _462_ = {...}
        local function _463_(...)
          local f_434_ = (_462_)[1]
          local e_435_ = (_462_)[2]
          return (function_3f(f_434_) and function_3f(e_435_))
        end
        if (((_G.type(_462_) == "table") and (nil ~= (_462_)[1]) and (nil ~= (_462_)[2])) and _463_(...)) then
          local f_434_ = (_462_)[1]
          local e_435_ = (_462_)[2]
          local function _464_(f, e)
            local function _465_(acc, ...)
              local key, val = f(...)
              local _ = assert((nil ~= key), "group-by key may not be nil")
              local _0 = assert((nil ~= val), "group-by on function must return (key value)")
              local group = (acc[key] or {})
              return M["set$"](acc, key, M["append$"](group, val))
            end
            return M.reduce(_465_, {}, e)
          end
          return _464_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__group_by_dispatch).bodies, _461_)
    return M["group-by"]
  end
  do local _ = {_444_, _452_, _460_()} end
  return M["group-by"]
end
setmetatable({nil, nil}, {__call = _443_})()
local __fn_2a_take_dispatch = {bodies = {}, help = {}}
local take
local function _472_(...)
  if (0 == #(__fn_2a_take_dispatch).bodies) then
    error(("multi-arity function " .. "take" .. " has no bodies"))
  else
  end
  local _474_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_take_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _474_ = f_74_auto
  end
  if (nil ~= _474_) then
    local f_74_auto = _474_
    return f_74_auto(...)
  elseif (_474_ == nil) then
    local view_77_auto
    do
      local _475_, _476_ = pcall(require, "fennel")
      if ((_475_ == true) and ((_G.type(_476_) == "table") and (nil ~= (_476_).view))) then
        local view_77_auto0 = (_476_).view
        view_77_auto = view_77_auto0
      elseif ((_475_ == false) and true) then
        local __75_auto = _476_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "take", view_77_auto({...}), table.concat((__fn_2a_take_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
take = _472_
local function _479_()
  local _480_
  do
    table.insert((__fn_2a_take_dispatch).help, "(where [e n] (and (seq? e) (number? n)))")
    local function _481_(...)
      if (2 == select("#", ...)) then
        local _482_ = {...}
        local function _483_(...)
          local e_468_ = (_482_)[1]
          local n_469_ = (_482_)[2]
          return (seq_3f(e_468_) and number_3f(n_469_))
        end
        if (((_G.type(_482_) == "table") and (nil ~= (_482_)[1]) and (nil ~= (_482_)[2])) and _483_(...)) then
          local e_468_ = (_482_)[1]
          local n_469_ = (_482_)[2]
          local function _484_(e, n)
            return error("todo")
          end
          return _484_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_take_dispatch).bodies, _481_)
    _480_ = take
  end
  local function _487_()
    table.insert((__fn_2a_take_dispatch).help, "(where [e n] (and (function? e) (number? n)))")
    local function _488_(...)
      if (2 == select("#", ...)) then
        local _489_ = {...}
        local function _490_(...)
          local e_470_ = (_489_)[1]
          local n_471_ = (_489_)[2]
          return (function_3f(e_470_) and number_3f(n_471_))
        end
        if (((_G.type(_489_) == "table") and (nil ~= (_489_)[1]) and (nil ~= (_489_)[2])) and _490_(...)) then
          local e_470_ = (_489_)[1]
          local n_471_ = (_489_)[2]
          local function _491_(e, n)
            return error("todo")
          end
          return _491_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_take_dispatch).bodies, _488_)
    return take
  end
  do local _ = {_480_, _487_()} end
  return take
end
setmetatable({nil, nil}, {__call = _479_})()
local __fn_2a_M__pluck_dispatch = {bodies = {}, help = {}}
local function _496_(...)
  if (0 == #(__fn_2a_M__pluck_dispatch).bodies) then
    error(("multi-arity function " .. "M.pluck" .. " has no bodies"))
  else
  end
  local _498_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__pluck_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _498_ = f_74_auto
  end
  if (nil ~= _498_) then
    local f_74_auto = _498_
    return f_74_auto(...)
  elseif (_498_ == nil) then
    local view_77_auto
    do
      local _499_, _500_ = pcall(require, "fennel")
      if ((_499_ == true) and ((_G.type(_500_) == "table") and (nil ~= (_500_).view))) then
        local view_77_auto0 = (_500_).view
        view_77_auto = view_77_auto0
      elseif ((_499_ == false) and true) then
        local __75_auto = _500_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.pluck", view_77_auto({...}), table.concat((__fn_2a_M__pluck_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.pluck = _496_
local function _503_()
  local function _504_()
    table.insert((__fn_2a_M__pluck_dispatch).help, "(where [t ks] (and (table? t) (seq? ks)))")
    local function _505_(...)
      if (2 == select("#", ...)) then
        local _506_ = {...}
        local function _507_(...)
          local t_494_ = (_506_)[1]
          local ks_495_ = (_506_)[2]
          return (table_3f(t_494_) and seq_3f(ks_495_))
        end
        if (((_G.type(_506_) == "table") and (nil ~= (_506_)[1]) and (nil ~= (_506_)[2])) and _507_(...)) then
          local t_494_ = (_506_)[1]
          local ks_495_ = (_506_)[2]
          local function _508_(t, ks)
            local function _509_(_241, _242)
              return t[_242]
            end
            return M.map(_509_, ks)
          end
          return _508_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__pluck_dispatch).bodies, _505_)
    return M.pluck
  end
  do local _ = {_504_()} end
  return M.pluck
end
setmetatable({nil, nil}, {__call = _503_})()
local function negable_seq_index(seq, i, ctx)
  assert(ctx, "ind-mod requires :insert or :remove ctx")
  local _512_ = {i, #seq, ctx}
  local function _513_()
    local n = (_512_)[2]
    return (function(_514_,_515_,_516_) return (_514_ < _515_) and (_515_ < _516_) end)(0,i,(n + 1))
  end
  if (((_G.type(_512_) == "table") and ((_512_)[1] == i) and (nil ~= (_512_)[2])) and _513_()) then
    local n = (_512_)[2]
    return i
  elseif ((_G.type(_512_) == "table") and ((_512_)[1] == -1) and ((_512_)[2] == 0)) then
    return 1
  else
    local function _517_()
      local n = (_512_)[2]
      return (function(_518_,_519_,_520_) return (_518_ <= _519_) and (_519_ <= _520_) end)(((-1 * n) - 1),i,-1)
    end
    if (((_G.type(_512_) == "table") and ((_512_)[1] == i) and (nil ~= (_512_)[2]) and ((_512_)[3] == "insert")) and _517_()) then
      local n = (_512_)[2]
      return (n + 2 + i)
    else
      local function _521_()
        local n = (_512_)[2]
        return (function(_522_,_523_,_524_) return (_522_ <= _523_) and (_523_ <= _524_) end)((-1 * n),i,-1)
      end
      if (((_G.type(_512_) == "table") and ((_512_)[1] == i) and (nil ~= (_512_)[2]) and ((_512_)[3] == "remove")) and _521_()) then
        local n = (_512_)[2]
        return (n + 1 + i)
      else
        local function _525_()
          local n = (_512_)[2]
          return (n < i)
        end
        if (((_G.type(_512_) == "table") and ((_512_)[1] == i) and (nil ~= (_512_)[2])) and _525_()) then
          local n = (_512_)[2]
          return error(string.format("index %d overbounds", i, n))
        else
          local function _526_()
            local n = (_512_)[2]
            return (i < 0)
          end
          if (((_G.type(_512_) == "table") and ((_512_)[1] == i) and (nil ~= (_512_)[2])) and _526_()) then
            local n = (_512_)[2]
            return error(string.format("index %d underbounds", i, n))
          elseif ((_G.type(_512_) == "table") and ((_512_)[1] == 0) and (nil ~= (_512_)[2])) then
            local n = (_512_)[2]
            return error(string.format("index 0 invalid, use 1 or %d", ((-1 * n) - 1)))
          else
            return nil
          end
        end
      end
    end
  end
end
local __fn_2a_M__insert_24_dispatch = {bodies = {}, help = {}}
local function _531_(...)
  if (0 == #(__fn_2a_M__insert_24_dispatch).bodies) then
    error(("multi-arity function " .. "M.insert$" .. " has no bodies"))
  else
  end
  local _533_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__insert_24_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _533_ = f_74_auto
  end
  if (nil ~= _533_) then
    local f_74_auto = _533_
    return f_74_auto(...)
  elseif (_533_ == nil) then
    local view_77_auto
    do
      local _534_, _535_ = pcall(require, "fennel")
      if ((_534_ == true) and ((_G.type(_535_) == "table") and (nil ~= (_535_).view))) then
        local view_77_auto0 = (_535_).view
        view_77_auto = view_77_auto0
      elseif ((_534_ == false) and true) then
        local __75_auto = _535_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.insert$", view_77_auto({...}), table.concat((__fn_2a_M__insert_24_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["insert$"] = _531_
local function _538_()
  local function _539_()
    table.insert((__fn_2a_M__insert_24_dispatch).help, "(where [seq i v] (and (seq? seq) (number? i)))")
    local function _540_(...)
      if (3 == select("#", ...)) then
        local _541_ = {...}
        local function _542_(...)
          local seq_528_ = (_541_)[1]
          local i_529_ = (_541_)[2]
          local v_530_ = (_541_)[3]
          return (seq_3f(seq_528_) and number_3f(i_529_))
        end
        if (((_G.type(_541_) == "table") and (nil ~= (_541_)[1]) and (nil ~= (_541_)[2]) and (nil ~= (_541_)[3])) and _542_(...)) then
          local seq_528_ = (_541_)[1]
          local i_529_ = (_541_)[2]
          local v_530_ = (_541_)[3]
          local function _543_(seq, i, v)
            table.insert(seq, negable_seq_index(seq, i, "insert"), v)
            return seq
          end
          return _543_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__insert_24_dispatch).bodies, _540_)
    return M["insert$"]
  end
  do local _ = {_539_()} end
  return M["insert$"]
end
setmetatable({nil, nil}, {__call = _538_})()
local __fn_2a_M__remove_24_dispatch = {bodies = {}, help = {}}
local function _548_(...)
  if (0 == #(__fn_2a_M__remove_24_dispatch).bodies) then
    error(("multi-arity function " .. "M.remove$" .. " has no bodies"))
  else
  end
  local _550_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__remove_24_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _550_ = f_74_auto
  end
  if (nil ~= _550_) then
    local f_74_auto = _550_
    return f_74_auto(...)
  elseif (_550_ == nil) then
    local view_77_auto
    do
      local _551_, _552_ = pcall(require, "fennel")
      if ((_551_ == true) and ((_G.type(_552_) == "table") and (nil ~= (_552_).view))) then
        local view_77_auto0 = (_552_).view
        view_77_auto = view_77_auto0
      elseif ((_551_ == false) and true) then
        local __75_auto = _552_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.remove$", view_77_auto({...}), table.concat((__fn_2a_M__remove_24_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["remove$"] = _548_
local function _555_()
  local function _556_()
    table.insert((__fn_2a_M__remove_24_dispatch).help, "(where [seq i] (and (seq? seq) (number? i)))")
    local function _557_(...)
      if (2 == select("#", ...)) then
        local _558_ = {...}
        local function _559_(...)
          local seq_546_ = (_558_)[1]
          local i_547_ = (_558_)[2]
          return (seq_3f(seq_546_) and number_3f(i_547_))
        end
        if (((_G.type(_558_) == "table") and (nil ~= (_558_)[1]) and (nil ~= (_558_)[2])) and _559_(...)) then
          local seq_546_ = (_558_)[1]
          local i_547_ = (_558_)[2]
          local function _560_(seq, i)
            table.remove(seq, negable_seq_index(seq, i, "remove"))
            return seq
          end
          return _560_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__remove_24_dispatch).bodies, _557_)
    return M["remove$"]
  end
  do local _ = {_556_()} end
  return M["remove$"]
end
setmetatable({nil, nil}, {__call = _555_})()
local __fn_2a_M__append_24_dispatch = {bodies = {}, help = {}}
local function _564_(...)
  if (0 == #(__fn_2a_M__append_24_dispatch).bodies) then
    error(("multi-arity function " .. "M.append$" .. " has no bodies"))
  else
  end
  local _566_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__append_24_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _566_ = f_74_auto
  end
  if (nil ~= _566_) then
    local f_74_auto = _566_
    return f_74_auto(...)
  elseif (_566_ == nil) then
    local view_77_auto
    do
      local _567_, _568_ = pcall(require, "fennel")
      if ((_567_ == true) and ((_G.type(_568_) == "table") and (nil ~= (_568_).view))) then
        local view_77_auto0 = (_568_).view
        view_77_auto = view_77_auto0
      elseif ((_567_ == false) and true) then
        local __75_auto = _568_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.append$", view_77_auto({...}), table.concat((__fn_2a_M__append_24_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["append$"] = _564_
local function _571_()
  local function _572_()
    table.insert((__fn_2a_M__append_24_dispatch).help, "(where [seq ...] (and (seq? seq) (< 0 (select \"#\" ...))))")
    local function _573_(...)
      if (1 <= select("#", ...)) then
        local _574_ = {...}
        local function _575_(...)
          local seq_563_ = (_574_)[1]
          return (seq_3f(seq_563_) and (0 < select("#", select(2, ...))))
        end
        if (((_G.type(_574_) == "table") and (nil ~= (_574_)[1])) and _575_(...)) then
          local seq_563_ = (_574_)[1]
          local function _576_(seq, ...)
            local _let_577_ = M.pack(...)
            local n = _let_577_["n"]
            local vals = _let_577_
            for i = 1, n do
              M["insert$"](seq, -1, vals[i])
            end
            return seq
          end
          return _576_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__append_24_dispatch).bodies, _573_)
    return M["append$"]
  end
  do local _ = {_572_()} end
  return M["append$"]
end
setmetatable({nil, nil}, {__call = _571_})()
local __fn_2a_M__concat_24_dispatch = {bodies = {}, help = {}}
local function _585_(...)
  if (0 == #(__fn_2a_M__concat_24_dispatch).bodies) then
    error(("multi-arity function " .. "M.concat$" .. " has no bodies"))
  else
  end
  local _587_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__concat_24_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _587_ = f_74_auto
  end
  if (nil ~= _587_) then
    local f_74_auto = _587_
    return f_74_auto(...)
  elseif (_587_ == nil) then
    local view_77_auto
    do
      local _588_, _589_ = pcall(require, "fennel")
      if ((_588_ == true) and ((_G.type(_589_) == "table") and (nil ~= (_589_).view))) then
        local view_77_auto0 = (_589_).view
        view_77_auto = view_77_auto0
      elseif ((_588_ == false) and true) then
        local __75_auto = _589_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.concat$", view_77_auto({...}), table.concat((__fn_2a_M__concat_24_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["concat$"] = _585_
local function _592_()
  local _593_
  do
    table.insert((__fn_2a_M__concat_24_dispatch).help, "(where [seq seq-1] (and (seq? seq) (seq? seq-1)))")
    local function _594_(...)
      if (2 == select("#", ...)) then
        local _595_ = {...}
        local function _596_(...)
          local seq_580_ = (_595_)[1]
          local seq_1_581_ = (_595_)[2]
          return (seq_3f(seq_580_) and seq_3f(seq_1_581_))
        end
        if (((_G.type(_595_) == "table") and (nil ~= (_595_)[1]) and (nil ~= (_595_)[2])) and _596_(...)) then
          local seq_580_ = (_595_)[1]
          local seq_1_581_ = (_595_)[2]
          local function _597_(seq, seq_1)
            local tbl_17_auto = seq
            local i_18_auto = #tbl_17_auto
            for _, v in ipairs(seq_1) do
              local val_19_auto = v
              if (nil ~= val_19_auto) then
                i_18_auto = (i_18_auto + 1)
                do end (tbl_17_auto)[i_18_auto] = val_19_auto
              else
              end
            end
            return tbl_17_auto
          end
          return _597_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__concat_24_dispatch).bodies, _594_)
    _593_ = M["concat$"]
  end
  local function _601_()
    table.insert((__fn_2a_M__concat_24_dispatch).help, "(where [seq seq-1 seq-2 ...] (and (seq? seq) (seq? seq-1) (seq? seq-2)))")
    local function _602_(...)
      if (3 <= select("#", ...)) then
        local _603_ = {...}
        local function _604_(...)
          local seq_582_ = (_603_)[1]
          local seq_1_583_ = (_603_)[2]
          local seq_2_584_ = (_603_)[3]
          return (seq_3f(seq_582_) and seq_3f(seq_1_583_) and seq_3f(seq_2_584_))
        end
        if (((_G.type(_603_) == "table") and (nil ~= (_603_)[1]) and (nil ~= (_603_)[2]) and (nil ~= (_603_)[3])) and _604_(...)) then
          local seq_582_ = (_603_)[1]
          local seq_1_583_ = (_603_)[2]
          local seq_2_584_ = (_603_)[3]
          local function _605_(seq, seq_1, seq_2, ...)
            return M["concat$"](M["concat$"](seq, seq_1), seq_2, ...)
          end
          return _605_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__concat_24_dispatch).bodies, _602_)
    return M["concat$"]
  end
  do local _ = {_593_, _601_()} end
  return M["concat$"]
end
setmetatable({nil, nil}, {__call = _592_})()
local __fn_2a_M__shuffle_24_dispatch = {bodies = {}, help = {}}
local function _609_(...)
  if (0 == #(__fn_2a_M__shuffle_24_dispatch).bodies) then
    error(("multi-arity function " .. "M.shuffle$" .. " has no bodies"))
  else
  end
  local _611_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__shuffle_24_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _611_ = f_74_auto
  end
  if (nil ~= _611_) then
    local f_74_auto = _611_
    return f_74_auto(...)
  elseif (_611_ == nil) then
    local view_77_auto
    do
      local _612_, _613_ = pcall(require, "fennel")
      if ((_612_ == true) and ((_G.type(_613_) == "table") and (nil ~= (_613_).view))) then
        local view_77_auto0 = (_613_).view
        view_77_auto = view_77_auto0
      elseif ((_612_ == false) and true) then
        local __75_auto = _613_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.shuffle$", view_77_auto({...}), table.concat((__fn_2a_M__shuffle_24_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["shuffle$"] = _609_
local function _616_()
  local function _617_()
    table.insert((__fn_2a_M__shuffle_24_dispatch).help, "(where [seq] (seq? seq))")
    local function _618_(...)
      if (1 == select("#", ...)) then
        local _619_ = {...}
        local function _620_(...)
          local seq_608_ = (_619_)[1]
          return seq_3f(seq_608_)
        end
        if (((_G.type(_619_) == "table") and (nil ~= (_619_)[1])) and _620_(...)) then
          local seq_608_ = (_619_)[1]
          local function _621_(seq)
            for i = #seq, 1, -1 do
              local j = math.random(1, i)
              local hold = seq[j]
              seq[j] = seq[i]
              seq[i] = hold
            end
            return seq
          end
          return _621_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__shuffle_24_dispatch).bodies, _618_)
    return M["shuffle$"]
  end
  do local _ = {_617_()} end
  return M["shuffle$"]
end
setmetatable({nil, nil}, {__call = _616_})()
local __fn_2a_M__hd_dispatch = {bodies = {}, help = {}}
local function _625_(...)
  if (0 == #(__fn_2a_M__hd_dispatch).bodies) then
    error(("multi-arity function " .. "M.hd" .. " has no bodies"))
  else
  end
  local _627_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__hd_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _627_ = f_74_auto
  end
  if (nil ~= _627_) then
    local f_74_auto = _627_
    return f_74_auto(...)
  elseif (_627_ == nil) then
    local view_77_auto
    do
      local _628_, _629_ = pcall(require, "fennel")
      if ((_628_ == true) and ((_G.type(_629_) == "table") and (nil ~= (_629_).view))) then
        local view_77_auto0 = (_629_).view
        view_77_auto = view_77_auto0
      elseif ((_628_ == false) and true) then
        local __75_auto = _629_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.hd", view_77_auto({...}), table.concat((__fn_2a_M__hd_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.hd = _625_
local function _632_()
  local function _633_()
    table.insert((__fn_2a_M__hd_dispatch).help, "(where [seq] (seq? seq))")
    local function _634_(...)
      if (1 == select("#", ...)) then
        local _635_ = {...}
        local function _636_(...)
          local seq_624_ = (_635_)[1]
          return seq_3f(seq_624_)
        end
        if (((_G.type(_635_) == "table") and (nil ~= (_635_)[1])) and _636_(...)) then
          local seq_624_ = (_635_)[1]
          local function _637_(seq)
            local _let_638_ = seq
            local h = _let_638_[1]
            return h
          end
          return _637_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__hd_dispatch).bodies, _634_)
    return M.hd
  end
  do local _ = {_633_()} end
  return M.hd
end
setmetatable({nil, nil}, {__call = _632_})()
local __fn_2a_M__tl_dispatch = {bodies = {}, help = {}}
local function _642_(...)
  if (0 == #(__fn_2a_M__tl_dispatch).bodies) then
    error(("multi-arity function " .. "M.tl" .. " has no bodies"))
  else
  end
  local _644_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__tl_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _644_ = f_74_auto
  end
  if (nil ~= _644_) then
    local f_74_auto = _644_
    return f_74_auto(...)
  elseif (_644_ == nil) then
    local view_77_auto
    do
      local _645_, _646_ = pcall(require, "fennel")
      if ((_645_ == true) and ((_G.type(_646_) == "table") and (nil ~= (_646_).view))) then
        local view_77_auto0 = (_646_).view
        view_77_auto = view_77_auto0
      elseif ((_645_ == false) and true) then
        local __75_auto = _646_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.tl", view_77_auto({...}), table.concat((__fn_2a_M__tl_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.tl = _642_
local function _649_()
  local function _650_()
    table.insert((__fn_2a_M__tl_dispatch).help, "(where [seq] (seq? seq))")
    local function _651_(...)
      if (1 == select("#", ...)) then
        local _652_ = {...}
        local function _653_(...)
          local seq_641_ = (_652_)[1]
          return seq_3f(seq_641_)
        end
        if (((_G.type(_652_) == "table") and (nil ~= (_652_)[1])) and _653_(...)) then
          local seq_641_ = (_652_)[1]
          local function _654_(seq)
            local _let_655_ = seq
            local _ = _let_655_[1]
            local tail = (function (t, k, e) local mt = getmetatable(t) if 'table' == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) elseif e then local rest = {} for k, v in pairs(t) do if not e[k] then rest[k] = v end end return rest else return {(table.unpack or unpack)(t, k)} end end)(_let_655_, 2)
            return tail
          end
          return _654_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__tl_dispatch).bodies, _651_)
    return M.tl
  end
  do local _ = {_650_()} end
  return M.tl
end
setmetatable({nil, nil}, {__call = _649_})()
local __fn_2a_M__first_dispatch = {bodies = {}, help = {}}
local function _659_(...)
  if (0 == #(__fn_2a_M__first_dispatch).bodies) then
    error(("multi-arity function " .. "M.first" .. " has no bodies"))
  else
  end
  local _661_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__first_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _661_ = f_74_auto
  end
  if (nil ~= _661_) then
    local f_74_auto = _661_
    return f_74_auto(...)
  elseif (_661_ == nil) then
    local view_77_auto
    do
      local _662_, _663_ = pcall(require, "fennel")
      if ((_662_ == true) and ((_G.type(_663_) == "table") and (nil ~= (_663_).view))) then
        local view_77_auto0 = (_663_).view
        view_77_auto = view_77_auto0
      elseif ((_662_ == false) and true) then
        local __75_auto = _663_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.first", view_77_auto({...}), table.concat((__fn_2a_M__first_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.first = _659_
local function _666_()
  local function _667_()
    table.insert((__fn_2a_M__first_dispatch).help, "(where [seq] (seq? seq))")
    local function _668_(...)
      if (1 == select("#", ...)) then
        local _669_ = {...}
        local function _670_(...)
          local seq_658_ = (_669_)[1]
          return seq_3f(seq_658_)
        end
        if (((_G.type(_669_) == "table") and (nil ~= (_669_)[1])) and _670_(...)) then
          local seq_658_ = (_669_)[1]
          local function _671_(seq)
            return M.hd(seq)
          end
          return _671_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__first_dispatch).bodies, _668_)
    return M.first
  end
  do local _ = {_667_()} end
  return M.first
end
setmetatable({nil, nil}, {__call = _666_})()
local __fn_2a_M__last_dispatch = {bodies = {}, help = {}}
local function _675_(...)
  if (0 == #(__fn_2a_M__last_dispatch).bodies) then
    error(("multi-arity function " .. "M.last" .. " has no bodies"))
  else
  end
  local _677_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__last_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _677_ = f_74_auto
  end
  if (nil ~= _677_) then
    local f_74_auto = _677_
    return f_74_auto(...)
  elseif (_677_ == nil) then
    local view_77_auto
    do
      local _678_, _679_ = pcall(require, "fennel")
      if ((_678_ == true) and ((_G.type(_679_) == "table") and (nil ~= (_679_).view))) then
        local view_77_auto0 = (_679_).view
        view_77_auto = view_77_auto0
      elseif ((_678_ == false) and true) then
        local __75_auto = _679_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.last", view_77_auto({...}), table.concat((__fn_2a_M__last_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.last = _675_
local function _682_()
  local function _683_()
    table.insert((__fn_2a_M__last_dispatch).help, "(where [seq] (seq? seq))")
    local function _684_(...)
      if (1 == select("#", ...)) then
        local _685_ = {...}
        local function _686_(...)
          local seq_674_ = (_685_)[1]
          return seq_3f(seq_674_)
        end
        if (((_G.type(_685_) == "table") and (nil ~= (_685_)[1])) and _686_(...)) then
          local seq_674_ = (_685_)[1]
          local function _687_(seq)
            return seq[#seq]
          end
          return _687_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__last_dispatch).bodies, _684_)
    return M.last
  end
  do local _ = {_683_()} end
  return M.last
end
setmetatable({nil, nil}, {__call = _682_})()
local __fn_2a_M__unique_dispatch = {bodies = {}, help = {}}
local function _693_(...)
  if (0 == #(__fn_2a_M__unique_dispatch).bodies) then
    error(("multi-arity function " .. "M.unique" .. " has no bodies"))
  else
  end
  local _695_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__unique_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _695_ = f_74_auto
  end
  if (nil ~= _695_) then
    local f_74_auto = _695_
    return f_74_auto(...)
  elseif (_695_ == nil) then
    local view_77_auto
    do
      local _696_, _697_ = pcall(require, "fennel")
      if ((_696_ == true) and ((_G.type(_697_) == "table") and (nil ~= (_697_).view))) then
        local view_77_auto0 = (_697_).view
        view_77_auto = view_77_auto0
      elseif ((_696_ == false) and true) then
        local __75_auto = _697_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.unique", view_77_auto({...}), table.concat((__fn_2a_M__unique_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.unique = _693_
local function _700_()
  local _701_
  do
    table.insert((__fn_2a_M__unique_dispatch).help, "(where [seq] (seq? seq))")
    local function _702_(...)
      if (1 == select("#", ...)) then
        local _703_ = {...}
        local function _704_(...)
          local seq_690_ = (_703_)[1]
          return seq_3f(seq_690_)
        end
        if (((_G.type(_703_) == "table") and (nil ~= (_703_)[1])) and _704_(...)) then
          local seq_690_ = (_703_)[1]
          local function _705_(seq)
            local function _706_(_241)
              return _241
            end
            return M.unique(seq, _706_)
          end
          return _705_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__unique_dispatch).bodies, _702_)
    _701_ = M.unique
  end
  local function _709_()
    table.insert((__fn_2a_M__unique_dispatch).help, "(where [seq identity] (and (seq? seq) (function? identity)))")
    local function _710_(...)
      if (2 == select("#", ...)) then
        local _711_ = {...}
        local function _712_(...)
          local seq_691_ = (_711_)[1]
          local identity_692_ = (_711_)[2]
          return (seq_3f(seq_691_) and function_3f(identity_692_))
        end
        if (((_G.type(_711_) == "table") and (nil ~= (_711_)[1]) and (nil ~= (_711_)[2])) and _712_(...)) then
          local seq_691_ = (_711_)[1]
          local identity_692_ = (_711_)[2]
          local function _713_(seq, identity)
            local function _716_(_714_, _index, value)
              local _arg_715_ = _714_
              local new_seq = _arg_715_[1]
              local seen = _arg_715_[2]
              local id_key = identity(value)
              if nil_3f(seen[id_key]) then
                seen[id_key] = true
                table.insert(new_seq, value)
                return {new_seq, seen}
              else
                return {new_seq, seen}
              end
            end
            return M.first(M.reduce(_716_, {{}, {}}, seq))
          end
          return _713_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__unique_dispatch).bodies, _710_)
    return M.unique
  end
  do local _ = {_701_, _709_()} end
  return M.unique
end
setmetatable({nil, nil}, {__call = _700_})()
local __fn_2a_M__split_dispatch = {bodies = {}, help = {}}
local function _722_(...)
  if (0 == #(__fn_2a_M__split_dispatch).bodies) then
    error(("multi-arity function " .. "M.split" .. " has no bodies"))
  else
  end
  local _724_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__split_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _724_ = f_74_auto
  end
  if (nil ~= _724_) then
    local f_74_auto = _724_
    return f_74_auto(...)
  elseif (_724_ == nil) then
    local view_77_auto
    do
      local _725_, _726_ = pcall(require, "fennel")
      if ((_725_ == true) and ((_G.type(_726_) == "table") and (nil ~= (_726_).view))) then
        local view_77_auto0 = (_726_).view
        view_77_auto = view_77_auto0
      elseif ((_725_ == false) and true) then
        local __75_auto = _726_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.split", view_77_auto({...}), table.concat((__fn_2a_M__split_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.split = _722_
local function _729_()
  local function _730_()
    table.insert((__fn_2a_M__split_dispatch).help, "(where [seq index] (and (seq? seq) (number? index) (<= 1 index)))")
    local function _731_(...)
      if (2 == select("#", ...)) then
        local _732_ = {...}
        local function _733_(...)
          local seq_720_ = (_732_)[1]
          local index_721_ = (_732_)[2]
          return (seq_3f(seq_720_) and number_3f(index_721_) and (1 <= index_721_))
        end
        if (((_G.type(_732_) == "table") and (nil ~= (_732_)[1]) and (nil ~= (_732_)[2])) and _733_(...)) then
          local seq_720_ = (_732_)[1]
          local index_721_ = (_732_)[2]
          local function _734_(seq, index)
            local left, right = {}, {}
            for i, v in ipairs(seq) do
              if (i < index) then
                left, right = M["insert$"](left, -1, v), right
              else
                left, right = left, M["insert$"](right, -1, v)
              end
            end
            return left, right
          end
          return _734_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__split_dispatch).bodies, _731_)
    return M.split
  end
  do local _ = {_730_()} end
  return M.split
end
setmetatable({nil, nil}, {__call = _729_})()
local __fn_2a_M__chunk_every_dispatch = {bodies = {}, help = {}}
local function _743_(...)
  if (0 == #(__fn_2a_M__chunk_every_dispatch).bodies) then
    error(("multi-arity function " .. "M.chunk-every" .. " has no bodies"))
  else
  end
  local _745_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__chunk_every_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _745_ = f_74_auto
  end
  if (nil ~= _745_) then
    local f_74_auto = _745_
    return f_74_auto(...)
  elseif (_745_ == nil) then
    local view_77_auto
    do
      local _746_, _747_ = pcall(require, "fennel")
      if ((_746_ == true) and ((_G.type(_747_) == "table") and (nil ~= (_747_).view))) then
        local view_77_auto0 = (_747_).view
        view_77_auto = view_77_auto0
      elseif ((_746_ == false) and true) then
        local __75_auto = _747_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.chunk-every", view_77_auto({...}), table.concat((__fn_2a_M__chunk_every_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["chunk-every"] = _743_
local function _750_()
  local _751_
  do
    table.insert((__fn_2a_M__chunk_every_dispatch).help, "(where [seq n] (and (seq? seq) (number? n)))")
    local function _752_(...)
      if (2 == select("#", ...)) then
        local _753_ = {...}
        local function _754_(...)
          local seq_738_ = (_753_)[1]
          local n_739_ = (_753_)[2]
          return (seq_3f(seq_738_) and number_3f(n_739_))
        end
        if (((_G.type(_753_) == "table") and (nil ~= (_753_)[1]) and (nil ~= (_753_)[2])) and _754_(...)) then
          local seq_738_ = (_753_)[1]
          local n_739_ = (_753_)[2]
          local function _755_(seq, n)
            return M["chunk-every"](seq, n, nil)
          end
          return _755_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__chunk_every_dispatch).bodies, _752_)
    _751_ = M["chunk-every"]
  end
  local function _758_()
    table.insert((__fn_2a_M__chunk_every_dispatch).help, "(where [seq n ?fill] (and (seq? seq) (number? n)))")
    local function _759_(...)
      if (3 == select("#", ...)) then
        local _760_ = {...}
        local function _761_(...)
          local seq_740_ = (_760_)[1]
          local n_741_ = (_760_)[2]
          local _3ffill_742_ = (_760_)[3]
          return (seq_3f(seq_740_) and number_3f(n_741_))
        end
        if (((_G.type(_760_) == "table") and (nil ~= (_760_)[1]) and (nil ~= (_760_)[2]) and true) and _761_(...)) then
          local seq_740_ = (_760_)[1]
          local n_741_ = (_760_)[2]
          local _3ffill_742_ = (_760_)[3]
          local function _762_(seq, n, _3ffill)
            local l = #seq
            if (0 < l) then
              local tbl_17_auto = {}
              local i_18_auto = #tbl_17_auto
              for i = 1, #seq, n do
                local val_19_auto
                do
                  local tbl_17_auto0 = {}
                  local i_18_auto0 = #tbl_17_auto0
                  for ii = 0, (n - 1) do
                    local val_19_auto0
                    do
                      local _763_ = seq[(i + ii)]
                      if (_763_ == nil) then
                        val_19_auto0 = _3ffill
                      elseif (nil ~= _763_) then
                        local any = _763_
                        val_19_auto0 = any
                      else
                        val_19_auto0 = nil
                      end
                    end
                    if (nil ~= val_19_auto0) then
                      i_18_auto0 = (i_18_auto0 + 1)
                      do end (tbl_17_auto0)[i_18_auto0] = val_19_auto0
                    else
                    end
                  end
                  val_19_auto = tbl_17_auto0
                end
                if (nil ~= val_19_auto) then
                  i_18_auto = (i_18_auto + 1)
                  do end (tbl_17_auto)[i_18_auto] = val_19_auto
                else
                end
              end
              return tbl_17_auto
            else
              return {}
            end
          end
          return _762_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__chunk_every_dispatch).bodies, _759_)
    return M["chunk-every"]
  end
  do local _ = {_751_, _758_()} end
  return M["chunk-every"]
end
setmetatable({nil, nil}, {__call = _750_})()
local __fn_2a_M__set_24_dispatch = {bodies = {}, help = {}}
local function _776_(...)
  if (0 == #(__fn_2a_M__set_24_dispatch).bodies) then
    error(("multi-arity function " .. "M.set$" .. " has no bodies"))
  else
  end
  local _778_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__set_24_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _778_ = f_74_auto
  end
  if (nil ~= _778_) then
    local f_74_auto = _778_
    return f_74_auto(...)
  elseif (_778_ == nil) then
    local view_77_auto
    do
      local _779_, _780_ = pcall(require, "fennel")
      if ((_779_ == true) and ((_G.type(_780_) == "table") and (nil ~= (_780_).view))) then
        local view_77_auto0 = (_780_).view
        view_77_auto = view_77_auto0
      elseif ((_779_ == false) and true) then
        local __75_auto = _780_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.set$", view_77_auto({...}), table.concat((__fn_2a_M__set_24_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["set$"] = _776_
local function _783_()
  local _784_
  do
    table.insert((__fn_2a_M__set_24_dispatch).help, "(where [t k ?v] (table? t))")
    local function _785_(...)
      if (3 == select("#", ...)) then
        local _786_ = {...}
        local function _787_(...)
          local t_770_ = (_786_)[1]
          local k_771_ = (_786_)[2]
          local _3fv_772_ = (_786_)[3]
          return table_3f(t_770_)
        end
        if (((_G.type(_786_) == "table") and (nil ~= (_786_)[1]) and (nil ~= (_786_)[2]) and true) and _787_(...)) then
          local t_770_ = (_786_)[1]
          local k_771_ = (_786_)[2]
          local _3fv_772_ = (_786_)[3]
          local function _788_(t, k, _3fv)
            t[k] = _3fv
            return t
          end
          return _788_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__set_24_dispatch).bodies, _785_)
    _784_ = M["set$"]
  end
  local _791_
  do
    table.insert((__fn_2a_M__set_24_dispatch).help, "(where [t] (table? t))")
    local function _792_(...)
      if (1 == select("#", ...)) then
        local _793_ = {...}
        local function _794_(...)
          local t_773_ = (_793_)[1]
          return table_3f(t_773_)
        end
        if (((_G.type(_793_) == "table") and (nil ~= (_793_)[1])) and _794_(...)) then
          local t_773_ = (_793_)[1]
          local function _795_(t)
            local function _796_(_241, _242)
              t[_241] = _242
              return t
            end
            return _796_
          end
          return _795_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__set_24_dispatch).bodies, _792_)
    _791_ = M["set$"]
  end
  local function _799_()
    table.insert((__fn_2a_M__set_24_dispatch).help, "(where [t k] (table? t))")
    local function _800_(...)
      if (2 == select("#", ...)) then
        local _801_ = {...}
        local function _802_(...)
          local t_774_ = (_801_)[1]
          local k_775_ = (_801_)[2]
          return table_3f(t_774_)
        end
        if (((_G.type(_801_) == "table") and (nil ~= (_801_)[1]) and (nil ~= (_801_)[2])) and _802_(...)) then
          local t_774_ = (_801_)[1]
          local k_775_ = (_801_)[2]
          local function _803_(t, k)
            local function _804_(_241)
              t[k] = _241
              return t
            end
            return _804_
          end
          return _803_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__set_24_dispatch).bodies, _800_)
    return M["set$"]
  end
  do local _ = {_784_, _791_, _799_()} end
  return M["set$"]
end
setmetatable({nil, nil}, {__call = _783_})()
local __fn_2a_M__sort_24_dispatch = {bodies = {}, help = {}}
local function _811_(...)
  if (0 == #(__fn_2a_M__sort_24_dispatch).bodies) then
    error(("multi-arity function " .. "M.sort$" .. " has no bodies"))
  else
  end
  local _813_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__sort_24_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _813_ = f_74_auto
  end
  if (nil ~= _813_) then
    local f_74_auto = _813_
    return f_74_auto(...)
  elseif (_813_ == nil) then
    local view_77_auto
    do
      local _814_, _815_ = pcall(require, "fennel")
      if ((_814_ == true) and ((_G.type(_815_) == "table") and (nil ~= (_815_).view))) then
        local view_77_auto0 = (_815_).view
        view_77_auto = view_77_auto0
      elseif ((_814_ == false) and true) then
        local __75_auto = _815_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.sort$", view_77_auto({...}), table.concat((__fn_2a_M__sort_24_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["sort$"] = _811_
local function _818_()
  local _819_
  do
    table.insert((__fn_2a_M__sort_24_dispatch).help, "(where [f] (function? f))")
    local function _820_(...)
      if (1 == select("#", ...)) then
        local _821_ = {...}
        local function _822_(...)
          local f_807_ = (_821_)[1]
          return function_3f(f_807_)
        end
        if (((_G.type(_821_) == "table") and (nil ~= (_821_)[1])) and _822_(...)) then
          local f_807_ = (_821_)[1]
          local function _823_(f)
            local function _824_(_241)
              return M["sort$"](f, _241)
            end
            return _824_
          end
          return _823_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__sort_24_dispatch).bodies, _820_)
    _819_ = M["sort$"]
  end
  local _827_
  do
    table.insert((__fn_2a_M__sort_24_dispatch).help, "(where [seq] (seq? seq))")
    local function _828_(...)
      if (1 == select("#", ...)) then
        local _829_ = {...}
        local function _830_(...)
          local seq_808_ = (_829_)[1]
          return seq_3f(seq_808_)
        end
        if (((_G.type(_829_) == "table") and (nil ~= (_829_)[1])) and _830_(...)) then
          local seq_808_ = (_829_)[1]
          local function _831_(seq)
            table.sort(seq)
            return seq
          end
          return _831_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__sort_24_dispatch).bodies, _828_)
    _827_ = M["sort$"]
  end
  local function _834_()
    table.insert((__fn_2a_M__sort_24_dispatch).help, "(where [f seq] (and (function? f) (seq? seq)))")
    local function _835_(...)
      if (2 == select("#", ...)) then
        local _836_ = {...}
        local function _837_(...)
          local f_809_ = (_836_)[1]
          local seq_810_ = (_836_)[2]
          return (function_3f(f_809_) and seq_3f(seq_810_))
        end
        if (((_G.type(_836_) == "table") and (nil ~= (_836_)[1]) and (nil ~= (_836_)[2])) and _837_(...)) then
          local f_809_ = (_836_)[1]
          local seq_810_ = (_836_)[2]
          local function _838_(f, seq)
            table.sort(seq, f)
            return seq
          end
          return _838_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__sort_24_dispatch).bodies, _835_)
    return M["sort$"]
  end
  do local _ = {_819_, _827_, _834_()} end
  return M["sort$"]
end
setmetatable({nil, nil}, {__call = _818_})()
local __fn_2a_M__sort_dispatch = {bodies = {}, help = {}}
local function _844_(...)
  if (0 == #(__fn_2a_M__sort_dispatch).bodies) then
    error(("multi-arity function " .. "M.sort" .. " has no bodies"))
  else
  end
  local _846_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__sort_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _846_ = f_74_auto
  end
  if (nil ~= _846_) then
    local f_74_auto = _846_
    return f_74_auto(...)
  elseif (_846_ == nil) then
    local view_77_auto
    do
      local _847_, _848_ = pcall(require, "fennel")
      if ((_847_ == true) and ((_G.type(_848_) == "table") and (nil ~= (_848_).view))) then
        local view_77_auto0 = (_848_).view
        view_77_auto = view_77_auto0
      elseif ((_847_ == false) and true) then
        local __75_auto = _848_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.sort", view_77_auto({...}), table.concat((__fn_2a_M__sort_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.sort = _844_
local function _851_()
  local _852_
  do
    table.insert((__fn_2a_M__sort_dispatch).help, "(where [f] (function? f))")
    local function _853_(...)
      if (1 == select("#", ...)) then
        local _854_ = {...}
        local function _855_(...)
          local f_841_ = (_854_)[1]
          return function_3f(f_841_)
        end
        if (((_G.type(_854_) == "table") and (nil ~= (_854_)[1])) and _855_(...)) then
          local f_841_ = (_854_)[1]
          local function _856_(f)
            local function _857_(_241)
              return M.sort(f, _241)
            end
            return _857_
          end
          return _856_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__sort_dispatch).bodies, _853_)
    _852_ = M.sort
  end
  local function _860_()
    table.insert((__fn_2a_M__sort_dispatch).help, "(where [f seq] (function? f) (seq? seq))")
    local function _861_(...)
      if (2 == select("#", ...)) then
        local _862_ = {...}
        local function _863_(...)
          local f_842_ = (_862_)[1]
          local seq_843_ = (_862_)[2]
          return function_3f(f_842_)
        end
        if (((_G.type(_862_) == "table") and (nil ~= (_862_)[1]) and (nil ~= (_862_)[2])) and _863_(...)) then
          local f_842_ = (_862_)[1]
          local seq_843_ = (_862_)[2]
          local function _864_(f, seq)
            local sorted_keys
            local function _865_(_241)
              local function _868_(acc, i, _866_)
                local _arg_867_ = _866_
                local oi = _arg_867_[1]
                local v = _arg_867_[2]
                return M["set$"](acc, oi, i)
              end
              return M.reduce(_868_, {}, _241)
            end
            local function _869_(_241)
              local function _874_(_870_, _872_)
                local _arg_871_ = _870_
                local _ = _arg_871_[1]
                local a = _arg_871_[2]
                local _arg_873_ = _872_
                local _0 = _arg_873_[1]
                local b = _arg_873_[2]
                return f(a, b)
              end
              table.sort(_241, _874_)
              return _241
            end
            sorted_keys = _865_(_869_(M["table->pairs"](seq)))
            local function _875_(acc, i, v)
              return M["set$"](acc, sorted_keys[i], v)
            end
            return M.reduce(_875_, {}, seq)
          end
          return _864_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__sort_dispatch).bodies, _861_)
    return M.sort
  end
  do local _ = {_852_, _860_()} end
  return M.sort
end
setmetatable({nil, nil}, {__call = _851_})()
local __fn_2a_M__table__3epairs_dispatch = {bodies = {}, help = {}}
local function _879_(...)
  if (0 == #(__fn_2a_M__table__3epairs_dispatch).bodies) then
    error(("multi-arity function " .. "M.table->pairs" .. " has no bodies"))
  else
  end
  local _881_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__table__3epairs_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _881_ = f_74_auto
  end
  if (nil ~= _881_) then
    local f_74_auto = _881_
    return f_74_auto(...)
  elseif (_881_ == nil) then
    local view_77_auto
    do
      local _882_, _883_ = pcall(require, "fennel")
      if ((_882_ == true) and ((_G.type(_883_) == "table") and (nil ~= (_883_).view))) then
        local view_77_auto0 = (_883_).view
        view_77_auto = view_77_auto0
      elseif ((_882_ == false) and true) then
        local __75_auto = _883_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.table->pairs", view_77_auto({...}), table.concat((__fn_2a_M__table__3epairs_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["table->pairs"] = _879_
local function _886_()
  local function _887_()
    table.insert((__fn_2a_M__table__3epairs_dispatch).help, "(where [t] (table? t))")
    local function _888_(...)
      if (1 == select("#", ...)) then
        local _889_ = {...}
        local function _890_(...)
          local t_878_ = (_889_)[1]
          return table_3f(t_878_)
        end
        if (((_G.type(_889_) == "table") and (nil ~= (_889_)[1])) and _890_(...)) then
          local t_878_ = (_889_)[1]
          local function _891_(t)
            local function _892_(_241, _242)
              return {_241, _242}
            end
            return M.map(_892_, t)
          end
          return _891_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__table__3epairs_dispatch).bodies, _888_)
    return M["table->pairs"]
  end
  do local _ = {_887_()} end
  return M["table->pairs"]
end
setmetatable({nil, nil}, {__call = _886_})()
local __fn_2a_M__pairs__3etable_dispatch = {bodies = {}, help = {}}
local function _896_(...)
  if (0 == #(__fn_2a_M__pairs__3etable_dispatch).bodies) then
    error(("multi-arity function " .. "M.pairs->table" .. " has no bodies"))
  else
  end
  local _898_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__pairs__3etable_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _898_ = f_74_auto
  end
  if (nil ~= _898_) then
    local f_74_auto = _898_
    return f_74_auto(...)
  elseif (_898_ == nil) then
    local view_77_auto
    do
      local _899_, _900_ = pcall(require, "fennel")
      if ((_899_ == true) and ((_G.type(_900_) == "table") and (nil ~= (_900_).view))) then
        local view_77_auto0 = (_900_).view
        view_77_auto = view_77_auto0
      elseif ((_899_ == false) and true) then
        local __75_auto = _900_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.pairs->table", view_77_auto({...}), table.concat((__fn_2a_M__pairs__3etable_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["pairs->table"] = _896_
local function _903_()
  local function _904_()
    table.insert((__fn_2a_M__pairs__3etable_dispatch).help, "(where [seq] (seq? seq))")
    local function _905_(...)
      if (1 == select("#", ...)) then
        local _906_ = {...}
        local function _907_(...)
          local seq_895_ = (_906_)[1]
          return seq_3f(seq_895_)
        end
        if (((_G.type(_906_) == "table") and (nil ~= (_906_)[1])) and _907_(...)) then
          local seq_895_ = (_906_)[1]
          local function _908_(seq)
            local function _911_(acc, i, _909_)
              local _arg_910_ = _909_
              local k = _arg_910_[1]
              local v = _arg_910_[2]
              return M["set$"](acc, k, v)
            end
            return M.reduce(_911_, {}, seq)
          end
          return _908_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__pairs__3etable_dispatch).bodies, _905_)
    return M["pairs->table"]
  end
  do local _ = {_904_()} end
  return M["pairs->table"]
end
setmetatable({nil, nil}, {__call = _903_})()
local __fn_2a_M__keys_dispatch = {bodies = {}, help = {}}
local function _915_(...)
  if (0 == #(__fn_2a_M__keys_dispatch).bodies) then
    error(("multi-arity function " .. "M.keys" .. " has no bodies"))
  else
  end
  local _917_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__keys_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _917_ = f_74_auto
  end
  if (nil ~= _917_) then
    local f_74_auto = _917_
    return f_74_auto(...)
  elseif (_917_ == nil) then
    local view_77_auto
    do
      local _918_, _919_ = pcall(require, "fennel")
      if ((_918_ == true) and ((_G.type(_919_) == "table") and (nil ~= (_919_).view))) then
        local view_77_auto0 = (_919_).view
        view_77_auto = view_77_auto0
      elseif ((_918_ == false) and true) then
        local __75_auto = _919_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.keys", view_77_auto({...}), table.concat((__fn_2a_M__keys_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.keys = _915_
local function _922_()
  local function _923_()
    table.insert((__fn_2a_M__keys_dispatch).help, "(where [enumerable] (table? enumerable))")
    local function _924_(...)
      if (1 == select("#", ...)) then
        local _925_ = {...}
        local function _926_(...)
          local enumerable_914_ = (_925_)[1]
          return table_3f(enumerable_914_)
        end
        if (((_G.type(_925_) == "table") and (nil ~= (_925_)[1])) and _926_(...)) then
          local enumerable_914_ = (_925_)[1]
          local function _927_(enumerable)
            local function _928_(_241)
              return _241
            end
            local function _929_()
              return pairs(enumerable)
            end
            return M.map(_928_, _929_)
          end
          return _927_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__keys_dispatch).bodies, _924_)
    return M.keys
  end
  do local _ = {_923_()} end
  return M.keys
end
setmetatable({nil, nil}, {__call = _922_})()
local __fn_2a_M__vals_dispatch = {bodies = {}, help = {}}
local function _933_(...)
  if (0 == #(__fn_2a_M__vals_dispatch).bodies) then
    error(("multi-arity function " .. "M.vals" .. " has no bodies"))
  else
  end
  local _935_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__vals_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _935_ = f_74_auto
  end
  if (nil ~= _935_) then
    local f_74_auto = _935_
    return f_74_auto(...)
  elseif (_935_ == nil) then
    local view_77_auto
    do
      local _936_, _937_ = pcall(require, "fennel")
      if ((_936_ == true) and ((_G.type(_937_) == "table") and (nil ~= (_937_).view))) then
        local view_77_auto0 = (_937_).view
        view_77_auto = view_77_auto0
      elseif ((_936_ == false) and true) then
        local __75_auto = _937_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.vals", view_77_auto({...}), table.concat((__fn_2a_M__vals_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.vals = _933_
local function _940_()
  local function _941_()
    table.insert((__fn_2a_M__vals_dispatch).help, "(where [enumerable] (table? enumerable))")
    local function _942_(...)
      if (1 == select("#", ...)) then
        local _943_ = {...}
        local function _944_(...)
          local enumerable_932_ = (_943_)[1]
          return table_3f(enumerable_932_)
        end
        if (((_G.type(_943_) == "table") and (nil ~= (_943_)[1])) and _944_(...)) then
          local enumerable_932_ = (_943_)[1]
          local function _945_(enumerable)
            local function _946_(_241, _242)
              return _242
            end
            local function _947_()
              return pairs(enumerable)
            end
            return M.map(_946_, _947_)
          end
          return _945_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__vals_dispatch).bodies, _942_)
    return M.vals
  end
  do local _ = {_941_()} end
  return M.vals
end
setmetatable({nil, nil}, {__call = _940_})()
local __fn_2a_M__intersperse_dispatch = {bodies = {}, help = {}}
local function _952_(...)
  if (0 == #(__fn_2a_M__intersperse_dispatch).bodies) then
    error(("multi-arity function " .. "M.intersperse" .. " has no bodies"))
  else
  end
  local _954_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__intersperse_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _954_ = f_74_auto
  end
  if (nil ~= _954_) then
    local f_74_auto = _954_
    return f_74_auto(...)
  elseif (_954_ == nil) then
    local view_77_auto
    do
      local _955_, _956_ = pcall(require, "fennel")
      if ((_955_ == true) and ((_G.type(_956_) == "table") and (nil ~= (_956_).view))) then
        local view_77_auto0 = (_956_).view
        view_77_auto = view_77_auto0
      elseif ((_955_ == false) and true) then
        local __75_auto = _956_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.intersperse", view_77_auto({...}), table.concat((__fn_2a_M__intersperse_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.intersperse = _952_
local function _959_()
  local function _960_()
    table.insert((__fn_2a_M__intersperse_dispatch).help, "(where [e inter] (seq? e))")
    local function _961_(...)
      if (2 == select("#", ...)) then
        local _962_ = {...}
        local function _963_(...)
          local e_950_ = (_962_)[1]
          local inter_951_ = (_962_)[2]
          return seq_3f(e_950_)
        end
        if (((_G.type(_962_) == "table") and (nil ~= (_962_)[1]) and (nil ~= (_962_)[2])) and _963_(...)) then
          local e_950_ = (_962_)[1]
          local inter_951_ = (_962_)[2]
          local function _964_(e, inter)
            local __fn_2a_fn_2a__anonymous___965__dispatch = {bodies = {}, help = {}}
            local fn_2a__anonymous___965_
            local function _972_(...)
              if (0 == #(__fn_2a_fn_2a__anonymous___965__dispatch).bodies) then
                error(("multi-arity function " .. "fn*__anonymous___965_" .. " has no bodies"))
              else
              end
              local _974_
              do
                local f_74_auto = nil
                for __75_auto, match_3f_76_auto in ipairs((__fn_2a_fn_2a__anonymous___965__dispatch).bodies) do
                  if f_74_auto then break end
                  f_74_auto = match_3f_76_auto(...)
                end
                _974_ = f_74_auto
              end
              if (nil ~= _974_) then
                local f_74_auto = _974_
                return f_74_auto(...)
              elseif (_974_ == nil) then
                local view_77_auto
                do
                  local _975_, _976_ = pcall(require, "fennel")
                  if ((_975_ == true) and ((_G.type(_976_) == "table") and (nil ~= (_976_).view))) then
                    local view_77_auto0 = (_976_).view
                    view_77_auto = view_77_auto0
                  elseif ((_975_ == false) and true) then
                    local __75_auto = _976_
                    view_77_auto = (_G.vim.inspect or print)
                  else
                    view_77_auto = nil
                  end
                end
                local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "fn*__anonymous___965_", view_77_auto({...}), table.concat((__fn_2a_fn_2a__anonymous___965__dispatch).help, "\n"))
                return error(msg_78_auto)
              else
                return nil
              end
            end
            fn_2a__anonymous___965_ = _972_
            local function _979_()
              local _980_
              do
                table.insert((__fn_2a_fn_2a__anonymous___965__dispatch).help, "(where [acc n v] (= n (length ^e)))")
                local function _981_(...)
                  if (3 == select("#", ...)) then
                    local _982_ = {...}
                    local function _983_(...)
                      local acc_966_ = (_982_)[1]
                      local n_967_ = (_982_)[2]
                      local v_968_ = (_982_)[3]
                      return (n_967_ == #e)
                    end
                    if (((_G.type(_982_) == "table") and (nil ~= (_982_)[1]) and (nil ~= (_982_)[2]) and (nil ~= (_982_)[3])) and _983_(...)) then
                      local acc_966_ = (_982_)[1]
                      local n_967_ = (_982_)[2]
                      local v_968_ = (_982_)[3]
                      local function _984_(acc, n, v)
                        return M["append$"](acc, v)
                      end
                      return _984_
                    else
                      return nil
                    end
                  else
                    return nil
                  end
                end
                table.insert((__fn_2a_fn_2a__anonymous___965__dispatch).bodies, _981_)
                _980_ = fn_2a__anonymous___965_
              end
              local function _987_()
                table.insert((__fn_2a_fn_2a__anonymous___965__dispatch).help, "(where [acc i v])")
                local function _988_(...)
                  if (3 == select("#", ...)) then
                    local _989_ = {...}
                    local function _990_(...)
                      local acc_969_ = (_989_)[1]
                      local i_970_ = (_989_)[2]
                      local v_971_ = (_989_)[3]
                      return true
                    end
                    if (((_G.type(_989_) == "table") and (nil ~= (_989_)[1]) and (nil ~= (_989_)[2]) and (nil ~= (_989_)[3])) and _990_(...)) then
                      local acc_969_ = (_989_)[1]
                      local i_970_ = (_989_)[2]
                      local v_971_ = (_989_)[3]
                      local function _991_(acc, i, v)
                        return M["append$"](acc, v, inter)
                      end
                      return _991_
                    else
                      return nil
                    end
                  else
                    return nil
                  end
                end
                table.insert((__fn_2a_fn_2a__anonymous___965__dispatch).bodies, _988_)
                return fn_2a__anonymous___965_
              end
              do local _ = {_980_, _987_()} end
              return fn_2a__anonymous___965_
            end
            return M.reduce(setmetatable({nil, nil}, {__call = _979_})(), {}, e)
          end
          return _964_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__intersperse_dispatch).bodies, _961_)
    return M.intersperse
  end
  do local _ = {_960_()} end
  return M.intersperse
end
setmetatable({nil, nil}, {__call = _959_})()
local __fn_2a_M__empty_3f_dispatch = {bodies = {}, help = {}}
local function _997_(...)
  if (0 == #(__fn_2a_M__empty_3f_dispatch).bodies) then
    error(("multi-arity function " .. "M.empty?" .. " has no bodies"))
  else
  end
  local _999_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__empty_3f_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _999_ = f_74_auto
  end
  if (nil ~= _999_) then
    local f_74_auto = _999_
    return f_74_auto(...)
  elseif (_999_ == nil) then
    local view_77_auto
    do
      local _1000_, _1001_ = pcall(require, "fennel")
      if ((_1000_ == true) and ((_G.type(_1001_) == "table") and (nil ~= (_1001_).view))) then
        local view_77_auto0 = (_1001_).view
        view_77_auto = view_77_auto0
      elseif ((_1000_ == false) and true) then
        local __75_auto = _1001_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.empty?", view_77_auto({...}), table.concat((__fn_2a_M__empty_3f_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["empty?"] = _997_
local function _1004_()
  local function _1005_()
    table.insert((__fn_2a_M__empty_3f_dispatch).help, "(where [t] (table? t))")
    local function _1006_(...)
      if (1 == select("#", ...)) then
        local _1007_ = {...}
        local function _1008_(...)
          local t_996_ = (_1007_)[1]
          return table_3f(t_996_)
        end
        if (((_G.type(_1007_) == "table") and (nil ~= (_1007_)[1])) and _1008_(...)) then
          local t_996_ = (_1007_)[1]
          local function _1009_(t)
            return (nil == next(t))
          end
          return _1009_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__empty_3f_dispatch).bodies, _1006_)
    return M["empty?"]
  end
  do local _ = {_1005_()} end
  return M["empty?"]
end
setmetatable({nil, nil}, {__call = _1004_})()
local __fn_2a_M__stream_dispatch = {bodies = {}, help = {}}
local function _1013_(...)
  if (0 == #(__fn_2a_M__stream_dispatch).bodies) then
    error(("multi-arity function " .. "M.stream" .. " has no bodies"))
  else
  end
  local _1015_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__stream_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _1015_ = f_74_auto
  end
  if (nil ~= _1015_) then
    local f_74_auto = _1015_
    return f_74_auto(...)
  elseif (_1015_ == nil) then
    local view_77_auto
    do
      local _1016_, _1017_ = pcall(require, "fennel")
      if ((_1016_ == true) and ((_G.type(_1017_) == "table") and (nil ~= (_1017_).view))) then
        local view_77_auto0 = (_1017_).view
        view_77_auto = view_77_auto0
      elseif ((_1016_ == false) and true) then
        local __75_auto = _1017_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.stream", view_77_auto({...}), table.concat((__fn_2a_M__stream_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M.stream = _1013_
local function _1020_()
  local function _1021_()
    table.insert((__fn_2a_M__stream_dispatch).help, "(where [t] (enumerable? t))")
    local function _1022_(...)
      if (1 == select("#", ...)) then
        local _1023_ = {...}
        local function _1024_(...)
          local t_1012_ = (_1023_)[1]
          return enumerable_3f(t_1012_)
        end
        if (((_G.type(_1023_) == "table") and (nil ~= (_1023_)[1])) and _1024_(...)) then
          local t_1012_ = (_1023_)[1]
          local function _1025_(t)
            return {enum = t, funs = {}}
          end
          return _1025_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__stream_dispatch).bodies, _1022_)
    return M.stream
  end
  do local _ = {_1021_()} end
  return M.stream
end
setmetatable({nil, nil}, {__call = _1020_})()
local __fn_2a_M__stream__3eseq_dispatch = {bodies = {}, help = {}}
local function _1030_(...)
  if (0 == #(__fn_2a_M__stream__3eseq_dispatch).bodies) then
    error(("multi-arity function " .. "M.stream->seq" .. " has no bodies"))
  else
  end
  local _1032_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__stream__3eseq_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _1032_ = f_74_auto
  end
  if (nil ~= _1032_) then
    local f_74_auto = _1032_
    return f_74_auto(...)
  elseif (_1032_ == nil) then
    local view_77_auto
    do
      local _1033_, _1034_ = pcall(require, "fennel")
      if ((_1033_ == true) and ((_G.type(_1034_) == "table") and (nil ~= (_1034_).view))) then
        local view_77_auto0 = (_1034_).view
        view_77_auto = view_77_auto0
      elseif ((_1033_ == false) and true) then
        local __75_auto = _1034_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "M.stream->seq", view_77_auto({...}), table.concat((__fn_2a_M__stream__3eseq_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
M["stream->seq"] = _1030_
local function _1037_()
  local _1038_
  do
    table.insert((__fn_2a_M__stream__3eseq_dispatch).help, "(where [l] (and (stream? l) (or (seq? l.enum) (assoc? l.enum))))")
    local function _1039_(...)
      if (1 == select("#", ...)) then
        local _1040_ = {...}
        local function _1041_(...)
          local l_1028_ = (_1040_)[1]
          return (stream_3f(l_1028_) and (seq_3f(l_1028_.enum) or assoc_3f(l_1028_.enum)))
        end
        if (((_G.type(_1040_) == "table") and (nil ~= (_1040_)[1])) and _1041_(...)) then
          local l_1028_ = (_1040_)[1]
          local function _1042_(l)
            local function _1043_(k, v)
              local function _1044_(acc, i, f)
                local _1045_ = {f(k, acc)}
                if ((_G.type(_1045_) == "table") and ((_1045_)[1] == stream_halt_marker)) then
                  return M.reduced(nil)
                elseif ((_G.type(_1045_) == "table") and ((_1045_)[1] == stream_use_last_value_marker)) then
                  return acc
                elseif ((_G.type(_1045_) == "table") and ((_1045_)[1] == stream_use_new_value_marker) and true) then
                  local _3fnew_acc = (_1045_)[2]
                  return _3fnew_acc
                else
                  return nil
                end
              end
              return M.reduce(_1044_, v, l.funs)
            end
            return M.map(_1043_, l.enum)
          end
          return _1042_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__stream__3eseq_dispatch).bodies, _1039_)
    _1038_ = M["stream->seq"]
  end
  local function _1049_()
    table.insert((__fn_2a_M__stream__3eseq_dispatch).help, "(where [l] (and (stream? l) (function? l.enum)))")
    local function _1050_(...)
      if (1 == select("#", ...)) then
        local _1051_ = {...}
        local function _1052_(...)
          local l_1029_ = (_1051_)[1]
          return (stream_3f(l_1029_) and function_3f(l_1029_.enum))
        end
        if (((_G.type(_1051_) == "table") and (nil ~= (_1051_)[1])) and _1052_(...)) then
          local l_1029_ = (_1051_)[1]
          local function _1053_(l)
            local function _1054_(...)
              local function _1055_(acc, _, f)
                local new = M.pack(f(M.unpack(acc)))
                local _1056_ = new
                if ((_G.type(_1056_) == "table") and ((_1056_)[1] == stream_halt_marker)) then
                  return M.reduced(nil)
                elseif ((_G.type(_1056_) == "table") and ((_1056_)[1] == stream_use_last_value_marker)) then
                  return acc
                elseif ((_G.type(_1056_) == "table") and ((_1056_)[1] == stream_use_new_value_marker)) then
                  return M.pack(M.unpack(new, 2))
                else
                  return nil
                end
              end
              return M.reduce(_1055_, M.pack(...), l.funs)
            end
            return M.flatten(M.map(_1054_, l.enum))
          end
          return _1053_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_M__stream__3eseq_dispatch).bodies, _1050_)
    return M["stream->seq"]
  end
  do local _ = {_1038_, _1049_()} end
  return M["stream->seq"]
end
setmetatable({nil, nil}, {__call = _1037_})()
return M