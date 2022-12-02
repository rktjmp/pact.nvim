







 local _local_5_, enum, _local_6_, _local_7_ = nil, nil, nil, nil do local _4_ = require("pact.valid") local _3_ = string local _2_ = require("pact.lib.ruin.enum") local _1_ = require("pact.lib.ruin.type") _local_5_, enum, _local_6_, _local_7_ = _1_, _2_, _3_, _4_ end local _local_8_ = _local_5_
 local string_3f = _local_8_["string?"] local table_3f = _local_8_["table?"] local _local_9_ = _local_6_

 local fmt = _local_9_["format"] local _local_10_ = _local_7_
 local valid_version_spec_3f = _local_10_["valid-version-spec?"] local valid_version_3f = _local_10_["valid-version?"] do local _ = {nil, nil} end

 local function compare(a, b)


 local function to_sym(x, y)
 local _11_ = {x, y} local function _12_() return (x == y) end if (((_G.type(_11_) == "table") and ((_11_)[1] == x) and ((_11_)[2] == y)) and _12_()) then return "=" else local function _13_() return (x > y) end if (((_G.type(_11_) == "table") and ((_11_)[1] == x) and ((_11_)[2] == y)) and _13_()) then return ">" else local function _14_() return (x < y) end if (((_G.type(_11_) == "table") and ((_11_)[1] == x) and ((_11_)[2] == y)) and _14_()) then return "<" else return nil end end end end



 return {to_sym(a.major, b.major), to_sym(a.minor, b.minor), to_sym(a.patch, b.patch)} end



 local function eq_3f(a, b)
 local _16_ = compare(a, b) if ((_G.type(_16_) == "table") and ((_16_)[1] == "=") and ((_16_)[2] == "=") and ((_16_)[3] == "=")) then return true elseif true then local _ = _16_ return false else return nil end end



 local function lt_3f(a, b)
 local _18_ = compare(a, b) local function _19_() local _ = (_18_)[2] local _0 = (_18_)[3] return true end if (((_G.type(_18_) == "table") and ((_18_)[1] == "<") and true and true) and _19_()) then local _ = (_18_)[2] local _0 = (_18_)[3] return true else local function _20_() local _ = (_18_)[3] return true end if (((_G.type(_18_) == "table") and ((_18_)[1] == "=") and ((_18_)[2] == "<") and true) and _20_()) then local _ = (_18_)[3] return true else local function _21_() return true end if (((_G.type(_18_) == "table") and ((_18_)[1] == "=") and ((_18_)[2] == "=") and ((_18_)[3] == "<")) and _21_()) then return true elseif true then local _ = _18_ return false else return nil end end end end



 local function gt_3f(a, b)
 local _23_ = compare(a, b) local function _24_() local _ = (_23_)[2] local _0 = (_23_)[3] return true end if (((_G.type(_23_) == "table") and ((_23_)[1] == ">") and true and true) and _24_()) then local _ = (_23_)[2] local _0 = (_23_)[3] return true else local function _25_() local _ = (_23_)[3] return true end if (((_G.type(_23_) == "table") and ((_23_)[1] == "=") and ((_23_)[2] == ">") and true) and _25_()) then local _ = (_23_)[3] return true else local function _26_() return true end if (((_G.type(_23_) == "table") and ((_23_)[1] == "=") and ((_23_)[2] == "=") and ((_23_)[3] == ">")) and _26_()) then return true elseif true then local _ = _23_ return false else return nil end end end end



 local function lte_3f(a, b)
 return (eq_3f(a, b) or lt_3f(a, b)) end


 local function gte_3f(a, b)
 return (eq_3f(a, b) or gt_3f(a, b)) end


 local function at_most_patch_ahead_3f(a, b)
 local _28_ = compare(a, b) local function _29_() return true end if (((_G.type(_28_) == "table") and ((_28_)[1] == "=") and ((_28_)[2] == "=") and ((_28_)[3] == "=")) and _29_()) then return true else local function _30_() return true end if (((_G.type(_28_) == "table") and ((_28_)[1] == "=") and ((_28_)[2] == "=") and ((_28_)[3] == ">")) and _30_()) then return true elseif true then local _ = _28_ return false else return nil end end end




 local function at_most_minor_ahead_3f(a, b)
 local _32_ = compare(a, b) local function _33_() return true end if (((_G.type(_32_) == "table") and ((_32_)[1] == "=") and ((_32_)[2] == "=") and ((_32_)[3] == "=")) and _33_()) then return true else local function _34_() return true end if (((_G.type(_32_) == "table") and ((_32_)[1] == "=") and ((_32_)[2] == "=") and ((_32_)[3] == ">")) and _34_()) then return true else local function _35_() local _ = (_32_)[3] return true end if (((_G.type(_32_) == "table") and ((_32_)[1] == "=") and ((_32_)[2] == ">") and true) and _35_()) then local _ = (_32_)[3] return true elseif true then local _ = _32_ return false else return nil end end end end





 local function tilde_3f(a, b)
 return at_most_patch_ahead_3f(a, b) end

 local function caret_3f(a, b)
 local _37_ = b.major if (_37_ == 0) then

 return at_most_patch_ahead_3f(a, b) elseif true then local _ = _37_

 return at_most_minor_ahead_3f(a, b) else return nil end end

 local function str__3ever(str)
 local v_maj, v_min, v_patch = string.match(str, "^([%d]+)%.([%d]+)%.([%d]+)$")
 local function _39_(_241, _242, _243) return enum["set$"](_241, _242, tonumber(_243)) end return enum.reduce(_39_, {}, {major = v_maj, minor = v_min, patch = v_patch}) end


 local function str__3espec(str) local pat = "([%^~><=]+)%s?([%d]+)%.([%d]+)%.([%d]+)"

 local s_op, s_maj, s_min, s_patch = string.match(str, pat)
 local function _40_(_241, _242, _243) return enum["set$"](_241, _242, tonumber(_243)) end return enum["set$"](enum.reduce(_40_, {}, {major = s_maj, minor = s_min, patch = s_patch}), "operator", s_op) end



 local __fn_2a_satisfies_3f_dispatch = {bodies = {}, help = {}} local satisfies_3f local function _43_(...) if (0 == #(__fn_2a_satisfies_3f_dispatch).bodies) then error(("multi-arity function " .. "satisfies?" .. " has no bodies")) else end local _45_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_satisfies_3f_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _45_ = f_74_auto end if (nil ~= _45_) then local f_74_auto = _45_ return f_74_auto(...) elseif (_45_ == nil) then local view_77_auto do local _46_, _47_ = pcall(require, "fennel") if ((_46_ == true) and ((_G.type(_47_) == "table") and (nil ~= (_47_).view))) then local view_77_auto0 = (_47_).view view_77_auto = view_77_auto0 elseif ((_46_ == false) and true) then local __75_auto = _47_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "satisfies?", view_77_auto({...}), table.concat((__fn_2a_satisfies_3f_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end satisfies_3f = _43_ local function _50_() local function _51_() table.insert((__fn_2a_satisfies_3f_dispatch).help, "(where [spec ver] (and (valid-version-spec? spec) (valid-version? ver)))") local function _52_(...) if (2 == select("#", ...)) then local _53_ = {...} local function _54_(...) local spec_41_ = (_53_)[1] local ver_42_ = (_53_)[2] return (valid_version_spec_3f(spec_41_) and valid_version_3f(ver_42_)) end if (((_G.type(_53_) == "table") and (nil ~= (_53_)[1]) and (nil ~= (_53_)[2])) and _54_(...)) then local spec_41_ = (_53_)[1] local ver_42_ = (_53_)[2] local function _55_(spec, ver)

 local ver0 = str__3ever(ver)
 local spec0 = str__3espec(spec)


 local _56_ = spec0.operator if (_56_ == "=") then
 return eq_3f(ver0, spec0) elseif (_56_ == ">") then
 return gt_3f(ver0, spec0) elseif (_56_ == "<") then
 return lt_3f(ver0, spec0) elseif (_56_ == ">=") then
 return gte_3f(ver0, spec0) elseif (_56_ == "<=") then
 return lte_3f(ver0, spec0) elseif (_56_ == "^") then
 return caret_3f(ver0, spec0) elseif (_56_ == "~") then
 return tilde_3f(ver0, spec0) elseif true then local _ = _56_
 return error(fmt("unsupported version spec operator %s", spec0.operator)) else return nil end end return _55_ else return nil end else return nil end end table.insert((__fn_2a_satisfies_3f_dispatch).bodies, _52_) return satisfies_3f end do local _ = {_51_()} end return satisfies_3f end setmetatable({nil, nil}, {__call = _50_})()

 local __fn_2a_solve_dispatch = {bodies = {}, help = {}} local solve local function _64_(...) if (0 == #(__fn_2a_solve_dispatch).bodies) then error(("multi-arity function " .. "solve" .. " has no bodies")) else end local _66_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_solve_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _66_ = f_74_auto end if (nil ~= _66_) then local f_74_auto = _66_ return f_74_auto(...) elseif (_66_ == nil) then local view_77_auto do local _67_, _68_ = pcall(require, "fennel") if ((_67_ == true) and ((_G.type(_68_) == "table") and (nil ~= (_68_).view))) then local view_77_auto0 = (_68_).view view_77_auto = view_77_auto0 elseif ((_67_ == false) and true) then local __75_auto = _68_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "solve", view_77_auto({...}), table.concat((__fn_2a_solve_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end solve = _64_ local function _71_() local _72_ do table.insert((__fn_2a_solve_dispatch).help, "(where [spec versions] (and (valid-version-spec? spec) (table? versions)))") local function _73_(...) if (2 == select("#", ...)) then local _74_ = {...} local function _75_(...) local spec_60_ = (_74_)[1] local versions_61_ = (_74_)[2] return (valid_version_spec_3f(spec_60_) and table_3f(versions_61_)) end if (((_G.type(_74_) == "table") and (nil ~= (_74_)[1]) and (nil ~= (_74_)[2])) and _75_(...)) then local spec_60_ = (_74_)[1] local versions_61_ = (_74_)[2] local function _76_(spec, versions)







 local function _77_(_241, _242) local a = str__3ever(_241)
 local b = str__3ever(_242)
 return gt_3f(a, b) end local function _78_(_241, _242) return satisfies_3f(spec, _242) end return enum.sort(_77_, enum.filter(_78_, versions)) end return _76_ else return nil end else return nil end end table.insert((__fn_2a_solve_dispatch).bodies, _73_) _72_ = solve end local function _81_() table.insert((__fn_2a_solve_dispatch).help, "(where [specs versions] (and (table? specs) (table? versions)))") local function _82_(...) if (2 == select("#", ...)) then local _83_ = {...} local function _84_(...) local specs_62_ = (_83_)[1] local versions_63_ = (_83_)[2] return (table_3f(specs_62_) and table_3f(versions_63_)) end if (((_G.type(_83_) == "table") and (nil ~= (_83_)[1]) and (nil ~= (_83_)[2])) and _84_(...)) then local specs_62_ = (_83_)[1] local versions_63_ = (_83_)[2] local function _85_(specs, versions)











 local function _86_(_241, _242) local a = str__3ever(_241)
 local b = str__3ever(_242)
 return gt_3f(a, b) end local function _87_(_241, _242) return (#specs == _242) end local function _88_(_241, _242, _243) return enum["set$"](_241, _243, (1 + ((_241)[_243] or 0))) end local function _89_(_241, _242) return solve(_242, versions) end return enum.sort(_86_, enum.keys(enum.filter(_87_, enum.reduce(_88_, {}, enum.flatten(enum.map(_89_, specs)))))) end return _85_ else return nil end else return nil end end table.insert((__fn_2a_solve_dispatch).bodies, _82_) return solve end do local _ = {_72_, _81_()} end return solve end setmetatable({nil, nil}, {__call = _71_})()

 return {["satisfies?"] = satisfies_3f, solve = solve}