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
  return fmt("git-error: [%d] %s", code, inspect(err))
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
      return "could not find SHA in command output"
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
  local code, lines, err = nil, nil, nil
  do
    local _28_ = url_3f(repo_path_or_url)
    if (_28_ == true) then
      local _let_29_ = require("pact.async-await")
      local await_wrap_3_auto = _let_29_["await-wrap"]
      code, lines, err = await_wrap_3_auto(run, {"git", {"ls-remote", "--tags", "--heads", repo_path_or_url}, ".", const.ENV})
    elseif (_28_ == false) then
      local _let_30_ = require("pact.async-await")
      local await_wrap_3_auto = _let_30_["await-wrap"]
      code, lines, err = await_wrap_3_auto(run, {"git", {"ls-remote", "--tags", "--heads"}, repo_path_or_url, const.ENV})
    else
      code, lines, err = nil
    end
  end
  local _32_ = {code, lines, err}
  if ((_G.type(_32_) == "table") and ((_32_)[1] == 0) and ((_32_)[2] == lines) and true) then
    local _ = (_32_)[3]
    return lines
  elseif ((_G.type(_32_) == "table") and ((_32_)[1] == code) and true and ((_32_)[3] == err)) then
    local _ = (_32_)[2]
    return nil, dump_err(code, err)
  else
    return nil
  end
end
local function set_origin(repo_path, url)
  local _34_, _35_, _36_ = nil, nil, nil
  do
    local _let_37_ = require("pact.async-await")
    local await_wrap_3_auto = _let_37_["await-wrap"]
    _34_, _35_, _36_ = await_wrap_3_auto(run, {"git", {"remote", "add", "origin", url}, repo_path, const.ENV})
  end
  if ((_34_ == 0) and true and true) then
    local _ = _35_
    local _0 = _36_
    return url
  elseif ((nil ~= _34_) and true and (nil ~= _36_)) then
    local code = _34_
    local _ = _35_
    local err = _36_
    return nil, dump_err(code, err)
  else
    return nil
  end
end
local function get_origin(repo_path)
  local _39_, _40_, _41_ = nil, nil, nil
  do
    local _let_42_ = require("pact.async-await")
    local await_wrap_3_auto = _let_42_["await-wrap"]
    _39_, _40_, _41_ = await_wrap_3_auto(run, {"git", {"remote", "get-url", "origin"}, repo_path, const.ENV})
  end
  if ((_39_ == 0) and ((_G.type(_40_) == "table") and (nil ~= (_40_)[1])) and true) then
    local url = (_40_)[1]
    local _ = _41_
    return string.match(url, "([^\13\n]+)")
  elseif ((nil ~= _39_) and true and (nil ~= _41_)) then
    local code = _39_
    local _ = _40_
    local err = _41_
    return nil, dump_err(code, err)
  else
    return nil
  end
end
local function fetch_sha(repo_path, sha)
  local _44_, _45_, _46_ = nil, nil, nil
  do
    local _let_47_ = require("pact.async-await")
    local await_wrap_3_auto = _let_47_["await-wrap"]
    _44_, _45_, _46_ = await_wrap_3_auto(run, {"git", {"fetch", "--depth=1", "origin", sha}, repo_path, const.ENV})
  end
  if ((_44_ == 0) and true and true) then
    local _ = _45_
    local _0 = _46_
    return sha
  elseif ((nil ~= _44_) and true and (nil ~= _46_)) then
    local code = _44_
    local _ = _45_
    local err = _46_
    return nil, dump_err(code, err)
  else
    return nil
  end
end
local function fetch(repo_path)
  local _49_, _50_, _51_ = nil, nil, nil
  do
    local _let_52_ = require("pact.async-await")
    local await_wrap_3_auto = _let_52_["await-wrap"]
    _49_, _50_, _51_ = await_wrap_3_auto(run, {"git", {"fetch", "origin"}, repo_path, const.ENV})
  end
  if ((_49_ == 0) and true and true) then
    local _ = _50_
    local _0 = _51_
    return true
  elseif ((nil ~= _49_) and true and (nil ~= _51_)) then
    local code = _49_
    local _ = _50_
    local err = _51_
    return nil, dump_err(code, err)
  else
    return nil
  end
