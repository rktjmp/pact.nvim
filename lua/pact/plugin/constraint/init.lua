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
local _local_12_, enum, _, _local_13_, _local_14_ = nil, nil, nil, nil, nil
do
  local _11_ = require("pact.valid")
  local _10_ = string
  local _9_ = require("pact.plugin.constraint.version")
  local _8_ = require("pact.lib.ruin.enum")
  local _7_ = require("pact.lib.ruin.type")
  _local_12_, enum, _, _local_13_, _local_14_ = _7_, _8_, _9_, _10_, _11_
end
local _local_15_ = _local_12_
local string_3f0 = _local_15_["string?"]
local table_3f0 = _local_15_["table?"]
local _local_16_ = _local_13_
local fmt = _local_16_["format"]
local _local_17_ = _local_14_
local valid_sha_3f = _local_17_["valid-sha?"]
local valid_version_spec_3f = _local_17_["valid-version-spec?"]
do local _ = {nil, nil} end
local function one_of_3f(coll, test)
  local function _18_(_241, _242)
    return (_242 == test)
  end
  return enum["any?"](_18_, coll)
end
local function set_tostring(t)
  local function _21_(_19_)
    local _arg_20_ = _19_
    local _0 = _arg_20_[1]
    local kind = _arg_20_[2]
    local spec = _arg_20_[3]
    return (kind .. "#" .. string.gsub(spec, "%s", ""))
  end
  return setmetatable(t, {__tostring = _21_})
end
local __fn_2a_git_3f_dispatch = {bodies = {}, help = {}}
local git_3f
local function _24_(...)
  if (0 == #(__fn_2a_git_3f_dispatch).bodies) then
    error(("multi-arity function " .. "git?" .. " has no bodies"))
  else
  end
  local _26_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_git_3f_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _26_ = f_74_auto
  end
  if (nil ~= _26_) then
    local f_74_auto = _26_
    return f_74_auto(...)
  elseif (_26_ == nil) then
    local view_77_auto
    do
      local _27_, _28_ = pcall(require, "fennel")
      if ((_27_ == true) and ((_G.type(_28_) == "table") and (nil ~= (_28_).view))) then
        local view_77_auto0 = (_28_).view
        view_77_auto = view_77_auto0
      elseif ((_27_ == false) and true) then
        local __75_auto = _28_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "git?", view_77_auto({...}), table.concat((__fn_2a_git_3f_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
git_3f = _24_
local function _31_()
  local _32_
  do
    table.insert((__fn_2a_git_3f_dispatch).help, "(where [[\"git\" kind spec]] (and (one-of? [\"commit\" \"branch\" \"tag\" \"version\"] kind) (string? spec)))")
    local function _33_(...)
      if (1 == select("#", ...)) then
        local _34_ = {...}
        local function _35_(...)
          local kind_22_ = ((_34_)[1])[2]
          local spec_23_ = ((_34_)[1])[3]
          return (one_of_3f({"commit", "branch", "tag", "version"}, kind_22_) and string_3f0(spec_23_))
        end
        if (((_G.type(_34_) == "table") and ((_G.type((_34_)[1]) == "table") and (((_34_)[1])[1] == "git") and (nil ~= ((_34_)[1])[2]) and (nil ~= ((_34_)[1])[3]))) and _35_(...)) then
          local kind_22_ = ((_34_)[1])[2]
          local spec_23_ = ((_34_)[1])[3]
          local function _38_(_36_)
            local _arg_37_ = _36_
            local _0 = _arg_37_[1]
            local kind = _arg_37_[2]
            local spec = _arg_37_[3]
            return true
          end
          return _38_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_git_3f_dispatch).bodies, _33_)
    _32_ = git_3f
  end
  local function _41_()
    table.insert((__fn_2a_git_3f_dispatch).help, "(where _)")
    local function _42_(...)
      if true then
        local _43_ = {...}
        local function _44_(...)
          return true
        end
        if ((_G.type(_43_) == "table") and _44_(...)) then
          local function _45_(...)
            return false
          end
          return _45_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_git_3f_dispatch).bodies, _42_)
    return git_3f
  end
  do local _ = {_32_, _41_()} end
  return git_3f
