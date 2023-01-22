
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local _local_9_, _local_10_ = nil, nil do local _8_ = string local _7_ = vim _local_9_, _local_10_ = _7_, _8_ end local _local_11_ = _local_9_ local api = _local_11_["api"] local uv = _local_11_["loop"] local _local_12_ = _local_10_
 local fmt = _local_12_["format"]

 local Log = {}

 Log["new-log-file"] = function(path)
 local else_fn_13_ local function _14_(...) local _15_, _16_ = ... if ((_15_ == nil) and (nil ~= _16_)) then local err = _16_


 return print("no-log", err) else return nil end end else_fn_13_ = _14_ local function down_18_auto(...) local _18_ = ... if (nil ~= _18_) then local fd = _18_ Log.fd = fd return nil elseif true then local _ = _18_ return else_fn_13_(...) else return nil end end return down_18_auto(uv.fs_open(path, "w", 384)) end

 Log.log = function(data, _3ftag, _3flocation)
 do local inspect = require("pact.inspect")
 local data0 = inspect(data)
 if _3ftag then
 uv.fs_write(Log.fd, ("#" .. inspect(_3ftag) .. "\n")) else end
 uv.fs_write(Log.fd, data0)
 uv.fs_write(Log.fd, "\n")
 uv.fs_fsync(Log.fd) end
 return data end

 return Log