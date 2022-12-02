 local function async_wrap(func)





 local future = nil
 local final_value = nil
 local first_call_args = nil
 local function_co = coroutine.create(func)

 local function resume_with_correct_args(thread, new_args)







 local args = (first_call_args or new_args) local _
 first_call_args = nil _ = nil
 return coroutine.resume(thread, unpack(args)) end

 local function awaitable_fn(...)
 while (final_value == nil) do
 local _1_ = future if (_1_ == nil) then


 local _2_ = {resume_with_correct_args(function_co, {...})} local function _3_(...) local thread = (_2_)[2] return ("thread" == type(thread)) end if (((_G.type(_2_) == "table") and ((_2_)[1] == true) and (nil ~= (_2_)[2])) and _3_(...)) then local thread = (_2_)[2]
 future = thread elseif ((_G.type(_2_) == "table") and ((_2_)[1] == true) and ((_2_)[2] == "info")) then local info = {select(3, (table.unpack or _G.unpack)(_2_))} elseif ((_G.type(_2_) == "table") and ((_2_)[1] == true)) then local value = {select(2, (table.unpack or _G.unpack)(_2_))}

 final_value = value elseif ((_G.type(_2_) == "table") and ((_2_)[1] == false) and (nil ~= (_2_)[2])) then local err = (_2_)[2]
 error(err) else end elseif (_1_ == future) then



 local _5_ = coroutine.status(future) if (_5_ == "dead") then

 future = nil elseif (nil ~= _5_) then local status = _5_


 coroutine.yield(future) else end else end end
 return unpack(final_value) end

 local function _8_(...)
 first_call_args = {...}
 return coroutine.create(awaitable_fn) end return _8_ end

 local function await_wrap(func, argv)

























 assert(coroutine.running(), "must call await inside (async ...)")
 local co = coroutine
 local awaited_value = nil

 local function create_thread(func0, argv0)
 local await_co = co.running() local resolve_future
 local function _9_(...)

 awaited_value = {...}

 return co.resume(await_co) end resolve_future = _9_
 local _ = table.insert(argv0, resolve_future)


 func0(unpack(argv0))



 return co.yield(await_co) end

 local await_co = co.create(create_thread)

 do local _10_, _11_ = co.resume(await_co, func, argv) if ((_10_ == true) and (nil ~= _11_)) then local thread = _11_
 co.yield(thread) elseif ((_10_ == false) and (nil ~= _11_)) then local err = _11_
 error(err) else end end



 return unpack(awaited_value) end

 return {["async-wrap"] = async_wrap, ["await-wrap"] = await_wrap}