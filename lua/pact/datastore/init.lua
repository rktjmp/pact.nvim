
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local inspect, E, FS, Log, _local_12_ = nil, nil, nil, nil, nil do local _11_ = string local _10_ = require("pact.log") local _9_ = require("pact.fs") local _8_ = require("pact.lib.ruin.enum") local _7_ = require("pact.inspect") inspect, E, FS, Log, _local_12_ = _7_, _8_, _9_, _10_, _11_ end local _local_13_ = _local_12_



 local fmt = _local_13_["format"]

 local Datastore = {}

 Datastore.Git = require("pact.datastore.git")
 Datastore.Rock = require("pact.datastore.rock")

 Datastore.new = function(data_path) _G.assert((nil ~= data_path), "Missing argument data-path on ./fnl/pact/datastore/init.fnl:15")

 return {path = {git = FS["join-path"](data_path, "repos"), rock = FS["join-path"](data_path, "rocks")}, packages = {}} end



 Datastore["package-by-canonical-id"] = function(ds, canonical_id) _G.assert((nil ~= canonical_id), "Missing argument canonical-id on ./fnl/pact/datastore/init.fnl:21") _G.assert((nil ~= ds), "Missing argument ds on ./fnl/pact/datastore/init.fnl:21")




 return ds.packages[canonical_id] end

 return Datastore