end
local function init(repo_path, inited)
  local _54_, _55_, _56_ = nil, nil, nil
  do
    local _let_57_ = require("pact.async-await")
    local await_wrap_3_auto = _let_57_["await-wrap"]
    _54_, _55_, _56_ = await_wrap_3_auto(run, {"git", {"init", repo_path}, ".", const.ENV})
  end
  if ((_54_ == 0) and true and true) then
    local _ = _55_
    local _0 = _56_
    return repo_path
  elseif ((nil ~= _54_) and true and (nil ~= _56_)) then
    local code = _54_
    local _ = _55_
    local err = _56_
    return nil, dump_err(code, err)
  else
    return nil
  end
end
local function checkout_sha(repo_path, sha)
  local _59_, _60_, _61_ = nil, nil, nil
  do
    local _let_62_ = require("pact.async-await")
    local await_wrap_3_auto = _let_62_["await-wrap"]
    _59_, _60_, _61_ = await_wrap_3_auto(run, {"git", {"checkout", sha}, repo_path, const.ENV})
  end
  if ((_59_ == 0) and true and true) then
    local _ = _60_
    local _0 = _61_
    return sha
  elseif ((nil ~= _59_) and true and (nil ~= _61_)) then
    local code = _59_
    local _ = _60_
    local err = _61_
    return nil, dump_err(code, err)
  else
    return nil
  end
end
local function shallow_3f(repo_path)
  local _64_, _65_, _66_ = nil, nil, nil
  do
    local _let_67_ = require("pact.async-await")
    local await_wrap_3_auto = _let_67_["await-wrap"]
    _64_, _65_, _66_ = await_wrap_3_auto(run, {"git", {"rev-parse", "--is-shallow-repository"}, repo_path, const.ENV})
  end
  if ((_64_ == 0) and ((_G.type(_65_) == "table") and ((_65_)[1] == "false")) and true) then
    local _ = _66_
    return false
  elseif ((_64_ == 0) and ((_G.type(_65_) == "table") and ((_65_)[1] == "true")) and true) then
    local _ = _66_
    return true
  elseif ((_64_ == 0) and (nil ~= _65_) and (nil ~= _66_)) then
    local a = _65_
    local b = _66_
    return nil, dump_err(0, {a, b})
  elseif ((nil ~= _64_) and true and (nil ~= _66_)) then
    local code = _64_
    local _ = _65_
    local err = _66_
    return nil, dump_err(code, err)
  else
    return nil
  end
end
local function unshallow(repo_path)
  local _69_, _70_, _71_ = nil, nil, nil
  do
    local _let_72_ = require("pact.async-await")
    local await_wrap_3_auto = _let_72_["await-wrap"]
    _69_, _70_, _71_ = await_wrap_3_auto(run, {"git", {"fetch", "--unshallow"}, repo_path, const.ENV})
  end
  if ((_69_ == 0) and (nil ~= _70_) and (nil ~= _71_)) then
    local a = _70_
    local b = _71_
    return true
  elseif ((nil ~= _69_) and true and (nil ~= _71_)) then
    local code = _69_
    local _ = _70_
    local err = _71_
    return nil, dump_err(code, err)
  else
    return nil
  end
end
local function log_diff(repo_path, old_sha, new_sha)
  local _74_, _75_, _76_ = nil, nil, nil
  do
    local _let_77_ = require("pact.async-await")
    local await_wrap_3_auto = _let_77_["await-wrap"]
    _74_, _75_, _76_ = await_wrap_3_auto(run, {"git", {"log", "--oneline", fmt("%s..%s", old_sha, new_sha)}, repo_path, const.ENV})
  end
  local function _78_()
    local log = _75_
    local _ = _76_
    return (0 == #log)
  end
  if (((_74_ == 0) and (nil ~= _75_) and true) and _78_()) then
    local log = _75_
    local _ = _76_
    return nil, "git log produced no output, are you moving backwards?"
  elseif ((_74_ == 0) and (nil ~= _75_) and true) then
    local log = _75_
    local _ = _76_
    return log
  elseif ((nil ~= _74_) and true and (nil ~= _76_)) then
    local code = _74_
    local _ = _75_
    local err = _76_
    return nil, dump_err(code, err)
  else
    return nil
  end
end
return {init = init, ["HEAD-sha"] = HEAD_sha, ["ls-remote"] = ls_remote, ["set-origin"] = set_origin, ["get-origin"] = get_origin, ["fetch-sha"] = fetch_sha, fetch = fetch, ["checkout-sha"] = checkout_sha, ["shallow?"] = shallow_3f, unshallow = unshallow, ["log-diff"] = log_diff}