end
setmetatable({nil, nil}, {__call = _31_})()
local __fn_2a_git_dispatch = {bodies = {}, help = {}}
local git
local function _48_(...)
  if (0 == #(__fn_2a_git_dispatch).bodies) then
    error(("multi-arity function " .. "git" .. " has no bodies"))
  else
  end
  local _50_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_git_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _50_ = f_74_auto
  end
  if (nil ~= _50_) then
    local f_74_auto = _50_
    return f_74_auto(...)
  elseif (_50_ == nil) then
    local view_77_auto
    do
      local _51_, _52_ = pcall(require, "fennel")
      if ((_51_ == true) and ((_G.type(_52_) == "table") and (nil ~= (_52_).view))) then
        local view_77_auto0 = (_52_).view
        view_77_auto = view_77_auto0
      elseif ((_51_ == false) and true) then
        local __75_auto = _52_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "git", view_77_auto({...}), table.concat((__fn_2a_git_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
git = _48_
local function _55_()
  do local _ = {} end
  return git
end
setmetatable({nil, nil}, {__call = _55_})()
do
  table.insert((__fn_2a_git_dispatch).help, "(where [\"version\" ver])")
  local function _57_(...)
    if (2 == select("#", ...)) then
      local _58_ = {...}
      local function _59_(...)
        local ver_56_ = (_58_)[2]
        return true
      end
      if (((_G.type(_58_) == "table") and ((_58_)[1] == "version") and (nil ~= (_58_)[2])) and _59_(...)) then
        local ver_56_ = (_58_)[2]
        local function _60_(_0, ver)
          local _61_ = valid_version_spec_3f(ver)
          if (_61_ == true) then
            return set_tostring({"git", "version", ver})
          elseif (_61_ == false) then
            return nil, "invalid version spec for version constraint"
          else
            return nil
          end
        end
        return _60_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_git_dispatch).bodies, _57_)
end
do
  table.insert((__fn_2a_git_dispatch).help, "(where [\"commit\" sha])")
  local function _66_(...)
    if (2 == select("#", ...)) then
      local _67_ = {...}
      local function _68_(...)
        local sha_65_ = (_67_)[2]
        return true
      end
      if (((_G.type(_67_) == "table") and ((_67_)[1] == "commit") and (nil ~= (_67_)[2])) and _68_(...)) then
        local sha_65_ = (_67_)[2]
        local function _69_(_0, sha)
          local _70_ = valid_sha_3f(sha)
          if (_70_ == true) then
            return set_tostring({"git", "commit", sha})
          elseif (_70_ == false) then
            return nil, "invalid sha for commit constraint"
          else
            return nil
          end
        end
        return _69_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_git_dispatch).bodies, _66_)
end
do
  table.insert((__fn_2a_git_dispatch).help, "(where [kind spec])")
  local function _76_(...)
    if (2 == select("#", ...)) then
      local _77_ = {...}
      local function _78_(...)
        local kind_74_ = (_77_)[1]
        local spec_75_ = (_77_)[2]
        return true
      end
      if (((_G.type(_77_) == "table") and (nil ~= (_77_)[1]) and (nil ~= (_77_)[2])) and _78_(...)) then
        local kind_74_ = (_77_)[1]
        local spec_75_ = (_77_)[2]
        local function _79_(kind, spec)
          one_of_3f({"branch", "tag"}, kind)
          local _80_ = string_3f0(spec)
          if (_80_ == true) then
            return set_tostring({"git", kind, spec})
          elseif (_80_ == false) then
            return nil, fmt("invalid spec for %s constraint, must be string", kind)
          else
            return nil
          end
        end
        return _79_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_git_dispatch).bodies, _76_)
end
do
  table.insert((__fn_2a_git_dispatch).help, "(where [...])")
  local function _84_(...)
    if (0 <= select("#", ...)) then
      local _85_ = {...}
      local function _86_(...)
        return true
      end
      if ((_G.type(_85_) == "table") and _86_(...)) then
        local function _87_(...)
          return nil, "must provide `commit|branch|tag|version` and appropriate value", ...
        end
        return _87_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_git_dispatch).bodies, _84_)
