
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local R, E, FS, inspect, Datastore, Solver, PubSub, Package, Commit, Constraint, _local_19_, _local_20_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil do local _18_ = require("pact.task") local _17_ = string local _16_ = require("pact.package.git.constraint") local _15_ = require("pact.package.git.commit") local _14_ = require("pact.package") local _13_ = require("pact.pubsub") local _12_ = require("pact.solver") local _11_ = require("pact.datastore") local _10_ = require("pact.inspect") local _9_ = require("pact.fs") local _8_ = require("pact.lib.ruin.enum") local _7_ = require("pact.lib.ruin.result") R, E, FS, inspect, Datastore, Solver, PubSub, Package, Commit, Constraint, _local_19_, _local_20_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_, _16_, _17_, _18_ end local _local_21_ = _local_19_










 local fmt = _local_21_["format"] local _local_22_ = _local_20_
 local task_2fawait = _local_22_["await"] local task_2fnew = _local_22_["new"] local task_2frun = _local_22_["run"] local task_2ftrace = _local_22_["trace"] do local _ = {nil, nil} end

 local function distribute_solved_result(canonical_set, solved_to) _G.assert((nil ~= solved_to), "Missing argument solved-to on ./fnl/pact/runtime/command/initial-load.fnl:18") _G.assert((nil ~= canonical_set), "Missing argument canonical-set on ./fnl/pact/runtime/command/initial-load.fnl:18")
 local _23_ = solved_to if ((_G.type(_23_) == "table") and ((_23_)[1] == "ok") and (nil ~= (_23_)[2])) then local commit = (_23_)[2]



 local function _24_(_241) return Package["set-target-commit"](_241, commit) end E.each(_24_, canonical_set)

 return R.ok(commit) elseif ((_G.type(_23_) == "table") and ((_23_)[1] == "err") and (nil ~= (_23_)[2])) then local mixed = (_23_)[2]






 local function _25_(_241) local _26_ = _241 if ((_G.type(_26_) == "table") and ((_26_)[1] == "ok") and ((_G.type((_26_)[2]) == "table") and (nil ~= ((_26_)[2]).constraint) and ((_G.type(((_26_)[2]).commits) == "table") and (nil ~= (((_26_)[2]).commits)[1])))) then local constraint = ((_26_)[2]).constraint local commit = (((_26_)[2]).commits)[1]



 local function _27_(p)
 Package["set-target-commit"](p, commit)
 return Package["degrade-health"](p, "degraded by sibling") end local function _28_(_2410) return Constraint["equal?"](_2410.constraint, constraint) end return E.each(_27_, E.filter(_28_, canonical_set)) elseif ((_G.type(_26_) == "table") and ((_26_)[1] == "err") and ((_G.type((_26_)[2]) == "table") and (nil ~= ((_26_)[2]).constraint) and (nil ~= ((_26_)[2]).msg))) then local constraint = ((_26_)[2]).constraint local msg = ((_26_)[2]).msg



 local function _29_(_2410) return Package["fail-health"](_2410, msg) end local function _30_(_2410) return Constraint["equal?"](_2410.constraint, constraint) end return E.each(_29_, E.filter(_30_, canonical_set)) else return nil end end E.each(_25_, mixed)

 return R.ok(nil) else return nil end end

 local function process_initial_packages(runtime_prefix, datastore, all_packages) _G.assert((nil ~= all_packages), "Missing argument all-packages on ./fnl/pact/runtime/command/initial-load.fnl:46") _G.assert((nil ~= datastore), "Missing argument datastore on ./fnl/pact/runtime/command/initial-load.fnl:46") _G.assert((nil ~= runtime_prefix), "Missing argument runtime-prefix on ./fnl/pact/runtime/command/initial-load.fnl:46")
 local function make_rock_process_task(sibling_packages, canonical_id)
 E.each(Package["increment-tasks-waiting"], sibling_packages)

 local function _33_()
 E.each(Package["decrement-tasks-waiting"], sibling_packages)
 E.each(Package["increment-tasks-active"], sibling_packages)
 local _34_ do local _let_36_ = require("pact.lib.ruin.result") local bind_15_auto = _let_36_["bind"] local unit_16_auto = _let_36_["unit"] local bind_37_ = bind_15_auto local unit_38_ = unit_16_auto local function _44_(_40_)
 local _arg_41_ = _40_ local _arg_42_ = _arg_41_["install"] local install_path = _arg_42_["path"]
 local _arg_43_ = _arg_41_["rock"] local server = _arg_43_["server"] local name = _arg_43_["name"] local function _45_(dsp) local function _46_()



 local function _47_(p) p.action = "retain" p["ready?"] = true


 return Package["decrement-tasks-active"](p) end E.each(_47_, sibling_packages)

 return R.ok() end return unit_38_(_46_()) end return unit_38_(bind_37_(unit_38_(task_2fawait(task_2frun(Datastore.Rock.register(datastore, canonical_id, name, server)))), _45_)) end _34_ = bind_37_(unit_38_(E.hd(sibling_packages)), _44_) end
 local function _48_(ok) return ok end
 local function _49_(err)
 local function _50_(_241) return Package["fail-health"](_241, inspect(err)) end E.each(_50_, sibling_packages)

 return err end return R.map(_34_, _48_, _49_) end
 local function _51_(msg)
 local function _52_(_241) return PubSub.broadcast(Package["add-event"](_241, "initial-load", msg), "changed") end return E.each(_52_, sibling_packages) end return {task_2fnew(fmt("process-package-%s", canonical_id), _33_), {traced = _51_}} end



 local function make_git_process_task(sibling_packages, canonical_id)








 E.each(Package["increment-tasks-waiting"], sibling_packages)

 local function _53_()
 E.each(Package["decrement-tasks-waiting"], sibling_packages)
 E.each(Package["increment-tasks-active"], sibling_packages)
 local _54_ do local _let_56_ = require("pact.lib.ruin.result") local bind_15_auto = _let_56_["bind"] local unit_16_auto = _let_56_["unit"] local bind_57_ = bind_15_auto local unit_58_ = unit_16_auto local function _64_(_60_)
 local _arg_61_ = _60_ local _arg_62_ = _arg_61_["install"] local install_path = _arg_62_["path"]
 local _arg_63_ = _arg_61_["git"] local origin = _arg_63_["origin"] local function _65_(dsp)



 local function _66_(sha)
 return task_2fawait(task_2frun(Datastore.Git["verify-commit"](dsp, Commit.new(sha)))) end local function _67_(verify_sha) local function _68_(commits) local function _69_(installs_to) local function _70_(head)










 local function _75_() if head then
 local c local function _71_(_241) local _72_ = _241 if ((_G.type(_72_) == "table") and ((_72_).sha == head.sha)) then return true elseif true then local __1_auto = _72_ return false else return nil end end c = (E.find(_71_, commits) or head)
 local function _74_(_241) return Package["set-current-commit"](_241, c) end return E.each(_74_, sibling_packages) else return nil end end local function _76_(_)

 local function _77_(_241) return _241.constraint end local function _78_(constraints)

 local function _79_() local solved = Solver.solve(constraints, commits, verify_sha)
 distribute_solved_result(sibling_packages, solved)



 local function _80_(_241) return R.ok(_241) end
 local function _81_() return R.ok(nil) end return R.map(solved, _80_, _81_) end local function _82_(solved) local function _83_(highest_version_constraint)


 local function _85_() local _84_ = Solver.solve({highest_version_constraint}, commits, verify_sha) if ((_G.type(_84_) == "table") and ((_84_)[1] == "ok") and (nil ~= (_84_)[2])) then local commit = (_84_)[2]
 local function _86_(_241) return Package["set-latest-commit"](_241, commit) end return E.each(_86_, sibling_packages) elseif ((_G.type(_84_) == "table") and ((_84_)[1] == "err") and true) then local _0 = (_84_)[2]
 return nil else return nil end end local function _88_(_0)
 local function _101_() if (head and solved) then
 local function _89_() local _let_90_ = require("pact.lib.ruin.result") local bind_15_auto0 = _let_90_["bind"] local unit_16_auto0 = _let_90_["unit"] local bind_91_ = bind_15_auto0 local unit_92_ = unit_16_auto0 local function _93_(dist_t) local function _94_(break_t) local function _97_(_95_)



 local _arg_96_ = _95_ local distance = _arg_96_[1] local breaking_3f = _arg_96_[2] local function _98_()


 if (R["ok?"](distance) and R["ok?"](breaking_3f)) then
 local function _99_(_2410) return Package["set-target-commit-meta"](_2410, R.unwrap(distance), R.unwrap(breaking_3f)) end return E.each(_99_, sibling_packages) else

 return R.join(distance, breaking_3f) end end return unit_92_(_98_()) end return unit_92_(bind_91_(unit_92_(task_2fawait({dist_t, break_t})), _97_)) end return unit_92_(bind_91_(unit_92_(task_2frun(Datastore.Git["breaking-between?"](dsp, head, solved))), _94_)) end return bind_91_(unit_92_(task_2frun(Datastore.Git["distance-between"](dsp, head, solved))), _93_) end return task_2fawait(task_2frun(_89_)) else return nil end end local function _102_(_1) local function _103_()


 local function _104_(p)
 if p.git.current.commit then p.action = "retain" else p.action = "discard" end p["ready?"] = true





 return Package["decrement-tasks-active"](p) end E.each(_104_, sibling_packages)

 return R.ok() end return unit_58_(_103_()) end return unit_58_(bind_57_(unit_58_(_101_()), _102_)) end return unit_58_(bind_57_(unit_58_(_85_()), _88_)) end return unit_58_(bind_57_(unit_58_(Constraint.version("> 0.0.0")), _83_)) end return unit_58_(bind_57_(unit_58_(_79_()), _82_)) end return unit_58_(bind_57_(unit_58_(E.map(_77_, sibling_packages)), _78_)) end return unit_58_(bind_57_(unit_58_(_75_()), _76_)) end return unit_58_(bind_57_(unit_58_(task_2fawait(task_2frun(Datastore.Git["commit-at-path"](dsp, installs_to)))), _70_)) end return unit_58_(bind_57_(unit_58_(FS["join-path"](runtime_prefix, install_path)), _69_)) end return unit_58_(bind_57_(unit_58_(task_2fawait(task_2frun(Datastore.Git["fetch-commits"](dsp)))), _68_)) end return unit_58_(bind_57_(unit_58_(_66_), _67_)) end return unit_58_(bind_57_(unit_58_(task_2fawait(task_2frun(Datastore.Git.register(datastore, canonical_id, origin)))), _65_)) end _54_ = bind_57_(unit_58_(E.hd(sibling_packages)), _64_) end
 local function _106_(ok) return ok end
 local function _107_(err)
 local function _108_(_241) return Package["fail-health"](_241, inspect(err)) end E.each(_108_, sibling_packages)

 return err end return R.map(_54_, _106_, _107_) end
 local function _109_(msg)
 local function _110_(_241) return PubSub.broadcast(Package["add-event"](_241, "initial-load", msg), "changed") end return E.each(_110_, sibling_packages) end return {task_2fnew(fmt("process-package-%s", canonical_id), _53_), {traced = _109_}} end




 local function make_process_task(sibling_packages, canonical_id)
 local _111_ = sibling_packages if ((_G.type(_111_) == "table") and ((_G.type((_111_)[1]) == "table") and (((_111_)[1]).kind == "git"))) then
 return make_git_process_task(sibling_packages, canonical_id) elseif ((_G.type(_111_) == "table") and ((_G.type((_111_)[1]) == "table") and (((_111_)[1]).kind == "rock"))) then
 return make_rock_process_task(sibling_packages, canonical_id) else return nil end end




 local function _115_(_113_) local _arg_114_ = _113_ local task = _arg_114_[1] local opts = _arg_114_[2]
 return task_2frun(task, opts) end local function _116_(_241) return _241["canonical-id"], _241 end local function _117_() return Package.iter(all_packages) end return E.map(_115_, E.map(make_process_task, E["group-by"](_116_, _117_))) end return process_initial_packages