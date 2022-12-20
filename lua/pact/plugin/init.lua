

 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
 local _local_14_, enum, git_source, constraints, inspect, _local_15_, _local_16_ = nil, nil, nil, nil, nil, nil, nil do local _13_ = string local _12_ = require("pact.valid")



 local _11_ = (vim.inspect or print) local _10_ = require("pact.plugin.constraint") local _9_ = require("pact.plugin.source.git") local _8_ = require("pact.lib.ruin.enum") local _7_ = require("pact.lib.ruin.result") _local_14_, enum, git_source, constraints, inspect, _local_15_, _local_16_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_ end local _local_17_ = _local_14_ local err = _local_17_["err"] local map_err = _local_17_["map-err"] local ok = _local_17_["ok"] local _local_18_ = _local_15_
 local valid_sha_3f = _local_18_["valid-sha?"] local valid_version_spec_3f = _local_18_["valid-version-spec?"] local _local_19_ = _local_16_
 local fmt = _local_19_["format"] do local _ = {nil, nil} end local id = 0


 local function generate_id(plugin)
 id = (id + 1)
 return fmt("plugin-%s", id) end

 local function valid_args(user_repo, constraint)
 return (string_3f(user_repo) and (string_3f(constraint) or table_3f(constraint))) end



 local function set_tostring(plugin)
 local function _20_() return fmt("%s@%s", plugin.source, plugin.constraint) end return setmetatable(plugin, {__tostring = _20_}) end

 local function set_package_path(plugin)
 local _let_21_ = plugin.source local _ = _let_21_[1] local source = _let_21_[2]
 local folder = string.match(plugin.source[2], ".+/([^/]-)$") local dir

 local _22_ if plugin["opt?"] then _22_ = "opt" else _22_ = "start" end dir = table.concat({vim.fn.stdpath("data"), "site/pack/pact", _22_, folder}, "/")

 return enum["set$"](plugin, "package-path", dir) end

 local function opts__3econstraint(opts)
 local else_fn_24_ local function _25_(...) return ... end else_fn_24_ = _25_ local function down_18_auto(...) local _26_ = ... if (nil ~= _26_) then local keys = _26_ local function down_18_auto0(...) local _27_ = ... if (_27_ == true) then







 local _28_ = opts local function _29_(...) local version = (_28_).version return valid_version_spec_3f(version) end if (((_G.type(_28_) == "table") and (nil ~= (_28_).version)) and _29_(...)) then local version = (_28_).version
 return constraints.git("version", version) elseif ((_G.type(_28_) == "table") and (nil ~= (_28_).version)) then local version = (_28_).version
 return nil, "invalid version spec" else local function _30_(...) local commit = (_28_).commit return valid_sha_3f(commit) end if (((_G.type(_28_) == "table") and (nil ~= (_28_).commit)) and _30_(...)) then local commit = (_28_).commit
 return constraints.git("commit", commit) elseif ((_G.type(_28_) == "table") and (nil ~= (_28_).commit)) then local commit = (_28_).commit
 return nil, "invalid commit sha, must be full 40 characters" else local function _31_(...) local branch = (_28_).branch return (string_3f(branch) and (1 <= #branch)) end if (((_G.type(_28_) == "table") and (nil ~= (_28_).branch)) and _31_(...)) then local branch = (_28_).branch
 return constraints.git("branch", branch) elseif ((_G.type(_28_) == "table") and (nil ~= (_28_).branch)) then local branch = (_28_).branch
 return nil, "invalid branch, must be non-empty string" else local function _32_(...) local tag = (_28_).tag return (string_3f(tag) and (1 <= #tag)) end if (((_G.type(_28_) == "table") and (nil ~= (_28_).tag)) and _32_(...)) then local tag = (_28_).tag
 return constraints.git("tag", tag) elseif ((_G.type(_28_) == "table") and (nil ~= (_28_).tag)) then local tag = (_28_).tag
 return nil, "invalid tag, must be non-empty string" elseif true then local _ = _28_
 return nil, "expected semver constraint string or table with branch, tag, commit or version" else return nil end end end end elseif true then local _ = _27_ return else_fn_24_(...) else return nil end end local function _35_(_241) if (1 == _241) then return true else return err("options table must contain at most one constraint key") end end local function _37_(_241) return (("branch" == _241) or ("tag" == _241) or ("commit" == _241) or ("version" == _241)) end return down_18_auto0(_35_(#enum["table->pairs"](enum.filter(_37_, opts)))) elseif true then local _ = _26_ return else_fn_24_(...) else return nil end end return down_18_auto(enum.keys(opts)) end


 local function make(basic, opts)
 basic["opt?"] = (true == (opts["opt?"] or opts.opt)) do end (basic)["after"] = opts.after basic["id"] = generate_id() set_package_path(basic) set_tostring(basic) return basic end






 local __fn_2a_forge_dispatch = {bodies = {}, help = {}} local forge local function _45_(...) if (0 == #(__fn_2a_forge_dispatch).bodies) then error(("multi-arity function " .. "forge" .. " has no bodies")) else end local _47_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_forge_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _47_ = f_74_auto end if (nil ~= _47_) then local f_74_auto = _47_ return f_74_auto(...) elseif (_47_ == nil) then local view_77_auto do local _48_, _49_ = pcall(require, "fennel") if ((_48_ == true) and ((_G.type(_49_) == "table") and (nil ~= (_49_).view))) then local view_77_auto0 = (_49_).view view_77_auto = view_77_auto0 elseif ((_48_ == false) and true) then local __75_auto = _49_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _51_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _51_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "forge", table.concat(_51_, ", "), table.concat((__fn_2a_forge_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end forge = _45_ local function _54_() local _55_ do table.insert((__fn_2a_forge_dispatch).help, "(where [forge-name user-repo constraint] (and (string? user-repo) (string? constraint) (valid-version-spec? constraint)))") local function _56_(...) if (3 == select("#", ...)) then local _57_ = {...} local function _58_(...) local forge_name_39_ = (_57_)[1] local user_repo_40_ = (_57_)[2] local constraint_41_ = (_57_)[3] return (string_3f(user_repo_40_) and string_3f(constraint_41_) and valid_version_spec_3f(constraint_41_)) end if (((_G.type(_57_) == "table") and (nil ~= (_57_)[1]) and (nil ~= (_57_)[2]) and (nil ~= (_57_)[3])) and _58_(...)) then local forge_name_39_ = (_57_)[1] local user_repo_40_ = (_57_)[2] local constraint_41_ = (_57_)[3] local function _59_(forge_name, user_repo, constraint)



 return forge(forge_name, user_repo, {version = constraint}) end return _59_ else return nil end else return nil end end table.insert((__fn_2a_forge_dispatch).bodies, _56_) _55_ = forge end local _62_ do table.insert((__fn_2a_forge_dispatch).help, "(where [forge-name user-repo opts] (and (string? user-repo) (table? opts)))") local function _63_(...) if (3 == select("#", ...)) then local _64_ = {...} local function _65_(...) local forge_name_42_ = (_64_)[1] local user_repo_43_ = (_64_)[2] local opts_44_ = (_64_)[3] return (string_3f(user_repo_43_) and table_3f(opts_44_)) end if (((_G.type(_64_) == "table") and (nil ~= (_64_)[1]) and (nil ~= (_64_)[2]) and (nil ~= (_64_)[3])) and _65_(...)) then local forge_name_42_ = (_64_)[1] local user_repo_43_ = (_64_)[2] local opts_44_ = (_64_)[3] local function _66_(forge_name, user_repo, opts)


 local _67_ do local _let_69_ = require("pact.lib.ruin.result") local bind_15_auto = _let_69_["bind"] local unit_16_auto = _let_69_["unit"] local bind_70_ = bind_15_auto local unit_71_ = unit_16_auto local function _73_(source) local function _74_(constraint) local function _75_()

 return make({name = user_repo, ["forge-name"] = forge_name, source = source, constraint = constraint}, opts) end return unit_71_(_75_()) end return unit_71_(bind_70_(unit_71_(opts__3econstraint(opts)), _74_)) end _67_ = bind_70_(unit_71_(git_source[forge_name](user_repo)), _73_) end



 local function _76_(e) return err(fmt("%s/%s %s", forge_name, user_repo, e)) end return map_err(_67_, _76_) end return _66_ else return nil end else return nil end end table.insert((__fn_2a_forge_dispatch).bodies, _63_) _62_ = forge end local function _79_() table.insert((__fn_2a_forge_dispatch).help, "(where _)") local function _80_(...) if true then local _81_ = {...} local function _82_(...) return true end if ((_G.type(_81_) == "table") and _82_(...)) then local function _83_(...)

 return err(fmt("requires user/repo and version-constraint string or constraint table, got %s", inspect({...}))) end return _83_ else return nil end else return nil end end table.insert((__fn_2a_forge_dispatch).bodies, _80_) return forge end do local _ = {_55_, _62_, _79_()} end return forge end setmetatable({nil, nil}, {__call = _54_})()


 local function github(user_repo, opts)
 return forge("github", user_repo, opts) end

 local function gitlab(user_repo, opts)
 return forge("gitlab", user_repo, opts) end

 local function sourcehut(user_repo, opts)
 return forge("sourcehut", user_repo, opts) end

 local __fn_2a_git_dispatch = {bodies = {}, help = {}} local git local function _90_(...) if (0 == #(__fn_2a_git_dispatch).bodies) then error(("multi-arity function " .. "git" .. " has no bodies")) else end local _92_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_git_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _92_ = f_74_auto end if (nil ~= _92_) then local f_74_auto = _92_ return f_74_auto(...) elseif (_92_ == nil) then local view_77_auto do local _93_, _94_ = pcall(require, "fennel") if ((_93_ == true) and ((_G.type(_94_) == "table") and (nil ~= (_94_).view))) then local view_77_auto0 = (_94_).view view_77_auto = view_77_auto0 elseif ((_93_ == false) and true) then local __75_auto = _94_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _96_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _96_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "git", table.concat(_96_, ", "), table.concat((__fn_2a_git_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end git = _90_ local function _99_() local _100_ do table.insert((__fn_2a_git_dispatch).help, "(where [url constraint] (and (string? url) (string? constraint) (valid-version-spec? constraint)))") local function _101_(...) if (2 == select("#", ...)) then local _102_ = {...} local function _103_(...) local url_86_ = (_102_)[1] local constraint_87_ = (_102_)[2] return (string_3f(url_86_) and string_3f(constraint_87_) and valid_version_spec_3f(constraint_87_)) end if (((_G.type(_102_) == "table") and (nil ~= (_102_)[1]) and (nil ~= (_102_)[2])) and _103_(...)) then local url_86_ = (_102_)[1] local constraint_87_ = (_102_)[2] local function _104_(url, constraint)



 return git(url, {version = constraint}) end return _104_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _101_) _100_ = git end local _107_ do table.insert((__fn_2a_git_dispatch).help, "(where [url opts] (and (string? url) (table? opts)))") local function _108_(...) if (2 == select("#", ...)) then local _109_ = {...} local function _110_(...) local url_88_ = (_109_)[1] local opts_89_ = (_109_)[2] return (string_3f(url_88_) and table_3f(opts_89_)) end if (((_G.type(_109_) == "table") and (nil ~= (_109_)[1]) and (nil ~= (_109_)[2])) and _110_(...)) then local url_88_ = (_109_)[1] local opts_89_ = (_109_)[2] local function _111_(url, opts)

 local _112_ do local _let_114_ = require("pact.lib.ruin.result") local bind_15_auto = _let_114_["bind"] local unit_16_auto = _let_114_["unit"] local bind_115_ = bind_15_auto local unit_116_ = unit_16_auto local function _118_(source) local function _119_(forge_name)

 local function _122_() local all_1_auto, val_2_auto = nil, nil do local nil_120_ = opts.name if nil_120_ then local name = nil_120_ all_1_auto, val_2_auto = true, name else all_1_auto, val_2_auto = false end end if all_1_auto then return val_2_auto else

 return nil, "requires name option" end end local function _124_(name) local function _125_(constraint) local function _126_()

 return make({name = name, ["forge-name"] = forge_name, source = source, constraint = constraint}, opts) end return unit_116_(_126_()) end return unit_116_(bind_115_(unit_116_(opts__3econstraint(opts)), _125_)) end return unit_116_(bind_115_(unit_116_(_122_()), _124_)) end return unit_116_(bind_115_(unit_116_("git"), _119_)) end _112_ = bind_115_(unit_116_(git_source.git(url)), _118_) end



 local function _127_(e) return err(fmt("%s/%s %s", "git", url, e)) end return map_err(_112_, _127_) end return _111_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _108_) _107_ = git end local function _130_() table.insert((__fn_2a_git_dispatch).help, "(where _)") local function _131_(...) if true then local _132_ = {...} local function _133_(...) return true end if ((_G.type(_132_) == "table") and _133_(...)) then local function _134_(...)

 return err("requires url and constraint/options table") end return _134_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _131_) return git end do local _ = {_100_, _107_, _130_()} end return git end setmetatable({nil, nil}, {__call = _99_})()

 return {git = git, github = github, gitlab = gitlab, sourcehut = sourcehut, srht = sourcehut}