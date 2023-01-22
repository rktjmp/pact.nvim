














 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local R, E, FS, Log, gen_id, Health, _local_14_ = nil, nil, nil, nil, nil, nil, nil do local _13_ = string local _12_ = require("pact.package.health") local _11_ = require("pact.gen-id") local _10_ = require("pact.log") local _9_ = require("pact.fs") local _8_ = require("pact.lib.ruin.enum") local _7_ = require("pact.lib.ruin.result") R, E, FS, Log, gen_id, Health, _local_14_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_ end local _local_15_ = _local_14_





 local fmt = _local_15_["format"]

 local Package = {Health = Health}

 local function common_spec__3epackage(spec)


 local root = spec["canonical-id"]




 local package_name = (string.match(spec.name, ".+/([^/]-)$") or string.gsub(spec.name, "/", "-")) local rtp_path

 local _16_ if spec["opt?"] then _16_ = "opt" else _16_ = "start" end rtp_path = FS["join-path"](_16_, package_name)
 return {uid = gen_id("plugin-package"), ["canonical-id"] = spec["canonical-id"], name = spec.name, ["package-name"] = package_name, ["depended-by"] = nil, ["depends-on"] = (spec.dependencies or {}), install = {path = rtp_path}, after = spec.after, ["opt?"] = spec["opt?"], health = Health.healthy(), tasks = {waiting = 0, active = 0}, constraint = spec.constraint, events = {}, action = "unknown", ["transacting?"] = false, ["ready?"] = false} end























 local __fn_2a_Package__spec__3epackage_dispatch = {bodies = {}, help = {}} local function _20_(...) if (0 == #(__fn_2a_Package__spec__3epackage_dispatch).bodies) then error(("multi-arity function " .. "Package.spec->package" .. " has no bodies")) else end local _22_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_Package__spec__3epackage_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _22_ = f_74_auto end if (nil ~= _22_) then local f_74_auto = _22_ return f_74_auto(...) elseif (_22_ == nil) then local view_77_auto do local _23_, _24_ = pcall(require, "fennel") if ((_23_ == true) and ((_G.type(_24_) == "table") and (nil ~= (_24_).view))) then local view_77_auto0 = (_24_).view view_77_auto = view_77_auto0 elseif ((_23_ == false) and true) then local __75_auto = _24_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _26_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _26_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "Package.spec->package", table.concat(_26_, ", "), table.concat((__fn_2a_Package__spec__3epackage_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end Package["spec->package"] = _20_ local function _29_() local _30_ do table.insert((__fn_2a_Package__spec__3epackage_dispatch).help, "(where [[\"git\" spec]])") local function _31_(...) if (1 == select("#", ...)) then local _32_ = {...} local function _33_(...) local spec_18_ = ((_32_)[1])[2] return true end if (((_G.type(_32_) == "table") and ((_G.type((_32_)[1]) == "table") and (((_32_)[1])[1] == "git") and (nil ~= ((_32_)[1])[2]))) and _33_(...)) then local spec_18_ = ((_32_)[1])[2] local function _36_(_34_)
 local _arg_35_ = _34_ local _ = _arg_35_[1] local spec = _arg_35_[2]
 local base = common_spec__3epackage(spec) base.kind = "git"

 base.git = {origin = spec.source, current = {commit = nil}, target = {commit = nil, distance = nil, ["breaking?"] = false}, latest = {commit = nil}}





 local function _37_(t, k)
 local _38_ = Package[k] local function _39_() local f = _38_ return function_3f(f) end if ((nil ~= _38_) and _39_()) then local f = _38_
 return f elseif true then local _0 = _38_
 return nil else return nil end end return setmetatable(base, {__index = _37_}) end return _36_ else return nil end else return nil end end table.insert((__fn_2a_Package__spec__3epackage_dispatch).bodies, _31_) _30_ = Package["spec->package"] end local function _43_() table.insert((__fn_2a_Package__spec__3epackage_dispatch).help, "(where [[\"rock\" spec]])") local function _44_(...) if (1 == select("#", ...)) then local _45_ = {...} local function _46_(...) local spec_19_ = ((_45_)[1])[2] return true end if (((_G.type(_45_) == "table") and ((_G.type((_45_)[1]) == "table") and (((_45_)[1])[1] == "rock") and (nil ~= ((_45_)[1])[2]))) and _46_(...)) then local spec_19_ = ((_45_)[1])[2] local function _49_(_47_)
 local _arg_48_ = _47_ local _ = _arg_48_[1] local spec = _arg_48_[2]
 local base = common_spec__3epackage(spec) base.kind = "rock"

 base.rock = {server = spec.server, name = spec["rock-name"]}

 local function _50_(t, k)
 local _51_ = Package[k] local function _52_() local f = _51_ return function_3f(f) end if ((nil ~= _51_) and _52_()) then local f = _51_
 return f elseif true then local _0 = _51_
 return nil else return nil end end return setmetatable(base, {__index = _50_}) end return _49_ else return nil end else return nil end end table.insert((__fn_2a_Package__spec__3epackage_dispatch).bodies, _44_) return Package["spec->package"] end do local _ = {_30_, _43_()} end return Package["spec->package"] end setmetatable({nil, nil}, {__call = _29_})()

 Package["increment-tasks-waiting"] = function(package)
 package.tasks.waiting = (package.tasks.waiting + 1)
 return package end

 Package["decrement-tasks-waiting"] = function(package)
 package.tasks.waiting = math.max(0, (package.tasks.waiting - 1))
 return package end

 Package["increment-tasks-active"] = function(package)
 package.tasks.active = (package.tasks.active + 1)
 return package end

 Package["decrement-tasks-active"] = function(package)
 package.tasks.active = math.max(0, (package.tasks.active - 1))
 return package end

 local __fn_2a_Package__add_event_dispatch = {bodies = {}, help = {}} local function _61_(...) if (0 == #(__fn_2a_Package__add_event_dispatch).bodies) then error(("multi-arity function " .. "Package.add-event" .. " has no bodies")) else end local _63_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_Package__add_event_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _63_ = f_74_auto end if (nil ~= _63_) then local f_74_auto = _63_ return f_74_auto(...) elseif (_63_ == nil) then local view_77_auto do local _64_, _65_ = pcall(require, "fennel") if ((_64_ == true) and ((_G.type(_65_) == "table") and (nil ~= (_65_).view))) then local view_77_auto0 = (_65_).view view_77_auto = view_77_auto0 elseif ((_64_ == false) and true) then local __75_auto = _65_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _67_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _67_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "Package.add-event", table.concat(_67_, ", "), table.concat((__fn_2a_Package__add_event_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end Package["add-event"] = _61_ local function _70_() local _71_ do table.insert((__fn_2a_Package__add_event_dispatch).help, "(where [package event])") local function _72_(...) if (2 == select("#", ...)) then local _73_ = {...} local function _74_(...) local package_56_ = (_73_)[1] local event_57_ = (_73_)[2] return true end if (((_G.type(_73_) == "table") and (nil ~= (_73_)[1]) and (nil ~= (_73_)[2])) and _74_(...)) then local package_56_ = (_73_)[1] local event_57_ = (_73_)[2] local function _75_(package, event)

 return Package["add-event"](package, "no-ctx", event) end return _75_ else return nil end else return nil end end table.insert((__fn_2a_Package__add_event_dispatch).bodies, _72_) _71_ = Package["add-event"] end local function _78_() table.insert((__fn_2a_Package__add_event_dispatch).help, "(where [package ctx event])") local function _79_(...) if (3 == select("#", ...)) then local _80_ = {...} local function _81_(...) local package_58_ = (_80_)[1] local ctx_59_ = (_80_)[2] local event_60_ = (_80_)[3] return true end if (((_G.type(_80_) == "table") and (nil ~= (_80_)[1]) and (nil ~= (_80_)[2]) and (nil ~= (_80_)[3])) and _81_(...)) then local package_58_ = (_80_)[1] local ctx_59_ = (_80_)[2] local event_60_ = (_80_)[3] local function _82_(package, ctx, event)


 Log.log({ctx, event})
 table.insert(package.events, 1, {ctx, event})
 return package end return _82_ else return nil end else return nil end end table.insert((__fn_2a_Package__add_event_dispatch).bodies, _79_) return Package["add-event"] end do local _ = {_71_, _78_()} end return Package["add-event"] end setmetatable({nil, nil}, {__call = _70_})()

 Package["update-health"] = function(package, health)

 assert((Health["healthy?"](health) or Health["degraded?"](health) or Health["failing?"](health)), "update-health given non-health value")



 package.health = Health.update(package.health, health)
 if (package["depended-by"] and (Health["degraded?"](health) or Health["failing?"](health))) then
 Package["update-health"](package["depended-by"], Health.degraded("degraded by subpackage")) else end

 return package end

 Package["degrade-health"] = function(package, message) _G.assert((nil ~= message), "Missing argument message on ./fnl/pact/package/init.fnl:124") _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/package/init.fnl:124")
 return Package["update-health"](package, Package.Health.degraded(message)) end

 Package["fail-health"] = function(package, message) _G.assert((nil ~= message), "Missing argument message on ./fnl/pact/package/init.fnl:127") _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/package/init.fnl:127")
 return Package["update-health"](package, Package.Health.failing(message)) end

 Package["healthy?"] = function(package)
 return Package.Health["healthy?"](package.health) end

 Package["degraded?"] = function(package)
 return Package.Health["degraded?"](package.health) end

 Package["failing?"] = function(package)
 return Package.Health["failing?"](package.health) end

 Package["set-current-commit"] = function(package, _3fcommit)
 package.git.current.commit = _3fcommit
 return package end

 Package["set-target-commit"] = function(package, commit) _G.assert((nil ~= commit), "Missing argument commit on ./fnl/pact/package/init.fnl:143") _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/package/init.fnl:143")
 package.git.target.commit = commit
 return package end

 Package["set-target-commit-meta"] = function(package, distance, breaking_3f) _G.assert((nil ~= breaking_3f), "Missing argument breaking? on ./fnl/pact/package/init.fnl:147") _G.assert((nil ~= distance), "Missing argument distance on ./fnl/pact/package/init.fnl:147") _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/package/init.fnl:147")
 package.git.target.distance = distance
 package.git.target["breaking?"] = breaking_3f
 return package end

 Package["set-latest-commit"] = function(package, version) _G.assert((nil ~= version), "Missing argument version on ./fnl/pact/package/init.fnl:152") _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/package/init.fnl:152")
 package.git.latest.commit = version
 return package end

 Package["ready?"] = function(package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/package/init.fnl:156")

 return (true == package["ready?"]) end

 local __fn_2a_Package__aligned_3f_dispatch = {bodies = {}, help = {}} local function _88_(...) if (0 == #(__fn_2a_Package__aligned_3f_dispatch).bodies) then error(("multi-arity function " .. "Package.aligned?" .. " has no bodies")) else end local _90_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_Package__aligned_3f_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _90_ = f_74_auto end if (nil ~= _90_) then local f_74_auto = _90_ return f_74_auto(...) elseif (_90_ == nil) then local view_77_auto do local _91_, _92_ = pcall(require, "fennel") if ((_91_ == true) and ((_G.type(_92_) == "table") and (nil ~= (_92_).view))) then local view_77_auto0 = (_92_).view view_77_auto = view_77_auto0 elseif ((_91_ == false) and true) then local __75_auto = _92_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _94_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _94_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "Package.aligned?", table.concat(_94_, ", "), table.concat((__fn_2a_Package__aligned_3f_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end Package["aligned?"] = _88_ local function _97_() local _98_ do table.insert((__fn_2a_Package__aligned_3f_dispatch).help, "(where [package] package.git)") local function _99_(...) if (1 == select("#", ...)) then local _100_ = {...} local function _101_(...) local package_86_ = (_100_)[1] return package_86_.git end if (((_G.type(_100_) == "table") and (nil ~= (_100_)[1])) and _101_(...)) then local package_86_ = (_100_)[1] local function _102_(package)

 return (not_nil_3f(package.git.target.commit) and not_nil_3f(package.git.current.commit) and (package.git.target.commit.sha == package.git.current.commit.sha)) end return _102_ else return nil end else return nil end end table.insert((__fn_2a_Package__aligned_3f_dispatch).bodies, _99_) _98_ = Package["aligned?"] end local function _105_() table.insert((__fn_2a_Package__aligned_3f_dispatch).help, "(where [package] package.rock)") local function _106_(...) if (1 == select("#", ...)) then local _107_ = {...} local function _108_(...) local package_87_ = (_107_)[1] return package_87_.rock end if (((_G.type(_107_) == "table") and (nil ~= (_107_)[1])) and _108_(...)) then local package_87_ = (_107_)[1] local function _109_(package) return false end return _109_ else return nil end else return nil end end table.insert((__fn_2a_Package__aligned_3f_dispatch).bodies, _106_) return Package["aligned?"] end do local _ = {_98_, _105_()} end return Package["aligned?"] end setmetatable({nil, nil}, {__call = _97_})()





 local __fn_2a_Package__installed_3f_dispatch = {bodies = {}, help = {}} local function _114_(...) if (0 == #(__fn_2a_Package__installed_3f_dispatch).bodies) then error(("multi-arity function " .. "Package.installed?" .. " has no bodies")) else end local _116_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_Package__installed_3f_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _116_ = f_74_auto end if (nil ~= _116_) then local f_74_auto = _116_ return f_74_auto(...) elseif (_116_ == nil) then local view_77_auto do local _117_, _118_ = pcall(require, "fennel") if ((_117_ == true) and ((_G.type(_118_) == "table") and (nil ~= (_118_).view))) then local view_77_auto0 = (_118_).view view_77_auto = view_77_auto0 elseif ((_117_ == false) and true) then local __75_auto = _118_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _120_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _120_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "Package.installed?", table.concat(_120_, ", "), table.concat((__fn_2a_Package__installed_3f_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end Package["installed?"] = _114_ local function _123_() local _124_ do table.insert((__fn_2a_Package__installed_3f_dispatch).help, "(where [package] package.git)") local function _125_(...) if (1 == select("#", ...)) then local _126_ = {...} local function _127_(...) local package_112_ = (_126_)[1] return package_112_.git end if (((_G.type(_126_) == "table") and (nil ~= (_126_)[1])) and _127_(...)) then local package_112_ = (_126_)[1] local function _128_(package)

 return not_nil_3f(package.git.current.commit) end return _128_ else return nil end else return nil end end table.insert((__fn_2a_Package__installed_3f_dispatch).bodies, _125_) _124_ = Package["installed?"] end local function _131_() table.insert((__fn_2a_Package__installed_3f_dispatch).help, "(where [package] package.rock)") local function _132_(...) if (1 == select("#", ...)) then local _133_ = {...} local function _134_(...) local package_113_ = (_133_)[1] return package_113_.rock end if (((_G.type(_133_) == "table") and (nil ~= (_133_)[1])) and _134_(...)) then local package_113_ = (_133_)[1] local function _135_(package) return false end return _135_ else return nil end else return nil end end table.insert((__fn_2a_Package__installed_3f_dispatch).bodies, _132_) return Package["installed?"] end do local _ = {_124_, _131_()} end return Package["installed?"] end setmetatable({nil, nil}, {__call = _123_})()









 Package["retaining?"] = function(package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/package/init.fnl:180")
 local _138_ = package if ((_G.type(_138_) == "table") and ((_138_).action == "retain")) then return true elseif true then local __1_auto = _138_ return false else return nil end end

 Package["discarding?"] = function(package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/package/init.fnl:183")
 local _140_ = package if ((_G.type(_140_) == "table") and ((_140_).action == "discard")) then return true elseif true then local __1_auto = _140_ return false else return nil end end

 Package["aligning?"] = function(package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/package/init.fnl:186")
 local _142_ = package if ((_G.type(_142_) == "table") and ((_142_).action == "align")) then return true elseif true then local __1_auto = _142_ return false else return nil end end

 local __fn_2a_Package__align_to_target_dispatch = {bodies = {}, help = {}} local function _144_(...) if (0 == #(__fn_2a_Package__align_to_target_dispatch).bodies) then error(("multi-arity function " .. "Package.align-to-target" .. " has no bodies")) else end local _146_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_Package__align_to_target_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _146_ = f_74_auto end if (nil ~= _146_) then local f_74_auto = _146_ return f_74_auto(...) elseif (_146_ == nil) then local view_77_auto do local _147_, _148_ = pcall(require, "fennel") if ((_147_ == true) and ((_G.type(_148_) == "table") and (nil ~= (_148_).view))) then local view_77_auto0 = (_148_).view view_77_auto = view_77_auto0 elseif ((_147_ == false) and true) then local __75_auto = _148_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _150_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _150_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "Package.align-to-target", table.concat(_150_, ", "), table.concat((__fn_2a_Package__align_to_target_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end Package["align-to-target"] = _144_ local function _153_() do local _ = {} end return Package["align-to-target"] end setmetatable({nil, nil}, {__call = _153_})()


 do table.insert((__fn_2a_Package__align_to_target_dispatch).help, "(where [package] package.git)") local function _155_(...) if (1 == select("#", ...)) then local _156_ = {...} local function _157_(...) local package_154_ = (_156_)[1] return package_154_.git end if (((_G.type(_156_) == "table") and (nil ~= (_156_)[1])) and _157_(...)) then local package_154_ = (_156_)[1] local function _158_(package)
 local else_fn_159_ local function _160_(...) local _161_ = ... if (_161_ == false) then



 return R.err("cannot stage unhealthy package") elseif (_161_ == nil) then
 return R.err("unable to stage package, no target commit to checkout!") else return nil end end else_fn_159_ = _160_ local function down_18_auto(...) local _163_ = ... if (_163_ == true) then package.action = "align" return R.ok(package) elseif true then local _ = _163_ return else_fn_159_(...) else return nil end end return down_18_auto(Package["healthy?"](package)) end return _158_ else return nil end else return nil end end table.insert((__fn_2a_Package__align_to_target_dispatch).bodies, _155_) do local _ = Package["align-to-target"] end end

 local __fn_2a_Package__align_to_checkout_dispatch = {bodies = {}, help = {}} local function _167_(...) if (0 == #(__fn_2a_Package__align_to_checkout_dispatch).bodies) then error(("multi-arity function " .. "Package.align-to-checkout" .. " has no bodies")) else end local _169_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_Package__align_to_checkout_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _169_ = f_74_auto end if (nil ~= _169_) then local f_74_auto = _169_ return f_74_auto(...) elseif (_169_ == nil) then local view_77_auto do local _170_, _171_ = pcall(require, "fennel") if ((_170_ == true) and ((_G.type(_171_) == "table") and (nil ~= (_171_).view))) then local view_77_auto0 = (_171_).view view_77_auto = view_77_auto0 elseif ((_170_ == false) and true) then local __75_auto = _171_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _173_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _173_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "Package.align-to-checkout", table.concat(_173_, ", "), table.concat((__fn_2a_Package__align_to_checkout_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end Package["align-to-checkout"] = _167_ local function _176_() do local _ = {} end return Package["align-to-checkout"] end setmetatable({nil, nil}, {__call = _176_})()


 do table.insert((__fn_2a_Package__align_to_checkout_dispatch).help, "(where [package] package.git)") local function _178_(...) if (1 == select("#", ...)) then local _179_ = {...} local function _180_(...) local package_177_ = (_179_)[1] return package_177_.git end if (((_G.type(_179_) == "table") and (nil ~= (_179_)[1])) and _180_(...)) then local package_177_ = (_179_)[1] local function _181_(package)
 local else_fn_182_ local function _183_(...) local _184_ = ... if (_184_ == nil) then



 return R.err("unable to stage package, no checkout commit to checkout!") else return nil end end else_fn_182_ = _183_ local function down_18_auto(...) local _186_ = ... if (nil ~= _186_) then local commit = _186_ package.action = "retain" return R.ok(package) elseif true then local _ = _186_ return else_fn_182_(...) else return nil end end return down_18_auto(package.git.current.commit) end return _181_ else return nil end else return nil end end table.insert((__fn_2a_Package__align_to_checkout_dispatch).bodies, _178_) do local _ = Package["align-to-checkout"] end end

 local __fn_2a_Package__discard_dispatch = {bodies = {}, help = {}} local function _190_(...) if (0 == #(__fn_2a_Package__discard_dispatch).bodies) then error(("multi-arity function " .. "Package.discard" .. " has no bodies")) else end local _192_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_Package__discard_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _192_ = f_74_auto end if (nil ~= _192_) then local f_74_auto = _192_ return f_74_auto(...) elseif (_192_ == nil) then local view_77_auto do local _193_, _194_ = pcall(require, "fennel") if ((_193_ == true) and ((_G.type(_194_) == "table") and (nil ~= (_194_).view))) then local view_77_auto0 = (_194_).view view_77_auto = view_77_auto0 elseif ((_193_ == false) and true) then local __75_auto = _194_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _196_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _196_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "Package.discard", table.concat(_196_, ", "), table.concat((__fn_2a_Package__discard_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end Package.discard = _190_ local function _199_() do local _ = {} end return Package.discard end setmetatable({nil, nil}, {__call = _199_})()


 do table.insert((__fn_2a_Package__discard_dispatch).help, "(where [package])") local function _201_(...) if (1 == select("#", ...)) then local _202_ = {...} local function _203_(...) local package_200_ = (_202_)[1] return true end if (((_G.type(_202_) == "table") and (nil ~= (_202_)[1])) and _203_(...)) then local package_200_ = (_202_)[1] local function _204_(package) package.action = "discard"

 return R.ok(package) end return _204_ else return nil end else return nil end end table.insert((__fn_2a_Package__discard_dispatch).bodies, _201_) do local _ = Package.discard end end



 Package.iter = function(packages, opts)






 local function next_id(n) return n["depends-on"] end
 local opts0 = (opts or {}) local f
 local function _207_()
 local function _208_(_241) local function _209_(package, history)
 if (not R["err?"](package) or opts0["include-err?"]) then
 return coroutine.yield(package, history) else return nil end end return E["depth-walk"](_209_, _241, next_id) end return E.each(_208_, packages) end f = _207_ local iter


 local function _211_(coro)
 local r = E.pack(coroutine.resume(coro))
 local _212_ = r if ((_G.type(_212_) == "table") and ((_212_)[1] == true) and true) then local _ = (_212_)[2]
 return E.unpack(r, 2) elseif ((_G.type(_212_) == "table") and ((_212_)[1] == false) and true) then local _ = (_212_)[2]
 return error(E.unpack(r, 2)) else return nil end end iter = _211_
 return iter, coroutine.create(f), 0 end

 Package["find-canonical-set"] = function(package, packages)
 local function _214_(_241) if (package["canonical-id"] == _241["canonical-id"]) then return _241 else return nil end end
 local function _216_() return Package.iter(packages) end return E.map(_214_, _216_) end

 return Package