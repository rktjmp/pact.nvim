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
local _local_12_, git_tasks, fs_tasks, _local_13_, _local_14_ = nil, nil, nil, nil, nil
do
  local _11_ = require("pact.workflow")
  local _10_ = string
  local _9_ = require("pact.workflow.exec.fs")
  local _8_ = require("pact.workflow.exec.git")
  local _7_ = require("pact.lib.ruin.result")
  _local_12_, git_tasks, fs_tasks, _local_13_, _local_14_ = _7_, _8_, _9_, _10_, _11_
end
local _local_15_ = _local_12_
local err = _local_15_["err"]
local ok = _local_15_["ok"]
local _local_16_ = _local_13_
local fmt = _local_16_["format"]
local _local_17_ = _local_14_
local new_workflow = _local_17_["new"]
local yield = _local_17_["yield"]
do local _ = {nil, nil} end
local function absolute_path_3f(path)
  return not_nil_3f(string.match(path, "^/"))
end
local function git_dir_3f(path)
  return ("directory" == fs_tasks["what-is-at"]((path .. "/.git")))
end
local function diff_shas_impl(path, sha)
  local _let_18_ = require("pact.lib.ruin.result")
  local bind_15_auto = _let_18_["bind"]
  local unit_16_auto = _let_18_["unit"]
  local bind_19_ = bind_15_auto
  local unit_20_ = unit_16_auto
  local function _21_(_)
    local function _22_(shallow_3f)
      local function _23_()
        if shallow_3f then
          yield("unshallowing clone")
          return git_tasks.unshallow(path)
        else
          return nil
        end
      end
      local function _24_(_0)
        local function _25_(_1)
          local function _26_(_2)
            local function _27_(_3)
              local function _28_(HEAD)
                local function _29_(_4)
                  local function _30_(lines)
                    local function _31_()
                      return ok(lines)
                    end
                    return unit_20_(_31_())
                  end
                  return unit_20_(bind_19_(unit_20_(git_tasks["log-diff"](path, HEAD, sha)), _30_))
                end
                return unit_20_(bind_19_(unit_20_(yield("diffing range")), _29_))
              end
              return unit_20_(bind_19_(unit_20_(git_tasks["HEAD-sha"](path)), _28_))
            end
            return unit_20_(bind_19_(unit_20_(yield("get HEAD sha")), _27_))
          end
          return unit_20_(bind_19_(unit_20_(git_tasks.fetch(path)), _26_))
        end
        return unit_20_(bind_19_(unit_20_(yield("updating clone")), _25_))
      end
      return unit_20_(bind_19_(unit_20_(_23_()), _24_))
    end
    return unit_20_(bind_19_(unit_20_(git_tasks["shallow?"](path)), _22_))
  end
  return bind_19_(unit_20_(yield("checking clone shallowness")), _21_)
end
local function diff(path, sha)
  local _let_32_ = require("pact.lib.ruin.result")
  local map_ok_24_auto = _let_32_["map-ok"]
  local result_25_auto = _let_32_["result"]
  local unwrap_26_auto = _let_32_["unwrap"]
  local function _33_(_241)
    return (_241 or absolute_path_3f(path) or nil or fmt("plugin path must be absolute, got %s", path))
  end
  local function _34_(_241)
    local function _35_()
      if git_dir_3f(path) then
        return diff_shas_impl(path, sha)
      else
        return err(fmt("unable to diff, directory %s is not a git repo", path))
      end
    end
    return _35_(_241)
  end
  return map_ok_24_auto(map_ok_24_auto(result_25_auto(yield("starting git-diff workflow")), _33_), _34_)
end
local __fn_2a_new_dispatch = {bodies = {}, help = {}}
local new
local function _40_(...)
  if (0 == #(__fn_2a_new_dispatch).bodies) then
    error(("multi-arity function " .. "new" .. " has no bodies"))
  else
  end
  local _42_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _42_ = f_74_auto
  end
  if (nil ~= _42_) then
    local f_74_auto = _42_
    return f_74_auto(...)
  elseif (_42_ == nil) then
    local view_77_auto
    do
      local _43_, _44_ = pcall(require, "fennel")
      if ((_43_ == true) and ((_G.type(_44_) == "table") and (nil ~= (_44_).view))) then
        local view_77_auto0 = (_44_).view
        view_77_auto = view_77_auto0
      elseif ((_43_ == false) and true) then
        local __75_auto = _44_
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
new = _40_
local function _47_()
  local function _48_()
    table.insert((__fn_2a_new_dispatch).help, "(where [id path sha])")
    local function _49_(...)
      if (3 == select("#", ...)) then
        local _50_ = {...}
        local function _51_(...)
          local id_37_ = (_50_)[1]
          local path_38_ = (_50_)[2]
          local sha_39_ = (_50_)[3]
          return true
        end
        if (((_G.type(_50_) == "table") and (nil ~= (_50_)[1]) and (nil ~= (_50_)[2]) and (nil ~= (_50_)[3])) and _51_(...)) then
          local id_37_ = (_50_)[1]
          local path_38_ = (_50_)[2]
          local sha_39_ = (_50_)[3]
          local function _52_(id, path, sha)
            local function _53_()
              return diff(path, sha)
            end
            return new_workflow(id, _53_)
          end
          return _52_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_new_dispatch).bodies, _49_)
    return new
  end
  do local _ = {_48_()} end
  return new
end
setmetatable({nil, nil}, {__call = _47_})()
return {new = new}