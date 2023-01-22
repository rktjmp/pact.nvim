




 local root local function _1_(...) local full_mod_path_2_auto = ... local _2_ = full_mod_path_2_auto local function _3_(...) local path_3_auto = _2_ return ("string" == type(path_3_auto)) end if ((nil ~= _2_) and _3_(...)) then local path_3_auto = _2_ if string.find(full_mod_path_2_auto, "ruin") then local _4_ = string.match(full_mod_path_2_auto, ("(.+%.)" .. "ruin")) if (_4_ == nil) then return "" elseif (nil ~= _4_) then local root_4_auto = _4_ return root_4_auto else return nil end else return error(string.format("relative-root: no match in &from %q for %q", full_mod_path_2_auto, "ruin")) end elseif (_2_ == nil) then return "" else return nil end end root = ((_1_(...) or "") .. "ruin.")
 local aliases = {iter = (root .. "iter"), type = (root .. "type"), enum = (root .. "enum")}



 local function tap(v, f)
 f(v)
 return v end

 local function lazyload(t, k) local function _8_()

 local _9_ = aliases[k] if (nil ~= _9_) then local _10_ = require(_9_) if (nil ~= _10_) then

 local function _11_(_241)
 t[k] = _241
 aliases[k] = nil return nil end return tap(_10_, _11_) else return _10_ end else return _9_ end end return (t[k] or _8_()) end

 return setmetatable({__submodules_are_lazyloaded = aliases}, {__index = lazyload})