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
local function find_impl(root, known_paths)
  local _let_19_ = require("pact.lib.ruin.result")
  local bind_15_auto = _let_19_["bind"]
  local unit_16_auto = _let_19_["unit"]
  local bind_20_ = bind_15_auto
  local unit_21_ = unit_16_auto
  local function _22_(_241, _242)
    return {path = (root .. "/" .. _242.name), name = _242.name}
  end
  local function _23_(_241, _242)
    local _24_ = _242
    if ((_G.type(_24_) == "table") and ((_24_).kind == "directory")) then
      return true
    elseif true then
      local __1_auto = _24_
      return false
    else
      return nil
    end
  end
  local function _26_(all_names)
    local function _27_(_, found)
      local function _28_(_241, _242)
        return (found.path == _242)
      end
      return not enum["any?"](_28_, known_paths)
    end
    local function _29_(unknown_names)
      local function _30_()
        return ok(unknown_names)
      end
      return unit_21_(_30_())
    end
    return unit_21_(bind_20_(unit_21_(enum.filter(_27_, all_names)), _29_))
  end
  return bind_20_(unit_21_(enum.map(_22_, enum.filter(_23_, fs_tasks["ls-path"](root)))), _26_)
end
local function find(root, known_paths)
  if not absolute_path_3f(root) then
    return err(fmt("orphan search path must be absolute, got %s", root))
  else
    if dir_exists_3f(root) then
      return find_impl(root, known_paths)
    else
      return ok({})
    end
  end
end
local __fn_2a_new_dispatch = {bodies = {}, help = {}}
local new
local function _36_(...)
  if (0 == #(__fn_2a_new_dispatch).bodies) then
    error(("multi-arity function " .. "new" .. " has no bodies"))
  else
  end
  local _38_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _38_ = f_74_auto
  end
  if (nil ~= _38_) then
    local f_74_auto = _38_
    return f_74_auto(...)
  elseif (_38_ == nil) then
    local view_77_auto
    do
      local _39_, _40_ = pcall(require, "fennel")
      if ((_39_ == true) and ((_G.type(_40_) == "table") and (nil ~= (_40_).view))) then
        local view_77_auto0 = (_40_).view
        view_77_auto = view_77_auto0
      elseif ((_39_ == false) and true) then
        local __75_auto = _40_
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
new = _36_
local function _43_()
  local function _44_()
    table.insert((__fn_2a_new_dispatch).help, "(where [id root known-paths])")
    local function _45_(...)
      if (3 == select("#", ...)) then
        local _46_ = {...}
        local function _47_(...)
          local id_33_ = (_46_)[1]
          local root_34_ = (_46_)[2]
          local known_paths_35_ = (_46_)[3]
          return true
        end
        if (((_G.type(_46_) == "table") and (nil ~= (_46_)[1]) and (nil ~= (_46_)[2]) and (nil ~= (_46_)[3])) and _47_(...)) then
          local id_33_ = (_46_)[1]
          local root_34_ = (_46_)[2]
          local known_paths_35_ = (_46_)[3]
          local function _48_(id, root, known_paths)
            local function _49_()
              return find(root, known_paths)
            end
            return new_workflow(id, _49_)
          end
          return _48_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_new_dispatch).bodies, _45_)
    return new
  end
  do local _ = {_44_()} end
  return new
end
setmetatable({nil, nil}, {__call = _43_})()
return {new = new}