end
local __fn_2a_satisfies_3f_dispatch = {bodies = {}, help = {}}
local satisfies_3f
local function _101_(...)
  if (0 == #(__fn_2a_satisfies_3f_dispatch).bodies) then
    error(("multi-arity function " .. "satisfies?" .. " has no bodies"))
  else
  end
  local _103_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_satisfies_3f_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _103_ = f_74_auto
  end
  if (nil ~= _103_) then
    local f_74_auto = _103_
    return f_74_auto(...)
  elseif (_103_ == nil) then
    local view_77_auto
    do
      local _104_, _105_ = pcall(require, "fennel")
      if ((_104_ == true) and ((_G.type(_105_) == "table") and (nil ~= (_105_).view))) then
        local view_77_auto0 = (_105_).view
        view_77_auto = view_77_auto0
      elseif ((_104_ == false) and true) then
        local __75_auto = _105_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "satisfies?", view_77_auto({...}), table.concat((__fn_2a_satisfies_3f_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
satisfies_3f = _101_
local function _108_()
  local _109_
  do
    table.insert((__fn_2a_satisfies_3f_dispatch).help, "(where [[\"git\" \"commit\" sha] {:sha sha}])")
    local function _110_(...)
      if (2 == select("#", ...)) then
        local _111_ = {...}
        local function _112_(...)
          local sha_91_ = ((_111_)[1])[3]
          return true
        end
        if (((_G.type(_111_) == "table") and ((_G.type((_111_)[1]) == "table") and (((_111_)[1])[1] == "git") and (((_111_)[1])[2] == "commit") and (nil ~= ((_111_)[1])[3])) and ((_G.type((_111_)[2]) == "table") and (((_111_)[1])[3] == ((_111_)[2]).sha))) and _112_(...)) then
          local sha_91_ = ((_111_)[1])[3]
          local function _117_(_113_, _115_)
            local _arg_114_ = _113_
            local _0 = _arg_114_[1]
            local _1 = _arg_114_[2]
            local sha = _arg_114_[3]
            local _arg_116_ = _115_
            local sha0 = _arg_116_["sha"]
            return true
          end
          return _117_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_satisfies_3f_dispatch).bodies, _110_)
    _109_ = satisfies_3f
  end
  local _120_
  do
    table.insert((__fn_2a_satisfies_3f_dispatch).help, "(where [[\"git\" \"tag\" tag] {:tag tag}])")
    local function _121_(...)
      if (2 == select("#", ...)) then
        local _122_ = {...}
        local function _123_(...)
          local tag_93_ = ((_122_)[1])[3]
          return true
        end
        if (((_G.type(_122_) == "table") and ((_G.type((_122_)[1]) == "table") and (((_122_)[1])[1] == "git") and (((_122_)[1])[2] == "tag") and (nil ~= ((_122_)[1])[3])) and ((_G.type((_122_)[2]) == "table") and (((_122_)[1])[3] == ((_122_)[2]).tag))) and _123_(...)) then
          local tag_93_ = ((_122_)[1])[3]
          local function _128_(_124_, _126_)
            local _arg_125_ = _124_
            local _0 = _arg_125_[1]
            local _1 = _arg_125_[2]
            local tag = _arg_125_[3]
            local _arg_127_ = _126_
            local tag0 = _arg_127_["tag"]
            return true
          end
          return _128_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_satisfies_3f_dispatch).bodies, _121_)
    _120_ = satisfies_3f
  end
  local _131_
  do
    table.insert((__fn_2a_satisfies_3f_dispatch).help, "(where [[\"git\" \"branch\" branch] {:branch branch}])")
    local function _132_(...)
      if (2 == select("#", ...)) then
        local _133_ = {...}
        local function _134_(...)
          local branch_95_ = ((_133_)[1])[3]
          return true
        end
        if (((_G.type(_133_) == "table") and ((_G.type((_133_)[1]) == "table") and (((_133_)[1])[1] == "git") and (((_133_)[1])[2] == "branch") and (nil ~= ((_133_)[1])[3])) and ((_G.type((_133_)[2]) == "table") and (((_133_)[1])[3] == ((_133_)[2]).branch))) and _134_(...)) then
          local branch_95_ = ((_133_)[1])[3]
          local function _139_(_135_, _137_)
            local _arg_136_ = _135_
            local _0 = _arg_136_[1]
            local _1 = _arg_136_[2]
            local branch = _arg_136_[3]
            local _arg_138_ = _137_
            local branch0 = _arg_138_["branch"]
            return true
          end
          return _139_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_satisfies_3f_dispatch).bodies, _132_)
    _131_ = satisfies_3f
  end
  local _142_
  do
    table.insert((__fn_2a_satisfies_3f_dispatch).help, "(where [[\"git\" \"version\" version-spec] {:version version}])")
    local function _143_(...)
      if (2 == select("#", ...)) then
        local _144_ = {...}
        local function _145_(...)
          local version_spec_96_ = ((_144_)[1])[3]
          local version_97_ = ((_144_)[2]).version
          return true
        end
        if (((_G.type(_144_) == "table") and ((_G.type((_144_)[1]) == "table") and (((_144_)[1])[1] == "git") and (((_144_)[1])[2] == "version") and (nil ~= ((_144_)[1])[3])) and ((_G.type((_144_)[2]) == "table") and (nil ~= ((_144_)[2]).version))) and _145_(...)) then
          local version_spec_96_ = ((_144_)[1])[3]
          local version_97_ = ((_144_)[2]).version
          local function _150_(_146_, _148_)
            local _arg_147_ = _146_
            local _0 = _arg_147_[1]
            local _1 = _arg_147_[2]
            local version_spec = _arg_147_[3]
            local _arg_149_ = _148_
            local version = _arg_149_["version"]
            local _let_151_ = require("pact.plugin.constraint.version")
            local satisfies_3f0 = _let_151_["satisfies?"]
            return satisfies_3f0(version_spec, version)
          end
          return _150_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_satisfies_3f_dispatch).bodies, _143_)
    _142_ = satisfies_3f
  end
  local _154_
  do
    table.insert((__fn_2a_satisfies_3f_dispatch).help, "(where [[\"git\" _ _] {:sha sha}])")
    local function _155_(...)
      if (2 == select("#", ...)) then
        local _156_ = {...}
        local function _157_(...)
          local __99_ = ((_156_)[1])[2]
          local __99_ = ((_156_)[1])[3]
          local sha_100_ = ((_156_)[2]).sha
          return true
        end
        if (((_G.type(_156_) == "table") and ((_G.type((_156_)[1]) == "table") and (((_156_)[1])[1] == "git") and true and true) and ((_G.type((_156_)[2]) == "table") and (nil ~= ((_156_)[2]).sha))) and _157_(...)) then
          local __99_ = ((_156_)[1])[2]
          local __99_ = ((_156_)[1])[3]
          local sha_100_ = ((_156_)[2]).sha
          local function _162_(_158_, _160_)
            local _arg_159_ = _158_
            local _0 = _arg_159_[1]
            local _1 = _arg_159_[2]
            local _2 = _arg_159_[3]
            local _arg_161_ = _160_
            local sha = _arg_161_["sha"]
            return false
          end
          return _162_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_satisfies_3f_dispatch).bodies, _155_)
    _154_ = satisfies_3f
  end
  local function _165_()
    table.insert((__fn_2a_satisfies_3f_dispatch).help, "(where _)")
    local function _166_(...)
      if true then
        local _167_ = {...}
        local function _168_(...)
          return true
        end
        if ((_G.type(_167_) == "table") and _168_(...)) then
          local function _169_(...)
            return error("satisfies? requires constraint and commit")
          end
          return _169_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_satisfies_3f_dispatch).bodies, _166_)
    return satisfies_3f
  end
  do local _ = {_109_, _120_, _131_, _142_, _154_, _165_()} end
  return satisfies_3f
