
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

 local function same_sha_3f(a, b)
 local _34_ = {a, b} if ((_G.type(_34_) == "table") and ((_G.type((_34_)[1]) == "table") and (nil ~= ((_34_)[1]).sha)) and ((_G.type((_34_)[2]) == "table") and (((_34_)[1]).sha == ((_34_)[2]).sha))) then local sha = ((_34_)[1]).sha return true elseif true then local _ = _34_ return false else return nil end end



 local function maybe_latest_version(remote_commits)
 return solve_constraint({"git", "version", "> 0.0.0"}, remote_commits) end

 local function maybe_newer_commit(target, remote_commits)
 local _3flatest = maybe_latest_version(remote_commits)
 if not same_sha_3f(target, _3flatest) then return _3flatest else return nil end end

 local __fn_2a_status_new_repo_impl_dispatch = {bodies = {}, help = {}} local status_new_repo_impl local function _37_(...) if (0 == #(__fn_2a_status_new_repo_impl_dispatch).bodies) then error(("multi-arity function " .. "status-new-repo-impl" .. " has no bodies")) else end local _39_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_status_new_repo_impl_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _39_ = f_74_auto end if (nil ~= _39_) then local f_74_auto = _39_ return f_74_auto(...) elseif (_39_ == nil) then local view_77_auto do local _40_, _41_ = pcall(require, "fennel") if ((_40_ == true) and ((_G.type(_41_) == "table") and (nil ~= (_41_).view))) then local view_77_auto0 = (_41_).view view_77_auto = view_77_auto0 elseif ((_40_ == false) and true) then local __75_auto = _41_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _43_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _43_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "status-new-repo-impl", table.concat(_43_, ", "), table.concat((__fn_2a_status_new_repo_impl_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end status_new_repo_impl = _37_ local function _46_() do local _ = {} end return status_new_repo_impl end setmetatable({nil, nil}, {__call = _46_})()

 do table.insert((__fn_2a_status_new_repo_impl_dispatch).help, "(where [repo-url constraint] (commit-constraint? constraint))") local function _49_(...) if (2 == select("#", ...)) then local _50_ = {...} local function _51_(...) local repo_url_47_ = (_50_)[1] local constraint_48_ = (_50_)[2] return commit_constraint_3f(constraint_48_) end if (((_G.type(_50_) == "table") and (nil ~= (_50_)[1]) and (nil ~= (_50_)[2])) and _51_(...)) then local repo_url_47_ = (_50_)[1] local constraint_48_ = (_50_)[2] local function _52_(repo_url, constraint)

 return ok({"clone", git_commit.commit(constraint[3])}) end return _52_ else return nil end else return nil end end table.insert((__fn_2a_status_new_repo_impl_dispatch).bodies, _49_) end

 do table.insert((__fn_2a_status_new_repo_impl_dispatch).help, "(where [repo-url constraint] (or (tag-constraint? constraint) (branch-constraint? constraint) (version-constraint? constraint)))") local function _57_(...) if (2 == select("#", ...)) then local _58_ = {...} local function _59_(...) local repo_url_55_ = (_58_)[1] local constraint_56_ = (_58_)[2] return (tag_constraint_3f(constraint_56_) or branch_constraint_3f(constraint_56_) or version_constraint_3f(constraint_56_)) end if (((_G.type(_58_) == "table") and (nil ~= (_58_)[1]) and (nil ~= (_58_)[2])) and _59_(...)) then local repo_url_55_ = (_58_)[1] local constraint_56_ = (_58_)[2] local function _60_(repo_url, constraint)


 local _let_61_ = require("pact.lib.ruin.result") local bind_15_auto = _let_61_["bind"] local unit_16_auto = _let_61_["unit"] local bind_62_ = bind_15_auto local unit_63_ = unit_16_auto local function _64_(_)
 local function _65_() local _let_66_ = require("pact.lib.ruin.result") local map_ok_24_auto = _let_66_["map-ok"] local result_25_auto = _let_66_["result"] local unwrap_26_auto = _let_66_["unwrap"] local function _67_(_241) return ref_lines__3ecommits(_241) end return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _67_) end local function _68_(remote_commits) local function _69_()

 yield("solving for constraint")
 local all_1_auto, val_2_auto = nil, nil do local nil_70_ = solve_constraint(constraint, remote_commits) if (nil ~= nil_70_) then local target_commit = nil_70_ all_1_auto, val_2_auto = true, ok({"clone", target_commit}, maybe_latest_version(remote_commits)) else all_1_auto, val_2_auto = false end end if all_1_auto then return val_2_auto else

 return err(fmt("no commit satisfies %s", constraint)) end end return unit_63_(_69_()) end return unit_63_(bind_62_(unit_63_(_65_()), _68_)) end return bind_62_(unit_63_(yield("fetching remote refs")), _64_) end return _60_ else return nil end else return nil end end table.insert((__fn_2a_status_new_repo_impl_dispatch).bodies, _57_) end

 local __fn_2a_status_existing_repo_impl_dispatch = {bodies = {}, help = {}} local status_existing_repo_impl local function _75_(...) if (0 == #(__fn_2a_status_existing_repo_impl_dispatch).bodies) then error(("multi-arity function " .. "status-existing-repo-impl" .. " has no bodies")) else end local _77_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_status_existing_repo_impl_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _77_ = f_74_auto end if (nil ~= _77_) then local f_74_auto = _77_ return f_74_auto(...) elseif (_77_ == nil) then local view_77_auto do local _78_, _79_ = pcall(require, "fennel") if ((_78_ == true) and ((_G.type(_79_) == "table") and (nil ~= (_79_).view))) then local view_77_auto0 = (_79_).view view_77_auto = view_77_auto0 elseif ((_78_ == false) and true) then local __75_auto = _79_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _81_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _81_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "status-existing-repo-impl", table.concat(_81_, ", "), table.concat((__fn_2a_status_existing_repo_impl_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end status_existing_repo_impl = _75_ local function _84_() do local _ = {} end return status_existing_repo_impl end setmetatable({nil, nil}, {__call = _84_})()

 do table.insert((__fn_2a_status_existing_repo_impl_dispatch).help, "(where [path repo-url constraint] (commit-constraint? constraint))") local function _88_(...) if (3 == select("#", ...)) then local _89_ = {...} local function _90_(...) local path_85_ = (_89_)[1] local repo_url_86_ = (_89_)[2] local constraint_87_ = (_89_)[3] return commit_constraint_3f(constraint_87_) end if (((_G.type(_89_) == "table") and (nil ~= (_89_)[1]) and (nil ~= (_89_)[2]) and (nil ~= (_89_)[3])) and _90_(...)) then local path_85_ = (_89_)[1] local repo_url_86_ = (_89_)[2] local constraint_87_ = (_89_)[3] local function _91_(path, repo_url, constraint)



 local _let_92_ = require("pact.lib.ruin.result") local bind_15_auto = _let_92_["bind"] local unit_16_auto = _let_92_["unit"] local bind_93_ = bind_15_auto local unit_94_ = unit_16_auto local function _95_(_) local function _96_(HEAD_sha) local function _97_(_0)


 local function _98_() local _let_99_ = require("pact.lib.ruin.result") local map_ok_24_auto = _let_99_["map-ok"] local result_25_auto = _let_99_["result"] local unwrap_26_auto = _let_99_["unwrap"] local function _100_(_241) return ref_lines__3ecommits(_241) end return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _100_) end local function _101_(remote_commits) local function _102_(_1) local function _103_(HEAD_commit) local function _104_()



 if satisfies_constraint_3f(constraint, HEAD_commit) then
 return ok({"hold", HEAD_commit}, maybe_latest_version(remote_commits)) else
 return ok({"sync", git_commit.commit(constraint[3])}, maybe_latest_version(remote_commits)) end end return unit_94_(_104_()) end return unit_94_(bind_93_(unit_94_(git_commit.commit(HEAD_sha)), _103_)) end return unit_94_(bind_93_(unit_94_(yield("reticulating splines")), _102_)) end return unit_94_(bind_93_(unit_94_(_98_()), _101_)) end return unit_94_(bind_93_(unit_94_(yield("fetching remote refs")), _97_)) end return unit_94_(bind_93_(unit_94_(git_tasks["HEAD-sha"](path)), _96_)) end return bind_93_(unit_94_(yield("checking local sha")), _95_) end return _91_ else return nil end else return nil end end table.insert((__fn_2a_status_existing_repo_impl_dispatch).bodies, _88_) end

 do table.insert((__fn_2a_status_existing_repo_impl_dispatch).help, "(where [path repo-url constraint] (or (tag-constraint? constraint) (branch-constraint? constraint)))") local function _111_(...) if (3 == select("#", ...)) then local _112_ = {...} local function _113_(...) local path_108_ = (_112_)[1] local repo_url_109_ = (_112_)[2] local constraint_110_ = (_112_)[3] return (tag_constraint_3f(constraint_110_) or branch_constraint_3f(constraint_110_)) end if (((_G.type(_112_) == "table") and (nil ~= (_112_)[1]) and (nil ~= (_112_)[2]) and (nil ~= (_112_)[3])) and _113_(...)) then local path_108_ = (_112_)[1] local repo_url_109_ = (_112_)[2] local constraint_110_ = (_112_)[3] local function _114_(path, repo_url, constraint)






 local _let_115_ = require("pact.lib.ruin.result") local bind_15_auto = _let_115_["bind"] local unit_16_auto = _let_115_["unit"] local bind_116_ = bind_15_auto local unit_117_ = unit_16_auto local function _118_(_) local function _119_(HEAD_sha) local function _120_(_0)


 local function _121_() local _let_122_ = require("pact.lib.ruin.result") local map_ok_24_auto = _let_122_["map-ok"] local result_25_auto = _let_122_["result"] local unwrap_26_auto = _let_122_["unwrap"] local function _123_(_241) return ref_lines__3ecommits(_241) end return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _123_) end local function _124_(remote_commits) local function _125_(_1)












 local function _126_(_241, _242) return satisfies_constraint_3f(constraint, _242) end local function _127_(_241, _242) return ((not_nil_3f(_242.branch) or not_nil_3f(_242.tag)) and (HEAD_sha == _242.sha)) end local function _128_(HEAD_commits) local function _129_()
 if enum.hd(HEAD_commits) then


 return ok({"hold", enum.hd(HEAD_commits)}, maybe_latest_version(remote_commits)) else

 local all_1_auto, val_2_auto = nil, nil do local nil_130_ = solve_constraint(constraint, remote_commits) if (nil ~= nil_130_) then local target_commit = nil_130_ all_1_auto, val_2_auto = true, ok({"sync", target_commit}, maybe_latest_version(remote_commits)) else all_1_auto, val_2_auto = false end end if all_1_auto then return val_2_auto else


 return err(fmt("no commit satisfies %s", constraint)) end end end return unit_117_(_129_()) end return unit_117_(bind_116_(unit_117_(enum.filter(_126_, enum.filter(_127_, remote_commits))), _128_)) end return unit_117_(bind_116_(unit_117_(yield("reticulating splines")), _125_)) end return unit_117_(bind_116_(unit_117_(_121_()), _124_)) end return unit_117_(bind_116_(unit_117_(yield("fetching remote refs")), _120_)) end return unit_117_(bind_116_(unit_117_(git_tasks["HEAD-sha"](path)), _119_)) end return bind_116_(unit_117_(yield("checking local sha")), _118_) end return _114_ else return nil end else return nil end end table.insert((__fn_2a_status_existing_repo_impl_dispatch).bodies, _111_) end

 do table.insert((__fn_2a_status_existing_repo_impl_dispatch).help, "(where [path repo-url constraint] (version-constraint? constraint))") local function _139_(...) if (3 == select("#", ...)) then local _140_ = {...} local function _141_(...) local path_136_ = (_140_)[1] local repo_url_137_ = (_140_)[2] local constraint_138_ = (_140_)[3] return version_constraint_3f(constraint_138_) end if (((_G.type(_140_) == "table") and (nil ~= (_140_)[1]) and (nil ~= (_140_)[2]) and (nil ~= (_140_)[3])) and _141_(...)) then local path_136_ = (_140_)[1] local repo_url_137_ = (_140_)[2] local constraint_138_ = (_140_)[3] local function _142_(path, repo_url, constraint)




 local _let_143_ = require("pact.lib.ruin.result") local bind_15_auto = _let_143_["bind"] local unit_16_auto = _let_143_["unit"] local bind_144_ = bind_15_auto local unit_145_ = unit_16_auto local function _146_(_) local function _147_(HEAD_sha) local function _148_(_0)


 local function _149_() local _let_150_ = require("pact.lib.ruin.result") local map_ok_24_auto = _let_150_["map-ok"] local result_25_auto = _let_150_["result"] local unwrap_26_auto = _let_150_["unwrap"] local function _151_(_241) return ref_lines__3ecommits(_241) end return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _151_) end local function _152_(remote_commits) local function _153_(_1) local function _154_()



 local all_1_auto, val_2_auto = nil, nil do local nil_156_ = solve_constraint(constraint, remote_commits) if (nil ~= nil_156_) then local target_commit = nil_156_ local nil_155_



 local function _157_(_241, _242) return satisfies_constraint_3f(constraint, _242) end local function _158_(_241, _242) return (not_nil_3f(_242.version) and (HEAD_sha == _242.sha)) end nil_155_ = enum.filter(_157_, enum.filter(_158_, remote_commits)) if (nil ~= nil_155_) then local HEAD_commits = nil_155_


 local function _160_() local function _159_(_241, _242) return (target_commit.sha == _242.sha) end if enum["any?"](_159_, HEAD_commits) then




 return ok({"hold", target_commit}, maybe_newer_commit(target_commit, remote_commits)) else
 return ok({"sync", target_commit}, maybe_newer_commit(target_commit, remote_commits), solve_constraint({"git", "version", "> 0.0.0"}, HEAD_commits)) end end all_1_auto, val_2_auto = true, _160_() else all_1_auto, val_2_auto = false end else all_1_auto, val_2_auto = false end end if all_1_auto then return val_2_auto else







 return err(fmt("no commit satisfies %s", constraint)) end end return unit_145_(_154_()) end return unit_145_(bind_144_(unit_145_(yield("reticulating splines")), _153_)) end return unit_145_(bind_144_(unit_145_(_149_()), _152_)) end return unit_145_(bind_144_(unit_145_(yield("fetching remote refs")), _148_)) end return unit_145_(bind_144_(unit_145_(git_tasks["HEAD-sha"](path)), _147_)) end return bind_144_(unit_145_(yield("checking local sha")), _146_) end return _142_ else return nil end else return nil end end table.insert((__fn_2a_status_existing_repo_impl_dispatch).bodies, _139_) end

 local function detect_kind(repo_url, path, constraint)
 local _let_166_ = require("pact.lib.ruin.result") local map_ok_24_auto = _let_166_["map-ok"] local result_25_auto = _let_166_["result"] local unwrap_26_auto = _let_166_["unwrap"] local function _167_(_241) return (_241 or absolute_path_3f(path) or nil or fmt("plugin path must be absolute, got %s", path)) end local function _168_(_241)


 local function _169_() if git_dir_3f(path) then
 return status_existing_repo_impl(path, repo_url, constraint) else
 return status_new_repo_impl(repo_url, constraint) end end return _169_(_241) end return map_ok_24_auto(map_ok_24_auto(result_25_auto(yield("starting git-status workflow")), _167_), _168_) end

 local __fn_2a_new_dispatch = {bodies = {}, help = {}} local new local function _175_(...) if (0 == #(__fn_2a_new_dispatch).bodies) then error(("multi-arity function " .. "new" .. " has no bodies")) else end local _177_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _177_ = f_74_auto end if (nil ~= _177_) then local f_74_auto = _177_ return f_74_auto(...) elseif (_177_ == nil) then local view_77_auto do local _178_, _179_ = pcall(require, "fennel") if ((_178_ == true) and ((_G.type(_179_) == "table") and (nil ~= (_179_).view))) then local view_77_auto0 = (_179_).view view_77_auto = view_77_auto0 elseif ((_178_ == false) and true) then local __75_auto = _179_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _181_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _181_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "new", table.concat(_181_, ", "), table.concat((__fn_2a_new_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end new = _175_ local function _184_() local function _185_() table.insert((__fn_2a_new_dispatch).help, "(where [id repo-url path constraint])") local function _186_(...) if (4 == select("#", ...)) then local _187_ = {...} local function _188_(...) local id_171_ = (_187_)[1] local repo_url_172_ = (_187_)[2] local path_173_ = (_187_)[3] local constraint_174_ = (_187_)[4] return true end if (((_G.type(_187_) == "table") and (nil ~= (_187_)[1]) and (nil ~= (_187_)[2]) and (nil ~= (_187_)[3]) and (nil ~= (_187_)[4])) and _188_(...)) then local id_171_ = (_187_)[1] local repo_url_172_ = (_187_)[2] local path_173_ = (_187_)[3] local constraint_174_ = (_187_)[4] local function _189_(id, repo_url, path, constraint)

 local function _190_() return detect_kind(repo_url, path, constraint) end return new_workflow(id, _190_) end return _189_ else return nil end else return nil end end table.insert((__fn_2a_new_dispatch).bodies, _186_) return new end do local _ = {_185_()} end return new end setmetatable({nil, nil}, {__call = _184_})()

 return {new = new}