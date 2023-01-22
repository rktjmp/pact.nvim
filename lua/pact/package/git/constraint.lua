
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, _local_10_, _local_11_ = nil, nil, nil do local _9_ = require("pact.package.version") local _8_ = string local _7_ = require("pact.lib.ruin.enum") E, _local_10_, _local_11_ = _7_, _8_, _9_ end local _local_12_ = _local_10_

 local fmt = _local_12_["format"] local _local_13_ = _local_11_
 local version_spec_string_3f = _local_13_["version-spec-string?"] do local _ = {nil, nil} end

 local M = {}

 local function make(kind, val)
 local tos local function _16_(_14_) local _arg_15_ = _14_ local a = _arg_15_[1] local b = _arg_15_[2] local c = _arg_15_[3] return fmt("(constraint %s %s %s)", a, b, c) end tos = _16_
 return setmetatable({"git", kind, val}, {__tostring = tos, __fennelview = tos, __eq = M["equal?"], __index = {["git?"] = true, type = kind, value = val}}) end






 M.head = function() return {"git", "head", true} end

 M.version = function(ver)
 if version_spec_string_3f(ver) then
 return make("version", ver) else
 return nil, "invalid version spec for version constraint" end end

 M["version?"] = function(c)
 local _18_ = c if ((_G.type(_18_) == "table") and ((_18_)[1] == "git") and ((_18_)[2] == "version") and (nil ~= (_18_)[3])) then local any = (_18_)[3] return true elseif true then local __1_auto = _18_ return false else return nil end end

 M.head = function()
 return make("head", true) end

 M["head?"] = function(c)
 local _20_ = c if ((_G.type(_20_) == "table") and ((_20_)[1] == "git") and ((_20_)[2] == "head") and (nil ~= (_20_)[3])) then local any = (_20_)[3] return true elseif true then local __1_auto = _20_ return false else return nil end end

 M.commit = function(sha)
 local _let_22_ = require("pact.package.git.commit") local valid_sha_3f = _let_22_["valid-sha?"]
 if valid_sha_3f(sha) then
 return make("commit", sha) else
 return nil, "invalid sha for commit constraint, must be 7-40 characters" end end

 M["commit?"] = function(c)
 local _24_ = c if ((_G.type(_24_) == "table") and ((_24_)[1] == "git") and ((_24_)[2] == "commit") and (nil ~= (_24_)[3])) then local any = (_24_)[3] return true elseif true then local __1_auto = _24_ return false else return nil end end

 local function tag_or_branch(what, v)
 if (string_3f(v) and string.match(v, "^[^%s]+$")) then
 return make(what, v) else
 return nil, fmt("invalid %s, must be string and contain no whitespace", what) end end

 M.tag = function(tag)
 return tag_or_branch("tag", tag) end

 M["tag?"] = function(c)
 local _27_ = c if ((_G.type(_27_) == "table") and ((_27_)[1] == "git") and ((_27_)[2] == "tag") and (nil ~= (_27_)[3])) then local any = (_27_)[3] return true elseif true then local __1_auto = _27_ return false else return nil end end

 M.branch = function(branch)
 return tag_or_branch("branch", branch) end

 M["branch?"] = function(c)
 local _29_ = c if ((_G.type(_29_) == "table") and ((_29_)[1] == "git") and ((_29_)[2] == "branch") and (nil ~= (_29_)[3])) then local any = (_29_)[3] return true elseif true then local __1_auto = _29_ return false else return nil end end

 local function set_tostring(t)

 local function _33_(_31_) local _arg_32_ = _31_ local _ = _arg_32_[1] local kind = _arg_32_[2] local spec = _arg_32_[3]
 local datum do local _34_ = kind if (_34_ == "head") then datum = "HEAD" elseif (_34_ == "commit") then

 local _let_35_ = require("pact.package.git.commit") local abbrev_sha = _let_35_["abbrev-sha"]
 datum = abbrev_sha(spec) elseif (nil ~= _34_) then local any = _34_
 datum = spec else datum = nil end end local name
 do local _37_ = kind if (_37_ == "commit") then name = "" elseif (_37_ == "tag") then name = "#" elseif (_37_ == "version") then name = "" elseif (_37_ == "branch") then name = "" elseif (_37_ == "head") then name = "" elseif true then local _0 = _37_ name = "??" else name = nil end end







 return (name .. string.gsub(datum, "%s", "")) end return setmetatable(t, {__tostring = _33_}) end

 M["constraint?"] = function(c)
 local _39_ = c if ((_G.type(_39_) == "table") and ((_39_)[1] == "git") and (nil ~= (_39_)[2]) and (nil ~= (_39_)[3])) then local any_1 = (_39_)[2] local any_2 = (_39_)[3] return true elseif true then local __1_auto = _39_ return false else return nil end end

 M["equal?"] = function(a, b)
 local _41_ = {a, b} if ((_G.type(_41_) == "table") and ((_G.type((_41_)[1]) == "table") and (nil ~= ((_41_)[1])[1]) and (nil ~= ((_41_)[1])[2]) and (nil ~= ((_41_)[1])[3])) and ((_G.type((_41_)[2]) == "table") and (((_41_)[1])[1] == ((_41_)[2])[1]) and (((_41_)[1])[2] == ((_41_)[2])[2]) and (((_41_)[1])[3] == ((_41_)[2])[3]))) then local kind = ((_41_)[1])[1] local how = ((_41_)[1])[2] local what = ((_41_)[1])[3] return true elseif true then local _ = _41_ return false else return nil end end



 M["git?"] = function(c)
 local _43_ = c local function _44_() local any = (_43_)[3] return true end if (((_G.type(_43_) == "table") and ((_43_)[1] == "git") and ((_43_)[2] == "head") and (nil ~= (_43_)[3])) and _44_()) then local any = (_43_)[3] return true else local function _45_() local any = (_43_)[3] return true end if (((_G.type(_43_) == "table") and ((_43_)[1] == "git") and ((_43_)[2] == "commit") and (nil ~= (_43_)[3])) and _45_()) then local any = (_43_)[3] return true else local function _46_() local any = (_43_)[3] return true end if (((_G.type(_43_) == "table") and ((_43_)[1] == "git") and ((_43_)[2] == "version") and (nil ~= (_43_)[3])) and _46_()) then local any = (_43_)[3] return true else local function _47_() local any = (_43_)[3] return true end if (((_G.type(_43_) == "table") and ((_43_)[1] == "git") and ((_43_)[2] == "tag") and (nil ~= (_43_)[3])) and _47_()) then local any = (_43_)[3] return true else local function _48_() local any = (_43_)[3] return true end if (((_G.type(_43_) == "table") and ((_43_)[1] == "git") and ((_43_)[2] == "branch") and (nil ~= (_43_)[3])) and _48_()) then local any = (_43_)[3] return true elseif true then local _ = _43_ return false else return nil end end end end end end







 M.type = function(c)
 local _50_ = c if ((_G.type(_50_) == "table") and ((_50_)[1] == "git") and (nil ~= (_50_)[2]) and true) then local x = (_50_)[2] local _ = (_50_)[3]
 return x else return nil end end

 M.value = function(c)
 local _52_ = c if ((_G.type(_52_) == "table") and ((_52_)[1] == "git") and (nil ~= (_52_)[2]) and (nil ~= (_52_)[3])) then local kind = (_52_)[2] local val = (_52_)[3]
 return val elseif true then local _ = _52_
 return error(fmt("could not get constraint value! %s", c)) else return nil end end

 local __fn_2a_M__satisfies_3f_dispatch = {bodies = {}, help = {}} local function _67_(...) if (0 == #(__fn_2a_M__satisfies_3f_dispatch).bodies) then error(("multi-arity function " .. "M.satisfies?" .. " has no bodies")) else end local _69_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__satisfies_3f_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _69_ = f_74_auto end if (nil ~= _69_) then local f_74_auto = _69_ return f_74_auto(...) elseif (_69_ == nil) then local view_77_auto do local _70_, _71_ = pcall(require, "fennel") if ((_70_ == true) and ((_G.type(_71_) == "table") and (nil ~= (_71_).view))) then local view_77_auto0 = (_71_).view view_77_auto = view_77_auto0 elseif ((_70_ == false) and true) then local __75_auto = _71_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _73_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _73_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "M.satisfies?", table.concat(_73_, ", "), table.concat((__fn_2a_M__satisfies_3f_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end M["satisfies?"] = _67_ local function _76_() local _77_ do table.insert((__fn_2a_M__satisfies_3f_dispatch).help, "(where [[\"git\" \"commit\" sha] commit])") local function _78_(...) if (2 == select("#", ...)) then local _79_ = {...} local function _80_(...) local sha_54_ = ((_79_)[1])[3] local commit_55_ = (_79_)[2] return true end if (((_G.type(_79_) == "table") and ((_G.type((_79_)[1]) == "table") and (((_79_)[1])[1] == "git") and (((_79_)[1])[2] == "commit") and (nil ~= ((_79_)[1])[3])) and (nil ~= (_79_)[2])) and _80_(...)) then local sha_54_ = ((_79_)[1])[3] local commit_55_ = (_79_)[2] local function _83_(_81_, commit)
 local _arg_82_ = _81_ local _ = _arg_82_[1] local _0 = _arg_82_[2] local sha = _arg_82_[3]
 return not_nil_3f(string.match(commit.sha, fmt("^%s", sha))) end return _83_ else return nil end else return nil end end table.insert((__fn_2a_M__satisfies_3f_dispatch).bodies, _78_) _77_ = M["satisfies?"] end local _86_ do table.insert((__fn_2a_M__satisfies_3f_dispatch).help, "(where [[\"git\" \"tag\" tag] commit])") local function _87_(...) if (2 == select("#", ...)) then local _88_ = {...} local function _89_(...) local tag_56_ = ((_88_)[1])[3] local commit_57_ = (_88_)[2] return true end if (((_G.type(_88_) == "table") and ((_G.type((_88_)[1]) == "table") and (((_88_)[1])[1] == "git") and (((_88_)[1])[2] == "tag") and (nil ~= ((_88_)[1])[3])) and (nil ~= (_88_)[2])) and _89_(...)) then local tag_56_ = ((_88_)[1])[3] local commit_57_ = (_88_)[2] local function _92_(_90_, commit)
 local _arg_91_ = _90_ local _ = _arg_91_[1] local _0 = _arg_91_[2] local tag = _arg_91_[3]
 local function _93_(_241) return (tag == _241) end return E["any?"](_93_, commit.tags) end return _92_ else return nil end else return nil end end table.insert((__fn_2a_M__satisfies_3f_dispatch).bodies, _87_) _86_ = M["satisfies?"] end local _96_ do table.insert((__fn_2a_M__satisfies_3f_dispatch).help, "(where [[\"git\" \"branch\" branch] commit])") local function _97_(...) if (2 == select("#", ...)) then local _98_ = {...} local function _99_(...) local branch_58_ = ((_98_)[1])[3] local commit_59_ = (_98_)[2] return true end if (((_G.type(_98_) == "table") and ((_G.type((_98_)[1]) == "table") and (((_98_)[1])[1] == "git") and (((_98_)[1])[2] == "branch") and (nil ~= ((_98_)[1])[3])) and (nil ~= (_98_)[2])) and _99_(...)) then local branch_58_ = ((_98_)[1])[3] local commit_59_ = (_98_)[2] local function _102_(_100_, commit)
 local _arg_101_ = _100_ local _ = _arg_101_[1] local _0 = _arg_101_[2] local branch = _arg_101_[3]
 local function _103_(_241) return (branch == _241) end return E["any?"](_103_, commit.branches) end return _102_ else return nil end else return nil end end table.insert((__fn_2a_M__satisfies_3f_dispatch).bodies, _97_) _96_ = M["satisfies?"] end local _106_ do table.insert((__fn_2a_M__satisfies_3f_dispatch).help, "(where [[\"git\" \"version\" version-spec] commit])") local function _107_(...) if (2 == select("#", ...)) then local _108_ = {...} local function _109_(...) local version_spec_60_ = ((_108_)[1])[3] local commit_61_ = (_108_)[2] return true end if (((_G.type(_108_) == "table") and ((_G.type((_108_)[1]) == "table") and (((_108_)[1])[1] == "git") and (((_108_)[1])[2] == "version") and (nil ~= ((_108_)[1])[3])) and (nil ~= (_108_)[2])) and _109_(...)) then local version_spec_60_ = ((_108_)[1])[3] local commit_61_ = (_108_)[2] local function _112_(_110_, commit)
 local _arg_111_ = _110_ local _ = _arg_111_[1] local _0 = _arg_111_[2] local version_spec = _arg_111_[3]
 local _let_113_ = require("pact.package.version") local satisfies_3f = _let_113_["satisfies?"]
 local function _114_(_241) return satisfies_3f(version_spec, _241) end return E["any?"](_114_, commit.versions) end return _112_ else return nil end else return nil end end table.insert((__fn_2a_M__satisfies_3f_dispatch).bodies, _107_) _106_ = M["satisfies?"] end local _117_ do table.insert((__fn_2a_M__satisfies_3f_dispatch).help, "(where [[\"git\" \"head\" _] commit])") local function _118_(...) if (2 == select("#", ...)) then local _119_ = {...} local function _120_(...) local __62_ = ((_119_)[1])[3] local commit_63_ = (_119_)[2] return true end if (((_G.type(_119_) == "table") and ((_G.type((_119_)[1]) == "table") and (((_119_)[1])[1] == "git") and (((_119_)[1])[2] == "head") and true) and (nil ~= (_119_)[2])) and _120_(...)) then local __62_ = ((_119_)[1])[3] local commit_63_ = (_119_)[2] local function _123_(_121_, commit)
 local _arg_122_ = _121_ local _ = _arg_122_[1] local _0 = _arg_122_[2] local _1 = _arg_122_[3]
 return (true == commit["HEAD?"]) end return _123_ else return nil end else return nil end end table.insert((__fn_2a_M__satisfies_3f_dispatch).bodies, _118_) _117_ = M["satisfies?"] end local _126_ do table.insert((__fn_2a_M__satisfies_3f_dispatch).help, "(where [[\"git\" _ _] {:sha sha}])") local function _127_(...) if (2 == select("#", ...)) then local _128_ = {...} local function _129_(...) local __65_ = ((_128_)[1])[2] local __65_ = ((_128_)[1])[3] local sha_66_ = ((_128_)[2]).sha return true end if (((_G.type(_128_) == "table") and ((_G.type((_128_)[1]) == "table") and (((_128_)[1])[1] == "git") and true and true) and ((_G.type((_128_)[2]) == "table") and (nil ~= ((_128_)[2]).sha))) and _129_(...)) then local __65_ = ((_128_)[1])[2] local __65_ = ((_128_)[1])[3] local sha_66_ = ((_128_)[2]).sha local function _134_(_130_, _132_)
 local _arg_131_ = _130_ local _ = _arg_131_[1] local _0 = _arg_131_[2] local _1 = _arg_131_[3] local _arg_133_ = _132_ local sha = _arg_133_["sha"] return false end return _134_ else return nil end else return nil end end table.insert((__fn_2a_M__satisfies_3f_dispatch).bodies, _127_) _126_ = M["satisfies?"] end local function _137_() table.insert((__fn_2a_M__satisfies_3f_dispatch).help, "(where _)") local function _138_(...) if true then local _139_ = {...} local function _140_(...) return true end if ((_G.type(_139_) == "table") and _140_(...)) then local function _141_(...)


 return error("satisfies? requires constraint and commit") end return _141_ else return nil end else return nil end end table.insert((__fn_2a_M__satisfies_3f_dispatch).bodies, _138_) return M["satisfies?"] end do local _ = {_77_, _86_, _96_, _106_, _117_, _126_, _137_()} end return M["satisfies?"] end setmetatable({nil, nil}, {__call = _76_})()

 local __fn_2a_M__solve_dispatch = {bodies = {}, help = {}} local function _144_(...) if (0 == #(__fn_2a_M__solve_dispatch).bodies) then error(("multi-arity function " .. "M.solve" .. " has no bodies")) else end local _146_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__solve_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _146_ = f_74_auto end if (nil ~= _146_) then local f_74_auto = _146_ return f_74_auto(...) elseif (_146_ == nil) then local view_77_auto do local _147_, _148_ = pcall(require, "fennel") if ((_147_ == true) and ((_G.type(_148_) == "table") and (nil ~= (_148_).view))) then local view_77_auto0 = (_148_).view view_77_auto = view_77_auto0 elseif ((_147_ == false) and true) then local __75_auto = _148_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _150_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _150_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "M.solve", table.concat(_150_, ", "), table.concat((__fn_2a_M__solve_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end M.solve = _144_ local function _153_() do local _ = {} end return M.solve end setmetatable({nil, nil}, {__call = _153_})()



 do table.insert((__fn_2a_M__solve_dispatch).help, "(where [constraint commits] (and (M.version? constraint) (seq? commits)))") local function _156_(...) if (2 == select("#", ...)) then local _157_ = {...} local function _158_(...) local constraint_154_ = (_157_)[1] local commits_155_ = (_157_)[2] return (M["version?"](constraint_154_) and seq_3f(commits_155_)) end if (((_G.type(_157_) == "table") and (nil ~= (_157_)[1]) and (nil ~= (_157_)[2])) and _158_(...)) then local constraint_154_ = (_157_)[1] local commits_155_ = (_157_)[2] local function _159_(constraint, commits)

 local _let_160_ = require("pact.package.version") local solve = _let_160_["solve"]
 local spec = M.value(constraint) local possible_versions

 local function _161_(_241) return _241.versions end possible_versions = E.flatten(E.map(_161_, commits))

 local best_version = E.first(solve(spec, possible_versions))

 if best_version then



 local function _162_(_3fcommit, commit)
 local function _163_(_241) return (best_version == _241) end if E["any?"](_163_, commit.versions) then
 return E.reduced(commit) else return nil end end return E.reduce(_162_, nil, commits) else return nil end end return _159_ else return nil end else return nil end end table.insert((__fn_2a_M__solve_dispatch).bodies, _156_) do local _ = M.solve end end


 do table.insert((__fn_2a_M__solve_dispatch).help, "(where [constraint commits] (and (M.constraint? constraint) (seq? commits)))") local function _170_(...) if (2 == select("#", ...)) then local _171_ = {...} local function _172_(...) local constraint_168_ = (_171_)[1] local commits_169_ = (_171_)[2] return (M["constraint?"](constraint_168_) and seq_3f(commits_169_)) end if (((_G.type(_171_) == "table") and (nil ~= (_171_)[1]) and (nil ~= (_171_)[2])) and _172_(...)) then local constraint_168_ = (_171_)[1] local commits_169_ = (_171_)[2] local function _173_(constraint, commits)

 local function _174_(_241) return M["satisfies?"](constraint, _241) end return E.find(_174_, commits) end return _173_ else return nil end else return nil end end table.insert((__fn_2a_M__solve_dispatch).bodies, _170_) do local _ = M.solve end end

 return M