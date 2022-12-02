


 local math_path local function _1_(...) local full_mod_path_2_auto = ... local _2_ = full_mod_path_2_auto local function _3_(...) local path_3_auto = _2_ return ("string" == type(path_3_auto)) end if ((nil ~= _2_) and _3_(...)) then local path_3_auto = _2_ if string.find(full_mod_path_2_auto, "monad") then local _4_ = string.match(full_mod_path_2_auto, ("(.+%.)" .. "monad")) if (_4_ == nil) then return "" elseif (nil ~= _4_) then local root_4_auto = _4_ return root_4_auto else return nil end else return error(string.format("relative-root: no match in &from %q for %q", full_mod_path_2_auto, "monad")) end elseif (_2_ == nil) then return "" else return nil end end math_path = ((_1_(...) or "") .. "math")

 local function m__3e(monad_t, ival, ...)
 assert(monad_t, "m-> must receive monad-t as first argument")
 assert((("function" == type(monad_t.bind)) and ("function" == type(monad_t.result))), "monad-t must have .bind and .result functions")


 local function _8_(...) local val = ival for _, f in ipairs({...}) do
 val = monad_t.bind(val, f) end return val end return monad_t.result(_8_(...)) end


 local identity_m
 local function _9_(val, fun) return fun(val) end
 local function _10_(val) return val end identity_m = {bind = _9_, result = _10_}

 local maybe_m
 do local zero_val = nil

 local function _11_(...)
 local f, _break = zero_val, false
 for i = 1, select("#", ...) do if _break then break end
 if not (zero_val == select(i, ...)) then
 f = select(i, ...) _break = true else end end

 return f end
 local function _13_(val, fun)
 if (zero_val == val) then
 return zero_val else
 return fun(val) end end maybe_m = {zero = zero_val, plus = _11_, bind = _13_, result = identity_m.result} end


 local state_m
 local function bind(mv, f)
 local function _15_(s)
 local v, ss = mv(s)
 return f(v)(ss) end return _15_ end
 local function result(v)
 local function _16_(s) return v, s end return _16_ end
 local function _17_(key, val)
 local function _18_(s)
 local old_val = s[key] local new_s
 do s[key] = val new_s = s end
 return old_val, new_s end return _18_ end
 local function _19_(key)
 local function _20_(s)
 local _21_ = key if (nil ~= _21_) then local any = _21_
 return s[any], s elseif (_21_ == nil) then
 return s, s else return nil end end return _20_ end state_m = {bind = bind, result = result, set = _17_, get = _19_}

 return {["m->"] = m__3e, ["maybe-m"] = maybe_m, ["identity-m"] = identity_m, ["state-m"] = state_m}