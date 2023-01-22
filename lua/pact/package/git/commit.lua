







 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, _local_9_ = nil, nil do local _8_ = string local _7_ = require("pact.lib.ruin.enum") E, _local_9_ = _7_, _8_ end local _local_10_ = _local_9_
 local fmt = _local_10_["format"]

 local Commit = {}

 local __fn_2a_expand_version_dispatch = {bodies = {}, help = {}} local expand_version local function _14_(...) if (0 == #(__fn_2a_expand_version_dispatch).bodies) then error(("multi-arity function " .. "expand-version" .. " has no bodies")) else end local _16_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_expand_version_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _16_ = f_74_auto end if (nil ~= _16_) then local f_74_auto = _16_ return f_74_auto(...) elseif (_16_ == nil) then local view_77_auto do local _17_, _18_ = pcall(require, "fennel") if ((_17_ == true) and ((_G.type(_18_) == "table") and (nil ~= (_18_).view))) then local view_77_auto0 = (_18_).view view_77_auto = view_77_auto0 elseif ((_17_ == false) and true) then local __75_auto = _18_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _20_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _20_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "expand-version", table.concat(_20_, ", "), table.concat((__fn_2a_expand_version_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end expand_version = _14_ local function _23_() local _24_ do table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+)$\"))") local function _25_(...) if (1 == select("#", ...)) then local _26_ = {...} local function _27_(...) local v_11_ = (_26_)[1] return string.match(v_11_, "^(%d+)$") end if (((_G.type(_26_) == "table") and (nil ~= (_26_)[1])) and _27_(...)) then local v_11_ = (_26_)[1] local function _28_(v)


 return (v .. ".0.0") end return _28_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _25_) _24_ = expand_version end local _31_ do table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+%.%d+)$\"))") local function _32_(...) if (1 == select("#", ...)) then local _33_ = {...} local function _34_(...) local v_12_ = (_33_)[1] return string.match(v_12_, "^(%d+%.%d+)$") end if (((_G.type(_33_) == "table") and (nil ~= (_33_)[1])) and _34_(...)) then local v_12_ = (_33_)[1] local function _35_(v)

 return (v .. ".0") end return _35_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _32_) _31_ = expand_version end local _38_ do table.insert((__fn_2a_expand_version_dispatch).help, "(where [v] (string.match v \"^(%d+%.%d+%.%d+)$\"))") local function _39_(...) if (1 == select("#", ...)) then local _40_ = {...} local function _41_(...) local v_13_ = (_40_)[1] return string.match(v_13_, "^(%d+%.%d+%.%d+)$") end if (((_G.type(_40_) == "table") and (nil ~= (_40_)[1])) and _41_(...)) then local v_13_ = (_40_)[1] local function _42_(v)

 return v end return _42_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _39_) _38_ = expand_version end local function _45_() table.insert((__fn_2a_expand_version_dispatch).help, "(where _)") local function _46_(...) if true then local _47_ = {...} local function _48_(...) return true end if ((_G.type(_47_) == "table") and _48_(...)) then local function _49_(...)

 return nil end return _49_ else return nil end else return nil end end table.insert((__fn_2a_expand_version_dispatch).bodies, _46_) return expand_version end do local _ = {_24_, _31_, _38_, _45_()} end return expand_version end setmetatable({nil, nil}, {__call = _23_})()

 local function ref__3etypes(ref)




 if (ref == "HEAD") then
 return {"HEAD", true} else
 local _52_, _53_ = string.match(ref, "refs/(.-)/(.+)") if ((_52_ == "heads") and (nil ~= _53_)) then local name = _53_
 return {"branch", name} elseif ((_52_ == "tags") and (nil ~= _53_)) then local name = _53_
 return {"tag", name} elseif true then local _ = _52_
 return error(string.format("unexpected ref format: %s", ref)) else return nil end end end

 local function match_relaxed_version_3f(str)

 local patterns = {"^v?(%d+%.%d+%.%d+)$", "^v?(%d+%.%d+)$", "^v(%d+)$"}
 local function _56_(_241, _242) local _57_ = string.match(str, _242) if (nil ~= _57_) then local any = _57_
 return E.reduced(any) else return nil end end return E.reduce(_56_, nil, patterns) end


 local function to_string(c)
 local join local function _59_(prefix, list)
 if not E["empty?"](list) then

 local function _60_(_241) return fmt("%s%s", prefix, _241) end return fmt("(%s)", table.concat(E.map(_60_, list), " ")) else return "" end end join = _59_



 local function _62_(_241, _242) local _64_ do local _63_ = _242 if (_63_ == "versions") then _64_ = "v" elseif (_63_ == "branches") then _64_ = "" elseif (_63_ == "tags") then _64_ = "#" else _64_ = nil end end return (_241 .. join(_64_, c[_242])) end




 local function _69_() if c["HEAD?"] then return "HEAD" else return c["short-sha"] end end return E.reduce(_62_, fmt("%s@", _69_()), {"versions", "branches", "tags"}) end


 local function full_sha_3f(sha)


 local _71_ do local _70_ = string.match(sha, "^(%x+)$") if (nil ~= _70_) then _71_ = #_70_ else _71_ = _70_ end end return (string_3f(sha) and (40 == _71_)) end

 local __fn_2a_Commit__new_dispatch = {bodies = {}, help = {}} local function _76_(...) if (0 == #(__fn_2a_Commit__new_dispatch).bodies) then error(("multi-arity function " .. "Commit.new" .. " has no bodies")) else end local _78_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_Commit__new_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _78_ = f_74_auto end if (nil ~= _78_) then local f_74_auto = _78_ return f_74_auto(...) elseif (_78_ == nil) then local view_77_auto do local _79_, _80_ = pcall(require, "fennel") if ((_79_ == true) and ((_G.type(_80_) == "table") and (nil ~= (_80_).view))) then local view_77_auto0 = (_80_).view view_77_auto = view_77_auto0 elseif ((_79_ == false) and true) then local __75_auto = _80_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _82_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _82_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "Commit.new", table.concat(_82_, ", "), table.concat((__fn_2a_Commit__new_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end Commit.new = _76_ local function _85_() local _86_ do table.insert((__fn_2a_Commit__new_dispatch).help, "(where [sha] (string? sha))") local function _87_(...) if (1 == select("#", ...)) then local _88_ = {...} local function _89_(...) local sha_73_ = (_88_)[1] return string_3f(sha_73_) end if (((_G.type(_88_) == "table") and (nil ~= (_88_)[1])) and _89_(...)) then local sha_73_ = (_88_)[1] local function _90_(sha)

 return Commit.new(sha, {}) end return _90_ else return nil end else return nil end end table.insert((__fn_2a_Commit__new_dispatch).bodies, _87_) _86_ = Commit.new end local _93_ do table.insert((__fn_2a_Commit__new_dispatch).help, "(where [sha data] (string? sha))") local function _94_(...) if (2 == select("#", ...)) then local _95_ = {...} local function _96_(...) local sha_74_ = (_95_)[1] local data_75_ = (_95_)[2] return string_3f(sha_74_) end if (((_G.type(_95_) == "table") and (nil ~= (_95_)[1]) and (nil ~= (_95_)[2])) and _96_(...)) then local sha_74_ = (_95_)[1] local data_75_ = (_95_)[2] local function _97_(sha, data)



























 local function _98_(_241) return setmetatable(_241, {__tostring = to_string}) end local function _99_(_241, _242) local _100_ = _242 if ((_G.type(_100_) == "table") and ((_100_)[1] == "HEAD") and ((_100_)[2] == true)) then return E["set$"](_241, "HEAD?", true) elseif ((_G.type(_100_) == "table") and (nil ~= (_100_)[1]) and (nil ~= (_100_)[2])) then local where = (_100_)[1] local what = (_100_)[2] E["append$"]((_241)[where], what) return _241 elseif true then local _ = _100_ return error(fmt("unsuported data %s", _242)) else return nil end end local function _102_(_241) local _103_ = _241 if ((_G.type(_103_) == "table") and ((_103_)[1] == "tag") and (nil ~= (_103_)[2])) then local t = (_103_)[2] return {"tags", t} elseif ((_G.type(_103_) == "table") and ((_103_)[1] == "branch") and (nil ~= (_103_)[2])) then local b = (_103_)[2] return {"branches", b} elseif ((_G.type(_103_) == "table") and ((_103_)[1] == "version") and (nil ~= (_103_)[2])) then local v = (_103_)[2] return {"versions", expand_version(v)} else local function _104_() local h = (_103_)[2] return ((h == true) or (h == "true")) end if (((_G.type(_103_) == "table") and ((_103_)[1] == "HEAD") and (nil ~= (_103_)[2])) and _104_()) then local h = (_103_)[2] return {"HEAD", true} elseif true then local _ = _103_ return error(fmt("unknown commit data: %s", vim.inspect(_241))) else return nil end end end return _98_(E.reduce(_99_, {sha = sha, ["short-sha"] = Commit["abbrev-sha"](sha), tags = {}, branches = {}, versions = {}}, E.map(_102_, data))) end return _97_ else return nil end else return nil end end table.insert((__fn_2a_Commit__new_dispatch).bodies, _94_) _93_ = Commit.new end local function _108_() table.insert((__fn_2a_Commit__new_dispatch).help, "(where _)") local function _109_(...) if true then local _110_ = {...} local function _111_(...) return true end if ((_G.type(_110_) == "table") and _111_(...)) then local function _112_(...)

 return nil, "commit requires a valid sha and optional list of tags, branches or versions" end return _112_ else return nil end else return nil end end table.insert((__fn_2a_Commit__new_dispatch).bodies, _109_) return Commit.new end do local _ = {_86_, _93_, _108_()} end return Commit.new end setmetatable({nil, nil}, {__call = _85_})()

 Commit["remote-refs->commits"] = function(refs)
































































 local function _115_(data, sha) return Commit.new(sha, data) end local function _116_(_241, _242) return _241, _242 end local function _117_(_241, _242, _243) do local _118_ = _243 if ((_G.type(_118_) == "table") and ((_118_)[1] == "tag") and (nil ~= (_118_)[2])) then local t = (_118_)[2] local _119_ = match_relaxed_version_3f(t) if (nil ~= _119_) then local ver = _119_ E["set$"](_241, {"version", expand_version(ver)}, _242) else end else end end return E["set$"](_241, _243, _242) end local function _122_(_241, _242, _243) return E["set$"](_241, {string.match(_243, "(.+)@(.+)")}, _242) end local function _123_(_241, _242, _243) return E["set$"](_241, string.gsub(_243, "%^{}$", ""), _242) end local function _124_(data) local function _125_(acc, sha, ref) local _126_ = ref local function _127_() local name = _126_ return string.match(name, "^tag@") end if ((nil ~= _126_) and _127_()) then local name = _126_ if not data[(name .. "^{}")] then return E["set$"](acc, ref, sha) else return acc end elseif true then local _ = _126_ return E["set$"](acc, ref, sha) else return nil end end return E.reduce(_125_, {}, data) end local function _130_(acc, refs0, sha) local function _131_(_241, _242) return E["set$"](_241, _242, sha) end local function _132_(_241) return fmt("%s@%s", unpack(ref__3etypes(_241))) end return E.reduce(_131_, acc, E.map(_132_, refs0)) end local function _133_(_241) return string.match(_241, "(%x+)%s+(.+)") end return E.map(_115_, E["group-by"](_116_, E.reduce(_117_, {}, E.reduce(_122_, {}, E.reduce(_123_, {}, _124_(E.reduce(_130_, {}, E["group-by"](_133_, refs)))))))) end

 Commit["local-refs->commits"] = function(refs)










 local function _134_(_241) return string.gsub(_241, "%srefs/heads/HEAD$", " HEAD") end local function _135_(_241) return string.gsub(_241, "%srefs/remotes/origin", " refs/heads") end local function _136_(_241) return not string.match(_241, "%srefs/heads.+$") end return Commit["remote-refs->commits"](E.map(_134_, E.map(_135_, E.filter(_136_, refs)))) end



 Commit["valid-sha?"] = function(sha)


 local function _140_() local len local function _137_() local _138_ = string.match(sha, "^(%x+)$") if (nil ~= _138_) then return #_138_ else return _138_ end end len = (_137_() or 0)
 return ((7 <= len) and (len <= 40)) end return (string_3f(sha) and _140_()) end

 Commit["abbrev-sha"] = function(sha)


 return string.sub(sha, 1, 7) end

 return Commit