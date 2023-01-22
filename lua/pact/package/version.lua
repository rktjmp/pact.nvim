







 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, _local_9_ = nil, nil do local _8_ = string local _7_ = require("pact.lib.ruin.enum") E, _local_9_ = _7_, _8_ end local _local_10_ = _local_9_
 local fmt = _local_10_["format"]

 local function version_string_3f(v)
 return (string_3f(v) and ((nil ~= string.match(v, "^(%d+)$")) or (nil ~= string.match(v, "^(%d+%.%d+)$")) or (nil ~= string.match(v, "^(%d+%.%d+%.%d+)$")))) end




 local function version_spec_string_3f(v)
 return (string_3f(v) and (nil ~= string.match(v, "^[%^~><=]+%s?%d+%.%d+%.%d+$"))) end


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
 local function _39_(_241, _242, _243) return E["set$"](_241, _243, tonumber(_242)) end return E.reduce(_39_, {}, {major = v_maj, minor = v_min, patch = v_patch}) end


 local function str__3espec(str) local pat = "([%^~><=]+)%s?([%d]+)%.([%d]+)%.([%d]+)"

 local s_op, s_maj, s_min, s_patch = string.match(str, pat)
 local function _40_(_241, _242, _243) return E["set$"](_241, _243, tonumber(_242)) end return E["set$"](E.reduce(_40_, {}, {major = s_maj, minor = s_min, patch = s_patch}), "operator", s_op) end



 local function str_is_notation_3f(str)
 return string.match(str, "^([%^~><=]+%s?[%d]+%.[%d]+%.[%d]+)$") end

 local __fn_2a_satisfies_3f_dispatch = {bodies = {}, help = {}} local satisfies_3f local function _43_(...) if (0 == #(__fn_2a_satisfies_3f_dispatch).bodies) then error(("multi-arity function " .. "satisfies?" .. " has no bodies")) else end local _45_ do local f_78_auto = nil for __79_auto, match_3f_80_auto in ipairs((__fn_2a_satisfies_3f_dispatch).bodies) do if f_78_auto then break end f_78_auto = match_3f_80_auto(...) end _45_ = f_78_auto end if (nil ~= _45_) then local f_78_auto = _45_ return f_78_auto(...) elseif (_45_ == nil) then local view_81_auto do local _46_, _47_ = pcall(require, "fennel") if ((_46_ == true) and ((_G.type(_47_) == "table") and (nil ~= (_47_).view))) then local view_81_auto0 = (_47_).view view_81_auto = view_81_auto0 elseif ((_46_ == false) and true) then local __79_auto = _47_ view_81_auto = (_G.vim.inspect or print) else view_81_auto = nil end end local msg_82_auto local _49_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_83_auto = 1, select("#", ...) do local val_19_auto = view_81_auto(({...})[i_83_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _49_ = tbl_17_auto end msg_82_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "satisfies?", table.concat(_49_, ", "), table.concat((__fn_2a_satisfies_3f_dispatch).help, "\n")) return error(msg_82_auto) else return nil end end satisfies_3f = _43_ local function _52_() local function _53_() table.insert((__fn_2a_satisfies_3f_dispatch).help, "(where [spec ver] (and (version-spec-string? spec) (version-string? ver)))") local function _54_(...) if (2 == select("#", ...)) then local _55_ = {...} local function _56_(...) local spec_41_ = (_55_)[1] local ver_42_ = (_55_)[2] return (version_spec_string_3f(spec_41_) and version_string_3f(ver_42_)) end if (((_G.type(_55_) == "table") and (nil ~= (_55_)[1]) and (nil ~= (_55_)[2])) and _56_(...)) then local spec_41_ = (_55_)[1] local ver_42_ = (_55_)[2] local function _57_(spec, ver)

 local ver0 = str__3ever(ver)
 local spec0 = str__3espec(spec)


 local _58_ = spec0.operator if (_58_ == "=") then
 return eq_3f(ver0, spec0) elseif (_58_ == ">") then
 return gt_3f(ver0, spec0) elseif (_58_ == "<") then
 return lt_3f(ver0, spec0) elseif (_58_ == ">=") then
 return gte_3f(ver0, spec0) elseif (_58_ == "<=") then
 return lte_3f(ver0, spec0) elseif (_58_ == "^") then
 return caret_3f(ver0, spec0) elseif (_58_ == "~") then
 return tilde_3f(ver0, spec0) elseif true then local _ = _58_
 return error(fmt("unsupported version spec operator %s", spec0.operator)) else return nil end end return _57_ else return nil end else return nil end end table.insert((__fn_2a_satisfies_3f_dispatch).bodies, _54_) return satisfies_3f end do local _ = {_53_()} end return satisfies_3f end setmetatable({nil, nil}, {__call = _52_})()

 local __fn_2a_solve_dispatch = {bodies = {}, help = {}} local solve local function _66_(...) if (0 == #(__fn_2a_solve_dispatch).bodies) then error(("multi-arity function " .. "solve" .. " has no bodies")) else end local _68_ do local f_78_auto = nil for __79_auto, match_3f_80_auto in ipairs((__fn_2a_solve_dispatch).bodies) do if f_78_auto then break end f_78_auto = match_3f_80_auto(...) end _68_ = f_78_auto end if (nil ~= _68_) then local f_78_auto = _68_ return f_78_auto(...) elseif (_68_ == nil) then local view_81_auto do local _69_, _70_ = pcall(require, "fennel") if ((_69_ == true) and ((_G.type(_70_) == "table") and (nil ~= (_70_).view))) then local view_81_auto0 = (_70_).view view_81_auto = view_81_auto0 elseif ((_69_ == false) and true) then local __79_auto = _70_ view_81_auto = (_G.vim.inspect or print) else view_81_auto = nil end end local msg_82_auto local _72_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_83_auto = 1, select("#", ...) do local val_19_auto = view_81_auto(({...})[i_83_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _72_ = tbl_17_auto end msg_82_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "solve", table.concat(_72_, ", "), table.concat((__fn_2a_solve_dispatch).help, "\n")) return error(msg_82_auto) else return nil end end solve = _66_ local function _75_() local _76_ do table.insert((__fn_2a_solve_dispatch).help, "(where [spec versions] (and (version-spec-string? spec) (table? versions)))") local function _77_(...) if (2 == select("#", ...)) then local _78_ = {...} local function _79_(...) local spec_62_ = (_78_)[1] local versions_63_ = (_78_)[2] return (version_spec_string_3f(spec_62_) and table_3f(versions_63_)) end if (((_G.type(_78_) == "table") and (nil ~= (_78_)[1]) and (nil ~= (_78_)[2])) and _79_(...)) then local spec_62_ = (_78_)[1] local versions_63_ = (_78_)[2] local function _80_(spec, versions)







 local function _81_(_241, _242) local a = str__3ever(_241)
 local b = str__3ever(_242)
 return gt_3f(a, b) end local function _82_(_241) return satisfies_3f(spec, _241) end return E.sort(_81_, E.filter(_82_, versions)) end return _80_ else return nil end else return nil end end table.insert((__fn_2a_solve_dispatch).bodies, _77_) _76_ = solve end local function _85_() table.insert((__fn_2a_solve_dispatch).help, "(where [specs versions] (and (table? specs) (table? versions)))") local function _86_(...) if (2 == select("#", ...)) then local _87_ = {...} local function _88_(...) local specs_64_ = (_87_)[1] local versions_65_ = (_87_)[2] return (table_3f(specs_64_) and table_3f(versions_65_)) end if (((_G.type(_87_) == "table") and (nil ~= (_87_)[1]) and (nil ~= (_87_)[2])) and _88_(...)) then local specs_64_ = (_87_)[1] local versions_65_ = (_87_)[2] local function _89_(specs, versions)











 local function _90_(_241, _242) local a = str__3ever(_241)
 local b = str__3ever(_242)
 return gt_3f(a, b) end local function _91_(_241) return (#specs == _241) end local function _92_(_241, _242) return E["set$"](_241, _242, (1 + ((_241)[_242] or 0))) end local function _93_(_241) return solve(_241, versions) end return E.sort(_90_, E.keys(E.filter(_91_, E.reduce(_92_, {}, E.flatten(E.map(_93_, specs)))))) end return _89_ else return nil end else return nil end end table.insert((__fn_2a_solve_dispatch).bodies, _86_) return solve end do local _ = {_76_, _85_()} end return solve end setmetatable({nil, nil}, {__call = _75_})()

 return {["satisfies?"] = satisfies_3f, solve = solve, ["version-string?"] = version_string_3f, ["version-spec-string?"] = version_spec_string_3f, ["str-is-notation?"] = str_is_notation_3f}