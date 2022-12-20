 local function no_missing_access(t, _3fmsg_fmt)

 assert(("table" == type(t)), "tried to protect non-table")
 local mt = (getmetatable(t) or {})
 local msg_fmt = (_3fmsg_fmt or "unknown-key: %s") local __index
 local function _1_() return nil end __index = (mt.__index or _1_)
 local function _2_(_241, _242) local _3_ = __index(_241, _242) if (_3_ == nil) then
 return error(string.format(msg_fmt, _242)) elseif (nil ~= _3_) then local any = _3_
 return any else return nil end end mt["__index"] = _2_
 setmetatable(t, mt)

 for k, v in pairs(t) do
 if ("table" == type(v)) then
 no_missing_access(v) else end end
 return t end



 local function has_key(t, k)
 return not (nil == t[k]) end

 return {["no-missing-access"] = no_missing_access}