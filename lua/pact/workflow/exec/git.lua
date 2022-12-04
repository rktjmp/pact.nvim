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
local enum, inspect, _local_12_, _local_13_, _local_14_ = nil, nil, nil, nil, nil
do
  local _11_ = string
  local _10_ = vim
  local _9_ = require("pact.workflow.exec.process")
  local _8_ = require("pact.inspect")
  local _7_ = require("pact.lib.ruin.enum")
  enum, inspect, _local_12_, _local_13_, _local_14_ = _7_, _8_, _9_, _10_, _11_
end
local _local_15_ = _local_12_
local run = _local_15_["run"]
local _local_16_ = _local_13_
local uv = _local_16_["loop"]
local _local_17_ = _local_14_
local fmt = _local_17_["format"]
do local _ = {nil, nil} end
local const = {ENV = {"GIT_TERMINAL_PROMPT=0"}}
local function dump_err(code, err)
  return fmt("git-error: return-code: %s std-err: %s", code, inspect(err))
end
local function HEAD_sha(repo_root)
  assert(repo_root, "must provide repo root")
  local _18_, _19_, _20_ = nil, nil, nil
  do
    local _let_21_ = require("pact.async-await")
    local await_wrap_3_auto = _let_21_["await-wrap"]
    _18_, _19_, _20_ = await_wrap_3_auto(run, {"git", {"rev-parse", "--sq", "HEAD"}, repo_root, const.ENV})
  end
  if ((_18_ == 0) and ((_G.type(_19_) == "table") and (nil ~= (_19_)[1])) and true) then
    local line = (_19_)[1]
    local _ = _20_
    local _22_ = string.match(line, "([%x]+)")
    if (_22_ == nil) then
      return nil, "could not find SHA in command output"
    elseif (nil ~= _22_) then
      local sha = _22_
      return sha
    else
      return nil
    end
  elseif ((nil ~= _18_) and (nil ~= _19_) and (nil ~= _20_)) then
    local code = _18_
    local lines = _19_
    local err = _20_
    return nil, dump_err(code, {lines, err})
  elseif ((_18_ == nil) and (nil ~= _19_)) then
    local err = _19_
    return nil, err
  else
    return nil
  end
end
local function ls_remote(repo_path_or_url)
  local function url_3f(str)
    local str0 = string.lower(str)
    local http = string.match(str0, "^http")
    local ssh = string.match(str0, "^ssh")
    return not (function(_25_,_26_,_27_) return (_25_ == _26_) and (_26_ == _27_) end)(nil,http,ssh)
  end
  local args, cwd = nil, nil
  do
    local _28_ = url_3f(repo_path_or_url)
    if (_28_ == true) then
      args, cwd = {"ls-remote", "--tags", "--heads", repo_path_or_url}, "."
    elseif (_28_ == false) then
      args, cwd = {"ls-remote", "--tags", "--heads"}, repo_path_or_url
    else
      args, cwd = nil
    end
  end
  local _30_, _31_, _32_ = nil, nil, nil
  do
    local _let_33_ = require("pact.async-await")
    local await_wrap_3_auto = _let_33_["await-wrap"]
    _30_, _31_, _32_ = await_wrap_3_auto(run, {"git", args, cwd, const.ENV})
  end
  if ((_30_ == 0) and (nil ~= _31_) and true) then
    local lines = _31_
    local _ = _32_
    return lines
  elseif ((nil ~= _30_) and true and (nil ~= _32_)) then
    local code = _30_
    local _ = _31_
    local err = _32_
    return nil, dump_err(code, err)
  elseif ((_30_ == nil) and (nil ~= _31_)) then
    local err = _31_
    return nil, err
  else
    return nil
  end
end
local function set_origin(repo_path, url)
  local _35_, _36_, _37_ = nil, nil, nil
  do
    local _let_38_ = require("pact.async-await")
    local await_wrap_3_auto = _let_38_["await-wrap"]
    _35_, _36_, _37_ = await_wrap_3_auto(run, {"git", {"remote", "add", "origin", url}, repo_path, const.ENV})
  end
  if ((_35_ == 0) and true and true) then
    local _ = _36_
    local _0 = _37_
    return url
  elseif ((nil ~= _35_) and true and (nil ~= _37_)) then
    local code = _35_
    local _ = _36_
    local err = _37_
    return nil, dump_err(code, err)
  elseif ((_35_ == nil) and (nil ~= _36_)) then
    local err = _36_
    return nil, err
  else
    return nil
  end
