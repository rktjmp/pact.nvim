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
local enum, _local_10_, _local_11_ = nil, nil, nil
do
  local _9_ = string
  local _8_ = require("pact.valid")
  local _7_ = require("pact.lib.ruin.enum")
  enum, _local_10_, _local_11_ = _7_, _8_, _9_
end
local _local_12_ = _local_10_
local valid_sha_3f = _local_12_["valid-sha?"]
local _local_13_ = _local_11_
local fmt = _local_13_["format"]
local __fn_2a_expand_version_dispatch = {bodies = {}, help = {}}
local expand_version
local function _17_(...)
  if (0 == #(__fn_2a_expand_version_dispatch).bodies) then
    error(("multi-arity function " .. "expand-version" .. " has no bodies"))
  else
  end
  local _19_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_expand_version_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _19_ = f_74_auto
  end
  if (nil ~= _19_) then
    local f_74_auto = _19_
    return f_74_auto(...)
  elseif (_19_ == nil) then
    local view_77_auto
    do
      local _20_, _21_ = pcall(require, "fennel")
      if ((_20_ == true) and ((_G.type(_21_) == "table") and (nil ~= (_21_).view))) then
        local view_77_auto0 = (_21_).view
        view_77_auto = view_77_auto0
      elseif ((_20_ == false) and true) then
        local __75_auto = _21_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "expand-version", view_77_auto({...}), table.concat((__fn_2a_expand_version_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
expand_version = _17_
local function _24_()
  local _25_
  do
    table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+)$\"))")
    local function _26_(...)
      if (1 == select("#", ...)) then
        local _27_ = {...}
        local function _28_(...)
          local v_14_ = (_27_)[1]
          return string.match(v_14_, "^(%d+)$")
        end
        if (((_G.type(_27_) == "table") and (nil ~= (_27_)[1])) and _28_(...)) then
          local v_14_ = (_27_)[1]
          local function _29_(v)
            return (v .. ".0.0")
          end
          return _29_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_expand_version_dispatch).bodies, _26_)
    _25_ = expand_version
  end
  local _32_
  do
    table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+%.%d+)$\"))")
    local function _33_(...)
      if (1 == select("#", ...)) then
        local _34_ = {...}
        local function _35_(...)
          local v_15_ = (_34_)[1]
          return string.match(v_15_, "^(%d+%.%d+)$")
        end
        if (((_G.type(_34_) == "table") and (nil ~= (_34_)[1])) and _35_(...)) then
          local v_15_ = (_34_)[1]
          local function _36_(v)
            return (v .. ".0")
          end
          return _36_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_expand_version_dispatch).bodies, _33_)
    _32_ = expand_version
  end
  local _39_
  do
    table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+%.%d+%.%d+)$\"))")
    local function _40_(...)
      if (1 == select("#", ...)) then
        local _41_ = {...}
        local function _42_(...)
          local v_16_ = (_41_)[1]
          return string.match(v_16_, "^(%d+%.%d+%.%d+)$")
        end
        if (((_G.type(_41_) == "table") and (nil ~= (_41_)[1])) and _42_(...)) then
          local v_16_ = (_41_)[1]
          local function _43_(v)
            return v
          end
          return _43_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_expand_version_dispatch).bodies, _40_)
    _39_ = expand_version
  end
  local function _46_()
    table.insert((__fn_2a_expand_version_dispatch).help, "(where _)")
    local function _47_(...)
      if true then
        local _48_ = {...}
        local function _49_(...)
          return true
        end
        if ((_G.type(_48_) == "table") and _49_(...)) then
          local function _50_(...)
            return nil
          end
          return _50_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_expand_version_dispatch).bodies, _47_)
    return expand_version
  end
  do local _ = {_25_, _32_, _39_, _46_()} end
  return expand_version
