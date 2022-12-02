

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
 local dir local function _21_() if plugin["opt?"] then return "opt" else return "start" end end dir = ((vim.fn.stdpath("data") .. "/site/pack/pact" .. _21_()) .. "/" .. plugin["forge-name"] .. "-" .. string.gsub(plugin.name, "/", "-"))

 return enum["set$"](plugin, "package-path", dir) end

 local function opts__3econstraint(opts)
 local else_fn_22_ local function _23_(...) return ... end else_fn_22_ = _23_ local function down_18_auto(...) local _24_ = ... if (nil ~= _24_) then local keys = _24_ local function down_18_auto0(...) local _25_ = ... if (_25_ == true) then







 local _26_ = opts local function _27_(...) local version = (_26_).version return valid_version_spec_3f(version) end if (((_G.type(_26_) == "table") and (nil ~= (_26_).version)) and _27_(...)) then local version = (_26_).version
 return constraints.git("version", version) elseif ((_G.type(_26_) == "table") and (nil ~= (_26_).version)) then local version = (_26_).version
 return nil, "invalid version spec" else local function _28_(...) local commit = (_26_).commit return valid_sha_3f(commit) end if (((_G.type(_26_) == "table") and (nil ~= (_26_).commit)) and _28_(...)) then local commit = (_26_).commit
 return constraints.git("commit", commit) elseif ((_G.type(_26_) == "table") and (nil ~= (_26_).commit)) then local commit = (_26_).commit
 return nil, "invalid commit sha, must be full 40 characters" else local function _29_(...) local branch = (_26_).branch return (string_3f(branch) and (1 <= #branch)) end if (((_G.type(_26_) == "table") and (nil ~= (_26_).branch)) and _29_(...)) then local branch = (_26_).branch
 return constraints.git("branch", branch) elseif ((_G.type(_26_) == "table") and (nil ~= (_26_).branch)) then local branch = (_26_).branch
 return nil, "invalid branch, must be non-empty string" else local function _30_(...) local tag = (_26_).tag return (string_3f(tag) and (1 <= #tag)) end if (((_G.type(_26_) == "table") and (nil ~= (_26_).tag)) and _30_(...)) then local tag = (_26_).tag
 return constraints.git("tag", tag) elseif ((_G.type(_26_) == "table") and (nil ~= (_26_).tag)) then local tag = (_26_).tag
 return nil, "invalid tag, must be non-empty string" elseif true then local _ = _26_
 return nil, "expected semver constraint string or table with branch, tag, commit or version" else return nil end end end end elseif true then local _ = _25_ return else_fn_22_(...) else return nil end end local function _33_(_241) if (1 == _241) then return true else return err("options table must contain at most one constraint key") end end local function _35_(_241) return (("branch" == _241) or ("tag" == _241) or ("commit" == _241) or ("version" == _241)) end return down_18_auto0(_33_(#enum["table->pairs"](enum.filter(_35_, opts)))) elseif true then local _ = _24_ return else_fn_22_(...) else return nil end end return down_18_auto(enum.keys(opts)) end


 local function make(basic, opts)
 basic["opt?"] = not_nil_3f((opts["opt?"] or opts.opt)) do end (basic)["id"] = generate_id() set_package_path(basic) set_tostring(basic) return basic end





 local __fn_2a_forge_dispatch = {bodies = {}, help = {}} local forge local function _43_(...) if (0 == #(__fn_2a_forge_dispatch).bodies) then error(("multi-arity function " .. "forge" .. " has no bodies")) else end local _45_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_forge_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _45_ = f_74_auto end if (nil ~= _45_) then local f_74_auto = _45_ return f_74_auto(...) elseif (_45_ == nil) then local view_77_auto do local _46_, _47_ = pcall(require, "fennel") if ((_46_ == true) and ((_G.type(_47_) == "table") and (nil ~= (_47_).view))) then local view_77_auto0 = (_47_).view view_77_auto = view_77_auto0 elseif ((_46_ == false) and true) then local __75_auto = _47_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "forge", view_77_auto({...}), table.concat((__fn_2a_forge_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end forge = _43_ local function _50_() local _51_ do table.insert((__fn_2a_forge_dispatch).help, "(where [forge-name user-repo constraint] (and (string? user-repo) (string? constraint) (valid-version-spec? constraint)))") local function _52_(...) if (3 == select("#", ...)) then local _53_ = {...} local function _54_(...) local forge_name_37_ = (_53_)[1] local user_repo_38_ = (_53_)[2] local constraint_39_ = (_53_)[3] return (string_3f(user_repo_38_) and string_3f(constraint_39_) and valid_version_spec_3f(constraint_39_)) end if (((_G.type(_53_) == "table") and (nil ~= (_53_)[1]) and (nil ~= (_53_)[2]) and (nil ~= (_53_)[3])) and _54_(...)) then local forge_name_37_ = (_53_)[1] local user_repo_38_ = (_53_)[2] local constraint_39_ = (_53_)[3] local function _55_(forge_name, user_repo, constraint)



 return forge(forge_name, user_repo, {version = constraint}) end return _55_ else return nil end else return nil end end table.insert((__fn_2a_forge_dispatch).bodies, _52_) _51_ = forge end local _58_ do table.insert((__fn_2a_forge_dispatch).help, "(where [forge-name user-repo opts] (and (string? user-repo) (table? opts)))") local function _59_(...) if (3 == select("#", ...)) then local _60_ = {...} local function _61_(...) local forge_name_40_ = (_60_)[1] local user_repo_41_ = (_60_)[2] local opts_42_ = (_60_)[3] return (string_3f(user_repo_41_) and table_3f(opts_42_)) end if (((_G.type(_60_) == "table") and (nil ~= (_60_)[1]) and (nil ~= (_60_)[2]) and (nil ~= (_60_)[3])) and _61_(...)) then local forge_name_40_ = (_60_)[1] local user_repo_41_ = (_60_)[2] local opts_42_ = (_60_)[3] local function _62_(forge_name, user_repo, opts)


 local _63_ do local _let_65_ = require("pact.lib.ruin.result") local bind_15_auto = _let_65_["bind"] local unit_16_auto = _let_65_["unit"] local bind_66_ = bind_15_auto local unit_67_ = unit_16_auto local function _69_(source) local function _70_(constraint) local function _71_()

 return make({name = user_repo, ["forge-name"] = forge_name, source = source, constraint = constraint}, opts) end return unit_67_(_71_()) end return unit_67_(bind_66_(unit_67_(opts__3econstraint(opts)), _70_)) end _63_ = bind_66_(unit_67_(git_source[forge_name](user_repo)), _69_) end



 local function _72_(e) return err(fmt("%s/%s %s", forge_name, user_repo, e)) end return map_err(_63_, _72_) end return _62_ else return nil end else return nil end end table.insert((__fn_2a_forge_dispatch).bodies, _59_) _58_ = forge end local function _75_() table.insert((__fn_2a_forge_dispatch).help, "(where _)") local function _76_(...) if true then local _77_ = {...} local function _78_(...) return true end if ((_G.type(_77_) == "table") and _78_(...)) then local function _79_(...)

 return err(fmt("requires user/repo and version-constraint string or constraint table, got %s", inspect({...}))) end return _79_ else return nil end else return nil end end table.insert((__fn_2a_forge_dispatch).bodies, _76_) return forge end do local _ = {_51_, _58_, _75_()} end return forge end setmetatable({nil, nil}, {__call = _50_})()


 local function github(user_repo, opts)
 return forge("github", user_repo, opts) end

 local function gitlab(user_repo, opts)
 return forge("gitlab", user_repo, opts) end

 local function sourcehut(user_repo, opts)
 return forge("sourcehut", user_repo, opts) end

 local __fn_2a_git_dispatch = {bodies = {}, help = {}} local git local function _86_(...) if (0 == #(__fn_2a_git_dispatch).bodies) then error(("multi-arity function " .. "git" .. " has no bodies")) else end local _88_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_git_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _88_ = f_74_auto end if (nil ~= _88_) then local f_74_auto = _88_ return f_74_auto(...) elseif (_88_ == nil) then local view_77_auto do local _89_, _90_ = pcall(require, "fennel") if ((_89_ == true) and ((_G.type(_90_) == "table") and (nil ~= (_90_).view))) then local view_77_auto0 = (_90_).view view_77_auto = view_77_auto0 elseif ((_89_ == false) and true) then local __75_auto = _90_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "git", view_77_auto({...}), table.concat((__fn_2a_git_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end git = _86_ local function _93_() local _94_ do table.insert((__fn_2a_git_dispatch).help, "(where [url constraint] (and (string? url) (string? constraint) (valid-version-spec? constraint)))") local function _95_(...) if (2 == select("#", ...)) then local _96_ = {...} local function _97_(...) local url_82_ = (_96_)[1] local constraint_83_ = (_96_)[2] return (string_3f(url_82_) and string_3f(constraint_83_) and valid_version_spec_3f(constraint_83_)) end if (((_G.type(_96_) == "table") and (nil ~= (_96_)[1]) and (nil ~= (_96_)[2])) and _97_(...)) then local url_82_ = (_96_)[1] local constraint_83_ = (_96_)[2] local function _98_(url, constraint)



 return git(url, {version = constraint}) end return _98_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _95_) _94_ = git end local _101_ do table.insert((__fn_2a_git_dispatch).help, "(where [url opts] (and (string? url) (table? opts)))") local function _102_(...) if (2 == select("#", ...)) then local _103_ = {...} local function _104_(...) local url_84_ = (_103_)[1] local opts_85_ = (_103_)[2] return (string_3f(url_84_) and table_3f(opts_85_)) end if (((_G.type(_103_) == "table") and (nil ~= (_103_)[1]) and (nil ~= (_103_)[2])) and _104_(...)) then local url_84_ = (_103_)[1] local opts_85_ = (_103_)[2] local function _105_(url, opts)

 local _106_ do local _let_108_ = require("pact.lib.ruin.result") local bind_15_auto = _let_108_["bind"] local unit_16_auto = _let_108_["unit"] local bind_109_ = bind_15_auto local unit_110_ = unit_16_auto local function _112_(source) local function _113_(forge_name)

 local function _116_() local all_1_auto, val_2_auto = nil, nil do local nil_114_ = opts.name if nil_114_ then local name = nil_114_ all_1_auto, val_2_auto = true, name else all_1_auto, val_2_auto = false end end if all_1_auto then return val_2_auto else

 return nil, "requires name option" end end local function _118_(name) local function _119_(constraint) local function _120_()

 return make({name = name, ["forge-name"] = forge_name, source = source, constraint = constraint}, opts) end return unit_110_(_120_()) end return unit_110_(bind_109_(unit_110_(opts__3econstraint(opts)), _119_)) end return unit_110_(bind_109_(unit_110_(_116_()), _118_)) end return unit_110_(bind_109_(unit_110_("git"), _113_)) end _106_ = bind_109_(unit_110_(git_source.git(url)), _112_) end



 local function _121_(e) return err(fmt("%s/%s %s", "git", url, e)) end return map_err(_106_, _121_) end return _105_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _102_) _101_ = git end local function _124_() table.insert((__fn_2a_git_dispatch).help, "(where _)") local function _125_(...) if true then local _126_ = {...} local function _127_(...) return true end if ((_G.type(_126_) == "table") and _127_(...)) then local function _128_(...)

 return err("requires url and constraint/options table") end return _128_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _125_) return git end do local _ = {_94_, _101_, _124_()} end return git end setmetatable({nil, nil}, {__call = _93_})()

 return {git = git, github = github, gitlab = gitlab, sourcehut = sourcehut, srht = sourcehut}