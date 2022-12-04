local _local_6_ = require("pact.lib.ruin.type")
local assoc_3f = _local_6_["assoc?"]
local boolean_3f = _local_6_["boolean?"]
local function_3f = _local_6_["function?"]
local nil_3f = _local_6_["nil?"]
local not_nil_3f = _local_6_["not-nil?"]
local number_3f = _local_6_["number?"]
local seq_3f = _local_6_["seq?"]
local string_3f = _local_6_["string?"]
local table_3f = _local_6_["table?"]
local thread_3f = _local_6_["thread?"]
local userdata_3f = _local_6_["userdata?"]
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local _local_12_, enum, inspect, _local_13_, _local_14_ = nil, nil, nil, nil, nil
do
  local _11_ = require("pact.workflow")
  local _10_ = require("pact.lib.ruin.result")
  local _9_ = require("pact.inspect")
  local _8_ = require("pact.lib.ruin.enum")
  local _7_ = string
  _local_12_, enum, inspect, _local_13_, _local_14_ = _7_, _8_, _9_, _10_, _11_
end
local _local_15_ = _local_12_
local fmt = _local_15_["format"]
local _local_16_ = _local_13_
local err = _local_16_["err"]
local ok = _local_16_["ok"]
local result = _local_16_["result"]
local _local_17_ = _local_14_
local new_workflow = _local_17_["new"]
local yield = _local_17_["yield"]
do local _ = {nil, nil, nil} end
local function dump_err(code, err0)
  return fmt("run-error: [%d] %s", code, inspect(err0))
end
local function run_string(cmd, cwd)
  local _let_18_ = require("pact.workflow.exec.process")
  local run = _let_18_["run"]
  local parts
  local function _19_(_241)
    return _241
  end
  local function _20_()
    return string.gmatch(cmd, "(%S+)")
  end
  parts = enum.map(_19_, _20_)
  local _let_21_ = require("pact.lib.ruin.result")
  local bind_15_auto = _let_21_["bind"]
  local unit_16_auto = _let_21_["unit"]
  local bind_22_ = bind_15_auto
  local unit_23_ = unit_16_auto
  local function _24_(_)
    local function _29_()
      local _25_, _26_, _27_ = nil, nil, nil
      do
        local _let_28_ = require("pact.async-await")
        local await_wrap_3_auto = _let_28_["await-wrap"]
        _25_, _26_, _27_ = await_wrap_3_auto(run, {enum.hd(parts), enum.tl(parts), cwd, {}})
      end
      if ((_25_ == 0) and true and true) then
        local _0 = _26_
        local _1 = _27_
        return true
      elseif ((nil ~= _25_) and true and (_27_ == err)) then
        local code = _25_
        local _0 = _26_
        return nil, dump_err(code, err)
      elseif ((_25_ == nil) and (nil ~= _26_)) then
        local er = _26_
        return nil, er
      else
        return nil
      end
    end
    local function _31_(_0)
      local function _32_()
        return ok(cmd)
      end
      return unit_23_(_32_())
    end
    return unit_23_(bind_22_(unit_23_(_29_()), _31_))
  end
  return bind_22_(unit_23_(yield(fmt("%s", cmd))), _24_)
end
local function run_function(func, cwd)
  local _let_33_ = require("pact.workflow.exec.process")
  local run = _let_33_["run"]
  local wrapped_run
  local function _34_(cmd, args, _3fcwd)
    local _let_35_ = require("pact.async-await")
    local await_wrap_3_auto = _let_35_["await-wrap"]
    return await_wrap_3_auto(run, {cmd, args, (_3fcwd or cwd), {}})
  end
  wrapped_run = _34_
  return result(func({path = cwd, run = wrapped_run, yield = yield}))
end
local __fn_2a_new_dispatch = {bodies = {}, help = {}}
local new
local function _42_(...)
  if (0 == #(__fn_2a_new_dispatch).bodies) then
    error(("multi-arity function " .. "new" .. " has no bodies"))
  else
  end
  local _44_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _44_ = f_74_auto
  end
  if (nil ~= _44_) then
    local f_74_auto = _44_
    return f_74_auto(...)
  elseif (_44_ == nil) then
    local view_77_auto
    do
      local _45_, _46_ = pcall(require, "fennel")
      if ((_45_ == true) and ((_G.type(_46_) == "table") and (nil ~= (_46_).view))) then
        local view_77_auto0 = (_46_).view
        view_77_auto = view_77_auto0
      elseif ((_45_ == false) and true) then
        local __75_auto = _46_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "new", view_77_auto({...}), table.concat((__fn_2a_new_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
new = _42_
local function _49_()
  local _50_
  do
    table.insert((__fn_2a_new_dispatch).help, "(where [id cmd cwd] (string? cmd))")
    local function _51_(...)
      if (3 == select("#", ...)) then
        local _52_ = {...}
        local function _53_(...)
          local id_36_ = (_52_)[1]
          local cmd_37_ = (_52_)[2]
          local cwd_38_ = (_52_)[3]
          return string_3f(cmd_37_)
        end
        if (((_G.type(_52_) == "table") and (nil ~= (_52_)[1]) and (nil ~= (_52_)[2]) and (nil ~= (_52_)[3])) and _53_(...)) then
          local id_36_ = (_52_)[1]
          local cmd_37_ = (_52_)[2]
          local cwd_38_ = (_52_)[3]
          local function _54_(id, cmd, cwd)
            local function _55_()
              return run_string(cmd, cwd)
            end
            return new_workflow(id, _55_)
          end
          return _54_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_new_dispatch).bodies, _51_)
    _50_ = new
  end
  local function _58_()
    table.insert((__fn_2a_new_dispatch).help, "(where [id func cwd] (function? func))")
    local function _59_(...)
      if (3 == select("#", ...)) then
        local _60_ = {...}
        local function _61_(...)
          local id_39_ = (_60_)[1]
          local func_40_ = (_60_)[2]
          local cwd_41_ = (_60_)[3]
          return function_3f(func_40_)
        end
        if (((_G.type(_60_) == "table") and (nil ~= (_60_)[1]) and (nil ~= (_60_)[2]) and (nil ~= (_60_)[3])) and _61_(...)) then
          local id_39_ = (_60_)[1]
          local func_40_ = (_60_)[2]
          local cwd_41_ = (_60_)[3]
          local function _62_(id, func, cwd)
            local function _63_()
              return run_function(func, cwd)
            end
            return new_workflow(id, _63_)
          end
          return _62_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_new_dispatch).bodies, _59_)
    return new
  end
  do local _ = {_50_, _58_()} end
  return new
end
setmetatable({nil, nil}, {__call = _49_})()
return {new = new}