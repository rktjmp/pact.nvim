local _local_6_, enum, _local_7_, _local_8_, _local_9_ = nil, nil, nil, nil, nil
do
  local _5_ = require("pact.plugin.constraint")
  local _4_ = require("pact.valid")
  local _3_ = string
  local _2_ = require("pact.lib.ruin.enum")
  local _1_ = require("pact.lib.ruin.type")
  _local_6_, enum, _local_7_, _local_8_, _local_9_ = _1_, _2_, _3_, _4_, _5_
end
local _local_10_ = _local_6_
local string_3f = _local_10_["string?"]
local table_3f = _local_10_["table?"]
local _local_11_ = _local_7_
local fmt = _local_11_["format"]
local _local_12_ = _local_8_
local valid_sha_3f = _local_12_["valid-sha?"]
local valid_version_spec_3f = _local_12_["valid-version-spec?"]
local _local_13_ = _local_9_
local git_constraint = _local_13_["git"]
do local _ = {nil, nil, nil} end
local function make_provider(url)
  return {"git", url}
end
local function decorate_tostring(t, name, short)
  local function _14_()
    return fmt("%s/%s", name, short)
  end
  return setmetatable(t, {__tostring = _14_})
end
local __fn_2a_url_ok_3f_dispatch = {bodies = {}, help = {}}
local url_ok_3f
local function _16_(...)
  if (0 == #(__fn_2a_url_ok_3f_dispatch).bodies) then
    error(("multi-arity function " .. "url-ok?" .. " has no bodies"))
  else
  end
  local _18_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_url_ok_3f_dispatch).bodies) do
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
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "url-ok?", view_77_auto({...}), table.concat((__fn_2a_url_ok_3f_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
url_ok_3f = _16_
local function _23_()
  local _24_
  do
    table.insert((__fn_2a_url_ok_3f_dispatch).help, "(where [url] (string? url))")
    local function _25_(...)
      if (1 == select("#", ...)) then
        local _26_ = {...}
        local function _27_(...)
          local url_15_ = (_26_)[1]
          return string_3f(url_15_)
        end
        if (((_G.type(_26_) == "table") and (nil ~= (_26_)[1])) and _27_(...)) then
          local url_15_ = (_26_)[1]
          local function _28_(url)
            if ((string.match(url, "^https?:") or string.match(url, "^ssh:")) and string.match(url, ".+://.+%..+")) then
              return true
            else
              return nil, fmt("expected https or ssh url, got %s", url)
            end
          end
          return _28_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_url_ok_3f_dispatch).bodies, _25_)
    _24_ = url_ok_3f
  end
  local function _32_()
    table.insert((__fn_2a_url_ok_3f_dispatch).help, "(where _)")
    local function _33_(...)
      if true then
        local _34_ = {...}
        local function _35_(...)
          return true
        end
        if ((_G.type(_34_) == "table") and _35_(...)) then
          local function _36_(...)
            return nil, "expected https or ssh url string"
          end
          return _36_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_url_ok_3f_dispatch).bodies, _33_)
    return url_ok_3f
  end
  do local _ = {_24_, _32_()} end
  return url_ok_3f
end
setmetatable({nil, nil}, {__call = _23_})()
local __fn_2a_user_repo_ok_3f_dispatch = {bodies = {}, help = {}}
local user_repo_ok_3f
local function _40_(...)
  if (0 == #(__fn_2a_user_repo_ok_3f_dispatch).bodies) then
    error(("multi-arity function " .. "user-repo-ok?" .. " has no bodies"))
  else
  end
  local _42_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_user_repo_ok_3f_dispatch).bodies) do
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
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "user-repo-ok?", view_77_auto({...}), table.concat((__fn_2a_user_repo_ok_3f_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
user_repo_ok_3f = _40_
local function _47_()
  local _48_
  do
    table.insert((__fn_2a_user_repo_ok_3f_dispatch).help, "(where [user-repo] (and (string? user-repo) (string.match user-repo \"^[^/]+/[^/]+$\")))")
    local function _49_(...)
      if (1 == select("#", ...)) then
        local _50_ = {...}
        local function _51_(...)
          local user_repo_39_ = (_50_)[1]
          return (string_3f(user_repo_39_) and string.match(user_repo_39_, "^[^/]+/[^/]+$"))
        end
        if (((_G.type(_50_) == "table") and (nil ~= (_50_)[1])) and _51_(...)) then
          local user_repo_39_ = (_50_)[1]
          local function _52_(user_repo)
            return true
          end
          return _52_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_user_repo_ok_3f_dispatch).bodies, _49_)
    _48_ = user_repo_ok_3f
  end
  local function _55_()
    table.insert((__fn_2a_user_repo_ok_3f_dispatch).help, "(where _)")
    local function _56_(...)
      if true then
        local _57_ = {...}
        local function _58_(...)
          return true
        end
        if ((_G.type(_57_) == "table") and _58_(...)) then
          local function _59_(...)
            return nil, "expected user-name/repo-name"
          end
          return _59_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_user_repo_ok_3f_dispatch).bodies, _56_)
    return user_repo_ok_3f
  end
  do local _ = {_48_, _55_()} end
  return user_repo_ok_3f
end
setmetatable({nil, nil}, {__call = _47_})()
local function git(url)
  local else_fn_62_
  local function _63_(...)
    return ...
  end
  else_fn_62_ = _63_
  local function down_18_auto(...)
    local _64_ = ...
    if (_64_ == true) then
      return decorate_tostring(make_provider(url), "git", url)
    elseif true then
      local _ = _64_
      return else_fn_62_(...)
    else
      return nil
    end
  end
  return down_18_auto(url_ok_3f(url))
end
local function github(user_repo)
  local else_fn_66_
  local function _67_(...)
    return ...
  end
  else_fn_66_ = _67_
  local function down_18_auto(...)
    local _68_ = ...
    if (_68_ == true) then
      return decorate_tostring(git(("https://github.com/" .. user_repo)), "github", user_repo)
    elseif true then
      local _ = _68_
      return else_fn_66_(...)
    else
      return nil
    end
  end
  return down_18_auto(user_repo_ok_3f(user_repo))
end
local function gitlab(user_repo)
  local else_fn_70_
  local function _71_(...)
    return ...
  end
  else_fn_70_ = _71_
  local function down_18_auto(...)
    local _72_ = ...
    if (_72_ == true) then
      return decorate_tostring(git(("https://gitlab.com/" .. user_repo)), "gitlab", user_repo)
    elseif true then
      local _ = _72_
      return else_fn_70_(...)
    else
      return nil
    end
  end
  return down_18_auto(user_repo_ok_3f(user_repo))
end
local function sourcehut(user_repo)
  local else_fn_74_
  local function _75_(...)
    return ...
  end
  else_fn_74_ = _75_
  local function down_18_auto(...)
    local _76_ = ...
    if (_76_ == true) then
      return decorate_tostring(git(("https://git.sr.ht.com/~" .. user_repo)), "sourcehut", user_repo)
    elseif true then
      local _ = _76_
      return else_fn_74_(...)
    else
      return nil
    end
  end
  return down_18_auto(user_repo_ok_3f(user_repo))
end
return {github = github, gitlab = gitlab, sourcehut = sourcehut, srht = sourcehut, git = git}