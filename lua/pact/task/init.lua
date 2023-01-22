
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local inspect, gen_id, E, R, _local_13_, _local_14_ = nil, nil, nil, nil, nil, nil do local _12_ = vim local _11_ = string local _10_ = require("pact.lib.ruin.result") local _9_ = require("pact.lib.ruin.enum") local _8_ = require("pact.gen-id") local _7_ = require("pact.inspect") inspect, gen_id, E, R, _local_13_, _local_14_ = _7_, _8_, _9_, _10_, _11_, _12_ end local _local_15_ = _local_13_



 local fmt = _local_15_["format"] local _local_16_ = _local_14_
 local uv = _local_16_["loop"]

 local M = {}

 local function start_timer(task)
 return E["set$"](task, "timer", uv.now()) end

 local function stop_timer(task)
 return E["set$"](task, "timer", (uv.now() - task.timer)) end

 local function awaitable_3f(a)
 local _17_ = a if ((_G.type(_17_) == "table") and (nil ~= (_17_).awaiting) and (nil ~= (_17_)["awaited?"]) and (nil ~= (_17_)["return"])) then local awaiting = (_17_).awaiting local awaited_3f = (_17_)["awaited?"] local _return = (_17_)["return"] return true elseif true then local __1_auto = _17_ return false else return nil end end

 local __fn_2a_new_awaitable_dispatch = {bodies = {}, help = {}} local new_awaitable local function _22_(...) if (0 == #(__fn_2a_new_awaitable_dispatch).bodies) then error(("multi-arity function " .. "new-awaitable" .. " has no bodies")) else end local _24_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_awaitable_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _24_ = f_74_auto end if (nil ~= _24_) then local f_74_auto = _24_ return f_74_auto(...) elseif (_24_ == nil) then local view_77_auto do local _25_, _26_ = pcall(require, "fennel") if ((_25_ == true) and ((_G.type(_26_) == "table") and (nil ~= (_26_).view))) then local view_77_auto0 = (_26_).view view_77_auto = view_77_auto0 elseif ((_25_ == false) and true) then local __75_auto = _26_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _28_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _28_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "new-awaitable", table.concat(_28_, ", "), table.concat((__fn_2a_new_awaitable_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end new_awaitable = _22_ local function _31_() local _32_ do table.insert((__fn_2a_new_awaitable_dispatch).help, "(where [tasks] (and (seq? tasks) (M.task? (. tasks 1))))") local function _33_(...) if (1 == select("#", ...)) then local _34_ = {...} local function _35_(...) local tasks_19_ = (_34_)[1] return (seq_3f(tasks_19_) and M["task?"]((tasks_19_)[1])) end if (((_G.type(_34_) == "table") and (nil ~= (_34_)[1])) and _35_(...)) then local tasks_19_ = (_34_)[1] local function _36_(tasks)







 local function _37_() local function _38_(_2410) return ("dead" == coroutine.status(_2410.thread)) end return E["all?"](_38_, tasks) end

 local function _39_() local function _40_(vals, t, i)
 if M["task?"](t) then



 vals[i] = t.value else end
 return vals end return E.reduce(_40_, {n = #tasks}, tasks) end return {awaiting = tasks, ["awaited?"] = _37_, ["return"] = _39_} end return _36_ else return nil end else return nil end end table.insert((__fn_2a_new_awaitable_dispatch).bodies, _33_) _32_ = new_awaitable end local _44_ do table.insert((__fn_2a_new_awaitable_dispatch).help, "(where [thread] (thread? thread))") local function _45_(...) if (1 == select("#", ...)) then local _46_ = {...} local function _47_(...) local thread_20_ = (_46_)[1] return thread_3f(thread_20_) end if (((_G.type(_46_) == "table") and (nil ~= (_46_)[1])) and _47_(...)) then local thread_20_ = (_46_)[1] local function _48_(thread)



 local function _49_() return ("dead" == coroutine.status(thread)) end
 local function _50_() return nil end return {awaiting = {thread}, ["awaited?"] = _49_, ["return"] = _50_} end return _48_ else return nil end else return nil end end table.insert((__fn_2a_new_awaitable_dispatch).bodies, _45_) _44_ = new_awaitable end local function _53_() table.insert((__fn_2a_new_awaitable_dispatch).help, "(where [task] (. task \"thread\"))") local function _54_(...) if (1 == select("#", ...)) then local _55_ = {...} local function _56_(...) local task_21_ = (_55_)[1] return (task_21_).thread end if (((_G.type(_55_) == "table") and (nil ~= (_55_)[1])) and _56_(...)) then local task_21_ = (_55_)[1] local function _57_(task)


 local function _58_() return ("dead" == coroutine.status(task.thread)) end
 local function _59_() return task.value end return {awaiting = {task}, ["awaited?"] = _58_, ["return"] = _59_} end return _57_ else return nil end else return nil end end table.insert((__fn_2a_new_awaitable_dispatch).bodies, _54_) return new_awaitable end do local _ = {_32_, _44_, _53_()} end return new_awaitable end setmetatable({nil, nil}, {__call = _31_})()


 local function resume(task, ...)

 local _62_ = {coroutine.resume(task.thread, ...)} local function _63_(...) local msg_f = ((_62_)[2])[1] local msg = ((_62_)[2])[2] return function_3f(msg_f, msg) end if (((_G.type(_62_) == "table") and ((_62_)[1] == true) and ((_G.type((_62_)[2]) == "table") and (nil ~= ((_62_)[2])[1]) and (nil ~= ((_62_)[2])[2]))) and _63_(...)) then local msg_f = ((_62_)[2])[1] local msg = ((_62_)[2])[2]













 table.insert(task.events, {"message", msg})
 return "trace", {msg_f, msg} else local function _64_(...) local awaitable = (_62_)[2] return awaitable_3f(awaitable) end if (((_G.type(_62_) == "table") and ((_62_)[1] == true) and (nil ~= (_62_)[2])) and _64_(...)) then local awaitable = (_62_)[2]



 table.insert(task.events, {"suspend"})
 do end (task)["awaiting"] = awaitable
 return "wait", awaitable else local function _65_(...) local thread = (_62_)[2] return thread_3f(thread) end if (((_G.type(_62_) == "table") and ((_62_)[1] == true) and (nil ~= (_62_)[2])) and _65_(...)) then local thread = (_62_)[2]






 table.insert(task.events, {"suspended"})
 do end (task)["awaiting"] = new_awaitable(thread)
 return "wait", thread else local function _66_(...) local ok = (_62_)[2] return R["ok?"](ok) end if (((_G.type(_62_) == "table") and ((_62_)[1] == true) and (nil ~= (_62_)[2])) and _66_(...)) then local ok = (_62_)[2]




 stop_timer(task)
 do end (task)["value"] = ok
 table.insert(task.events, {"value", ok})
 return "halt", ok else local function _67_(...) local err = (_62_)[2] return R["err?"](err) end if (((_G.type(_62_) == "table") and ((_62_)[1] == true) and (nil ~= (_62_)[2])) and _67_(...)) then local err = (_62_)[2]





 stop_timer(task)
 do end (task)["value"] = err
 table.insert(task.events, {"value", err})
 return "halt", err elseif ((_G.type(_62_) == "table") and ((_62_)[1] == false) and (nil ~= (_62_)[2])) then local err = (_62_)[2]




 local err0 = R.err(debug.traceback(task.thread, err))
 stop_timer(task)
 do end (task)["value"] = err0
 table.insert(task.events, {"crash", err0})
 return "crash", err0 elseif (nil ~= _62_) then local any = _62_



 local t_s = inspect(task, true)
 local d_s = inspect(any, true) local msg = "OOPS! A task returned an unexpected value! Please report this error!"

 local err = string.format("%s, task: %s data: %s", msg, t_s, d_s)
 local function _68_() return vim.api.nvim_err_writeln(err) end vim.schedule(_68_)
 return "halt", err else return nil end end end end end end

 M.exec = function(task)
 local _70_ = task local function _71_() return (nil == task.timer) end if ((_70_ == task) and _71_()) then



 start_timer(task)
 return resume(task) else local function _72_() local awaiting = (_70_).awaiting return not awaiting["awaited?"]() end if (((_G.type(_70_) == "table") and (nil ~= (_70_).awaiting)) and _72_()) then local awaiting = (_70_).awaiting



 return "wait", awaiting else local function _73_() local awaiting = (_70_).awaiting return awaiting["awaited?"]() end if (((_G.type(_70_) == "table") and (nil ~= (_70_).awaiting)) and _73_()) then local awaiting = (_70_).awaiting




 task["awaiting"] = nil
 return resume(task, awaiting["return"]()) else local function _74_() return true end if ((_70_ == task) and _74_()) then



 return resume(task) else return nil end end end end end

 M["task?"] = function(t)

 local _76_ = t if ((_G.type(_76_) == "table") and (nil ~= (_76_).thread)) then local thread = (_76_).thread return true elseif true then local __1_auto = _76_ return false else return nil end end

 M.await = function(a) _G.assert((nil ~= a), "Missing argument a on ./fnl/pact/task/init.fnl:145")
 return coroutine.yield(new_awaitable(a)) end

 M.trace = function(msg, ...)





 local _let_78_ = require("pact.task.scheduler") local default_scheduler = _let_78_["default-scheduler"] local trace = _let_78_["trace"]
 local msg0 = fmt(msg, ...)
 local _79_ = coroutine.running() if (nil ~= _79_) then local thread = _79_
 return trace(default_scheduler, thread, msg0) else return nil end end

 M["cb->await"] = function(func, ...)






















 assert(coroutine.running(), "must call await inside (async ...)")
 local argv = E.pack(...)
 local awaited_value = nil
 local function create_thread(func0, argv0)
 local await_co = coroutine.running() local resolve_future
 local function _81_(...)

 awaited_value = E.pack(...)

 return coroutine.resume(await_co) end resolve_future = _81_
 local _ = table.insert(argv0, resolve_future) local _0
 argv0.n = (argv0.n + 1) _0 = nil



 local first_return = E.pack(func0(E.unpack(argv0)))
 local _82_ = first_return if ((_G.type(_82_) == "table") and ((_82_)[1] == nil) and (nil ~= (_82_)[2])) then local err = (_82_)[2] local _rest = {select(3, (table.unpack or _G.unpack)(_82_))}

 return E.unpack(first_return) elseif true then local _1 = _82_




 return coroutine.yield(await_co, E.unpack(first_return)) else return nil end end
 local await_co = coroutine.create(create_thread)
 local vals = E.pack(coroutine.resume(await_co, func, argv))
 do local _84_ = vals if ((_G.type(_84_) == "table") and ((_84_)[1] == false) and (nil ~= (_84_)[2])) then local err = (_84_)[2]

 error(err) elseif ((_G.type(_84_) == "table") and ((_84_)[1] == true) and ((_84_)[2] == nil)) then local rest = {select(3, (table.unpack or _G.unpack)(_84_))}


 awaited_value = E.pack(E.unpack(vals, 2)) else local function _85_(...) local thread = (_84_)[2] local rest = {select(3, (table.unpack or _G.unpack)(_84_))} return thread_3f(thread) end if (((_G.type(_84_) == "table") and ((_84_)[1] == true) and (nil ~= (_84_)[2])) and _85_(...)) then local thread = (_84_)[2] local rest = {select(3, (table.unpack or _G.unpack)(_84_))}

 coroutine.yield(E.unpack(vals, 2)) else end end end


 return E.unpack(awaited_value) end

 M["await-schedule"] = function(f)
 local function _87_(cb)
 local function _88_() return cb(f()) end return vim.schedule(_88_) end return M["cb->await"](_87_) end

 local __fn_2a_M__run_dispatch = {bodies = {}, help = {}} local function _95_(...) if (0 == #(__fn_2a_M__run_dispatch).bodies) then error(("multi-arity function " .. "M.run" .. " has no bodies")) else end local _97_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__run_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _97_ = f_74_auto end if (nil ~= _97_) then local f_74_auto = _97_ return f_74_auto(...) elseif (_97_ == nil) then local view_77_auto do local _98_, _99_ = pcall(require, "fennel") if ((_98_ == true) and ((_G.type(_99_) == "table") and (nil ~= (_99_).view))) then local view_77_auto0 = (_99_).view view_77_auto = view_77_auto0 elseif ((_98_ == false) and true) then local __75_auto = _99_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _101_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _101_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "M.run", table.concat(_101_, ", "), table.concat((__fn_2a_M__run_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end M.run = _95_ local function _104_() local _105_ do table.insert((__fn_2a_M__run_dispatch).help, "(where [f] (function? f))") local function _106_(...) if (1 == select("#", ...)) then local _107_ = {...} local function _108_(...) local f_89_ = (_107_)[1] return function_3f(f_89_) end if (((_G.type(_107_) == "table") and (nil ~= (_107_)[1])) and _108_(...)) then local f_89_ = (_107_)[1] local function _109_(f)





 return M.run(M.new(f)) end return _109_ else return nil end else return nil end end table.insert((__fn_2a_M__run_dispatch).bodies, _106_) _105_ = M.run end local _112_ do table.insert((__fn_2a_M__run_dispatch).help, "(where [f opts] (and (function? f) (table? opts)))") local function _113_(...) if (2 == select("#", ...)) then local _114_ = {...} local function _115_(...) local f_90_ = (_114_)[1] local opts_91_ = (_114_)[2] return (function_3f(f_90_) and table_3f(opts_91_)) end if (((_G.type(_114_) == "table") and (nil ~= (_114_)[1]) and (nil ~= (_114_)[2])) and _115_(...)) then local f_90_ = (_114_)[1] local opts_91_ = (_114_)[2] local function _116_(f, opts)

 return M.run(M.new(f), opts) end return _116_ else return nil end else return nil end end table.insert((__fn_2a_M__run_dispatch).bodies, _113_) _112_ = M.run end local _119_ do table.insert((__fn_2a_M__run_dispatch).help, "(where [task] (M.task? task))") local function _120_(...) if (1 == select("#", ...)) then local _121_ = {...} local function _122_(...) local task_92_ = (_121_)[1] return M["task?"](task_92_) end if (((_G.type(_121_) == "table") and (nil ~= (_121_)[1])) and _122_(...)) then local task_92_ = (_121_)[1] local function _123_(task)

 return M.run(task, {}) end return _123_ else return nil end else return nil end end table.insert((__fn_2a_M__run_dispatch).bodies, _120_) _119_ = M.run end local function _126_() table.insert((__fn_2a_M__run_dispatch).help, "(where [task opts] (and (M.task? task) (table? opts)))") local function _127_(...) if (2 == select("#", ...)) then local _128_ = {...} local function _129_(...) local task_93_ = (_128_)[1] local opts_94_ = (_128_)[2] return (M["task?"](task_93_) and table_3f(opts_94_)) end if (((_G.type(_128_) == "table") and (nil ~= (_128_)[1]) and (nil ~= (_128_)[2])) and _129_(...)) then local task_93_ = (_128_)[1] local opts_94_ = (_128_)[2] local function _130_(task, opts)

 local _let_131_ = require("pact.task.scheduler") local queue_task = _let_131_["queue-task"] local default_scheduler = _let_131_["default-scheduler"]
 queue_task(default_scheduler, task, opts)
 return task end return _130_ else return nil end else return nil end end table.insert((__fn_2a_M__run_dispatch).bodies, _127_) return M.run end do local _ = {_105_, _112_, _119_, _126_()} end return M.run end setmetatable({nil, nil}, {__call = _104_})()

 local __fn_2a_M__new_dispatch = {bodies = {}, help = {}} local function _137_(...) if (0 == #(__fn_2a_M__new_dispatch).bodies) then error(("multi-arity function " .. "M.new" .. " has no bodies")) else end local _139_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_M__new_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _139_ = f_74_auto end if (nil ~= _139_) then local f_74_auto = _139_ return f_74_auto(...) elseif (_139_ == nil) then local view_77_auto do local _140_, _141_ = pcall(require, "fennel") if ((_140_ == true) and ((_G.type(_141_) == "table") and (nil ~= (_141_).view))) then local view_77_auto0 = (_141_).view view_77_auto = view_77_auto0 elseif ((_140_ == false) and true) then local __75_auto = _141_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _143_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _143_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "M.new", table.concat(_143_, ", "), table.concat((__fn_2a_M__new_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end M.new = _137_ local function _146_() local _147_ do table.insert((__fn_2a_M__new_dispatch).help, "(where [f] (function? f))") local function _148_(...) if (1 == select("#", ...)) then local _149_ = {...} local function _150_(...) local f_134_ = (_149_)[1] return function_3f(f_134_) end if (((_G.type(_149_) == "table") and (nil ~= (_149_)[1])) and _150_(...)) then local f_134_ = (_149_)[1] local function _151_(f)

 return M.new("anonymous", f) end return _151_ else return nil end else return nil end end table.insert((__fn_2a_M__new_dispatch).bodies, _148_) _147_ = M.new end local function _154_() table.insert((__fn_2a_M__new_dispatch).help, "(where [id f] (and (string? id) (function? f)))") local function _155_(...) if (2 == select("#", ...)) then local _156_ = {...} local function _157_(...) local id_135_ = (_156_)[1] local f_136_ = (_156_)[2] return (string_3f(id_135_) and function_3f(f_136_)) end if (((_G.type(_156_) == "table") and (nil ~= (_156_)[1]) and (nil ~= (_156_)[2])) and _157_(...)) then local id_135_ = (_156_)[1] local f_136_ = (_156_)[2] local function _158_(id, f)

 local t = {id = gen_id((id .. "-task")), thread = nil, value = nil, events = {}, timer = nil, awaiting = nil}





 local function _159_(...)
 t.value = f(...)
 return t.value end t.thread = coroutine.create(_159_)
 return t end return _158_ else return nil end else return nil end end table.insert((__fn_2a_M__new_dispatch).bodies, _155_) return M.new end do local _ = {_147_, _154_()} end return M.new end setmetatable({nil, nil}, {__call = _146_})()


 M.task = M.new
 M.async = M.run

 return M