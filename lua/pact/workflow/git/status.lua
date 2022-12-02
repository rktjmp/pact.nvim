
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local _local_16_, git_tasks, fs_tasks, enum, _local_17_, _local_18_, _local_19_, git_commit, _local_20_ = nil, nil, nil, nil, nil, nil, nil, nil, nil do local _15_ = require("pact.plugin.constraint") local _14_ = require("pact.git.commit") local _13_ = require("pact.git.commit") local _12_ = require("pact.workflow") local _11_ = string local _10_ = require("pact.lib.ruin.enum") local _9_ = require("pact.workflow.exec.fs") local _8_ = require("pact.workflow.exec.git") local _7_ = require("pact.lib.ruin.result") _local_16_, git_tasks, fs_tasks, enum, _local_17_, _local_18_, _local_19_, git_commit, _local_20_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_ end local _local_21_ = _local_16_
 local err = _local_21_["err"] local ok = _local_21_["ok"] local _local_22_ = _local_17_



 local fmt = _local_22_["format"] local _local_23_ = _local_18_
 local new_workflow = _local_23_["new"] local yield = _local_23_["yield"] local _local_24_ = _local_19_
 local ref_lines__3ecommits = _local_24_["ref-lines->commits"] local _local_25_ = _local_20_


 local satisfies_constraint_3f = _local_25_["satisfies?"] local solve_constraint = _local_25_["solve"] do local _ = {nil, nil} end

 local function absolute_path_3f(path)
 return not_nil_3f(string.match(path, "^/")) end

 local function git_dir_3f(path)
 return ("directory" == fs_tasks["what-is-at"]((path .. "/.git"))) end


 local function commit_constraint_3f(c)
 local _26_ = c if ((_G.type(_26_) == "table") and ((_26_)[1] == "git") and ((_26_)[2] == "commit") and (nil ~= (_26_)[3])) then local any = (_26_)[3] return true elseif true then local __1_auto = _26_ return false else return nil end end

 local function tag_constraint_3f(c)
 local _28_ = c if ((_G.type(_28_) == "table") and ((_28_)[1] == "git") and ((_28_)[2] == "tag") and (nil ~= (_28_)[3])) then local any = (_28_)[3] return true elseif true then local __1_auto = _28_ return false else return nil end end

 local function branch_constraint_3f(c)
 local _30_ = c if ((_G.type(_30_) == "table") and ((_30_)[1] == "git") and ((_30_)[2] == "branch") and (nil ~= (_30_)[3])) then local any = (_30_)[3] return true elseif true then local __1_auto = _30_ return false else return nil end end

 local function version_constraint_3f(c)
 local _32_ = c if ((_G.type(_32_) == "table") and ((_32_)[1] == "git") and ((_32_)[2] == "version") and (nil ~= (_32_)[3])) then local any = (_32_)[3] return true elseif true then local __1_auto = _32_ return false else return nil end end

 local __fn_2a_status_new_repo_impl_dispatch = {bodies = {}, help = {}} local status_new_repo_impl local function _34_(...) if (0 == #(__fn_2a_status_new_repo_impl_dispatch).bodies) then error(("multi-arity function " .. "status-new-repo-impl" .. " has no bodies")) else end local _36_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_status_new_repo_impl_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _36_ = f_74_auto end if (nil ~= _36_) then local f_74_auto = _36_ return f_74_auto(...) elseif (_36_ == nil) then local view_77_auto do local _37_, _38_ = pcall(require, "fennel") if ((_37_ == true) and ((_G.type(_38_) == "table") and (nil ~= (_38_).view))) then local view_77_auto0 = (_38_).view view_77_auto = view_77_auto0 elseif ((_37_ == false) and true) then local __75_auto = _38_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "status-new-repo-impl", view_77_auto({...}), table.concat((__fn_2a_status_new_repo_impl_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end status_new_repo_impl = _34_ local function _41_() do local _ = {} end return status_new_repo_impl end setmetatable({nil, nil}, {__call = _41_})()

 do table.insert((__fn_2a_status_new_repo_impl_dispatch).help, "(where [repo-url constraint] (commit-constraint? constraint))") local function _44_(...) if (2 == select("#", ...)) then local _45_ = {...} local function _46_(...) local repo_url_42_ = (_45_)[1] local constraint_43_ = (_45_)[2] return commit_constraint_3f(constraint_43_) end if (((_G.type(_45_) == "table") and (nil ~= (_45_)[1]) and (nil ~= (_45_)[2])) and _46_(...)) then local repo_url_42_ = (_45_)[1] local constraint_43_ = (_45_)[2] local function _47_(repo_url, constraint)

 return ok({"clone", git_commit.commit(constraint[3])}) end return _47_ else return nil end else return nil end end table.insert((__fn_2a_status_new_repo_impl_dispatch).bodies, _44_) end

 do table.insert((__fn_2a_status_new_repo_impl_dispatch).help, "(where [repo-url constraint] (or (tag-constraint? constraint) (branch-constraint? constraint) (version-constraint? constraint)))") local function _52_(...) if (2 == select("#", ...)) then local _53_ = {...} local function _54_(...) local repo_url_50_ = (_53_)[1] local constraint_51_ = (_53_)[2] return (tag_constraint_3f(constraint_51_) or branch_constraint_3f(constraint_51_) or version_constraint_3f(constraint_51_)) end if (((_G.type(_53_) == "table") and (nil ~= (_53_)[1]) and (nil ~= (_53_)[2])) and _54_(...)) then local repo_url_50_ = (_53_)[1] local constraint_51_ = (_53_)[2] local function _55_(repo_url, constraint)


 local _let_56_ = require("pact.lib.ruin.result") local bind_15_auto = _let_56_["bind"] local unit_16_auto = _let_56_["unit"] local bind_57_ = bind_15_auto local unit_58_ = unit_16_auto local function _59_(_)
 local function _60_() local _let_61_ = require("pact.lib.ruin.result") local map_ok_24_auto = _let_61_["map-ok"] local result_25_auto = _let_61_["result"] local unwrap_26_auto = _let_61_["unwrap"] local function _62_(_241) return ref_lines__3ecommits(_241) end return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _62_) end local function _63_(remote_commits) local function _64_()

 yield("solving for constraint")
 local all_1_auto, val_2_auto = nil, nil do local nil_65_ = solve_constraint(constraint, remote_commits) if (nil ~= nil_65_) then local target_commit = nil_65_ all_1_auto, val_2_auto = true, ok({"clone", target_commit}) else all_1_auto, val_2_auto = false end end if all_1_auto then return val_2_auto else

 return err(fmt("no commit satisfies %s", constraint)) end end return unit_58_(_64_()) end return unit_58_(bind_57_(unit_58_(_60_()), _63_)) end return bind_57_(unit_58_(yield("fetching remote refs")), _59_) end return _55_ else return nil end else return nil end end table.insert((__fn_2a_status_new_repo_impl_dispatch).bodies, _52_) end

 local __fn_2a_status_existing_repo_impl_dispatch = {bodies = {}, help = {}} local status_existing_repo_impl local function _70_(...) if (0 == #(__fn_2a_status_existing_repo_impl_dispatch).bodies) then error(("multi-arity function " .. "status-existing-repo-impl" .. " has no bodies")) else end local _72_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_status_existing_repo_impl_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _72_ = f_74_auto end if (nil ~= _72_) then local f_74_auto = _72_ return f_74_auto(...) elseif (_72_ == nil) then local view_77_auto do local _73_, _74_ = pcall(require, "fennel") if ((_73_ == true) and ((_G.type(_74_) == "table") and (nil ~= (_74_).view))) then local view_77_auto0 = (_74_).view view_77_auto = view_77_auto0 elseif ((_73_ == false) and true) then local __75_auto = _74_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "status-existing-repo-impl", view_77_auto({...}), table.concat((__fn_2a_status_existing_repo_impl_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end status_existing_repo_impl = _70_ local function _77_() do local _ = {} end return status_existing_repo_impl end setmetatable({nil, nil}, {__call = _77_})()

 do table.insert((__fn_2a_status_existing_repo_impl_dispatch).help, "(where [path repo-url constraint] (commit-constraint? constraint))") local function _81_(...) if (3 == select("#", ...)) then local _82_ = {...} local function _83_(...) local path_78_ = (_82_)[1] local repo_url_79_ = (_82_)[2] local constraint_80_ = (_82_)[3] return commit_constraint_3f(constraint_80_) end if (((_G.type(_82_) == "table") and (nil ~= (_82_)[1]) and (nil ~= (_82_)[2]) and (nil ~= (_82_)[3])) and _83_(...)) then local path_78_ = (_82_)[1] local repo_url_79_ = (_82_)[2] local constraint_80_ = (_82_)[3] local function _84_(path, repo_url, constraint)



 local _let_85_ = require("pact.lib.ruin.result") local bind_15_auto = _let_85_["bind"] local unit_16_auto = _let_85_["unit"] local bind_86_ = bind_15_auto local unit_87_ = unit_16_auto local function _88_(_) local function _89_(HEAD_sha) local function _90_(_0) local function _91_(HEAD_commit) local function _92_()



 if satisfies_constraint_3f(constraint, HEAD_commit) then
 return ok({"hold", HEAD_commit}) else
 return ok({"sync", git_commit.commit(constraint[3])}) end end return unit_87_(_92_()) end return unit_87_(bind_86_(unit_87_(git_commit.commit(HEAD_sha)), _91_)) end return unit_87_(bind_86_(unit_87_(yield("reticulating splines")), _90_)) end return unit_87_(bind_86_(unit_87_(git_tasks["HEAD-sha"](path)), _89_)) end return bind_86_(unit_87_(yield("checking local sha")), _88_) end return _84_ else return nil end else return nil end end table.insert((__fn_2a_status_existing_repo_impl_dispatch).bodies, _81_) end

 do table.insert((__fn_2a_status_existing_repo_impl_dispatch).help, "(where [path repo-url constraint] (or (tag-constraint? constraint) (branch-constraint? constraint)))") local function _99_(...) if (3 == select("#", ...)) then local _100_ = {...} local function _101_(...) local path_96_ = (_100_)[1] local repo_url_97_ = (_100_)[2] local constraint_98_ = (_100_)[3] return (tag_constraint_3f(constraint_98_) or branch_constraint_3f(constraint_98_)) end if (((_G.type(_100_) == "table") and (nil ~= (_100_)[1]) and (nil ~= (_100_)[2]) and (nil ~= (_100_)[3])) and _101_(...)) then local path_96_ = (_100_)[1] local repo_url_97_ = (_100_)[2] local constraint_98_ = (_100_)[3] local function _102_(path, repo_url, constraint)






 local _let_103_ = require("pact.lib.ruin.result") local bind_15_auto = _let_103_["bind"] local unit_16_auto = _let_103_["unit"] local bind_104_ = bind_15_auto local unit_105_ = unit_16_auto local function _106_(_) local function _107_(HEAD_sha) local function _108_(_0)


 local function _109_() local _let_110_ = require("pact.lib.ruin.result") local map_ok_24_auto = _let_110_["map-ok"] local result_25_auto = _let_110_["result"] local unwrap_26_auto = _let_110_["unwrap"] local function _111_(_241) return ref_lines__3ecommits(_241) end return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _111_) end local function _112_(remote_commits) local function _113_(_1)












 local function _114_(_241, _242) return satisfies_constraint_3f(constraint, _242) end local function _115_(_241, _242) return ((not_nil_3f(_242.branch) or not_nil_3f(_242.tag)) and (HEAD_sha == _242.sha)) end local function _116_(HEAD_commits) local function _117_()
 if enum.hd(HEAD_commits) then


 return ok({"hold", enum.hd(HEAD_commits)}) else

 local all_1_auto, val_2_auto = nil, nil do local nil_118_ = solve_constraint(constraint, remote_commits) if (nil ~= nil_118_) then local target_commit = nil_118_ all_1_auto, val_2_auto = true, ok({"sync", target_commit}) else all_1_auto, val_2_auto = false end end if all_1_auto then return val_2_auto else


 return err(fmt("no commit satisfies %s", constraint)) end end end return unit_105_(_117_()) end return unit_105_(bind_104_(unit_105_(enum.filter(_114_, enum.filter(_115_, remote_commits))), _116_)) end return unit_105_(bind_104_(unit_105_(yield("reticulating splines")), _113_)) end return unit_105_(bind_104_(unit_105_(_109_()), _112_)) end return unit_105_(bind_104_(unit_105_(yield("fetching remote refs")), _108_)) end return unit_105_(bind_104_(unit_105_(git_tasks["HEAD-sha"](path)), _107_)) end return bind_104_(unit_105_(yield("checking local sha")), _106_) end return _102_ else return nil end else return nil end end table.insert((__fn_2a_status_existing_repo_impl_dispatch).bodies, _99_) end

 do table.insert((__fn_2a_status_existing_repo_impl_dispatch).help, "(where [path repo-url constraint] (version-constraint? constraint))") local function _127_(...) if (3 == select("#", ...)) then local _128_ = {...} local function _129_(...) local path_124_ = (_128_)[1] local repo_url_125_ = (_128_)[2] local constraint_126_ = (_128_)[3] return version_constraint_3f(constraint_126_) end if (((_G.type(_128_) == "table") and (nil ~= (_128_)[1]) and (nil ~= (_128_)[2]) and (nil ~= (_128_)[3])) and _129_(...)) then local path_124_ = (_128_)[1] local repo_url_125_ = (_128_)[2] local constraint_126_ = (_128_)[3] local function _130_(path, repo_url, constraint)




 local _let_131_ = require("pact.lib.ruin.result") local bind_15_auto = _let_131_["bind"] local unit_16_auto = _let_131_["unit"] local bind_132_ = bind_15_auto local unit_133_ = unit_16_auto local function _134_(_) local function _135_(HEAD_sha) local function _136_(_0)


 local function _137_() local _let_138_ = require("pact.lib.ruin.result") local map_ok_24_auto = _let_138_["map-ok"] local result_25_auto = _let_138_["result"] local unwrap_26_auto = _let_138_["unwrap"] local function _139_(_241) return ref_lines__3ecommits(_241) end return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _139_) end local function _140_(remote_commits) local function _141_(_1) local function _142_()



 local all_1_auto, val_2_auto = nil, nil do local nil_144_ = solve_constraint(constraint, remote_commits) if (nil ~= nil_144_) then local target_commit = nil_144_ local nil_143_



 local function _145_(_241, _242) return satisfies_constraint_3f(constraint, _242) end local function _146_(_241, _242) return (not_nil_3f(_242.version) and (HEAD_sha == _242.sha)) end nil_143_ = enum.filter(_145_, enum.filter(_146_, remote_commits)) if (nil ~= nil_143_) then local HEAD_commits = nil_143_


 local function _148_() local function _147_(_241, _242) return (target_commit.sha == _242.sha) end if enum["any?"](_147_, HEAD_commits) then

 return ok({"hold", target_commit}) else
 return ok({"sync", target_commit}) end end all_1_auto, val_2_auto = true, _148_() else all_1_auto, val_2_auto = false end else all_1_auto, val_2_auto = false end end if all_1_auto then return val_2_auto else

 return err(fmt("no commit satisfies %s", constraint)) end end return unit_133_(_142_()) end return unit_133_(bind_132_(unit_133_(yield("reticulating splines")), _141_)) end return unit_133_(bind_132_(unit_133_(_137_()), _140_)) end return unit_133_(bind_132_(unit_133_(yield("fetching remote refs")), _136_)) end return unit_133_(bind_132_(unit_133_(git_tasks["HEAD-sha"](path)), _135_)) end return bind_132_(unit_133_(yield("checking local sha")), _134_) end return _130_ else return nil end else return nil end end table.insert((__fn_2a_status_existing_repo_impl_dispatch).bodies, _127_) end

 local function detect_kind(repo_url, path, constraint)
 local _let_154_ = require("pact.lib.ruin.result") local map_ok_24_auto = _let_154_["map-ok"] local result_25_auto = _let_154_["result"] local unwrap_26_auto = _let_154_["unwrap"] local function _155_(_241) return (_241 or absolute_path_3f(path) or nil or fmt("plugin path must be absolute, got %s", path)) end local function _156_(_241)


 local function _157_() if git_dir_3f(path) then
 return status_existing_repo_impl(path, repo_url, constraint) else
 return status_new_repo_impl(repo_url, constraint) end end return _157_(_241) end return map_ok_24_auto(map_ok_24_auto(result_25_auto(yield("starting git-status workflow")), _155_), _156_) end

 local __fn_2a_new_dispatch = {bodies = {}, help = {}} local new local function _163_(...) if (0 == #(__fn_2a_new_dispatch).bodies) then error(("multi-arity function " .. "new" .. " has no bodies")) else end local _165_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _165_ = f_74_auto end if (nil ~= _165_) then local f_74_auto = _165_ return f_74_auto(...) elseif (_165_ == nil) then local view_77_auto do local _166_, _167_ = pcall(require, "fennel") if ((_166_ == true) and ((_G.type(_167_) == "table") and (nil ~= (_167_).view))) then local view_77_auto0 = (_167_).view view_77_auto = view_77_auto0 elseif ((_166_ == false) and true) then local __75_auto = _167_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "new", view_77_auto({...}), table.concat((__fn_2a_new_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end new = _163_ local function _170_() local function _171_() table.insert((__fn_2a_new_dispatch).help, "(where [id repo-url path constraint])") local function _172_(...) if (4 == select("#", ...)) then local _173_ = {...} local function _174_(...) local id_159_ = (_173_)[1] local repo_url_160_ = (_173_)[2] local path_161_ = (_173_)[3] local constraint_162_ = (_173_)[4] return true end if (((_G.type(_173_) == "table") and (nil ~= (_173_)[1]) and (nil ~= (_173_)[2]) and (nil ~= (_173_)[3]) and (nil ~= (_173_)[4])) and _174_(...)) then local id_159_ = (_173_)[1] local repo_url_160_ = (_173_)[2] local path_161_ = (_173_)[3] local constraint_162_ = (_173_)[4] local function _175_(id, repo_url, path, constraint)

 local function _176_() return detect_kind(repo_url, path, constraint) end return new_workflow(id, _176_) end return _175_ else return nil end else return nil end end table.insert((__fn_2a_new_dispatch).bodies, _172_) return new end do local _ = {_171_()} end return new end setmetatable({nil, nil}, {__call = _170_})()

 return {new = new}