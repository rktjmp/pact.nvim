
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local R, _local_13_, E, Commit, Constraint, _local_14_ = nil, nil, nil, nil, nil, nil do local _12_ = string local _11_ = require("pact.package.git.constraint") local _10_ = require("pact.package.git.commit") local _9_ = require("pact.lib.ruin.enum")

 local _8_ = require("pact.task") local _7_ = require("pact.lib.ruin.result") R, _local_13_, E, Commit, Constraint, _local_14_ = _7_, _8_, _9_, _10_, _11_, _12_ end local _local_15_ = _local_13_ local async = _local_15_["async"] local await = _local_15_["await"] local trace = _local_15_["trace"] local _local_16_ = _local_14_



 local fmt = _local_16_["format"] do local _ = {nil, nil} end

 local Solver = {}

 local __fn_2a_solve_constraint_dispatch = {bodies = {}, help = {}} local solve_constraint local function _26_(...) if (0 == #(__fn_2a_solve_constraint_dispatch).bodies) then error(("multi-arity function " .. "solve-constraint" .. " has no bodies")) else end local _28_ do local f_78_auto = nil for __79_auto, match_3f_80_auto in ipairs((__fn_2a_solve_constraint_dispatch).bodies) do if f_78_auto then break end f_78_auto = match_3f_80_auto(...) end _28_ = f_78_auto end if (nil ~= _28_) then local f_78_auto = _28_ return f_78_auto(...) elseif (_28_ == nil) then local view_81_auto do local _29_, _30_ = pcall(require, "fennel") if ((_29_ == true) and ((_G.type(_30_) == "table") and (nil ~= (_30_).view))) then local view_81_auto0 = (_30_).view view_81_auto = view_81_auto0 elseif ((_29_ == false) and true) then local __79_auto = _30_ view_81_auto = (_G.vim.inspect or print) else view_81_auto = nil end end local msg_82_auto local _32_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_83_auto = 1, select("#", ...) do local val_19_auto = view_81_auto(({...})[i_83_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _32_ = tbl_17_auto end msg_82_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "solve-constraint", table.concat(_32_, ", "), table.concat((__fn_2a_solve_constraint_dispatch).help, "\n")) return error(msg_82_auto) else return nil end end solve_constraint = _26_ local function _35_() local _36_ do table.insert((__fn_2a_solve_constraint_dispatch).help, "(where [constraint commits _] (Constraint.version? constraint))") local function _37_(...) if (3 == select("#", ...)) then local _38_ = {...} local function _39_(...) local constraint_17_ = (_38_)[1] local commits_18_ = (_38_)[2] local __19_ = (_38_)[3] return Constraint["version?"](constraint_17_) end if (((_G.type(_38_) == "table") and (nil ~= (_38_)[1]) and (nil ~= (_38_)[2]) and true) and _39_(...)) then local constraint_17_ = (_38_)[1] local commits_18_ = (_38_)[2] local __19_ = (_38_)[3] local function _40_(constraint, commits, _)








 local function _41_(_241) if E["empty?"](_241) then
 return R.err({constraint = constraint, msg = fmt("no version satisfied %s", Constraint.value(constraint))}) else

 return R.ok({constraint = constraint, commits = _241}) end end local function _43_(_241) return Constraint["satisfies?"](constraint, _241) end return _41_(E.filter(_43_, commits)) end return _40_ else return nil end else return nil end end table.insert((__fn_2a_solve_constraint_dispatch).bodies, _37_) _36_ = solve_constraint end local _46_ do table.insert((__fn_2a_solve_constraint_dispatch).help, "(where [constraint commits verify-sha] (Constraint.commit? constraint))") local function _47_(...) if (3 == select("#", ...)) then local _48_ = {...} local function _49_(...) local constraint_20_ = (_48_)[1] local commits_21_ = (_48_)[2] local verify_sha_22_ = (_48_)[3] return Constraint["commit?"](constraint_20_) end if (((_G.type(_48_) == "table") and (nil ~= (_48_)[1]) and (nil ~= (_48_)[2]) and (nil ~= (_48_)[3])) and _49_(...)) then local constraint_20_ = (_48_)[1] local commits_21_ = (_48_)[2] local verify_sha_22_ = (_48_)[3] local function _50_(constraint, commits, verify_sha)








 local _let_51_ = require("pact.lib.ruin.result") local bind_15_auto = _let_51_["bind"] local unit_16_auto = _let_51_["unit"] local bind_52_ = bind_15_auto local unit_53_ = unit_16_auto local function _54_(sha)
 local function _55_() return verify_sha(sha) end local function _56_(full_sha) local function _57_()
 if full_sha then
 return R.ok({constraint = constraint, commits = {Commit.new(full_sha)}}) else
 return R.err({constraint = constraint, msg = fmt("commit does not exist: %s", sha)}) end end return unit_53_(_57_()) end return unit_53_(bind_52_(unit_53_(await(async(_55_))), _56_)) end return bind_52_(unit_53_(Constraint.value(constraint)), _54_) end return _50_ else return nil end else return nil end end table.insert((__fn_2a_solve_constraint_dispatch).bodies, _47_) _46_ = solve_constraint end local function _61_() table.insert((__fn_2a_solve_constraint_dispatch).help, "(where [constraint commits _] (or (Constraint.branch? constraint) (Constraint.tag? constraint) (Constraint.head? constraint)))") local function _62_(...) if (3 == select("#", ...)) then local _63_ = {...} local function _64_(...) local constraint_23_ = (_63_)[1] local commits_24_ = (_63_)[2] local __25_ = (_63_)[3] return (Constraint["branch?"](constraint_23_) or Constraint["tag?"](constraint_23_) or Constraint["head?"](constraint_23_)) end if (((_G.type(_63_) == "table") and (nil ~= (_63_)[1]) and (nil ~= (_63_)[2]) and true) and _64_(...)) then local constraint_23_ = (_63_)[1] local commits_24_ = (_63_)[2] local __25_ = (_63_)[3] local function _65_(constraint, commits, _)





 local _66_ = Constraint.solve(constraint, commits) if (nil ~= _66_) then local commit = _66_
 return R.ok({constraint = constraint, commits = {commit}}) elseif (_66_ == nil) then

 return R.err({constraint = constraint, msg = fmt("%s does not exist: %s", Constraint.type(constraint), Constraint.value(constraint))}) else return nil end end return _65_ else return nil end else return nil end end table.insert((__fn_2a_solve_constraint_dispatch).bodies, _62_) return solve_constraint end do local _ = {_36_, _46_, _61_()} end return solve_constraint end setmetatable({nil, nil}, {__call = _35_})()




 local function latest_in_set(constraints_commits)
 local all_version_3f local function _70_(_241) return Constraint["version?"](_241.constraint) end all_version_3f = E["all?"](_70_, constraints_commits)

 if all_version_3f then


 local function _71_(_241) return _241.commit end return Constraint.solve(Constraint.version("> 0.0.0"), E.map(_71_, constraints_commits)) else



 return E.hd(constraints_commits).commit end end


 local __fn_2a_best_commit_or_error_dispatch = {bodies = {}, help = {}} local best_commit_or_error local function _73_(...) if (0 == #(__fn_2a_best_commit_or_error_dispatch).bodies) then error(("multi-arity function " .. "best-commit-or-error" .. " has no bodies")) else end local _75_ do local f_78_auto = nil for __79_auto, match_3f_80_auto in ipairs((__fn_2a_best_commit_or_error_dispatch).bodies) do if f_78_auto then break end f_78_auto = match_3f_80_auto(...) end _75_ = f_78_auto end if (nil ~= _75_) then local f_78_auto = _75_ return f_78_auto(...) elseif (_75_ == nil) then local view_81_auto do local _76_, _77_ = pcall(require, "fennel") if ((_76_ == true) and ((_G.type(_77_) == "table") and (nil ~= (_77_).view))) then local view_81_auto0 = (_77_).view view_81_auto = view_81_auto0 elseif ((_76_ == false) and true) then local __79_auto = _77_ view_81_auto = (_G.vim.inspect or print) else view_81_auto = nil end end local msg_82_auto local _79_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_83_auto = 1, select("#", ...) do local val_19_auto = view_81_auto(({...})[i_83_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _79_ = tbl_17_auto end msg_82_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "best-commit-or-error", table.concat(_79_, ", "), table.concat((__fn_2a_best_commit_or_error_dispatch).help, "\n")) return error(msg_82_auto) else return nil end end best_commit_or_error = _73_ local function _82_() do local _ = {} end return best_commit_or_error end setmetatable({nil, nil}, {__call = _82_})()




 do table.insert((__fn_2a_best_commit_or_error_dispatch).help, "(where [{false nil true good}])") local function _84_(...) if (1 == select("#", ...)) then local _85_ = {...} local function _86_(...) local good_83_ = ((_85_)[1])[true] return true end if (((_G.type(_85_) == "table") and ((_G.type((_85_)[1]) == "table") and (nil ~= ((_85_)[1])[true]) and (((_85_)[1])[false] == nil))) and _86_(...)) then local good_83_ = ((_85_)[1])[true] local function _89_(_87_) local _arg_88_ = _87_ local good = _arg_88_[true] local _ = _arg_88_[false]




 local x_solved

















 local function _90_(_241) return _241 end local function _91_(ccs, _sha) return (#good == #ccs) end local function _92_(_241) return _241.commit["short-sha"] end local function _93_(solved_constraint) local function _94_(_241) return {constraint = solved_constraint.constraint, commit = _241} end return E.map(_94_, solved_constraint.commits) end local function _95_(_241) return R.unwrap(_241) end x_solved = E.flatten(E.map(_90_, E.filter(_91_, E["group-by"](_92_, E.flatten(E.map(_93_, E.map(_95_, good)))))))

 if E["empty?"](x_solved) then
 return R.err(good) else
 return R.ok(latest_in_set(x_solved)) end end return _89_ else return nil end else return nil end end table.insert((__fn_2a_best_commit_or_error_dispatch).bodies, _84_) end

 do table.insert((__fn_2a_best_commit_or_error_dispatch).help, "(where [{false bad true good}])") local function _101_(...) if (1 == select("#", ...)) then local _102_ = {...} local function _103_(...) local good_100_ = ((_102_)[1])[true] local bad_99_ = ((_102_)[1])[false] return true end if (((_G.type(_102_) == "table") and ((_G.type((_102_)[1]) == "table") and (nil ~= ((_102_)[1])[true]) and (nil ~= ((_102_)[1])[false]))) and _103_(...)) then local good_100_ = ((_102_)[1])[true] local bad_99_ = ((_102_)[1])[false] local function _106_(_104_) local _arg_105_ = _104_ local good = _arg_105_[true] local bad = _arg_105_[false]
 return R.err(E["concat$"]({}, good, bad)) end return _106_ else return nil end else return nil end end table.insert((__fn_2a_best_commit_or_error_dispatch).bodies, _101_) end

 do table.insert((__fn_2a_best_commit_or_error_dispatch).help, "(where [{false bad true nil}])") local function _110_(...) if (1 == select("#", ...)) then local _111_ = {...} local function _112_(...) local bad_109_ = ((_111_)[1])[false] return true end if (((_G.type(_111_) == "table") and ((_G.type((_111_)[1]) == "table") and (((_111_)[1])[true] == nil) and (nil ~= ((_111_)[1])[false]))) and _112_(...)) then local bad_109_ = ((_111_)[1])[false] local function _115_(_113_) local _arg_114_ = _113_ local _ = _arg_114_[true] local bad = _arg_114_[false]
 return R.err(bad) end return _115_ else return nil end else return nil end end table.insert((__fn_2a_best_commit_or_error_dispatch).bodies, _110_) end


 Solver.solve = function(constraints, commits, verify_sha) _G.assert((nil ~= verify_sha), "Missing argument verify-sha on ./fnl/pact/solver/init.fnl:107") _G.assert((nil ~= commits), "Missing argument commits on ./fnl/pact/solver/init.fnl:107") _G.assert((nil ~= constraints), "Missing argument constraints on ./fnl/pact/solver/init.fnl:107")














 trace("solving %s-way package constraint", #constraints)


 local function _118_(_241) return R["ok?"](_241) end local function _119_(_241) return solve_constraint(_241, commits, verify_sha) end return best_commit_or_error(E["group-by"](_118_, E.map(_119_, constraints))) end


 return Solver