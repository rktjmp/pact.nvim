
 local _local_6_, enum, _local_7_, _local_8_, _local_9_ = nil, nil, nil, nil, nil do local _5_ = require("pact.plugin.constraint") local _4_ = require("pact.valid") local _3_ = string local _2_ = require("pact.lib.ruin.enum") local _1_ = require("pact.lib.ruin.type") _local_6_, enum, _local_7_, _local_8_, _local_9_ = _1_, _2_, _3_, _4_, _5_ end local _local_10_ = _local_6_
 local string_3f = _local_10_["string?"] local table_3f = _local_10_["table?"] local _local_11_ = _local_7_


 local fmt = _local_11_["format"] local _local_12_ = _local_8_
 local valid_sha_3f = _local_12_["valid-sha?"] local valid_version_spec_3f = _local_12_["valid-version-spec?"] local _local_13_ = _local_9_
 local git_constraint = _local_13_["git"] do local _ = {nil, nil, nil} end

 local function make_provider(url)
 return {"git", url} end

 local function decorate_tostring(t, name, short)
 local function _14_() return fmt("%s/%s", name, short) end return setmetatable(t, {__tostring = _14_}) end

 local __fn_2a_url_ok_3f_dispatch = {bodies = {}, help = {}} local url_ok_3f local function _16_(...) if (0 == #(__fn_2a_url_ok_3f_dispatch).bodies) then error(("multi-arity function " .. "url-ok?" .. " has no bodies")) else end local _18_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_url_ok_3f_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _18_ = f_74_auto end if (nil ~= _18_) then local f_74_auto = _18_ return f_74_auto(...) elseif (_18_ == nil) then local view_77_auto do local _19_, _20_ = pcall(require, "fennel") if ((_19_ == true) and ((_G.type(_20_) == "table") and (nil ~= (_20_).view))) then local view_77_auto0 = (_20_).view view_77_auto = view_77_auto0 elseif ((_19_ == false) and true) then local __75_auto = _20_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _22_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _22_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "url-ok?", table.concat(_22_, ", "), table.concat((__fn_2a_url_ok_3f_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end url_ok_3f = _16_ local function _25_() local _26_ do table.insert((__fn_2a_url_ok_3f_dispatch).help, "(where [url] (string? url))") local function _27_(...) if (1 == select("#", ...)) then local _28_ = {...} local function _29_(...) local url_15_ = (_28_)[1] return string_3f(url_15_) end if (((_G.type(_28_) == "table") and (nil ~= (_28_)[1])) and _29_(...)) then local url_15_ = (_28_)[1] local function _30_(url)

 if ((string.match(url, "^https?:") or string.match(url, "^ssh:")) and string.match(url, ".+://.+%..+")) then

 return true else
 return nil, fmt("expected https or ssh url, got %s", url) end end return _30_ else return nil end else return nil end end table.insert((__fn_2a_url_ok_3f_dispatch).bodies, _27_) _26_ = url_ok_3f end local function _34_() table.insert((__fn_2a_url_ok_3f_dispatch).help, "(where _)") local function _35_(...) if true then local _36_ = {...} local function _37_(...) return true end if ((_G.type(_36_) == "table") and _37_(...)) then local function _38_(...)

 return nil, "expected https or ssh url string" end return _38_ else return nil end else return nil end end table.insert((__fn_2a_url_ok_3f_dispatch).bodies, _35_) return url_ok_3f end do local _ = {_26_, _34_()} end return url_ok_3f end setmetatable({nil, nil}, {__call = _25_})()

 local __fn_2a_user_repo_ok_3f_dispatch = {bodies = {}, help = {}} local user_repo_ok_3f local function _42_(...) if (0 == #(__fn_2a_user_repo_ok_3f_dispatch).bodies) then error(("multi-arity function " .. "user-repo-ok?" .. " has no bodies")) else end local _44_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_user_repo_ok_3f_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _44_ = f_74_auto end if (nil ~= _44_) then local f_74_auto = _44_ return f_74_auto(...) elseif (_44_ == nil) then local view_77_auto do local _45_, _46_ = pcall(require, "fennel") if ((_45_ == true) and ((_G.type(_46_) == "table") and (nil ~= (_46_).view))) then local view_77_auto0 = (_46_).view view_77_auto = view_77_auto0 elseif ((_45_ == false) and true) then local __75_auto = _46_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _48_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _48_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "user-repo-ok?", table.concat(_48_, ", "), table.concat((__fn_2a_user_repo_ok_3f_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end user_repo_ok_3f = _42_ local function _51_() local _52_ do table.insert((__fn_2a_user_repo_ok_3f_dispatch).help, "(where [user-repo] (and (string? user-repo) (string.match user-repo \"^[^/]+/[^/]+$\")))") local function _53_(...) if (1 == select("#", ...)) then local _54_ = {...} local function _55_(...) local user_repo_41_ = (_54_)[1] return (string_3f(user_repo_41_) and string.match(user_repo_41_, "^[^/]+/[^/]+$")) end if (((_G.type(_54_) == "table") and (nil ~= (_54_)[1])) and _55_(...)) then local user_repo_41_ = (_54_)[1] local function _56_(user_repo)


 return true end return _56_ else return nil end else return nil end end table.insert((__fn_2a_user_repo_ok_3f_dispatch).bodies, _53_) _52_ = user_repo_ok_3f end local function _59_() table.insert((__fn_2a_user_repo_ok_3f_dispatch).help, "(where _)") local function _60_(...) if true then local _61_ = {...} local function _62_(...) return true end if ((_G.type(_61_) == "table") and _62_(...)) then local function _63_(...)

 return nil, "expected user-name/repo-name" end return _63_ else return nil end else return nil end end table.insert((__fn_2a_user_repo_ok_3f_dispatch).bodies, _60_) return user_repo_ok_3f end do local _ = {_52_, _59_()} end return user_repo_ok_3f end setmetatable({nil, nil}, {__call = _51_})()

 local function git(url)

 local else_fn_66_ local function _67_(...) return ... end else_fn_66_ = _67_ local function down_18_auto(...) local _68_ = ... if (_68_ == true) then
 return decorate_tostring(make_provider(url), "git", url) elseif true then local _ = _68_ return else_fn_66_(...) else return nil end end return down_18_auto(url_ok_3f(url)) end


 local function github(user_repo)

 local else_fn_70_ local function _71_(...) return ... end else_fn_70_ = _71_ local function down_18_auto(...) local _72_ = ... if (_72_ == true) then
 return decorate_tostring(git(("https://github.com/" .. user_repo)), "github", user_repo) elseif true then local _ = _72_ return else_fn_70_(...) else return nil end end return down_18_auto(user_repo_ok_3f(user_repo)) end


 local function gitlab(user_repo)

 local else_fn_74_ local function _75_(...) return ... end else_fn_74_ = _75_ local function down_18_auto(...) local _76_ = ... if (_76_ == true) then
 return decorate_tostring(git(("https://gitlab.com/" .. user_repo)), "gitlab", user_repo) elseif true then local _ = _76_ return else_fn_74_(...) else return nil end end return down_18_auto(user_repo_ok_3f(user_repo)) end


 local function sourcehut(user_repo)

 local else_fn_78_ local function _79_(...) return ... end else_fn_78_ = _79_ local function down_18_auto(...) local _80_ = ... if (_80_ == true) then
 return decorate_tostring(git(("https://git.sr.ht/~" .. user_repo)), "sourcehut", user_repo) elseif true then local _ = _80_ return else_fn_78_(...) else return nil end end return down_18_auto(user_repo_ok_3f(user_repo)) end


 return {github = github, gitlab = gitlab, sourcehut = sourcehut, srht = sourcehut, git = git}