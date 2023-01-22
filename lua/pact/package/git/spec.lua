
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local _local_13_, E, constraints, inspect, package, _local_14_ = nil, nil, nil, nil, nil, nil do local _12_ = string local _11_ = require("pact.package") local _10_ = require("pact.inspect") local _9_ = require("pact.package.constraint") local _8_ = require("pact.lib.ruin.enum") local _7_ = require("pact.lib.ruin.result") _local_13_, E, constraints, inspect, package, _local_14_ = _7_, _8_, _9_, _10_, _11_, _12_ end local _local_15_ = _local_13_ local err = _local_15_["err"] local ok = _local_15_["ok"] local _local_16_ = _local_14_




 local fmt = _local_16_["format"]

 local function validate_url(url)
 local protocols local function _17_() return string.match(url, "^http://.+") end
 local function _18_() return string.match(url, "^https://.+") end
 local function _19_() return string.match(url, "^ssh://.+") end protocols = {_17_, _18_, _19_}
 local _20_ local function _21_(_241) return (nil ~= _241()) end _20_ = E["any?"](_21_, protocols) if (_20_ == true) then return "ok" elseif (_20_ == false) then

 return {"error", "must be protocol must be http/https/ssh"} else return nil end end

 local function validate_name(opts) local pat = "^[%a%d_%-%./]+$"

 local function _23_(...) local _24_ = ... if (nil ~= _24_) then local name = _24_ local function _25_(...) local _26_ = ... if (_26_ == true) then return "ok" elseif (_26_ == nil) then




 return {"error", "must provide name"} elseif (_26_ == false) then
 return {"error", ("name must match " .. pat)} else return nil end end return _25_((nil ~= string.match(name, pat))) elseif (_24_ == nil) then return {"error", "must provide name"} elseif (_24_ == false) then return {"error", ("name must match " .. pat)} else return nil end end return _23_(opts.name) end

 local function url__3ename(url)

 return string.match(url, ".+/(.-)$") end

 local function url__3ecanonical_id(url)
 local clean = string.gsub(url, "[^%w]+", "-")
 return ("git-" .. clean) end

 local function translate_constraint(str) local git_pat = "[%a%d_%-%./]+"



 local checks






 local function _31_(_29_) local _arg_30_ = _29_ local kind = _arg_30_[1] local pat = _arg_30_[2] local make = _arg_30_[3] local function _32_() return string.match(str, pat) end return {kind, _32_, make} end checks = E.map(_31_, {{"head", "^%*$", constraints.git.head}, {"commit", "^%^(%x+)$", constraints.git.commit}, {"tag", ("^#([^%^]" .. git_pat .. ")$"), constraints.git.tag}, {"branch", ("^([^%^]" .. git_pat .. ")$"), constraints.git.branch}})

 local function _33_() return constraints.version["str-is-notation?"](str) end table.insert(checks, 1, {"version", _33_, constraints.git.version})

 local _34_ local function _37_(_, _35_) local _arg_36_ = _35_ local kind = _arg_36_[1] local is_3f = _arg_36_[2] local make = _arg_36_[3]
 local _38_ = is_3f() if (nil ~= _38_) then local any = _38_
 local _39_, _40_ = make(any) if (nil ~= _39_) then local val = _39_
 return E.reduced({"ok", val}) elseif ((_39_ == nil) and (_40_ == err)) then
 return {"error", err} else return nil end else return nil end end _34_ = E.reduce(_37_, "ignored", checks) if (_34_ == nil) then

 return {"error", "could not translate constraint spec"} elseif (nil ~= _34_) then local any = _34_
 return any else return nil end end

 local function validate_constraint(opts)
 local function _44_(...) local _45_ = ... if (nil ~= _45_) then local constraint = _45_






 local _46_ = constraint local function _47_(...) local str = _46_ return string_3f(str) end if ((nil ~= _46_) and _47_(...)) then local str = _46_
 return translate_constraint(str) elseif true then local _ = _46_
 return {"error", "invalid constraint"} else return nil end elseif ((_G.type(_45_) == "table") and ((_45_)[1] == "error") and (nil ~= (_45_)[2])) then local e = (_45_)[2]

 return {"error", e} elseif (_45_ == nil) then
 return {"error", "must provide constraint"} elseif true then local _ = _45_
 return {"error", "constraint invalid"} else return nil end end return _44_((opts.constraint or opts.version or opts.branch or (opts.tag and ("#" .. opts.tag)) or (opts.commit and ("^" .. opts.commit)) or "*")) end

 local __fn_2a_make_dispatch = {bodies = {}, help = {}} local make local function _52_(...) if (0 == #(__fn_2a_make_dispatch).bodies) then error(("multi-arity function " .. "make" .. " has no bodies")) else end local _54_ do local f_78_auto = nil for __79_auto, match_3f_80_auto in ipairs((__fn_2a_make_dispatch).bodies) do if f_78_auto then break end f_78_auto = match_3f_80_auto(...) end _54_ = f_78_auto end if (nil ~= _54_) then local f_78_auto = _54_ return f_78_auto(...) elseif (_54_ == nil) then local view_81_auto do local _55_, _56_ = pcall(require, "fennel") if ((_55_ == true) and ((_G.type(_56_) == "table") and (nil ~= (_56_).view))) then local view_81_auto0 = (_56_).view view_81_auto = view_81_auto0 elseif ((_55_ == false) and true) then local __79_auto = _56_ view_81_auto = (_G.vim.inspect or print) else view_81_auto = nil end end local msg_82_auto local _58_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_83_auto = 1, select("#", ...) do local val_19_auto = view_81_auto(({...})[i_83_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _58_ = tbl_17_auto end msg_82_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "make", table.concat(_58_, ", "), table.concat((__fn_2a_make_dispatch).help, "\n")) return error(msg_82_auto) else return nil end end make = _52_ local function _61_() local _62_ do table.insert((__fn_2a_make_dispatch).help, "(where [url opts] (and (string? url) (table? opts)))") local function _63_(...) if (2 == select("#", ...)) then local _64_ = {...} local function _65_(...) local url_50_ = (_64_)[1] local opts_51_ = (_64_)[2] return (string_3f(url_50_) and table_3f(opts_51_)) end if (((_G.type(_64_) == "table") and (nil ~= (_64_)[1]) and (nil ~= (_64_)[2])) and _65_(...)) then local url_50_ = (_64_)[1] local opts_51_ = (_64_)[2] local function _66_(url, opts)




 local function _67_(...) local _68_ = ... if (_68_ == "ok") then local function _69_(...) local _70_ = ... if true then local _ = _70_ local function _71_(...) local _72_ = ... if (_72_ == "ok") then local function _73_(...) local _74_ = ... if ((_G.type(_74_) == "table") and ((_74_)[1] == "ok") and (nil ~= (_74_)[2])) then local constraint = (_74_)[2]





 opts.source = url
 opts.constraint = constraint
 opts["canonical-id"] = url__3ecanonical_id(url)
 return ok({"git", opts}) elseif ((_G.type(_74_) == "table") and ((_74_)[1] == "error") and (nil ~= (_74_)[2])) then local e = (_74_)[2]

 return err(fmt("%s %s", (opts.name or opts.url or "unknown-package"), e)) elseif true then local _0 = _74_




 return err(fmt("%s %s", (opts.name or opts.url or "unknown-name"), "invalid git plugin spec")) else return nil end end return _73_(validate_constraint(opts)) elseif ((_G.type(_72_) == "table") and ((_72_)[1] == "error") and (nil ~= (_72_)[2])) then local e = (_72_)[2] return err(fmt("%s %s", (opts.name or opts.url or "unknown-package"), e)) elseif true then local _0 = _72_ return err(fmt("%s %s", (opts.name or opts.url or "unknown-name"), "invalid git plugin spec")) else return nil end end return _71_(validate_name(opts)) elseif ((_G.type(_70_) == "table") and ((_70_)[1] == "error") and (nil ~= (_70_)[2])) then local e = (_70_)[2] return err(fmt("%s %s", (opts.name or opts.url or "unknown-package"), e)) elseif true then local _ = _70_ return err(fmt("%s %s", (opts.name or opts.url or "unknown-name"), "invalid git plugin spec")) else return nil end end opts.name = (opts.name or url__3ename(url)) return _69_(nil) elseif ((_G.type(_68_) == "table") and ((_68_)[1] == "error") and (nil ~= (_68_)[2])) then local e = (_68_)[2] return err(fmt("%s %s", (opts.name or opts.url or "unknown-package"), e)) elseif true then local _ = _68_ return err(fmt("%s %s", (opts.name or opts.url or "unknown-name"), "invalid git plugin spec")) else return nil end end return _67_(validate_url(url)) end return _66_ else return nil end else return nil end end table.insert((__fn_2a_make_dispatch).bodies, _63_) _62_ = make end local function _81_() table.insert((__fn_2a_make_dispatch).help, "(where _)") local function _82_(...) if true then local _83_ = {...} local function _84_(...) return true end if ((_G.type(_83_) == "table") and _84_(...)) then local function _85_(...)





 return err("requires url and constraint/options table") end return _85_ else return nil end else return nil end end table.insert((__fn_2a_make_dispatch).bodies, _82_) return make end do local _ = {_62_, _81_()} end return make end setmetatable({nil, nil}, {__call = _61_})()

 local __fn_2a_git_dispatch = {bodies = {}, help = {}} local git local function _88_(...) if (0 == #(__fn_2a_git_dispatch).bodies) then error(("multi-arity function " .. "git" .. " has no bodies")) else end local _90_ do local f_78_auto = nil for __79_auto, match_3f_80_auto in ipairs((__fn_2a_git_dispatch).bodies) do if f_78_auto then break end f_78_auto = match_3f_80_auto(...) end _90_ = f_78_auto end if (nil ~= _90_) then local f_78_auto = _90_ return f_78_auto(...) elseif (_90_ == nil) then local view_81_auto do local _91_, _92_ = pcall(require, "fennel") if ((_91_ == true) and ((_G.type(_92_) == "table") and (nil ~= (_92_).view))) then local view_81_auto0 = (_92_).view view_81_auto = view_81_auto0 elseif ((_91_ == false) and true) then local __79_auto = _92_ view_81_auto = (_G.vim.inspect or print) else view_81_auto = nil end end local msg_82_auto local _94_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_83_auto = 1, select("#", ...) do local val_19_auto = view_81_auto(({...})[i_83_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _94_ = tbl_17_auto end msg_82_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "git", table.concat(_94_, ", "), table.concat((__fn_2a_git_dispatch).help, "\n")) return error(msg_82_auto) else return nil end end git = _88_ local function _97_() do local _ = {} end return git end setmetatable({nil, nil}, {__call = _97_})()

 do table.insert((__fn_2a_git_dispatch).help, "(where [url] (string? url))") local function _99_(...) if (1 == select("#", ...)) then local _100_ = {...} local function _101_(...) local url_98_ = (_100_)[1] return string_3f(url_98_) end if (((_G.type(_100_) == "table") and (nil ~= (_100_)[1])) and _101_(...)) then local url_98_ = (_100_)[1] local function _102_(url)
 return git(url, {constraint = "*"}) end return _102_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _99_) end

 do table.insert((__fn_2a_git_dispatch).help, "(where [url constraint] (and (string? url) (string? constraint)))") local function _107_(...) if (2 == select("#", ...)) then local _108_ = {...} local function _109_(...) local url_105_ = (_108_)[1] local constraint_106_ = (_108_)[2] return (string_3f(url_105_) and string_3f(constraint_106_)) end if (((_G.type(_108_) == "table") and (nil ~= (_108_)[1]) and (nil ~= (_108_)[2])) and _109_(...)) then local url_105_ = (_108_)[1] local constraint_106_ = (_108_)[2] local function _110_(url, constraint)

 return git(url, {constraint = constraint}) end return _110_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _107_) end

 do table.insert((__fn_2a_git_dispatch).help, "(where [url constraint opts] (and (string? url) (string? constraint) (table? opts)))") local function _116_(...) if (3 == select("#", ...)) then local _117_ = {...} local function _118_(...) local url_113_ = (_117_)[1] local constraint_114_ = (_117_)[2] local opts_115_ = (_117_)[3] return (string_3f(url_113_) and string_3f(constraint_114_) and table_3f(opts_115_)) end if (((_G.type(_117_) == "table") and (nil ~= (_117_)[1]) and (nil ~= (_117_)[2]) and (nil ~= (_117_)[3])) and _118_(...)) then local url_113_ = (_117_)[1] local constraint_114_ = (_117_)[2] local opts_115_ = (_117_)[3] local function _119_(url, constraint, opts)


 return git(url, E["merge$"](opts, {constraint = constraint})) end return _119_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _116_) end

 do table.insert((__fn_2a_git_dispatch).help, "(where [url opts] (and (string? url) (table? opts)))") local function _124_(...) if (2 == select("#", ...)) then local _125_ = {...} local function _126_(...) local url_122_ = (_125_)[1] local opts_123_ = (_125_)[2] return (string_3f(url_122_) and table_3f(opts_123_)) end if (((_G.type(_125_) == "table") and (nil ~= (_125_)[1]) and (nil ~= (_125_)[2])) and _126_(...)) then local url_122_ = (_125_)[1] local opts_123_ = (_125_)[2] local function _127_(url, opts)


 if nil_3f(opts.name) then
 local pats = {"github.com/(.+)$", "gitlab.com/(.+)$", "git.sr.ht/~(.+)$"} local name
 local function _128_(_, pat)
 local _129_ = string.match(url, pat) if (nil ~= _129_) then local name0 = _129_
 return E.reduced(name0) else return nil end end name = E.reduce(_128_, nil, pats)

 opts.name = name else end
 return make(url, opts) end return _127_ else return nil end else return nil end end table.insert((__fn_2a_git_dispatch).bodies, _124_) end

 local function github(user_repo, ...)
 return git(("https://github.com/" .. user_repo), ...) end

 local function gitlab(user_repo, ...)
 return git(("https://gitlab.com/" .. user_repo), ...) end

 local function sourcehut(user_repo, ...)
 return git(("https://git.sr.ht/~" .. user_repo), ...) end

 local function srht(...)
 return sourcehut(...) end

 return {git = git, github = github, gitlab = gitlab, sourcehut = sourcehut}