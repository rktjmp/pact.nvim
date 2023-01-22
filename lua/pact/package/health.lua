
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, _local_9_ = nil, nil do local _8_ = string local _7_ = require("pact.lib.ruin.enum") E, _local_9_ = _7_, _8_ end local _local_10_ = _local_9_
 local fmt = _local_10_["format"]

 local Health = {}

 Health.healthy = function() return {"healthy"} end
 Health["healthy?"] = function(h) local _11_ = h if ((_G.type(_11_) == "table") and ((_11_)[1] == "healthy")) then return true elseif true then local __1_auto = _11_ return false else return nil end end

 Health.degraded = function(msg) return {"degraded", msg} end
 Health["degraded?"] = function(h) local _13_ = h if ((_G.type(_13_) == "table") and ((_13_)[1] == "degraded")) then return true elseif true then local __1_auto = _13_ return false else return nil end end

 Health.failing = function(msg) return {"failing", msg} end
 Health["failing?"] = function(h) local _15_ = h if ((_G.type(_15_) == "table") and ((_15_)[1] == "failing")) then return true elseif true then local __1_auto = _15_ return false else return nil end end

 Health.update = function(old, new)
 local _let_17_ = old local old_kind = _let_17_[1] local rest_old = (function (t, k, e) local mt = getmetatable(t) if 'table' == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) elseif e then local rest = {} for k, v in pairs(t) do if not e[k] then rest[k] = v end end return rest else return {(table.unpack or unpack)(t, k)} end end)(_let_17_, 2)
 local _let_18_ = new local new_kind = _let_18_[1] local rest_new = (function (t, k, e) local mt = getmetatable(t) if 'table' == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) elseif e then local rest = {} for k, v in pairs(t) do if not e[k] then rest[k] = v end end return rest else return {(table.unpack or unpack)(t, k)} end end)(_let_18_, 2) local msgs
 local function _19_() return E["concat$"]({}, rest_new, rest_old) end msgs = _19_ local score
 local function _20_(_241) return ({healthy = 0, degraded = 1, failing = 2})[_241] end score = _20_
 if (score(old_kind) < score(new_kind)) then
 return {new_kind, E.unpack(msgs())} else
 return {old_kind, E.unpack(msgs())} end end

 return Health