end
local function get_origin(repo_path)
  local _40_, _41_, _42_ = nil, nil, nil
  do
    local _let_43_ = require("pact.async-await")
    local await_wrap_3_auto = _let_43_["await-wrap"]
    _40_, _41_, _42_ = await_wrap_3_auto(run, {"git", {"remote", "get-url", "origin"}, repo_path, const.ENV})
  end
  if ((_40_ == 0) and ((_G.type(_41_) == "table") and (nil ~= (_41_)[1])) and true) then
    local url = (_41_)[1]
    local _ = _42_
    return string.match(url, "([^\13\n]+)")
  elseif ((nil ~= _40_) and true and (nil ~= _42_)) then
    local code = _40_
    local _ = _41_
    local err = _42_
    return nil, dump_err(code, err)
  elseif ((_40_ == nil) and (nil ~= _41_)) then
    local err = _41_
    return nil, err
  else
    return nil
  end
end
local function fetch_sha(repo_path, sha)
  local _45_, _46_, _47_ = nil, nil, nil
  do
    local _let_48_ = require("pact.async-await")
    local await_wrap_3_auto = _let_48_["await-wrap"]
    _45_, _46_, _47_ = await_wrap_3_auto(run, {"git", {"fetch", "--depth=1", "origin", sha}, repo_path, const.ENV})
  end
  if ((_45_ == 0) and true and true) then
    local _ = _46_
    local _0 = _47_
    return sha
  elseif ((nil ~= _45_) and true and (nil ~= _47_)) then
    local code = _45_
    local _ = _46_
    local err = _47_
    return nil, dump_err(code, err)
  elseif ((_45_ == nil) and (nil ~= _46_)) then
    local err = _46_
    return nil, err
  else
    return nil
  end
end
local function fetch(repo_path)
  local _50_, _51_, _52_ = nil, nil, nil
  do
    local _let_53_ = require("pact.async-await")
    local await_wrap_3_auto = _let_53_["await-wrap"]
    _50_, _51_, _52_ = await_wrap_3_auto(run, {"git", {"fetch", "origin"}, repo_path, const.ENV})
  end
  if ((_50_ == 0) and true and true) then
    local _ = _51_
    local _0 = _52_
    return true
  elseif ((nil ~= _50_) and true and (nil ~= _52_)) then
    local code = _50_
    local _ = _51_
    local err = _52_
    return nil, dump_err(code, err)
  elseif ((_50_ == nil) and (nil ~= _51_)) then
    local err = _51_
    return nil, err
  else
    return nil
  end
end
local function init(repo_path, inited)
  local _55_, _56_, _57_ = nil, nil, nil
  do
    local _let_58_ = require("pact.async-await")
    local await_wrap_3_auto = _let_58_["await-wrap"]
    _55_, _56_, _57_ = await_wrap_3_auto(run, {"git", {"init", repo_path}, ".", const.ENV})
  end
  if ((_55_ == 0) and true and true) then
    local _ = _56_
    local _0 = _57_
    return repo_path
  elseif ((nil ~= _55_) and true and (nil ~= _57_)) then
    local code = _55_
    local _ = _56_
    local err = _57_
    return nil, dump_err(code, err)
  elseif ((_55_ == nil) and (nil ~= _56_)) then
    local err = _56_
    return nil, err
  else
    return nil
  end
end
local function checkout_sha(repo_path, sha)
  local _60_, _61_, _62_ = nil, nil, nil
  do
    local _let_63_ = require("pact.async-await")
    local await_wrap_3_auto = _let_63_["await-wrap"]
    _60_, _61_, _62_ = await_wrap_3_auto(run, {"git", {"checkout", sha}, repo_path, const.ENV})
  end
  if ((_60_ == 0) and true and true) then
    local _ = _61_
    local _0 = _62_
    return sha
  elseif ((nil ~= _60_) and true and (nil ~= _62_)) then
    local code = _60_
    local _ = _61_
    local err = _62_
    return nil, dump_err(code, err)
  elseif ((_60_ == nil) and (nil ~= _61_)) then
    local err = _61_
    return nil, err
  else
    return nil
  end
