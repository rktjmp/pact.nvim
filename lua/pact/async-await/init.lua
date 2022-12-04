local _local_1_ = require("pact.lib.ruin.enum")
local pack = _local_1_["pack"]
local unpack = _local_1_["unpack"]
local _local_2_ = require("pact.lib.ruin.type")
local thread_3f = _local_2_["thread?"]
local function async_wrap(func)
  local future = nil
  local final_value = nil
  local first_call_args = nil
  local function_co = coroutine.create(func)
  local function resume_with_correct_args(thread, new_args)
    local args = (first_call_args or new_args)
    local _
    first_call_args = nil
    _ = nil
    return coroutine.resume(thread, unpack(args))
  end
  local function awaitable_fn(...)
    while (final_value == nil) do
      local _3_ = future
      if (_3_ == nil) then
        local _4_ = {resume_with_correct_args(function_co, {...})}
        local function _5_(...)
          local thread = (_4_)[2]
          return ("thread" == type(thread))
        end
        if (((_G.type(_4_) == "table") and ((_4_)[1] == true) and (nil ~= (_4_)[2])) and _5_(...)) then
          local thread = (_4_)[2]
          future = thread
        elseif ((_G.type(_4_) == "table") and ((_4_)[1] == true) and ((_4_)[2] == "info")) then
          local info = {select(3, (table.unpack or _G.unpack)(_4_))}
        elseif ((_G.type(_4_) == "table") and ((_4_)[1] == true)) then
          local value = {select(2, (table.unpack or _G.unpack)(_4_))}
          final_value = value
        elseif ((_G.type(_4_) == "table") and ((_4_)[1] == false) and (nil ~= (_4_)[2])) then
          local err = (_4_)[2]
          error(err)
        else
        end
      elseif (_3_ == future) then
        local _7_ = coroutine.status(future)
        if (_7_ == "dead") then
          future = nil
        elseif (nil ~= _7_) then
          local status = _7_
          coroutine.yield(future)
        else
        end
      else
      end
    end
    return unpack(final_value)
  end
  local function _10_(...)
    first_call_args = {...}
    return coroutine.create(awaitable_fn)
  end
  return _10_
end
local function await_wrap(func, argv)
  assert(coroutine.running(), "must call await inside (async ...)")
  local co = coroutine
  local awaited_value = nil
  local function create_thread(func0, argv0)
    local await_co = co.running()
    local resolve_future
    local function _11_(...)
      awaited_value = pack(...)
      return co.resume(await_co)
    end
    resolve_future = _11_
    local _ = table.insert(argv0, resolve_future)
    local first_return = pack(func0(unpack(argv0)))
    local _12_ = first_return
    if ((_G.type(_12_) == "table") and ((_12_)[1] == nil)) then
      local rest = {select(2, (table.unpack or _G.unpack)(_12_))}
      return unpack(first_return)
    elseif true then
      local _0 = _12_
      return co.yield(await_co, unpack(first_return))
    else
      return nil
    end
  end
  local await_co = co.create(create_thread)
  local vals = pack(co.resume(await_co, func, argv))
  do
    local _14_ = vals
    if ((_G.type(_14_) == "table") and ((_14_)[1] == false) and (nil ~= (_14_)[2])) then
      local err = (_14_)[2]
      error(err)
    elseif ((_G.type(_14_) == "table") and ((_14_)[1] == true) and ((_14_)[2] == nil)) then
      local rest = {select(3, (table.unpack or _G.unpack)(_14_))}
      awaited_value = pack(unpack(vals, 2))
    else
      local function _15_()
        local thread = (_14_)[2]
        local rest = {select(3, (table.unpack or _G.unpack)(_14_))}
        return thread_3f(thread)
      end
      if (((_G.type(_14_) == "table") and ((_14_)[1] == true) and (nil ~= (_14_)[2])) and _15_()) then
        local thread = (_14_)[2]
        local rest = {select(3, (table.unpack or _G.unpack)(_14_))}
        co.yield(unpack(vals, 2))
      else
      end
    end
  end
  return unpack(awaited_value)
end
return {["async-wrap"] = async_wrap, ["await-wrap"] = await_wrap}