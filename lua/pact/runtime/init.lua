
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local R, E, inspect, FS, Datastore, Solver, PubSub, Package, Transaction, _local_17_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil do local _16_ = string local _15_ = require("pact.runtime.transaction") local _14_ = require("pact.package") local _13_ = require("pact.pubsub") local _12_ = require("pact.solver") local _11_ = require("pact.datastore") local _10_ = require("pact.fs") local _9_ = require("pact.inspect") local _8_ = require("pact.lib.ruin.enum") local _7_ = require("pact.lib.ruin.result") R, E, inspect, FS, Datastore, Solver, PubSub, Package, Transaction, _local_17_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_, _16_ end local _local_18_ = _local_17_









 local fmt = _local_18_["format"] do local _ = {nil, nil} end

 local Runtime = {}



 Runtime["add-proxied-plugins"] = function(runtime, proxies)





 local function unproxy_spec_graph(proxies0)

















 local function unroll(proxy)
 local _19_ = proxy() local function _20_() local r = _19_ return R["ok?"](r) end if ((nil ~= _19_) and _20_()) then local r = _19_

 local spec = R.unwrap(r)
 local package = Package["spec->package"](spec) local dependencies



 local function _21_(_241) return E["set$"](_241, "depended-by", package) end local function _22_(_241) return unroll(_241) end dependencies = E.map(_21_, E.map(_22_, package["depends-on"]))


 return E["set$"](package, "depends-on", dependencies) else local function _23_() local r = _19_ return R["err?"](r) end if ((nil ~= _19_) and _23_()) then local r = _19_


 return r else return nil end end end


 return E.map(unroll, E.flatten(proxies0)) end












 return E["set$"](runtime, "packages", unproxy_spec_graph(proxies)) end

 local function legacy_check(runtime_path) _G.assert((nil ~= runtime_path), "Missing argument runtime-path on ./fnl/pact/runtime/init.fnl:76")




 local function _25_(_241) if not _241 then
 vim.notify(fmt(("Whoops! %s contained unexpected content.\n" .. "You may have an existing legacy pact install, " .. "please see updated installation instructions and config format.\n" .. "You'll have to remove the directory listed above too.\n"), runtime_path), vim.log.levels.ERROR)





 return error("pact-halt") else return nil end end local function _27_(_241) return (("link" == _241) or ("nothing" == _241)) end local function _28_(_241) return FS.lstat(_241) end local function _29_(_241) return FS["join-path"](runtime_path, _241) end return _25_(E["all?"](_27_, E.map(_28_, E.map(_29_, {"start", "opt"})))) end

 local function bootstrap_filesystem(runtime) _G.assert((nil ~= runtime), "Missing argument runtime on ./fnl/pact/runtime/init.fnl:90")

 E.each(FS["make-path"], {runtime.path.data, runtime.path.runtime})
 do local _30_ = Transaction.latest(runtime.datastore, runtime.path.data) if (_30_ == nil) then
 local _let_31_ = require("pact.lib.ruin.result") local bind_15_auto = _let_31_["bind"] local unit_16_auto = _let_31_["unit"] local bind_32_ = bind_15_auto local unit_33_ = unit_16_auto local function _34_(t) local function _35_(_) local function _36_(_0) local function _37_()


 return t end return unit_33_(_37_()) end return unit_33_(bind_32_(unit_33_(Transaction.commit(t)), _36_)) end return unit_33_(bind_32_(unit_33_(Transaction.prepare(t)), _35_)) end bind_32_(unit_33_(Transaction.new(runtime.datastore, runtime.path.data)), _34_) else end end


 local function _39_(_241) local _40_ = FS.lstat(FS["join-path"](runtime.path.runtime, _241)) if (_40_ == "nothing") then
 return FS.symlink(FS["join-path"](runtime.path.head, _241), FS["join-path"](runtime.path.runtime, _241)) else return nil end end return E.each(_39_, {"start", "opt"}) end


 Runtime.new = function(opts) _G.assert((nil ~= opts), "Missing argument opts on ./fnl/pact/runtime/init.fnl:104")
 local config = require("pact.config")
 local FS0 = require("pact.fs")
 local Datastore0 = require("pact.datastore")
 local data_path = config.path.data
 local head_path = config.path.head
 local runtime_path = config.path.runtime
 local runtime = {path = {runtime = runtime_path, data = data_path, head = head_path}, datastore = Datastore0.new(data_path), transaction = nil, packages = {}}





 legacy_check(runtime_path)
 bootstrap_filesystem(runtime)
 return runtime end

 Runtime.Command = {}

 Runtime.Command["initial-load"] = function(runtime) _G.assert((nil ~= runtime), "Missing argument runtime on ./fnl/pact/runtime/init.fnl:123")
 local ingest_first = require("pact.runtime.command.initial-load")
 ingest_first(runtime.path.runtime, runtime.datastore, runtime.packages)
 return R.ok() end

 Runtime.Command["align-package-tree"] = function(runtime, package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/runtime/init.fnl:128") _G.assert((nil ~= runtime), "Missing argument runtime on ./fnl/pact/runtime/init.fnl:128")






 local function can_align_3f(package0)
 return (Package["healthy?"](package0) and package0.git.target.commit) end


 local function depends_ons_can_align_3f(package0)
 if not E["empty?"](package0["depends-on"]) then
 local function _42_(_241) return (can_align_3f(_241) and depends_ons_can_align_3f(_241)) end
 local function _43_() return Package.iter(package0["depends-on"]) end return E["all?"](_42_, _43_) else return true end end


 local function depended_bys_can_align_3f(package0)
 if package0["depended-by"] then
 return (Package["healthy?"](package0["depended-by"]) and depended_bys_can_align_3f(package0["depended-by"])) else return true end end



 local function propagate_between(package0)

 local function _46_(_241) if not Package["aligned?"](_241) then _241.action = "align"
 return nil else return nil end end return E.each(_46_, Package["find-canonical-set"](package0, runtime.packages)) end

 local function propagate(package0)
 propagate_between(package0)

 local function _48_() return Package.iter(package0["depends-on"]) end return E.each(propagate, _48_) end

 if (can_align_3f(package) and depends_ons_can_align_3f(package) and depended_bys_can_align_3f(package)) then



 propagate(package)
 return R.ok() else
 return R.err("unable to stage tree, some packages unstagable") end end

 Runtime.Command["unstage-package-tree"] = function(runtime, package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/runtime/init.fnl:169") _G.assert((nil ~= runtime), "Missing argument runtime on ./fnl/pact/runtime/init.fnl:169")



 local new_action local function _50_(_241) if Package["installed?"](_241) then return "retain" else return "discard" end end new_action = _50_ local propagate_between
 local function _52_(package0)



 local canonical_set = Package["find-canonical-set"](package0, runtime.packages)
 local function _53_(_241) local _54_ do local t_55_ = _241 if (nil ~= t_55_) then t_55_ = (t_55_)["depended-by"] else end if (nil ~= t_55_) then t_55_ = (t_55_).action else end _54_ = t_55_ end local function _58_() return true end if ((_54_ == nil) and _58_()) then return true else local function _59_() return true end if ((_54_ == "discard") and _59_()) then return true else local function _60_() return true end if ((_54_ == "retain") and _60_()) then return true elseif true then local _ = _54_ return false else return nil end end end end if E["all?"](_53_, canonical_set) then



 local function _62_(_241) _241.action = new_action(_241) return nil end return E.each(_62_, canonical_set) else return nil end end propagate_between = _52_

 local function _64_(_241) _241.action = new_action(_241) return nil end E.each(_64_, Package["find-canonical-set"](package, runtime.packages))


 local function _65_() return Package.iter(package["depends-on"]) end E.each(propagate_between, _65_)
 return R.ok() end

 Runtime.Command["discard-package-tree"] = function(runtime, package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/runtime/init.fnl:191") _G.assert((nil ~= runtime), "Missing argument runtime on ./fnl/pact/runtime/init.fnl:191")


 local function propagate_between(package0)



 local function _66_(_241) if ((_241["canonical-id"] == package0["canonical-id"]) and ((_241["depended-by"] == nil) or (_241["depended-by"].action == "discard"))) then _241.action = "discard"


 return nil else return nil end end
 local function _68_() return Package.iter(runtime.packages) end return E.each(_66_, _68_) end

 local function propagate_down(package0)

 local function _69_() return Package.iter(package0["depends-on"]) end return E.each(propagate_between, _69_) end


 if Package["installed?"](package) then package.action = "discard" else package.action = "discard" end


 return propagate_down(package) end

 Runtime.Command["get-logs"] = function(runtime, package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/runtime/init.fnl:214") _G.assert((nil ~= runtime), "Missing argument runtime on ./fnl/pact/runtime/init.fnl:214")
 local _let_71_ = require("pact.lib.ruin.result") local bind_15_auto = _let_71_["bind"] local unit_16_auto = _let_71_["unit"] local bind_72_ = bind_15_auto local unit_73_ = unit_16_auto local function _74_(dsp)
 local function _76_() local t_75_ = package if (nil ~= t_75_) then t_75_ = (t_75_).git else end if (nil ~= t_75_) then t_75_ = (t_75_).current else end if (nil ~= t_75_) then t_75_ = (t_75_).commit else end return t_75_ end local function _80_(from)
 local function _82_() local t_81_ = package if (nil ~= t_81_) then t_81_ = (t_81_).git else end if (nil ~= t_81_) then t_81_ = (t_81_).target else end if (nil ~= t_81_) then t_81_ = (t_81_).commit else end return t_81_ end local function _86_(to) local function _87_()
 local _88_ = {from, to} if ((_G.type(_88_) == "table") and ((_G.type((_88_)[1]) == "table") and (nil ~= ((_88_)[1]).sha)) and ((_G.type((_88_)[2]) == "table") and (((_88_)[1]).sha == ((_88_)[2]).sha))) then local sha = ((_88_)[1]).sha
 return R.err("cant diff without changes") elseif ((_G.type(_88_) == "table") and ((_88_)[1] == nil) and true) then local _ = (_88_)[2]
 return R.err("cant diff without current commit") elseif ((_G.type(_88_) == "table") and true and ((_88_)[2] == nil)) then local _ = (_88_)[1]
 return R.err("cant diff without target commit") elseif ((_G.type(_88_) == "table") and (nil ~= (_88_)[1]) and (nil ~= (_88_)[2])) then local a = (_88_)[1] local b = (_88_)[2]
 local _let_89_ = require("pact.task") local run = _let_89_["run"] local await = _let_89_["await"] local trace = _let_89_["trace"]
 local task = Datastore.Git["logs-between"](dsp, from, to)

 local function _90_()
 Package["increment-tasks-active"](package)
 trace("fetching logs")


 local function _91_(logs)
 Package["decrement-tasks-active"](package)
 do end (package)["git"]["target"]["logs"] = logs
 return R.ok() end
 local function _92_(err)
 Package["decrement-tasks-active"](package)
 return R.err(err) end return R.map(await(run(task)), _91_, _92_) end
 local function _93_(msg) return Package["add-event"](package, "logs", msg) end run(_90_, {traced = _93_})
 return R.ok("task-started") elseif true then local _ = _88_
 return R.err("thinking-face-emoji") else return nil end end return unit_73_(_87_()) end return unit_73_(bind_72_(unit_73_(_82_()), _86_)) end return unit_73_(bind_72_(unit_73_(_76_()), _80_)) end return bind_72_(unit_73_(Datastore["package-by-canonical-id"](runtime.datastore, package["canonical-id"])), _74_) end

 Runtime.Command["run-transaction"] = function(runtime, update_win)
 local run_transaction = require("pact.runtime.command.run-transaction")
 return run_transaction(runtime, update_win) end

 return Runtime