end
setmetatable({nil, nil}, {__call = _24_})()
local __fn_2a_commit_dispatch = {bodies = {}, help = {}}
local commit
local function _58_(...)
  if (0 == #(__fn_2a_commit_dispatch).bodies) then
    error(("multi-arity function " .. "commit" .. " has no bodies"))
  else
  end
  local _60_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_commit_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _60_ = f_74_auto
  end
  if (nil ~= _60_) then
    local f_74_auto = _60_
    return f_74_auto(...)
  elseif (_60_ == nil) then
    local view_77_auto
    do
      local _61_, _62_ = pcall(require, "fennel")
      if ((_61_ == true) and ((_G.type(_62_) == "table") and (nil ~= (_62_).view))) then
        local view_77_auto0 = (_62_).view
        view_77_auto = view_77_auto0
      elseif ((_61_ == false) and true) then
        local __75_auto = _62_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "commit", view_77_auto({...}), table.concat((__fn_2a_commit_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
commit = _58_
local function _65_()
  local _66_
  do
    table.insert((__fn_2a_commit_dispatch).help, "(where [sha] (valid-sha? sha))")
    local function _67_(...)
      if (1 == select("#", ...)) then
        local _68_ = {...}
        local function _69_(...)
          local sha_53_ = (_68_)[1]
          return valid_sha_3f(sha_53_)
        end
        if (((_G.type(_68_) == "table") and (nil ~= (_68_)[1])) and _69_(...)) then
          local sha_53_ = (_68_)[1]
          local function _70_(sha)
            return commit(sha, {})
          end
          return _70_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_commit_dispatch).bodies, _67_)
    _66_ = commit
  end
  local _73_
  do
    table.insert((__fn_2a_commit_dispatch).help, "(where [sha {:branch ?branch :tag ?tag :version ?version}] (and (valid-sha? sha) (string? (or ?tag \"\")) (string? (or ?branch \"\")) (string? (or ?version \"\"))))")
    local function _74_(...)
      if (2 == select("#", ...)) then
        local _75_ = {...}
        local function _76_(...)
          local sha_54_ = (_75_)[1]
          local _3ftag_56_ = ((_75_)[2]).tag
          local _3fbranch_57_ = ((_75_)[2]).branch
          local _3fversion_55_ = ((_75_)[2]).version
          return (valid_sha_3f(sha_54_) and string_3f((_3ftag_56_ or "")) and string_3f((_3fbranch_57_ or "")) and string_3f((_3fversion_55_ or "")))
        end
        if (((_G.type(_75_) == "table") and (nil ~= (_75_)[1]) and ((_G.type((_75_)[2]) == "table") and true and true and true)) and _76_(...)) then
          local sha_54_ = (_75_)[1]
          local _3ftag_56_ = ((_75_)[2]).tag
          local _3fbranch_57_ = ((_75_)[2]).branch
          local _3fversion_55_ = ((_75_)[2]).version
          local function _79_(sha, _77_)
            local _arg_78_ = _77_
            local _3ftag = _arg_78_["tag"]
            local _3fbranch = _arg_78_["branch"]
            local _3fversion = _arg_78_["version"]
            local function _80_(_241)
              return fmt("%s@%s", (_241.version or _241.branch or _241.tag or "commit"), string.sub(_241.sha, 1, 8))
            end
            return setmetatable({sha = sha, branch = _3fbranch, tag = _3ftag, version = expand_version(_3fversion)}, {__tostring = _80_})
          end
          return _79_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_commit_dispatch).bodies, _74_)
    _73_ = commit
  end
  local function _83_()
    table.insert((__fn_2a_commit_dispatch).help, "(where _)")
    local function _84_(...)
      if true then
        local _85_ = {...}
        local function _86_(...)
          return true
        end
        if ((_G.type(_85_) == "table") and _86_(...)) then
          local function _87_(...)
            return nil, "commit requires a valid sha and optional table of tag, branch or version"
          end
          return _87_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_commit_dispatch).bodies, _84_)
    return commit
  end
  do local _ = {_66_, _73_, _83_()} end
  return commit
end
setmetatable({nil, nil}, {__call = _65_})()
local function ref_line__3ecommit(ref)
  local function strip_peel(tag_name)
    return (string.match(tag_name, "(.+)%^{}$") or tag_name)
  end
  local _90_, _91_, _92_ = string.match(ref, "(%x+)%s+refs/(.-)/(.+)")
  if ((nil ~= _90_) and (_91_ == "heads") and (nil ~= _92_)) then
    local sha = _90_
    local name = _92_
    return commit(sha, {branch = name})
  elseif ((nil ~= _90_) and (_91_ == "tags") and (nil ~= _92_)) then
    local sha = _90_
    local name = _92_
    local _93_ = string.match(name, "v?(%d+%.%d+%.%d+)")
    if (_93_ == nil) then
      return commit(sha, {tag = strip_peel(name)})
    elseif (nil ~= _93_) then
      local version = _93_
      return commit(sha, {tag = strip_peel(name), version = version})
    else
      return nil
    end
  elseif (nil ~= _90_) then
    local other = _90_
    return error(string.format("unexpected remote-ref format: %s", other))
  else
    return nil
  end
end
local function ref_lines__3ecommits(refs)
  local function _96_(acc, group_name, commits)
    local _97_ = {group_name, #commits}
    if ((_G.type(_97_) == "table") and ((_97_)[1] == false) and true) then
      local _ = (_97_)[2]
      local function _98_(_241, _242)
        return _242.commit
      end
      return enum["concat$"](acc, enum.map(_98_, commits))
    elseif ((_G.type(_97_) == "table") and (nil ~= (_97_)[1]) and ((_97_)[2] == 1)) then
      local version = (_97_)[1]
      return enum["append$"](acc, commits[1].commit)
    elseif ((_G.type(_97_) == "table") and (nil ~= (_97_)[1]) and (nil ~= (_97_)[2])) then
      local version = (_97_)[1]
      local n = (_97_)[2]
      local function _99_(_241, _242)
        return _242.commit
      end
      local function _100_(_241, _242)
        return _242["peeled?"]
      end
      return enum["concat$"](acc, enum.map(_99_, enum.filter(_100_, commits)))
    else
      return nil
    end
  end
  local function _102_(_241, _242)
    return (_242.commit.tag or false)
  end
  local function _103_(_241, _242)
    local commit0 = ref_line__3ecommit(_242)
    local peeled_3f = not_nil_3f(string.match(_242, "%^{}$"))
    return {["peeled?"] = peeled_3f, commit = commit0}
  end
  return enum.reduce(_96_, {}, enum["group-by"](_102_, enum.map(_103_, refs)))
end
return {commit = commit, ["ref-lines->commits"] = ref_lines__3ecommits}