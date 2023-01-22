









 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local R, _local_13_, E, FS, _local_14_, _local_15_ = nil, nil, nil, nil, nil, nil do local _12_ = string




 local _11_ = require("pact.task") local _10_ = require("pact.fs") local _9_ = require("pact.lib.ruin.enum") local _8_ = require("pact.lib.ruin.fn") local _7_ = require("pact.lib.ruin.result") R, _local_13_, E, FS, _local_14_, _local_15_ = _7_, _8_, _9_, _10_, _11_, _12_ end local _local_16_ = _local_13_ local tap = _local_16_["tap"] local _local_17_ = _local_14_ local task_2fawait = _local_17_["await"] local task_2fnew = _local_17_["new"] local task_3f = _local_17_["task?"] local trace = _local_17_["trace"] local _local_18_ = _local_15_
 local fmt = _local_18_["format"] do local _ = {nil, nil} end

 local function register(ds, canonical_id, rock_name, server) _G.assert((nil ~= server), "Missing argument server on ./fnl/pact/datastore/rock/init.fnl:21") _G.assert((nil ~= rock_name), "Missing argument rock-name on ./fnl/pact/datastore/rock/init.fnl:21") _G.assert((nil ~= canonical_id), "Missing argument canonical-id on ./fnl/pact/datastore/rock/init.fnl:21") _G.assert((nil ~= ds), "Missing argument ds on ./fnl/pact/datastore/rock/init.fnl:21")
 local _local_19_ = require("pact.datastore") local package_by_canonical_id = _local_19_["package-by-canonical-id"]
 local _20_ = package_by_canonical_id(ds, canonical_id) if (nil ~= _20_) then local p = _20_
 return error(fmt("attempt to re-register known package %s", canonical_id)) elseif (_20_ == nil) then
 local f local function _21_() local _22_ do local _let_24_ = require("pact.lib.ruin.result") local bind_15_auto = _let_24_["bind"] local unit_16_auto = _let_24_["unit"] local bind_25_ = bind_15_auto local unit_26_ = unit_16_auto local function _28_(store_path) local function _29_()
 return R.ok({kind = "rock", id = canonical_id, path = store_path, name = rock_name, server = server}) end return unit_26_(_29_()) end _22_ = bind_25_(unit_26_(FS["join-path"](ds.path.rock, canonical_id)), _28_) end




 local function _30_(_2410) ds["packages"][canonical_id] = _2410 return nil end return tap(_22_, _30_) end f = _21_
 local task = task_2fnew(fmt("register-%s", canonical_id), f)
 do end (ds)["packages"][canonical_id] = task
 return task else return nil end end

 local function version_at_path(ds, path) _G.assert((nil ~= path), "Missing argument path on ./fnl/pact/datastore/rock/init.fnl:36") _G.assert((nil ~= ds), "Missing argument ds on ./fnl/pact/datastore/rock/init.fnl:36") return nil end

 local function fetch_versions(ds, canonical_id) _G.assert((nil ~= canonical_id), "Missing argument canonical-id on ./fnl/pact/datastore/rock/init.fnl:38") _G.assert((nil ~= ds), "Missing argument ds on ./fnl/pact/datastore/rock/init.fnl:38") return "Interrogate luarocks for versions related to previously registered package" end


















 return {register = register}