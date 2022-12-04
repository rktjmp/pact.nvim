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
local _local_13_, enum, git_tasks, fs_tasks, _local_14_, _local_15_ = nil, nil, nil, nil, nil, nil
do
  local _12_ = require("pact.workflow")
  local _11_ = string
  local _10_ = require("pact.workflow.exec.fs")
  local _9_ = require("pact.workflow.exec.git")
  local _8_ = require("pact.lib.ruin.enum")
  local _7_ = require("pact.lib.ruin.result")
  _local_13_, enum, git_tasks, fs_tasks, _local_14_, _local_15_ = _7_, _8_, _9_, _10_, _11_, _12_
end
local _local_16_ = _local_13_
local err = _local_16_["err"]
local ok = _local_16_["ok"]
local _local_17_ = _local_14_
local fmt = _local_17_["format"]
local _local_18_ = _local_15_
local new_workflow = _local_18_["new"]
local yield = _local_18_["yield"]
do local _ = {nil, nil} end
local function absolute_path_3f(path)
  return not_nil_3f(string.match(path, "^/"))
end
local function dir_exists_3f(path)
  return ("directory" == fs_tasks["what-is-at"](path))
end
local function remove(path)
  if not absolute_path_3f(path) then
    return err(fmt("remove path must be absolute, got %s", path))
  else
    if dir_exists_3f(path) then
      print("remove-path", path)
      fs_tasks["remove-path"](path)
      return ok(path)
    else
      return err(fmt("cant remove dir, it does not exist! %s", path))
    end
  end
end
local __fn_2a_new_dispatch = {bodies = {}, help = {}}
local new
local function _23_(...)
  if (0 == #(__fn_2a_new_dispatch).bodies) then
    error(("multi-arity function " .. "new" .. " has no bodies"))
  else
  end
  local _25_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do
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
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "new", view_77_auto({...}), table.concat((__fn_2a_new_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
new = _23_
local function _30_()
  local function _31_()
    table.insert((__fn_2a_new_dispatch).help, "(where [id path])")
    local function _32_(...)
      if (2 == select("#", ...)) then
        local _33_ = {...}
        local function _34_(...)
          local id_21_ = (_33_)[1]
          local path_22_ = (_33_)[2]
          return true
        end
        if (((_G.type(_33_) == "table") and (nil ~= (_33_)[1]) and (nil ~= (_33_)[2])) and _34_(...)) then
          local id_21_ = (_33_)[1]
          local path_22_ = (_33_)[2]
          local function _35_(id, path)
            local function _36_()
              return remove(path)
            end
            return new_workflow(id, _36_)
          end
          return _35_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_new_dispatch).bodies, _32_)
    return new
  end
  do local _ = {_31_()} end
  return new
end
setmetatable({nil, nil}, {__call = _30_})()
return {new = new}