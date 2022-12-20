
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local enum, _local_10_, _local_11_ = nil, nil, nil do local _9_ = string local _8_ = require("pact.valid") local _7_ = require("pact.lib.ruin.enum") enum, _local_10_, _local_11_ = _7_, _8_, _9_ end local _local_12_ = _local_10_
 local valid_sha_3f = _local_12_["valid-sha?"] local _local_13_ = _local_11_
 local fmt = _local_13_["format"]

 local __fn_2a_expand_version_dispatch = {bodies = {}, help = {}} local expand_version local function _17_(...) if (0 == #(__fn_2a_expand_version_dispatch).bodies) then error(("multi-arity function " .. "expand-version" .. " has no bodies")) else end local _19_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_expand_version_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _19_ = f_74_auto end if (nil ~= _19_) then local f_74_auto = _19_ return f_74_auto(...) elseif (_19_ == nil) then local view_77_auto do local _20_, _21_ = pcall(require, "fennel") if ((_20_ == true) and ((_G.type(_21_) == "table") and (nil ~= (_21_).view))) then local view_77_auto0 = (_21_).view view_77_auto = view_77_auto0 elseif ((_20_ == false) and true) then local __75_auto = _21_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _23_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _23_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "expand-version", table.concat(_23_, ", "), table.concat((__fn_2a_expand_version_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end expand_version = _17_ local function _26_() local _27_ do table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+)$\"))") local function _28_(...) if (1 == select("#", ...)) then local _29_ = {...} local function _30_(...) local v_14_ = (_29_)[1] return string.match(v_14_, "^(%d+)$") end if (((_G.type(_29_) == "table") and (nil ~= (_29_)[1])) and _30_(...)) then local v_14_ = (_29_)[1] local function _31_(v)


 return (v .. ".0.0") end return _31_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _28_) _27_ = expand_version end local _34_ do table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+%.%d+)$\"))") local function _35_(...) if (1 == select("#", ...)) then local _36_ = {...} local function _37_(...) local v_15_ = (_36_)[1] return string.match(v_15_, "^(%d+%.%d+)$") end if (((_G.type(_36_) == "table") and (nil ~= (_36_)[1])) and _37_(...)) then local v_15_ = (_36_)[1] local function _38_(v)

 return (v .. ".0") end return _38_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _35_) _34_ = expand_version end local _41_ do table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+%.%d+%.%d+)$\"))") local function _42_(...) if (1 == select("#", ...)) then local _43_ = {...} local function _44_(...) local v_16_ = (_43_)[1] return string.match(v_16_, "^(%d+%.%d+%.%d+)$") end if (((_G.type(_43_) == "table") and (nil ~= (_43_)[1])) and _44_(...)) then local v_16_ = (_43_)[1] local function _45_(v)

 return v end return _45_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _42_) _41_ = expand_version end local function _48_() table.insert((__fn_2a_expand_version_dispatch).help, "(where _)") local function _49_(...) if true then local _50_ = {...} local function _51_(...) return true end if ((_G.type(_50_) == "table") and _51_(...)) then local function _52_(...)

 return nil end return _52_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _49_) return expand_version end do local _ = {_27_, _34_, _41_, _48_()} end return expand_version end setmetatable({nil, nil}, {__call = _26_})()



 local __fn_2a_commit_dispatch = {bodies = {}, help = {}} local commit local function _60_(...) if (0 == #(__fn_2a_commit_dispatch).bodies) then error(("multi-arity function " .. "commit" .. " has no bodies")) else end local _62_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_commit_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _62_ = f_74_auto end if (nil ~= _62_) then local f_74_auto = _62_ return f_74_auto(...) elseif (_62_ == nil) then local view_77_auto do local _63_, _64_ = pcall(require, "fennel") if ((_63_ == true) and ((_G.type(_64_) == "table") and (nil ~= (_64_).view))) then local view_77_auto0 = (_64_).view view_77_auto = view_77_auto0 elseif ((_63_ == false) and true) then local __75_auto = _64_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _66_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _66_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "commit", table.concat(_66_, ", "), table.concat((__fn_2a_commit_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end commit = _60_ local function _69_() local _70_ do table.insert((__fn_2a_commit_dispatch).help, "(where [sha] (valid-sha? sha))") local function _71_(...) if (1 == select("#", ...)) then local _72_ = {...} local function _73_(...) local sha_55_ = (_72_)[1] return valid_sha_3f(sha_55_) end if (((_G.type(_72_) == "table") and (nil ~= (_72_)[1])) and _73_(...)) then local sha_55_ = (_72_)[1] local function _74_(sha)

 return commit(sha, {}) end return _74_ else return nil end else return nil end end table.insert((__fn_2a_commit_dispatch).bodies, _71_) _70_ = commit end local _77_ do table.insert((__fn_2a_commit_dispatch).help, "(where [sha {:branch ?branch :tag ?tag :version ?version}] (and (valid-sha? sha) (string? (or ?tag \"\")) (string? (or ?branch \"\")) (string? (or ?version \"\"))))") local function _78_(...) if (2 == select("#", ...)) then local _79_ = {...} local function _80_(...) local sha_56_ = (_79_)[1] local _3ftag_57_ = ((_79_)[2]).tag local _3fbranch_58_ = ((_79_)[2]).branch local _3fversion_59_ = ((_79_)[2]).version return (valid_sha_3f(sha_56_) and string_3f((_3ftag_57_ or "")) and string_3f((_3fbranch_58_ or "")) and string_3f((_3fversion_59_ or ""))) end if (((_G.type(_79_) == "table") and (nil ~= (_79_)[1]) and ((_G.type((_79_)[2]) == "table") and true and true and true)) and _80_(...)) then local sha_56_ = (_79_)[1] local _3ftag_57_ = ((_79_)[2]).tag local _3fbranch_58_ = ((_79_)[2]).branch local _3fversion_59_ = ((_79_)[2]).version local function _83_(sha, _81_)
 local _arg_82_ = _81_ local _3ftag = _arg_82_["tag"] local _3fbranch = _arg_82_["branch"] local _3fversion = _arg_82_["version"]








 local function _84_(_241) return fmt("%s@%s", (_241.version or _241.branch or _241.tag or "commit"), string.sub(_241.sha, 1, 8)) end return setmetatable({sha = sha, branch = _3fbranch, tag = _3ftag, version = expand_version(_3fversion)}, {__tostring = _84_}) end return _83_ else return nil end else return nil end end table.insert((__fn_2a_commit_dispatch).bodies, _78_) _77_ = commit end local function _87_() table.insert((__fn_2a_commit_dispatch).help, "(where _)") local function _88_(...) if true then local _89_ = {...} local function _90_(...) return true end if ((_G.type(_89_) == "table") and _90_(...)) then local function _91_(...)



 return nil, "commit requires a valid sha and optional table of tag, branch or version" end return _91_ else return nil end else return nil end end table.insert((__fn_2a_commit_dispatch).bodies, _88_) return commit end do local _ = {_70_, _77_, _87_()} end return commit end setmetatable({nil, nil}, {__call = _69_})()

 local function ref_line__3ecommit(ref)

















 local function strip_peel(tag_name)
 return (string.match(tag_name, "(.+)%^{}$") or tag_name) end



 local _94_, _95_, _96_ = string.match(ref, "(%x+)%s+refs/(.-)/(.+)") if ((nil ~= _94_) and (_95_ == "heads") and (nil ~= _96_)) then local sha = _94_ local name = _96_
 return commit(sha, {branch = name}) elseif ((nil ~= _94_) and (_95_ == "tags") and (nil ~= _96_)) then local sha = _94_ local name = _96_
 local _97_ = string.match(name, "v?(%d+%.%d+%.%d+)") if (_97_ == nil) then
 return commit(sha, {tag = strip_peel(name)}) elseif (nil ~= _97_) then local version = _97_

 return commit(sha, {tag = strip_peel(name), version = version}) else return nil end elseif (nil ~= _94_) then local other = _94_

 return error(string.format("unexpected remote-ref format: %s", other)) else return nil end end

 local function ref_lines__3ecommits(refs)






 local function _100_(acc, group_name, commits)
 local _101_ = {group_name, #commits} if ((_G.type(_101_) == "table") and ((_101_)[1] == false) and true) then local _ = (_101_)[2]

 local function _102_(_241, _242) return _242.commit end return enum["concat$"](acc, enum.map(_102_, commits)) elseif ((_G.type(_101_) == "table") and (nil ~= (_101_)[1]) and ((_101_)[2] == 1)) then local version = (_101_)[1]


 return enum["append$"](acc, commits[1].commit) elseif ((_G.type(_101_) == "table") and (nil ~= (_101_)[1]) and (nil ~= (_101_)[2])) then local version = (_101_)[1] local n = (_101_)[2]



 local function _103_(_241, _242) return _242.commit end local function _104_(_241, _242) return _242["peeled?"] end return enum["concat$"](acc, enum.map(_103_, enum.filter(_104_, commits))) else return nil end end local function _106_(_241, _242) return (_242.commit.tag or false) end local function _107_(_241, _242) local commit0 = ref_line__3ecommit(_242) local peeled_3f = not_nil_3f(string.match(_242, "%^{}$")) return {["peeled?"] = peeled_3f, commit = commit0} end return enum.reduce(_100_, {}, enum["group-by"](_106_, enum.map(_107_, refs))) end



 return {commit = commit, ["ref-lines->commits"] = ref_lines__3ecommits}