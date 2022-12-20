
 local result, _local_6_, enum, _local_7_, _local_8_ = nil, nil, nil, nil, nil do local _5_ = vim local _4_ = string local _3_ = require("pact.lib.ruin.enum") local _2_ = require("pact.lib.ruin.type") local _1_ = require("pact.lib.ruin.result") result, _local_6_, enum, _local_7_, _local_8_ = _1_, _2_, _3_, _4_, _5_ end local _local_9_ = _local_6_

 local string_3f = _local_9_["string?"] local thread_3f = _local_9_["thread?"] local _local_10_ = _local_7_

 local fmt = _local_10_["format"] local _local_11_ = _local_8_
 local uv = _local_11_["loop"] do local _ = {nil, nil} end

 local _local_12_ = require("pact.pubsub") local broadcast = _local_12_["broadcast"]

 local function make_timer_cb(scheduler)
 local function _13_()

 while ((#scheduler.active < scheduler["concurrency-limit"]) and (0 < #scheduler.queue)) do


 local workflow = table.remove(scheduler.queue, 1)
 table.insert(scheduler.active, 1, workflow) end

 local _let_14_ = require("pact.workflow") local run = _let_14_["run"]
 local _let_15_ = require("pact.lib.ruin.result") local ok_3f = _let_15_["ok?"] local err_3f = _let_15_["err?"]



 local function _17_(_241, _242) local _18_, _19_ = run(_242) if ((nil ~= _18_) and (nil ~= _19_)) then local action = _18_ local value = _19_
 return action, {_242, value} elseif true then local _ = _18_
 return error("workflow.run did not return 2 values") else return nil end end local _let_16_ = enum["group-by"](_17_, scheduler.active) local halted = _let_16_["halt"] local continued = _let_16_["cont"] local _




 local function _23_(_0, _21_) local _arg_22_ = _21_ local wf = _arg_22_[1] local _result = _arg_22_[2] return wf end scheduler["active"] = enum.map(_23_, (continued or {})) _ = nil local _0



 local function _24_(_241, _242) local function _27_(_1, _25_) local _arg_26_ = _25_ local wf = _arg_26_[1] local result0 = _arg_26_[2] return broadcast(wf, result0) end return enum.map(_27_, _242) end _0 = enum.map(_24_, {(halted or {}), (continued or {})})


 if (function(_28_,_29_,_30_) return (_28_ == _29_) and (_29_ == _30_) end)(0,#scheduler.queue,#scheduler.active) then
 uv.timer_stop(scheduler["timer-handle"])
 uv.close(scheduler["timer-handle"])
 do end (scheduler)["timer-handle"] = nil return nil else return nil end end return _13_ end

 local __fn_2a_new_dispatch = {bodies = {}, help = {}} local new local function _33_(...) if (0 == #(__fn_2a_new_dispatch).bodies) then error(("multi-arity function " .. "new" .. " has no bodies")) else end local _35_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _35_ = f_74_auto end if (nil ~= _35_) then local f_74_auto = _35_ return f_74_auto(...) elseif (_35_ == nil) then local view_77_auto do local _36_, _37_ = pcall(require, "fennel") if ((_36_ == true) and ((_G.type(_37_) == "table") and (nil ~= (_37_).view))) then local view_77_auto0 = (_37_).view view_77_auto = view_77_auto0 elseif ((_36_ == false) and true) then local __75_auto = _37_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _39_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _39_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "new", table.concat(_39_, ", "), table.concat((__fn_2a_new_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end new = _33_ local function _42_() local _43_ do table.insert((__fn_2a_new_dispatch).help, "(where {})") local function _44_(...) if (0 == select("#", ...)) then local _45_ = {...} local function _46_(...) return true end if ((_G.type(_45_) == "table") and _46_(...)) then local function _47_()

 return new({}) end return _47_ else return nil end else return nil end end table.insert((__fn_2a_new_dispatch).bodies, _44_) _43_ = new end local function _50_() table.insert((__fn_2a_new_dispatch).help, "(where [opts])") local function _51_(...) if (1 == select("#", ...)) then local _52_ = {...} local function _53_(...) local opts_32_ = (_52_)[1] return true end if (((_G.type(_52_) == "table") and (nil ~= (_52_)[1])) and _53_(...)) then local opts_32_ = (_52_)[1] local function _54_(opts) local function _55_()

 local t_56_ = opts if (nil ~= t_56_) then t_56_ = (t_56_)["concurrency-limit"] else end return t_56_ end return {["concurrency-limit"] = (_55_() or 5), queue = {}, active = {}, ["timer-handle"] = nil} end return _54_ else return nil end else return nil end end table.insert((__fn_2a_new_dispatch).bodies, _51_) return new end do local _ = {_43_, _50_()} end return new end setmetatable({nil, nil}, {__call = _42_})()




 local function add_workflow(scheduler, workflow)


 table.insert(scheduler.queue, workflow)
 if (nil == scheduler["timer-handle"]) then
 local h = uv.new_timer()
 do end (scheduler)["timer-handle"] = h
 return uv.timer_start(h, 0, (1000 / 60), make_timer_cb(scheduler)) else return nil end end

 local function stop(scheduler)

 uv.timer_stop(scheduler["timer-handle"])




 for i, _ in ipairs(scheduler.queue) do
 scheduler.queue[i] = nil end
 scheduler["active"] = nil
 return uv.close(scheduler["timer-handle"]) end

 return {new = new, ["add-workflow"] = add_workflow, stop = stop}