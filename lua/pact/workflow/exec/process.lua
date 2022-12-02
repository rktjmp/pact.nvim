








 local enum, _local_4_, _local_5_ = nil, nil, nil do local _3_ = string local _2_ = vim.loop local _1_ = require("pact.lib.ruin.enum") enum, _local_4_, _local_5_ = _1_, _2_, _3_ end local _local_6_ = _local_4_



 local close = _local_6_["close"] local fs_close = _local_6_["fs_close"] local fs_open = _local_6_["fs_open"] local new_pipe = _local_6_["new_pipe"] local pipe_open = _local_6_["pipe_open"] local read_start = _local_6_["read_start"] local spawn = _local_6_["spawn"] local _local_7_ = _local_5_
 local fmt = _local_7_["format"]

 local function into_table(t)
 local function _8_(err, data)
 if err then
 error(err) else end
 if data then
 return table.insert(t, data) else return nil end end return _8_ end

 local function stream__3elines(bytes)
 local function _11_(_241) return _241 end local function _12_() return string.gmatch(table.concat(bytes), "[^\13\n]+") end return enum.map(_11_, _12_) end

 local function close_io(log, pipe)
 fs_close(log)
 return close(pipe) end

 local function run(cmd, args, cwd, env, on_exit)

 local stdout = new_pipe()
 local stderr = new_pipe()
 local _let_13_ = {{}, {}} local out_bytes = _let_13_[1] local err_bytes = _let_13_[2]
 local stdio = {nil, stdout, stderr}

 local _var_14_ = {nil, nil} local process_h = _var_14_[1] local pid = _var_14_[2]


 local function _15_(code, sig)
 close(process_h)
 close(stdout)
 close(stderr)
 return on_exit(code, stream__3elines(out_bytes), stream__3elines(err_bytes)) end process_h, pid = spawn(cmd, {args = args, cwd = cwd, env = env, stdio = stdio}, _15_)


 local _16_ = process_h if (_16_ == nil) then



 local _let_17_ = require("fennel") local view = _let_17_["view"]
 return nil, fmt(("Could not spawn process, " .. "maybe the command wasn't found? %s (for %s)"), pid, view({cmd, args, cwd})) elseif true then local _ = _16_






 read_start(stdout, into_table(out_bytes))
 read_start(stderr, into_table(err_bytes))
 return pid else return nil end end

 return {run = run}