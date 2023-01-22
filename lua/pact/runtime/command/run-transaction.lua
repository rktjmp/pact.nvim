
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local R, E, FS, inspect, Package, _local_15_, _local_16_, Transaction = nil, nil, nil, nil, nil, nil, nil, nil do local _14_ = require("pact.runtime.transaction") local _13_ = require("pact.task") local _12_ = string local _11_ = require("pact.package") local _10_ = require("pact.inspect") local _9_ = require("pact.fs") local _8_ = require("pact.lib.ruin.enum") local _7_ = require("pact.lib.ruin.result") R, E, FS, inspect, Package, _local_15_, _local_16_, Transaction = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_ end local _local_17_ = _local_15_





 local fmt = _local_17_["format"] local _local_18_ = _local_16_
 local task_2fawait = _local_18_["await"]

 local task_2fawait_schedule = _local_18_["await-schedule"] local task_2fnew = _local_18_["new"] local task_2frun = _local_18_["run"] local task_2ftrace = _local_18_["trace"] do local _ = {nil, nil} end


 local __hack_render = nil

 local function run_afters(t, packages) _G.assert((nil ~= packages), "Missing argument packages on ./fnl/pact/runtime/command/run-transaction.fnl:18") _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/command/run-transaction.fnl:18")



 local function unique_afters(canonical_set)





 local function _19_(acc, after)



 local _20_ = type(after) if (_20_ == "function") then
 return E["set$"](acc, after, after) elseif (_20_ == "string") then
 local function _21_() return vim.cmd(after) end return E["set$"](acc, after, _21_) else return nil end end local function _23_(_241) local _24_ = _241.after local function _25_() local f = _24_ return function_3f(f) end if ((nil ~= _24_) and _25_()) then local f = _24_ return f else local function _26_() local s = _24_ return string_3f(s) end if ((nil ~= _24_) and _26_()) then local s = _24_ return s elseif (nil ~= _24_) then local other = _24_ local function _27_() return error(fmt("`after` must be function or string, got %s", type(other))) end return _27_ else return nil end end end return E.reduce(_19_, {}, E.map(_23_, canonical_set)) end













































 local function _29_(_241) return task_2fawait(_241) end local function _30_(canonical_set, canonical_id) local _let_31_ = canonical_set local canonical_package = _let_31_[1] local call_chain = {} local pre if canonical_package["opt?"] then local function _32_() return vim.cmd(fmt("packadd! %s", canonical_package["package-name"])) end pre = table.insert(call_chain, _32_) else pre = nil end local afters = unique_afters(canonical_set) local _ if (1 < #E.keys(afters)) then local function _34_() return vim.notify(fmt("%s.after had multiple different definitions, execution order is not guaranteed.", canonical_package.name), vim.log.levels.WARN) end _ = table.insert(call_chain, 1, _34_) else _ = nil end local _0 local function _36_(_241) return table.insert(call_chain, _241) end _0 = E.each(_36_, afters) local _1 = Package["increment-tasks-waiting"](canonical_package) local task local function _37_() local _2 = Package["decrement-tasks-waiting"](canonical_package) local _3 = Package["increment-tasks-active"](canonical_package) local _4 = task_2ftrace("Running after") local _5 t.progress.afters.waiting = (t.progress.afters.waiting - 1) _5 = nil local _6 t.progress.afters.running = (t.progress.afters.running + 1) _6 = nil local _7 = __hack_render() local after_helpers = {trace = task_2ftrace, path = Transaction["package-path"](t, canonical_package)} local result local function _38_() local _39_, _40_ = nil, nil local function _41_(_2411) return _2411(after_helpers) end _39_, _40_ = pcall(E.each, _41_, call_chain) if ((_39_ == true) and true) then local _8 = _40_ return R.ok() elseif ((_39_ == false) and (nil ~= _40_)) then local err = _40_ vim.notify(fmt("%s.after encountered an error: %s", canonical_package.name, err), vim.log.levels.ERROR) return R.err(err) else return nil end end result = task_2fawait_schedule(_38_) local _8 canonical_package.transaction = "done" _8 = nil local _9 t.progress.afters.running = (t.progress.afters.running - 1) _9 = nil local _10 t.progress.afters.done = (t.progress.afters.done + 1) _10 = nil local _11 = __hack_render() local _12 = Package["decrement-tasks-active"](canonical_package) return result end task = _37_ local function _43_(_241) return Package["add-event"](canonical_package, "transaction-after", _241) end return task_2frun(task, {traced = _43_}) end local function _44_(_241) return _241["canonical-id"] end local function _45_(_241) return _241.after end local function _46_(_241) local _48_ do local _47_ = _241 if ((_G.type(_47_) == "table") and ((_47_).action == "align")) then _48_ = true elseif true then local __1_auto = _47_ _48_ = false else _48_ = nil end end if _48_ then return _241 else return nil end end local function _53_() return Package.iter(packages) end return E.map(_29_, E.map(_30_, E["group-by"](_44_, E.filter(_45_, E.map(_46_, _53_))))) end

 local function transact_package_set(transaction, canonical_set) _G.assert((nil ~= canonical_set), "Missing argument canonical-set on ./fnl/pact/runtime/command/run-transaction.fnl:82") _G.assert((nil ~= transaction), "Missing argument transaction on ./fnl/pact/runtime/command/run-transaction.fnl:82")
 local _let_54_ = canonical_set local canonical_package = _let_54_[1]
 Transaction["package-waiting->package-running"](transaction)
 __hack_render()
 local function _55_(p) p.transaction = "start"

 Package["decrement-tasks-waiting"](p)
 return Package["increment-tasks-active"](p) end E.each(_55_, canonical_set)

 local result do local _56_ = canonical_package.action if (_56_ == "discard") then
 result = Transaction["discard-package"](transaction, canonical_package) elseif (_56_ == "retain") then
 result = Transaction["retain-package"](transaction, canonical_package) elseif (_56_ == "align") then
 result = Transaction["align-package"](transaction, canonical_package) elseif true then local _ = _56_
 result = R.err({"unhandled", canonical_package.action}) else result = nil end end
 local function _58_(p)
 if not p.after then p.transaction = "done" else end

 return Package["decrement-tasks-active"](p) end E.each(_58_, canonical_set)

 __hack_render()
 Transaction["package-running->package-done"](transaction)
 return result end

 local function run_transaction(runtime, update_win) _G.assert((nil ~= update_win), "Missing argument update-win on ./fnl/pact/runtime/command/run-transaction.fnl:105") _G.assert((nil ~= runtime), "Missing argument runtime on ./fnl/pact/runtime/command/run-transaction.fnl:105")
 local function _60_() local _let_61_ = require("pact.lib.ruin.result") local bind_15_auto = _let_61_["bind"] local unit_16_auto = _let_61_["unit"] local bind_62_ = bind_15_auto local unit_63_ = unit_16_auto local function _64_(t) local function _65_(_)


 local function _66_(_2410) return _2410["canonical-id"], _2410 end
 local function _67_() return Package.iter(runtime.packages) end local function _68_(canonical_sets) local function _69_(_0)


 local function _72_(acc, _70_) local _arg_71_ = _70_ local p = _arg_71_[1]
 if ((p.action == "align") and not_nil_3f(p.after)) then
 return (acc + 1) else return acc end end t.progress.afters.waiting = E.reduce(_72_, 0, canonical_sets) local function _74_(_1)

 local function _75_() local function _76_() return update_win(t.progress.packages.waiting, t.progress.packages.running, t.progress.packages.done, t.progress.afters.waiting, t.progress.afters.running, t.progress.afters.done) end return vim.schedule(_76_) end __hack_render = _75_ local function _77_(_2) local function _78_(_3)








 local function _79_() return Package.iter(runtime.packages) end local function _80_(_4)
 local function _81_(canonical_set, canonical_id)
 local task local function _82_() return transact_package_set(t, canonical_set) end task = task_2fnew(_82_)
 task["queued-at"] = vim.loop.hrtime()

 local function _83_(msg)
 local function _84_(_2410) return Package["add-event"](_2410, "transaction", msg) end return E.each(_84_, canonical_set) end return task_2frun(task, {traced = _83_}) end local function _85_(package_tasks) local function _88_(_86_)




 local _arg_87_ = _86_ local ok_results = _arg_87_[true] local err_results = _arg_87_[false] local function _89_()

 if not err_results then




 Transaction.commit(t)

 local function _90_()
 vim.notify(fmt("Committed %s", t.id), vim.log.levels.INFO)

 vim.cmd("packloadall!")
 return vim.cmd("silent! helptags ALL") end task_2fawait_schedule(_90_)
 local a = vim.loop.hrtime()
 local _5 = print("running-afters", a)
 local _6 = run_afters(t, runtime.packages)
 local b = vim.loop.hrtime()
 local _7 = print("ran-afters", ((b - a) / 1000000), "ms")
 local function _91_() return vim.notify(fmt("Transaction complete %s", t.id), vim.log.levels.INFO) end vim.schedule(_91_)

 R.ok() else

 local function _92_(_2410) return vim.notify(tostring(_2410), vim.log.levels.error) end E.each(_92_, err_results)
 Transaction.cancel(t)
 R.err("not-committed") end
 return {traced = print} end return unit_63_(_89_()) end return unit_63_(bind_62_(unit_63_(E["group-by"](R["ok?"], task_2fawait(package_tasks))), _88_)) end return unit_63_(bind_62_(unit_63_(E.map(_81_, canonical_sets)), _85_)) end return unit_63_(bind_62_(unit_63_(E.each(Package["increment-tasks-waiting"], _79_)), _80_)) end return unit_63_(bind_62_(unit_63_(__hack_render()), _78_)) end return unit_63_(bind_62_(unit_63_(nil), _77_)) end return unit_63_(bind_62_(unit_63_(nil), _74_)) end return unit_63_(bind_62_(unit_63_(Transaction["packages-waiting"](t, #E.keys(canonical_sets))), _69_)) end return unit_63_(bind_62_(unit_63_(E["group-by"](_66_, _67_)), _68_)) end return unit_63_(bind_62_(unit_63_(Transaction.prepare(t)), _65_)) end return bind_62_(unit_63_(Transaction.new(runtime.datastore, runtime.path.data)), _64_) end return task_2frun(_60_) end return run_transaction