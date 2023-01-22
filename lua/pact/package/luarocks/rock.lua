





 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, _local_9_ = nil, nil do local _8_ = string local _7_ = require("pact.lib.ruin.enum") E, _local_9_ = _7_, _8_ end local _local_10_ = _local_9_
 local fmt = _local_10_["format"]

 local Rock = {}

 Rock.new = function(name, version, revision) _G.assert((nil ~= revision), "Missing argument revision on ./fnl/pact/package/luarocks/rock.fnl:14") _G.assert((nil ~= version), "Missing argument version on ./fnl/pact/package/luarocks/rock.fnl:14") _G.assert((nil ~= name), "Missing argument name on ./fnl/pact/package/luarocks/rock.fnl:14")


 return {name = name, version = version, revision = revision} end



 Rock["search-results->rocks"] = function(results) end



 return Rock