end
local function update_submodules(repo_path)
  local _65_, _66_, _67_ = nil, nil, nil
  do
    local _let_68_ = require("pact.async-await")
    local await_wrap_3_auto = _let_68_["await-wrap"]
    _65_, _66_, _67_ = await_wrap_3_auto(run, {"git", {"submodule", "update", "--init", "--recursive"}, repo_path, const.ENV})
  end
  if ((_65_ == 0) and (nil ~= _66_) and true) then
    local lines = _66_
    local _ = _67_
    return lines
  elseif ((nil ~= _65_) and true and (nil ~= _67_)) then
    local code = _65_
    local _ = _66_
    local err = _67_
    return nil, dump_err(code, err)
  elseif ((_65_ == nil) and (nil ~= _66_)) then
    local err = _66_
    return nil, err
  else
    return nil
  end
end
local function shallow_3f(repo_path)
  local _70_, _71_, _72_ = nil, nil, nil
  do
    local _let_73_ = require("pact.async-await")
    local await_wrap_3_auto = _let_73_["await-wrap"]
    _70_, _71_, _72_ = await_wrap_3_auto(run, {"git", {"rev-parse", "--is-shallow-repository"}, repo_path, const.ENV})
  end
  if ((_70_ == 0) and ((_G.type(_71_) == "table") and ((_71_)[1] == "false")) and true) then
    local _ = _72_
    return false
  elseif ((_70_ == 0) and ((_G.type(_71_) == "table") and ((_71_)[1] == "true")) and true) then
    local _ = _72_
    return true
  elseif ((_70_ == 0) and (nil ~= _71_) and (nil ~= _72_)) then
    local a = _71_
    local b = _72_
    return nil, dump_err(0, {a, b})
  elseif ((nil ~= _70_) and true and (nil ~= _72_)) then
    local code = _70_
    local _ = _71_
    local err = _72_
    return nil, dump_err(code, err)
  elseif ((_70_ == nil) and (nil ~= _71_)) then
    local err = _71_
    return nil, err
  else
    return nil
  end
end
local function unshallow(repo_path)
  local _75_, _76_, _77_ = nil, nil, nil
  do
    local _let_78_ = require("pact.async-await")
    local await_wrap_3_auto = _let_78_["await-wrap"]
    _75_, _76_, _77_ = await_wrap_3_auto(run, {"git", {"fetch", "--unshallow"}, repo_path, const.ENV})
  end
  if ((_75_ == 0) and (nil ~= _76_) and (nil ~= _77_)) then
    local a = _76_
    local b = _77_
    return true
  elseif ((nil ~= _75_) and true and (nil ~= _77_)) then
    local code = _75_
    local _ = _76_
    local err = _77_
    return nil, dump_err(code, err)
  elseif ((_75_ == nil) and (nil ~= _76_)) then
    local err = _76_
    return nil, err
  else
    return nil
  end
end
local function log_diff(repo_path, old_sha, new_sha)
  local _80_, _81_, _82_ = nil, nil, nil
  do
    local _let_83_ = require("pact.async-await")
    local await_wrap_3_auto = _let_83_["await-wrap"]
    _80_, _81_, _82_ = await_wrap_3_auto(run, {"git", {"log", "--oneline", fmt("%s..%s", old_sha, new_sha)}, repo_path, const.ENV})
  end
  local function _84_()
    local log = _81_
    local _ = _82_
    return (0 == #log)
  end
  if (((_80_ == 0) and (nil ~= _81_) and true) and _84_()) then
    local log = _81_
    local _ = _82_
    return nil, "git log produced no output, are you moving backwards?"
  elseif ((_80_ == 0) and (nil ~= _81_) and true) then
    local log = _81_
    local _ = _82_
    return log
  elseif ((nil ~= _80_) and true and (nil ~= _82_)) then
    local code = _80_
    local _ = _81_
    local err = _82_
    return nil, dump_err(code, err)
  elseif ((_80_ == nil) and (nil ~= _81_)) then
    local err = _81_
    return nil, err
  else
    return nil
  end
end
return {init = init, ["HEAD-sha"] = HEAD_sha, ["ls-remote"] = ls_remote, ["set-origin"] = set_origin, ["get-origin"] = get_origin, ["fetch-sha"] = fetch_sha, fetch = fetch, ["checkout-sha"] = checkout_sha, ["update-submodules"] = update_submodules, ["shallow?"] = shallow_3f, unshallow = unshallow, ["log-diff"] = log_diff}