end
setmetatable({nil, nil}, {__call = _108_})()
local __fn_2a_solve_dispatch = {bodies = {}, help = {}}
local solve
local function _172_(...)
  if (0 == #(__fn_2a_solve_dispatch).bodies) then
    error(("multi-arity function " .. "solve" .. " has no bodies"))
  else
  end
  local _174_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_solve_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _174_ = f_74_auto
  end
  if (nil ~= _174_) then
    local f_74_auto = _174_
    return f_74_auto(...)
  elseif (_174_ == nil) then
    local view_77_auto
    do
      local _175_, _176_ = pcall(require, "fennel")
      if ((_175_ == true) and ((_G.type(_176_) == "table") and (nil ~= (_176_).view))) then
        local view_77_auto0 = (_176_).view
        view_77_auto = view_77_auto0
      elseif ((_175_ == false) and true) then
        local __75_auto = _176_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "solve", view_77_auto({...}), table.concat((__fn_2a_solve_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
solve = _172_
local function _179_()
  do local _ = {} end
  return solve
end
setmetatable({nil, nil}, {__call = _179_})()
do
  table.insert((__fn_2a_solve_dispatch).help, "(where [[\"git\" \"commit\" sha] commits] (seq? commits))")
  local function _182_(...)
    if (2 == select("#", ...)) then
      local _183_ = {...}
      local function _184_(...)
        local sha_180_ = ((_183_)[1])[3]
        local commits_181_ = (_183_)[2]
        return seq_3f(commits_181_)
      end
      if (((_G.type(_183_) == "table") and ((_G.type((_183_)[1]) == "table") and (((_183_)[1])[1] == "git") and (((_183_)[1])[2] == "commit") and (nil ~= ((_183_)[1])[3])) and (nil ~= (_183_)[2])) and _184_(...)) then
        local sha_180_ = ((_183_)[1])[3]
        local commits_181_ = (_183_)[2]
        local function _187_(_185_, commits)
          local _arg_186_ = _185_
          local _0 = _arg_186_[1]
          local _1 = _arg_186_[2]
          local sha = _arg_186_[3]
          local function _188_(_241, _242)
            return (sha == _242.sha)
          end
          return enum["find-value"](_188_, commits)
        end
        return _187_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_solve_dispatch).bodies, _182_)
end
do
  table.insert((__fn_2a_solve_dispatch).help, "(where [[\"git\" \"tag\" tag] commits] (seq? commits))")
  local function _193_(...)
    if (2 == select("#", ...)) then
      local _194_ = {...}
      local function _195_(...)
        local tag_191_ = ((_194_)[1])[3]
        local commits_192_ = (_194_)[2]
        return seq_3f(commits_192_)
      end
      if (((_G.type(_194_) == "table") and ((_G.type((_194_)[1]) == "table") and (((_194_)[1])[1] == "git") and (((_194_)[1])[2] == "tag") and (nil ~= ((_194_)[1])[3])) and (nil ~= (_194_)[2])) and _195_(...)) then
        local tag_191_ = ((_194_)[1])[3]
        local commits_192_ = (_194_)[2]
        local function _198_(_196_, commits)
          local _arg_197_ = _196_
          local _0 = _arg_197_[1]
          local _1 = _arg_197_[2]
          local tag = _arg_197_[3]
          local function _199_(_241, _242)
            return (tag == _242.tag)
          end
          return enum["find-value"](_199_, commits)
        end
        return _198_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_solve_dispatch).bodies, _193_)
