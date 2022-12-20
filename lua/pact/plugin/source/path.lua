






 local _local_2_ do local _1_ = require("pact.lib.ruin.type") _local_2_ = _1_ end local _local_3_ = _local_2_
 local string_3f = _local_3_["string?"] local table_3f = _local_3_["table?"] do local _ = {nil, nil} end

 local function path__3eid(path)
 local _4_ = path if (nil ~= _4_) then local _5_ = string.reverse(_4_) if (nil ~= _5_) then local _6_ = string.match(_5_, "([^/]+)/.+") if (nil ~= _6_) then return string.reverse(_6_) else return _6_ end else return _5_ end else return _4_ end end





 local __fn_2a_path_dispatch = {bodies = {}, help = {}} local path local function _11_(...) if (0 == #(__fn_2a_path_dispatch).bodies) then error(("multi-arity function " .. "path" .. " has no bodies")) else end local _13_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_path_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _13_ = f_74_auto end if (nil ~= _13_) then local f_74_auto = _13_ return f_74_auto(...) elseif (_13_ == nil) then local view_77_auto do local _14_, _15_ = pcall(require, "fennel") if ((_14_ == true) and ((_G.type(_15_) == "table") and (nil ~= (_15_).view))) then local view_77_auto0 = (_15_).view view_77_auto = view_77_auto0 elseif ((_14_ == false) and true) then local __75_auto = _15_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _17_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _17_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "path", table.concat(_17_, ", "), table.concat((__fn_2a_path_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end path = _11_ local function _20_() local _21_ do table.insert((__fn_2a_path_dispatch).help, "(where [local-path] (string? local-path))") local function _22_(...) if (1 == select("#", ...)) then local _23_ = {...} local function _24_(...) local local_path_10_ = (_23_)[1] return string_3f(local_path_10_) end if (((_G.type(_23_) == "table") and (nil ~= (_23_)[1])) and _24_(...)) then local local_path_10_ = (_23_)[1] local function _25_(local_path)


 local constraint do local _26_ = require("pact.constraint.path") constraint = _26_ end
 return {id = path__3eid(local_path), path = local_path, constraint = constraint.path(local_path)} end return _25_ else return nil end else return nil end end table.insert((__fn_2a_path_dispatch).bodies, _22_) _21_ = path end local function _29_() table.insert((__fn_2a_path_dispatch).help, "(where _)") local function _30_(...) if true then local _31_ = {...} local function _32_(...) return true end if ((_G.type(_31_) == "table") and _32_(...)) then local function _33_(...)



 return nil, "must be called with `path`" end return _33_ else return nil end else return nil end end table.insert((__fn_2a_path_dispatch).bodies, _30_) return path end do local _ = {_21_, _29_()} end return path end setmetatable({nil, nil}, {__call = _20_})()

 return {path = path}