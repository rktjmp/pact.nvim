


 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local _local_16_, R, E, FS, Git, Commit, _local_17_, Log, _local_18_ = nil, nil, nil, nil, nil, nil, nil, nil, nil do local _15_ = string local _14_ = require("pact.log")






 local _13_ = require("pact.task") local _12_ = require("pact.package.git.commit") local _11_ = require("pact.package.git.exec") local _10_ = require("pact.fs") local _9_ = require("pact.lib.ruin.enum") local _8_ = require("pact.lib.ruin.result") local _7_ = require("pact.lib.ruin.fn") _local_16_, R, E, FS, Git, Commit, _local_17_, Log, _local_18_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_ end local _local_19_ = _local_16_ local tap = _local_19_["tap"] local _local_20_ = _local_17_ local task_2fawait = _local_20_["await"] local task_2fnew = _local_20_["new"] local task_3f = _local_20_["task?"] local trace = _local_20_["trace"] local _local_21_ = _local_18_

 local fmt = _local_21_["format"] do local _ = {nil, nil} end

 local function validate_git_dir(path) _G.assert((nil ~= path), "Missing argument path on ./fnl/pact/datastore/git/init.fnl:17")

 if not FS["absolute-path?"](path) then
 return R.err(fmt("repo path must be absolute, got %s", path)) else
 local _22_ = {FS["dir-exists?"](path), FS["git-dir?"](path)} if ((_G.type(_22_) == "table") and ((_22_)[1] == true) and ((_22_)[2] == true)) then
 return R.ok(path) elseif ((_G.type(_22_) == "table") and ((_22_)[1] == true) and ((_22_)[2] == false)) then
 return R.err(fmt("%s exists but is not a git dir", path)) elseif ((_G.type(_22_) == "table") and ((_22_)[1] == false) and true) then local _ = (_22_)[2]
 return R.err(fmt("%s does not exist", path)) else return nil end end end

 local function clone_if_missing(repo_origin, repo_path) _G.assert((nil ~= repo_path), "Missing argument repo-path on ./fnl/pact/datastore/git/init.fnl:26") _G.assert((nil ~= repo_origin), "Missing argument repo-origin on ./fnl/pact/datastore/git/init.fnl:26")

 trace("clone-if-missing %s", repo_origin)
 local _let_25_ = require("pact.lib.ruin.result") local bind_15_auto = _let_25_["bind"] local unit_16_auto = _let_25_["unit"] local bind_26_ = bind_15_auto local unit_27_ = unit_16_auto local function _28_() if not FS["absolute-path?"](repo_path) then
 return R.err(fmt("repo path must be absolute, got %s", repo_path)) else return nil end end local function _29_(_)
 local function _31_() local _30_ = {FS["dir-exists?"](repo_path), FS["git-dir?"](repo_path)} if ((_G.type(_30_) == "table") and ((_30_)[1] == true) and ((_30_)[2] == true)) then
 return R.ok() elseif ((_G.type(_30_) == "table") and ((_30_)[1] == true) and ((_30_)[2] == false)) then
 return R.err(fmt("%s exists already but is not a git dir", repo_path)) elseif true then local _0 = _30_

 trace("git clone %s -> %s", repo_origin, repo_path)
 return R.result(Git["create-stub-clone"](repo_origin, repo_path)) else return nil end end local function _33_(_0) local function _34_()
 return R.ok(repo_path) end return unit_27_(_34_()) end return unit_27_(bind_26_(unit_27_(_31_()), _33_)) end return bind_26_(unit_27_(_28_()), _29_) end

 local function update_refs(repo_path) _G.assert((nil ~= repo_path), "Missing argument repo-path on ./fnl/pact/datastore/git/init.fnl:39")
 local _let_35_ = require("pact.lib.ruin.result") local bind_15_auto = _let_35_["bind"] local unit_16_auto = _let_35_["unit"] local bind_36_ = bind_15_auto local unit_37_ = unit_16_auto local function _38_(_) local function _39_(_0) local function _40_(_1) local function _41_()


 return R.ok("updated-refs") end return unit_37_(_41_()) end return unit_37_(bind_36_(unit_37_(Git["update-refs"](repo_path)), _40_)) end return unit_37_(bind_36_(unit_37_(validate_git_dir(repo_path)), _39_)) end return bind_36_(unit_37_(trace("git update refs %s", repo_path)), _38_) end

 local function register(ds, canonical_id, repo_origin) _G.assert((nil ~= repo_origin), "Missing argument repo-origin on ./fnl/pact/datastore/git/init.fnl:45") _G.assert((nil ~= canonical_id), "Missing argument canonical-id on ./fnl/pact/datastore/git/init.fnl:45") _G.assert((nil ~= ds), "Missing argument ds on ./fnl/pact/datastore/git/init.fnl:45")




 local _local_42_ = require("pact.datastore") local package_by_canonical_id = _local_42_["package-by-canonical-id"]
 local _43_ = package_by_canonical_id(ds, canonical_id) if (nil ~= _43_) then local p = _43_
 return error(fmt("attempt to re-register known package %s", canonical_id)) elseif (_43_ == nil) then
 local f local function _44_() local _45_ do local _let_47_ = require("pact.lib.ruin.result") local bind_15_auto = _let_47_["bind"] local unit_16_auto = _let_47_["unit"] local bind_48_ = bind_15_auto local unit_49_ = unit_16_auto local function _51_(store_path) local function _52_(_) local function _53_()

 return R.ok({kind = "git", id = canonical_id, path = store_path, origin = repo_origin}) end return unit_49_(_53_()) end return unit_49_(bind_48_(unit_49_(clone_if_missing(repo_origin, store_path)), _52_)) end _45_ = bind_48_(unit_49_(FS["join-path"](ds.path.git, canonical_id, "HEAD")), _51_) end



 local function _54_(_2410) ds["packages"][canonical_id] = _2410 return nil end return tap(_45_, _54_) end f = _44_
 local task = task_2fnew(fmt("register-%s", canonical_id), f)
 do end (ds)["packages"][canonical_id] = task
 return task else return nil end end

 local function fetch_commits(ds_package) _G.assert((nil ~= ds_package), "Missing argument ds-package on ./fnl/pact/datastore/git/init.fnl:64")

 local function _56_() local _let_57_ = require("pact.lib.ruin.result") local bind_15_auto = _let_57_["bind"] local unit_16_auto = _let_57_["unit"] local bind_58_ = bind_15_auto local unit_59_ = unit_16_auto local function _62_(_60_) local _arg_61_ = _60_ local path = _arg_61_["path"] local function _63_(_) local function _64_(_0) local function _65_(_1) local function _66_(refs) local function _67_()




 return R.ok(Commit["local-refs->commits"](refs)) end return unit_59_(_67_()) end return unit_59_(bind_58_(unit_59_(Git["ls-local"](path)), _66_)) end return unit_59_(bind_58_(unit_59_(trace("git ls-local-refs")), _65_)) end return unit_59_(bind_58_(unit_59_(update_refs(path)), _64_)) end return unit_59_(bind_58_(unit_59_(validate_git_dir(path)), _63_)) end return bind_58_(unit_59_(ds_package), _62_) end return task_2fnew(_56_) end

 local function setup_commit(ds_package, commit) _G.assert((nil ~= commit), "Missing argument commit on ./fnl/pact/datastore/git/init.fnl:73") _G.assert((nil ~= ds_package), "Missing argument ds-package on ./fnl/pact/datastore/git/init.fnl:73")

 local function _68_() local _let_69_ = require("pact.lib.ruin.result") local bind_15_auto = _let_69_["bind"] local unit_16_auto = _let_69_["unit"] local bind_70_ = bind_15_auto local unit_71_ = unit_16_auto local function _74_(_72_) local _arg_73_ = _72_ local repo_path = _arg_73_["path"] local function _77_(_75_)
 local _arg_76_ = _75_ local sha = _arg_76_["short-sha"] local function _78_(_) local function _79_(worktree_path)


 local function _81_() local _80_ = {FS["dir-exists?"](worktree_path), FS["git-dir?"](worktree_path)} if ((_G.type(_80_) == "table") and ((_80_)[1] == true) and ((_80_)[2] == true)) then
 return R.ok(worktree_path) elseif ((_G.type(_80_) == "table") and ((_80_)[1] == true) and ((_80_)[2] == false)) then
 return R.err(fmt("%s exists already but is not a git dir", worktree_path)) elseif true then local _0 = _80_

 trace("git add-worktree %s %s -> %s", repo_path, commit.short, worktree_path)
 Git["add-worktree"](repo_path, worktree_path, sha)
 trace("git checkout %s", commit["short-sha"])
 Git["checkout-sha"](worktree_path, sha)
 return trace("git checked-out %s", commit["short-sha"]) else return nil end end local function _83_(_0) local function _84_()
 return R.ok(worktree_path) end return unit_71_(_84_()) end return unit_71_(bind_70_(unit_71_(_81_()), _83_)) end return unit_71_(bind_70_(unit_71_(string.gsub(repo_path, "HEAD$", sha)), _79_)) end return unit_71_(bind_70_(unit_71_(validate_git_dir(repo_path)), _78_)) end return unit_71_(bind_70_(unit_71_(commit), _77_)) end return bind_70_(unit_71_(ds_package), _74_) end return task_2fnew(_68_) end

 local function verify_commit(ds_package, commit) _G.assert((nil ~= commit), "Missing argument commit on ./fnl/pact/datastore/git/init.fnl:90") _G.assert((nil ~= ds_package), "Missing argument ds-package on ./fnl/pact/datastore/git/init.fnl:90")

 local function _85_() local _let_86_ = require("pact.lib.ruin.result") local bind_15_auto = _let_86_["bind"] local unit_16_auto = _let_86_["unit"] local bind_87_ = bind_15_auto local unit_88_ = unit_16_auto local function _91_(_89_) local _arg_90_ = _89_ local path = _arg_90_["path"] local function _92_(sha) local function _93_()

 return R.ok(sha) end return unit_88_(_93_()) end return unit_88_(bind_87_(unit_88_(Git["verify-commit"](path, commit.sha)), _92_)) end return bind_87_(unit_88_(ds_package), _91_) end return task_2fnew(_85_) end

 local function commit_at_path(ds_package, path) _G.assert((nil ~= path), "Missing argument path on ./fnl/pact/datastore/git/init.fnl:96") _G.assert((nil ~= ds_package), "Missing argument ds-package on ./fnl/pact/datastore/git/init.fnl:96")



 local function _94_() local _let_95_ = require("pact.lib.ruin.result") local bind_15_auto = _let_95_["bind"] local unit_16_auto = _let_95_["unit"] local bind_96_ = bind_15_auto local unit_97_ = unit_16_auto local function _98_() if not FS["absolute-path?"](path) then
 return R.err(fmt("repo path must be absolute, got %s", path)) else return nil end end local function _99_(_)
 local function _101_() local _100_ = {FS["dir-exists?"](path), FS["git-dir?"](path)} if ((_G.type(_100_) == "table") and ((_100_)[1] == true) and ((_100_)[2] == true)) then
 return Git["HEAD-sha"](path) elseif ((_G.type(_100_) == "table") and ((_100_)[1] == true) and ((_100_)[2] == false)) then
 return R.err(fmt("%s exists but is not a git dir", path)) elseif ((_G.type(_100_) == "table") and ((_100_)[1] == false) and true) then local _0 = (_100_)[2]
 return nil else return nil end end local function _103_(_3fsha) local function _104_()
 if _3fsha then
 return R.ok(Commit.new(_3fsha)) else

 return R.ok(nil) end end return unit_97_(_104_()) end return unit_97_(bind_96_(unit_97_(_101_()), _103_)) end return bind_96_(unit_97_(_98_()), _99_) end return task_2fnew(_94_) end



 local function distance_between(ds_package, commit_a, commit_b) _G.assert((nil ~= commit_b), "Missing argument commit-b on ./fnl/pact/datastore/git/init.fnl:113") _G.assert((nil ~= commit_a), "Missing argument commit-a on ./fnl/pact/datastore/git/init.fnl:113") _G.assert((nil ~= ds_package), "Missing argument ds-package on ./fnl/pact/datastore/git/init.fnl:113")
 local function _106_() local _let_107_ = require("pact.lib.ruin.result") local bind_15_auto = _let_107_["bind"] local unit_16_auto = _let_107_["unit"] local bind_108_ = bind_15_auto local unit_109_ = unit_16_auto local function _112_(_110_) local _arg_111_ = _110_ local path = _arg_111_["path"] local function _113_(_) local function _114_(ts_a) local function _115_(ts_b) local function _116_(commit_a_ts) local function _117_(commit_b_ts)







 local function _118_() if (commit_a_ts <= commit_b_ts) then
 return {1, commit_a, commit_b} else
 return {-1, commit_b, commit_a} end end local function _121_(_119_) local _arg_120_ = _119_ local mod = _arg_120_[1] local early = _arg_120_[2] local late = _arg_120_[3] local function _122_(logs) local function _123_()

 return (mod * #logs) end return unit_109_(_123_()) end return unit_109_(bind_108_(unit_109_(Git["log-diff"](path, early.sha, late.sha)), _122_)) end return unit_109_(bind_108_(unit_109_(_118_()), _121_)) end return unit_109_(bind_108_(unit_109_(tonumber(ts_b)), _117_)) end return unit_109_(bind_108_(unit_109_(tonumber(ts_a)), _116_)) end return unit_109_(bind_108_(unit_109_(Git["sha-timestamp"](path, commit_b.sha)), _115_)) end return unit_109_(bind_108_(unit_109_(Git["sha-timestamp"](path, commit_a.sha)), _114_)) end return unit_109_(bind_108_(unit_109_(validate_git_dir(path)), _113_)) end return bind_108_(unit_109_(ds_package), _112_) end return task_2fnew(_106_) end

 local function breaking_between_3f(ds_package, commit_a, commit_b) _G.assert((nil ~= commit_b), "Missing argument commit-b on ./fnl/pact/datastore/git/init.fnl:128") _G.assert((nil ~= commit_a), "Missing argument commit-a on ./fnl/pact/datastore/git/init.fnl:128") _G.assert((nil ~= ds_package), "Missing argument ds-package on ./fnl/pact/datastore/git/init.fnl:128")
 local function _124_() local _let_125_ = require("pact.lib.ruin.result") local bind_15_auto = _let_125_["bind"] local unit_16_auto = _let_125_["unit"] local bind_126_ = bind_15_auto local unit_127_ = unit_16_auto local function _130_(_128_) local _arg_129_ = _128_ local path = _arg_129_["path"] local function _131_(_) local function _132_(ts_a) local function _133_(ts_b) local function _134_(commit_a_ts) local function _135_(commit_b_ts)







 local function _136_() if (commit_a_ts <= commit_b_ts) then
 return {commit_a, commit_b} else
 return {commit_b, commit_a} end end local function _139_(_137_) local _arg_138_ = _137_ local early = _arg_138_[1] local late = _arg_138_[2] local function _140_(breaking_logs) local function _141_()

 return (1 <= #breaking_logs) end return unit_127_(_141_()) end return unit_127_(bind_126_(unit_127_(Git["log-breaking"](path, early.sha, late.sha)), _140_)) end return unit_127_(bind_126_(unit_127_(_136_()), _139_)) end return unit_127_(bind_126_(unit_127_(tonumber(ts_b)), _135_)) end return unit_127_(bind_126_(unit_127_(tonumber(ts_a)), _134_)) end return unit_127_(bind_126_(unit_127_(Git["sha-timestamp"](path, commit_b.sha)), _133_)) end return unit_127_(bind_126_(unit_127_(Git["sha-timestamp"](path, commit_a.sha)), _132_)) end return unit_127_(bind_126_(unit_127_(validate_git_dir(path)), _131_)) end return bind_126_(unit_127_(ds_package), _130_) end return task_2fnew(_124_) end

 local function logs_between(ds_package, commit_a, commit_b) _G.assert((nil ~= commit_b), "Missing argument commit-b on ./fnl/pact/datastore/git/init.fnl:143") _G.assert((nil ~= commit_a), "Missing argument commit-a on ./fnl/pact/datastore/git/init.fnl:143") _G.assert((nil ~= ds_package), "Missing argument ds-package on ./fnl/pact/datastore/git/init.fnl:143")
 local function _142_() local _let_143_ = require("pact.lib.ruin.result") local bind_15_auto = _let_143_["bind"] local unit_16_auto = _let_143_["unit"] local bind_144_ = bind_15_auto local unit_145_ = unit_16_auto local function _148_(_146_) local _arg_147_ = _146_ local path = _arg_147_["path"] local function _149_(_) local function _150_(ts_a) local function _151_(ts_b) local function _152_(commit_a_ts) local function _153_(commit_b_ts)







 local function _154_() if (commit_a_ts <= commit_b_ts) then
 return {1, commit_a, commit_b} else
 return {-1, commit_b, commit_a} end end local function _157_(_155_) local _arg_156_ = _155_ local mod = _arg_156_[1] local early = _arg_156_[2] local late = _arg_156_[3] local function _158_(logs) local function _159_()

 return logs end return unit_145_(_159_()) end return unit_145_(bind_144_(unit_145_(Git["log-diff"](path, early.sha, late.sha)), _158_)) end return unit_145_(bind_144_(unit_145_(_154_()), _157_)) end return unit_145_(bind_144_(unit_145_(tonumber(ts_b)), _153_)) end return unit_145_(bind_144_(unit_145_(tonumber(ts_a)), _152_)) end return unit_145_(bind_144_(unit_145_(Git["sha-timestamp"](path, commit_b.sha)), _151_)) end return unit_145_(bind_144_(unit_145_(Git["sha-timestamp"](path, commit_a.sha)), _150_)) end return unit_145_(bind_144_(unit_145_(validate_git_dir(path)), _149_)) end return bind_144_(unit_145_(ds_package), _148_) end return task_2fnew(_142_) end
 return {register = register, ["fetch-commits"] = fetch_commits, ["setup-commit"] = setup_commit, ["verify-commit"] = verify_commit, ["commit-at-path"] = commit_at_path, ["logs-between"] = logs_between, ["distance-between"] = distance_between, ["breaking-between?"] = breaking_between_3f}