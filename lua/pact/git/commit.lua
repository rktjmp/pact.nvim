

 local _local_5_, enum, _local_6_, _local_7_ = nil, nil, nil, nil do local _4_ = string local _3_ = require("pact.valid") local _2_ = require("pact.lib.ruin.enum") local _1_ = require("pact.lib.ruin.type") _local_5_, enum, _local_6_, _local_7_ = _1_, _2_, _3_, _4_ end local _local_8_ = _local_5_
 local string_3f = _local_8_["string?"] local table_3f = _local_8_["table?"] local _local_9_ = _local_6_

 local valid_sha_3f = _local_9_["valid-sha?"] local _local_10_ = _local_7_
 local fmt = _local_10_["format"] do local _ = {nil, nil} end

 local __fn_2a_expand_version_dispatch = {bodies = {}, help = {}} local expand_version local function _14_(...) if (0 == #(__fn_2a_expand_version_dispatch).bodies) then error(("multi-arity function " .. "expand-version" .. " has no bodies")) else end local _16_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_expand_version_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _16_ = f_74_auto end if (nil ~= _16_) then local f_74_auto = _16_ return f_74_auto(...) elseif (_16_ == nil) then local view_77_auto do local _17_, _18_ = pcall(require, "fennel") if ((_17_ == true) and ((_G.type(_18_) == "table") and (nil ~= (_18_).view))) then local view_77_auto0 = (_18_).view view_77_auto = view_77_auto0 elseif ((_17_ == false) and true) then local __75_auto = _18_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "expand-version", view_77_auto({...}), table.concat((__fn_2a_expand_version_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end expand_version = _14_ local function _21_() local _22_ do table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+)$\"))") local function _23_(...) if (1 == select("#", ...)) then local _24_ = {...} local function _25_(...) local v_11_ = (_24_)[1] return string.match(v_11_, "^(%d+)$") end if (((_G.type(_24_) == "table") and (nil ~= (_24_)[1])) and _25_(...)) then local v_11_ = (_24_)[1] local function _26_(v)


 return (v .. ".0.0") end return _26_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _23_) _22_ = expand_version end local _29_ do table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+%.%d+)$\"))") local function _30_(...) if (1 == select("#", ...)) then local _31_ = {...} local function _32_(...) local v_12_ = (_31_)[1] return string.match(v_12_, "^(%d+%.%d+)$") end if (((_G.type(_31_) == "table") and (nil ~= (_31_)[1])) and _32_(...)) then local v_12_ = (_31_)[1] local function _33_(v)

 return (v .. ".0") end return _33_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _30_) _29_ = expand_version end local _36_ do table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+%.%d+%.%d+)$\"))") local function _37_(...) if (1 == select("#", ...)) then local _38_ = {...} local function _39_(...) local v_13_ = (_38_)[1] return string.match(v_13_, "^(%d+%.%d+%.%d+)$") end if (((_G.type(_38_) == "table") and (nil ~= (_38_)[1])) and _39_(...)) then local v_13_ = (_38_)[1] local function _40_(v)

 return v end return _40_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _37_) _36_ = expand_version end local function _43_() table.insert((__fn_2a_expand_version_dispatch).help, "(where _)") local function _44_(...) if true then local _45_ = {...} local function _46_(...) return true end if ((_G.type(_45_) == "table") and _46_(...)) then local function _47_(...)

 return nil end return _47_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _44_) return expand_version end do local _ = {_22_, _29_, _36_, _43_()} end return expand_version end setmetatable({nil, nil}, {__call = _21_})()



 local __fn_2a_commit_dispatch = {bodies = {}, help = {}} local commit local function _55_(...) if (0 == #(__fn_2a_commit_dispatch).bodies) then error(("multi-arity function " .. "commit" .. " has no bodies")) else end local _57_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_commit_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _57_ = f_74_auto end if (nil ~= _57_) then local f_74_auto = _57_ return f_74_auto(...) elseif (_57_ == nil) then local view_77_auto do local _58_, _59_ = pcall(require, "fennel") if ((_58_ == true) and ((_G.type(_59_) == "table") and (nil ~= (_59_).view))) then local view_77_auto0 = (_59_).view view_77_auto = view_77_auto0 elseif ((_58_ == false) and true) then local __75_auto = _59_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "commit", view_77_auto({...}), table.concat((__fn_2a_commit_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end commit = _55_ local function _62_() local _63_ do table.insert((__fn_2a_commit_dispatch).help, "(where [sha] (valid-sha? sha))") local function _64_(...) if (1 == select("#", ...)) then local _65_ = {...} local function _66_(...) local sha_50_ = (_65_)[1] return valid_sha_3f(sha_50_) end if (((_G.type(_65_) == "table") and (nil ~= (_65_)[1])) and _66_(...)) then local sha_50_ = (_65_)[1] local function _67_(sha)

 return commit(sha, {}) end return _67_ else return nil end else return nil end end table.insert((__fn_2a_commit_dispatch).bodies, _64_) _63_ = commit end local _70_ do table.insert((__fn_2a_commit_dispatch).help, "(where [sha {:branch ?branch :tag ?tag :version ?version}] (and (valid-sha? sha) (string? (or ?tag \"\")) (string? (or ?branch \"\")) (string? (or ?version \"\"))))") local function _71_(...) if (2 == select("#", ...)) then local _72_ = {...} local function _73_(...) local sha_51_ = (_72_)[1] local _3ftag_52_ = ((_72_)[2]).tag local _3fbranch_53_ = ((_72_)[2]).branch local _3fversion_54_ = ((_72_)[2]).version return (valid_sha_3f(sha_51_) and string_3f((_3ftag_52_ or "")) and string_3f((_3fbranch_53_ or "")) and string_3f((_3fversion_54_ or ""))) end if (((_G.type(_72_) == "table") and (nil ~= (_72_)[1]) and ((_G.type((_72_)[2]) == "table") and true and true and true)) and _73_(...)) then local sha_51_ = (_72_)[1] local _3ftag_52_ = ((_72_)[2]).tag local _3fbranch_53_ = ((_72_)[2]).branch local _3fversion_54_ = ((_72_)[2]).version local function _76_(sha, _74_)
 local _arg_75_ = _74_ local _3ftag = _arg_75_["tag"] local _3fbranch = _arg_75_["branch"] local _3fversion = _arg_75_["version"]








 local function _77_(_241) return fmt("%s@%s", (_241.version or _241.branch or _241.tag or "commit"), string.sub(_241.sha, 1, 8)) end return setmetatable({sha = sha, branch = _3fbranch, tag = _3ftag, version = expand_version(_3fversion)}, {__tostring = _77_}) end return _76_ else return nil end else return nil end end table.insert((__fn_2a_commit_dispatch).bodies, _71_) _70_ = commit end local function _80_() table.insert((__fn_2a_commit_dispatch).help, "(where _)") local function _81_(...) if true then local _82_ = {...} local function _83_(...) return true end if ((_G.type(_82_) == "table") and _83_(...)) then local function _84_(...)



 return nil, "commit requires a valid sha and optional table of tag, branch or version" end return _84_ else return nil end else return nil end end table.insert((__fn_2a_commit_dispatch).bodies, _81_) return commit end do local _ = {_63_, _70_, _80_()} end return commit end setmetatable({nil, nil}, {__call = _62_})()

 local function ref_line__3ecommit(ref)

















 local _87_, _88_, _89_ = string.match(ref, "(%x+)%s+refs/(.+)/(.+)") if ((nil ~= _87_) and (_88_ == "heads") and (nil ~= _89_)) then local sha = _87_ local name = _89_
 return commit(sha, {branch = name}) elseif ((nil ~= _87_) and (_88_ == "tags") and (nil ~= _89_)) then local sha = _87_ local name = _89_
 local _90_ = string.match(name, "v?(%d+%.%d+%.%d+)") if (_90_ == nil) then
 return commit(sha, {tag = name}) elseif (nil ~= _90_) then local version = _90_

 return commit(sha, {tag = name, version = version}) else return nil end else return nil end end


 local function ref_lines__3ecommits(refs)

 local function _93_(_241, _242) return ref_line__3ecommit(_242) end return enum.map(_93_, refs) end

 return {commit = commit, ["ref-line->commit"] = ref_line__3ecommit, ["ref-lines->commits"] = ref_lines__3ecommits}