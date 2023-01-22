
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
 local E do local _7_ = require("pact.lib.ruin.enum") E = _7_ end


 local registry = {}



 local bcast_queue = {}

 local function drain_queue()

 local current_queue = bcast_queue local _
 bcast_queue = {} _ = nil
 local function _8_(_241) local _let_9_ = _241 local topic = _let_9_["topic"] local payload = _let_9_["payload"]
 local targets = (registry[topic] or {})
 local function _10_(_2410, _2420) return _2420(E.unpack(payload)) end return E.each(_10_, targets) end return E.each(_8_, current_queue) end





 local __fn_2a_subscribe_dispatch = {bodies = {}, help = {}} local subscribe local function _13_(...) if (0 == #(__fn_2a_subscribe_dispatch).bodies) then error(("multi-arity function " .. "subscribe" .. " has no bodies")) else end local _15_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_subscribe_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _15_ = f_74_auto end if (nil ~= _15_) then local f_74_auto = _15_ return f_74_auto(...) elseif (_15_ == nil) then local view_77_auto do local _16_, _17_ = pcall(require, "fennel") if ((_16_ == true) and ((_G.type(_17_) == "table") and (nil ~= (_17_).view))) then local view_77_auto0 = (_17_).view view_77_auto = view_77_auto0 elseif ((_16_ == false) and true) then local __75_auto = _17_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _19_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _19_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "subscribe", table.concat(_19_, ", "), table.concat((__fn_2a_subscribe_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end subscribe = _13_ local function _22_() local function _23_() table.insert((__fn_2a_subscribe_dispatch).help, "(where [topic-id callback] (function? callback))") local function _24_(...) if (2 == select("#", ...)) then local _25_ = {...} local function _26_(...) local topic_id_11_ = (_25_)[1] local callback_12_ = (_25_)[2] return function_3f(callback_12_) end if (((_G.type(_25_) == "table") and (nil ~= (_25_)[1]) and (nil ~= (_25_)[2])) and _26_(...)) then local topic_id_11_ = (_25_)[1] local callback_12_ = (_25_)[2] local function _27_(topic_id, callback)


 local topic = (registry[topic_id] or {})
 do end (topic)[callback] = true
 registry[topic_id] = topic
 return true end return _27_ else return nil end else return nil end end table.insert((__fn_2a_subscribe_dispatch).bodies, _24_) return subscribe end do local _ = {_23_()} end return subscribe end setmetatable({nil, nil}, {__call = _22_})()

 local __fn_2a_unsubscribe_dispatch = {bodies = {}, help = {}} local unsubscribe local function _32_(...) if (0 == #(__fn_2a_unsubscribe_dispatch).bodies) then error(("multi-arity function " .. "unsubscribe" .. " has no bodies")) else end local _34_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_unsubscribe_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _34_ = f_74_auto end if (nil ~= _34_) then local f_74_auto = _34_ return f_74_auto(...) elseif (_34_ == nil) then local view_77_auto do local _35_, _36_ = pcall(require, "fennel") if ((_35_ == true) and ((_G.type(_36_) == "table") and (nil ~= (_36_).view))) then local view_77_auto0 = (_36_).view view_77_auto = view_77_auto0 elseif ((_35_ == false) and true) then local __75_auto = _36_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _38_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _38_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "unsubscribe", table.concat(_38_, ", "), table.concat((__fn_2a_unsubscribe_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end unsubscribe = _32_ local function _41_() local function _42_() table.insert((__fn_2a_unsubscribe_dispatch).help, "(where [topic-id callback] (function? callback))") local function _43_(...) if (2 == select("#", ...)) then local _44_ = {...} local function _45_(...) local topic_id_30_ = (_44_)[1] local callback_31_ = (_44_)[2] return function_3f(callback_31_) end if (((_G.type(_44_) == "table") and (nil ~= (_44_)[1]) and (nil ~= (_44_)[2])) and _45_(...)) then local topic_id_30_ = (_44_)[1] local callback_31_ = (_44_)[2] local function _46_(topic_id, callback)

 local topic = registry[topic_id]
 if topic then
 topic[callback] = nil
 if E["empty?"](topic) then
 registry[topic_id] = nil else end
 return true else return nil end end return _46_ else return nil end else return nil end end table.insert((__fn_2a_unsubscribe_dispatch).bodies, _43_) return unsubscribe end do local _ = {_42_()} end return unsubscribe end setmetatable({nil, nil}, {__call = _41_})()

 local function broadcast(topic, ...)
 table.insert(bcast_queue, {topic = topic, payload = E.pack(...)})

 if (1 == #bcast_queue) then
 return vim.schedule(drain_queue) else return nil end end

 return {subscribe = subscribe, unsubscribe = unsubscribe, broadcast = broadcast}