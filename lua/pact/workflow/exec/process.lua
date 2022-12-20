








 local enum, inspect, _local_5_, _local_6_ = nil, nil, nil, nil do local _4_ = string local _3_ = vim.loop local _2_ = require("pact.inspect") local _1_ = require("pact.lib.ruin.enum") enum, inspect, _local_5_, _local_6_ = _1_, _2_, _3_, _4_ end local _local_7_ = _local_5_




 local close = _local_7_["close"] local fs_close = _local_7_["fs_close"] local fs_open = _local_7_["fs_open"] local new_pipe = _local_7_["new_pipe"] local pipe_open = _local_7_["pipe_open"] local read_start = _local_7_["read_start"] local spawn = _local_7_["spawn"] local _local_8_ = _local_6_
 local fmt = _local_8_["format"]

 local function into_table(t)
 local function _9_(err, data)
 if err then
 error(err) else end
 if data then
 return table.insert(t, data) else return nil end end return _9_ end

 local function stream__3elines(bytes)
 local function _12_(_241) return _241 end local function _13_() return string.gmatch(table.concat(bytes), "[^\13\n]+") end return enum.map(_12_, _13_) end

 local function run(cmd, args, cwd, env, on_exit)

 local stdout = new_pipe()
 local stderr = new_pipe()
 local _let_14_ = {{}, {}} local out_bytes = _let_14_[1] local err_bytes = _let_14_[2]
 local stdio = {nil, stdout, stderr}

 local _var_15_ = {nil, nil} local process_h = _var_15_[1] local pid = _var_15_[2]


 local function _16_(code, sig)
 close(process_h)
 close(stdout)
 close(stderr)
 return on_exit(code, stream__3elines(out_bytes), stream__3elines(err_bytes)) end process_h, pid = spawn(cmd, {args = args, cwd = cwd, env = env, stdio = stdio}, _16_)


 local _17_ = process_h if (_17_ == nil) then



 return nil, fmt("Could not spawn process, maybe the command wasn't found? %s (for %s)", pid, inspect({cmd, args, cwd})) elseif true then local _ = _17_





 read_start(stdout, into_table(out_bytes))
 read_start(stderr, into_table(err_bytes))
 return pid else return nil end end

 return {run = run}