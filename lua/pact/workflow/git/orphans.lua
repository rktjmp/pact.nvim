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
local function dir_exists_3f(path)
  return ("directory" == fs_tasks["what-is-at"](path))
end
local function clone_repo_impl(repo_url, sha, path)
  local _let_18_ = require("pact.lib.ruin.result")
  local bind_15_auto = _let_18_["bind"]
  local unit_16_auto = _let_18_["unit"]
  local bind_19_ = bind_15_auto
  local unit_20_ = unit_16_auto
  local function _21_(_)
    local function _22_(_0)
      local function _23_(_1)
        local function _24_(_2)
          local function _25_(_3)
            local function _26_(_4)
              local function _27_(_5)
                local function _28_(_6)
                  local function _29_(_7)
                    local function _30_(_8)
                      local function _31_()
                        return ok(sha)
                      end
                      return unit_20_(_31_())
                    end
                    return unit_20_(bind_19_(unit_20_(git_tasks["update-submodules"](path)), _30_))
                  end
                  return unit_20_(bind_19_(unit_20_(yield("updating submodules")), _29_))
                end
                return unit_20_(bind_19_(unit_20_(git_tasks["checkout-sha"](path, sha)), _28_))
              end
              return unit_20_(bind_19_(unit_20_(yield("checking out sha")), _27_))
            end
            return unit_20_(bind_19_(unit_20_(git_tasks["fetch-sha"](path, sha)), _26_))
          end
          return unit_20_(bind_19_(unit_20_(yield("fetching sha")), _25_))
        end
        return unit_20_(bind_19_(unit_20_(git_tasks["set-origin"](path, repo_url)), _24_))
      end
      return unit_20_(bind_19_(unit_20_(yield("set remote origin")), _23_))
    end
    return unit_20_(bind_19_(unit_20_(git_tasks.init(path)), _22_))
  end
  return bind_19_(unit_20_(yield("init new local repo")), _21_)
end
local function clone(repo_url, sha, path)
  local _let_32_ = require("pact.lib.ruin.result")
  local map_ok_24_auto = _let_32_["map-ok"]
  local result_25_auto = _let_32_["result"]
  local unwrap_26_auto = _let_32_["unwrap"]
  local function _33_(_241)
    return (_241 or absolute_path_3f(path) or nil or fmt("plugin path must be absolute, got %s", path))
  end
  local function _34_(_241)
    local function _35_()
      if not dir_exists_3f(path) then
        return clone_repo_impl(repo_url, sha, path)
      else
        return err(fmt("unable to clone, directory %s already exists", path))
      end
    end
    return _35_(_241)
  end
  return map_ok_24_auto(map_ok_24_auto(result_25_auto(yield("starting git-clone workflow")), _33_), _34_)
end
local __fn_2a_new_dispatch = {bodies = {}, help = {}}
local new
local function _41_(...)
  if (0 == #(__fn_2a_new_dispatch).bodies) then
    error(("multi-arity function " .. "new" .. " has no bodies"))
  else
  end
  local _43_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _43_ = f_74_auto
  end
  if (nil ~= _43_) then
    local f_74_auto = _43_
    return f_74_auto(...)
  elseif (_43_ == nil) then
    local view_77_auto
    do
      local _44_, _45_ = pcall(require, "fennel")
      if ((_44_ == true) and ((_G.type(_45_) == "table") and (nil ~= (_45_).view))) then
        local view_77_auto0 = (_45_).view
        view_77_auto = view_77_auto0
      elseif ((_44_ == false) and true) then
        local __75_auto = _45_
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
new = _41_
local function _48_()
  local function _49_()
    table.insert((__fn_2a_new_dispatch).help, "(where [id path repo-url sha])")
    local function _50_(...)
      if (4 == select("#", ...)) then
        local _51_ = {...}
        local function _52_(...)
          local id_37_ = (_51_)[1]
          local path_38_ = (_51_)[2]
          local repo_url_39_ = (_51_)[3]
          local sha_40_ = (_51_)[4]
          return true
        end
        if (((_G.type(_51_) == "table") and (nil ~= (_51_)[1]) and (nil ~= (_51_)[2]) and (nil ~= (_51_)[3]) and (nil ~= (_51_)[4])) and _52_(...)) then
          local id_37_ = (_51_)[1]
          local path_38_ = (_51_)[2]
          local repo_url_39_ = (_51_)[3]
          local sha_40_ = (_51_)[4]
          local function _53_(id, path, repo_url, sha)
            local function _54_()
              return clone(repo_url, sha, path)
            end
            return new_workflow(id, _54_)
          end
          return _53_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_new_dispatch).bodies, _50_)
    return new
  end
  do local _ = {_49_()} end
  return new
end
setmetatable({nil, nil}, {__call = _48_})()
return {new = new}