end
do
  table.insert((__fn_2a_solve_dispatch).help, "(where [[\"git\" \"branch\" branch] commits] (seq? commits))")
  local function _204_(...)
    if (2 == select("#", ...)) then
      local _205_ = {...}
      local function _206_(...)
        local branch_202_ = ((_205_)[1])[3]
        local commits_203_ = (_205_)[2]
        return seq_3f(commits_203_)
      end
      if (((_G.type(_205_) == "table") and ((_G.type((_205_)[1]) == "table") and (((_205_)[1])[1] == "git") and (((_205_)[1])[2] == "branch") and (nil ~= ((_205_)[1])[3])) and (nil ~= (_205_)[2])) and _206_(...)) then
        local branch_202_ = ((_205_)[1])[3]
        local commits_203_ = (_205_)[2]
        local function _209_(_207_, commits)
          local _arg_208_ = _207_
          local _0 = _arg_208_[1]
          local _1 = _arg_208_[2]
          local branch = _arg_208_[3]
          local function _210_(_241, _242)
            return (branch == _242.branch)
          end
          return enum["find-value"](_210_, commits)
        end
        return _209_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_solve_dispatch).bodies, _204_)
end
do
  table.insert((__fn_2a_solve_dispatch).help, "(where [[\"git\" \"version\" version] commits] (seq? commits))")
  local function _215_(...)
    if (2 == select("#", ...)) then
      local _216_ = {...}
      local function _217_(...)
        local version_213_ = ((_216_)[1])[3]
        local commits_214_ = (_216_)[2]
        return seq_3f(commits_214_)
      end
      if (((_G.type(_216_) == "table") and ((_G.type((_216_)[1]) == "table") and (((_216_)[1])[1] == "git") and (((_216_)[1])[2] == "version") and (nil ~= ((_216_)[1])[3])) and (nil ~= (_216_)[2])) and _217_(...)) then
        local version_213_ = ((_216_)[1])[3]
        local commits_214_ = (_216_)[2]
        local function _220_(_218_, commits)
          local _arg_219_ = _218_
          local _0 = _arg_219_[1]
          local _1 = _arg_219_[2]
          local version = _arg_219_[3]
          local _let_221_ = require("pact.plugin.constraint.version")
          local solve0 = _let_221_["solve"]
          local possible_versions
          local function _222_(_241, _242)
            return _242.version
          end
          possible_versions = enum.map(_222_, commits)
          local best_version = enum.first(solve0(version, possible_versions))
          if best_version then
            local function _223_(_241, _242)
              return (best_version == _242.version)
            end
            return enum["find-value"](_223_, commits)
          else
            return nil
          end
        end
        return _220_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_solve_dispatch).bodies, _215_)
end
return {git = git, ["git?"] = git_3f, ["satisfies?"] = satisfies_3f, solve = solve}