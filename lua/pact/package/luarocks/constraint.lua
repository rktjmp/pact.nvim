
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, _local_10_, _local_11_ = nil, nil, nil do local _9_ = require("pact.package.version") local _8_ = string local _7_ = require("pact.lib.ruin.enum") E, _local_10_, _local_11_ = _7_, _8_, _9_ end local _local_12_ = _local_10_

 local fmt = _local_12_["format"] local _local_13_ = _local_11_
 local version_spec_string_3f = _local_13_["version-spec-string?"] do local _ = {nil, nil} end

 local M = {}

 M.version = function(constraint)
 return {"luarocks", "version", constraint} end

 return M