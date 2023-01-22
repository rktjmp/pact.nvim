
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local R, E, PubSub, gen_id, Log, _local_14_, _local_15_ = nil, nil, nil, nil, nil, nil, nil do local _13_ = vim local _12_ = string local _11_ = require("pact.log") local _10_ = require("pact.gen-id") local _9_ = require("pact.pubsub") local _8_ = require("pact.lib.ruin.enum") local _7_ = require("pact.lib.ruin.result") R, E, PubSub, gen_id, Log, _local_14_, _local_15_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_ end local _local_16_ = _local_14_




 local fmt = _local_16_["format"] local _local_17_ = _local_15_
 local uv = _local_17_["loop"]

 local function tasks_iter(tasks)

 local iter local function _18_()
 local function _19_(_241) local function _20_(task, parents)
 return coroutine.yield(task, parents) end
 local function _21_(_2410) return _2410.tasks end return E["depth-walk"](_20_, _241, _21_) end return E.each(_19_, tasks) end iter = _18_

 return coroutine.wrap(iter), 0, 0 end

 local function add_child_task(parent_context, child_context)

 table.insert(parent_context.tasks, child_context)
 child_context.parent = parent_context return nil end

 local function remove_child_task(task_context, child_context)

 local function _22_(_241) return (_241.id == child_context.id) end task_context.tasks = E.reject(_22_, task_context.tasks) return nil end


 local function make_timer_cb(scheduler)

 local function _23_() local runnable local function _24_(acc, task_context)
 if E["empty?"](task_context.tasks) then
 table.insert(acc, task_context) else end
 if (#acc == scheduler["concurrency-limit"]) then
 return E.reduced(acc) else
 return acc end end
 local function _27_() return tasks_iter(scheduler.tasks) end runnable = E.reduce(_24_, {}, _27_)

 local _let_28_ = require("pact.task") local task_2fexec = _let_28_["exec"] local results
 local function _29_(task_context)
 local _ scheduler["current-task"] = task_context _ = nil
 local action, value = task_2fexec(task_context.task) local _0
 scheduler["current-task"] = nil _0 = nil
 return {task_context, action, value} end results = E.map(_29_, runnable) local _


 local function _32_(_30_) local _arg_31_ = _30_ local task_context = _arg_31_[1] local action = _arg_31_[2] local _value = _arg_31_[3]
 local _33_ = action if (_33_ == "halt") then
 return remove_child_task((task_context.parent or scheduler), task_context) elseif (_33_ == "crash") then

 return remove_child_task((task_context.parent or scheduler), task_context) else return nil end end _ = E.each(_32_, results) local _0



 local function _37_(_35_) local _arg_36_ = _35_ local task_context = _arg_36_[1] local action = _arg_36_[2] local value = _arg_36_[3]
 local _38_ = {action, value} if ((_G.type(_38_) == "table") and ((_38_)[1] == "trace") and ((_G.type((_38_)[2]) == "table") and (nil ~= ((_38_)[2])[1]) and (nil ~= ((_38_)[2])[2]))) then local f = ((_38_)[2])[1] local msg = ((_38_)[2])[2]

 local _39_, _40_ = pcall(f, msg) if ((_39_ == false) and (nil ~= _40_)) then local err = _40_

 local function _41_() return vim.notify(fmt("Task (%s) trace handler crashed: %s", task_context.task.id, err), vim.log.levels.ERROR) end return vim.schedule(_41_) else return nil end elseif ((_G.type(_38_) == "table") and ((_38_)[1] == "crash") and (nil ~= (_38_)[2])) then local err = (_38_)[2]




 local msg = debug.traceback(task_context.task.thread, fmt("Task (%s) crashed: %s", task_context.task.id, tostring(err)))



 Log.log(msg)
 local function _43_() return vim.notify(msg, vim.log.levels.ERROR) end return vim.schedule(_43_) else local function _44_() local err = (_38_)[2] return R["err?"](err) end if (((_G.type(_38_) == "table") and ((_38_)[1] == "halt") and (nil ~= (_38_)[2])) and _44_()) then local err = (_38_)[2]


 local function _45_() return vim.notify(fmt("Task (%s) returned an error: %s", task_context.task.id, tostring(err)), vim.log.levels.WARN) end return vim.schedule(_45_) else return nil end end end _0 = E.each(_37_, results)




 PubSub.broadcast(scheduler, "tick")
 if (0 == #scheduler.tasks) then

 uv.timer_stop(scheduler["timer-handle"])
 uv.close(scheduler["timer-handle"])
 do end (scheduler)["timer-handle"] = nil return nil else return nil end end return _23_ end

 local function trace(scheduler, thread, message)

 local _local_48_ = require("pact.lib.ruin.iter") local bward = _local_48_["bward"]
 local else_fn_49_ local function _50_(...) local _51_ = ... if true then local _ = _51_








 local function _52_() return nil end return _52_ else return nil end end else_fn_49_ = _50_ local function down_18_auto(...) local _54_, _55_ = ... if ((nil ~= _54_) and (nil ~= _55_)) then local task_context = _54_ local parents = _55_ local function down_18_auto0(...) local _56_, _57_ = ... if (true and ((_G.type(_57_) == "table") and (nil ~= (_57_).traced))) then local _index = _56_ local traced = (_57_).traced return coroutine.yield({traced, message}) elseif true then local _ = _56_ return else_fn_49_(...) else return nil end end local function _63_(...) if task_context.traced then return 0, task_context else local function _59_(_241, _242) local _60_ = _242 if ((_G.type(_60_) == "table") and (nil ~= (_60_).traced)) then local traced = (_60_).traced return true elseif true then local __1_auto = _60_ return false else return nil end end local function _62_() return bward(parents) end return E.find(_59_, _62_) end end return down_18_auto0(_63_(...)) elseif true then local _ = _54_ return else_fn_49_(...) else return nil end end local function _65_(task_context, history) return (task_context.task.thread == thread) end local function _66_() return tasks_iter(scheduler.tasks) end return down_18_auto(E.find(_65_, _66_)) end

 local function queue_task(scheduler, task, _3fopts)


 assert((task.thread and task.id), "add-task arg did not look like task")
 local task_context



 local _68_ do local t_67_ = _3fopts if (nil ~= t_67_) then t_67_ = (t_67_).traced else end _68_ = t_67_ end task_context = {id = gen_id((task.id .. "-ctx")), task = task, parent = nil, tasks = {}, traced = _68_}
 add_child_task((scheduler["current-task"] or scheduler), task_context)
 if (nil == scheduler["timer-handle"]) then
 local h = uv.new_timer()
 do end (scheduler)["timer-handle"] = h
 scheduler["created-at"] = vim.loop.hrtime()
 uv.timer_start(h, 0, scheduler["timer-rate-per-ms"], make_timer_cb(scheduler)) else end
 return task end

 local function shutdown(scheduler)

 uv.timer_stop(scheduler["timer-handle"])
 uv.close(scheduler["timer-handle"])
 scheduler.tasks = {} return nil end

 local __fn_2a_new_dispatch = {bodies = {}, help = {}} local new local function _72_(...) if (0 == #(__fn_2a_new_dispatch).bodies) then error(("multi-arity function " .. "new" .. " has no bodies")) else end local _74_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _74_ = f_74_auto end if (nil ~= _74_) then local f_74_auto = _74_ return f_74_auto(...) elseif (_74_ == nil) then local view_77_auto do local _75_, _76_ = pcall(require, "fennel") if ((_75_ == true) and ((_G.type(_76_) == "table") and (nil ~= (_76_).view))) then local view_77_auto0 = (_76_).view view_77_auto = view_77_auto0 elseif ((_75_ == false) and true) then local __75_auto = _76_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _78_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _78_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "new", table.concat(_78_, ", "), table.concat((__fn_2a_new_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end new = _72_ local function _81_() local _82_ do table.insert((__fn_2a_new_dispatch).help, "(where {})") local function _83_(...) if (0 == select("#", ...)) then local _84_ = {...} local function _85_(...) return true end if ((_G.type(_84_) == "table") and _85_(...)) then local function _86_()

 return new({}) end return _86_ else return nil end else return nil end end table.insert((__fn_2a_new_dispatch).bodies, _83_) _82_ = new end local function _89_() table.insert((__fn_2a_new_dispatch).help, "(where [opts])") local function _90_(...) if (1 == select("#", ...)) then local _91_ = {...} local function _92_(...) local opts_71_ = (_91_)[1] return true end if (((_G.type(_91_) == "table") and (nil ~= (_91_)[1])) and _92_(...)) then local opts_71_ = (_91_)[1] local function _93_(opts) local function _94_()


 local t_95_ = opts if (nil ~= t_95_) then t_95_ = (t_95_)["concurrency-limit"] else end return t_95_ end return {id = gen_id("scheduler"), ["concurrency-limit"] = (_94_() or 20), tasks = {}, ["timer-handle"] = nil, ["timer-rate-per-ms"] = (1000 / 30)} end return _93_ else return nil end else return nil end end table.insert((__fn_2a_new_dispatch).bodies, _90_) return new end do local _ = {_82_, _89_()} end return new end setmetatable({nil, nil}, {__call = _81_})()




 local default_scheduler do local config = require("pact.config")
 default_scheduler = new({["concurrency-limit"] = config["concurrency-limit"]}) end

 return {new = new, trace = trace, ["queue-task"] = queue_task, shutdown = shutdown, ["default-scheduler"] = default_scheduler}