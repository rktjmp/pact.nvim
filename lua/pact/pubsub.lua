local _local_6_ = require("pact.lib.ruin.type")
local assoc_3f = _local_6_["assoc?"]
local boolean_3f = _local_6_["boolean?"]
local function_3f = _local_6_["function?"]
local nil_3f = _local_6_["nil?"]
local not_nil_3f = _local_6_["not-nil?"]
local number_3f = _local_6_["number?"]
local seq_3f = _local_6_["seq?"]
local string_3f = _local_6_["string?"]
local table_3f = _local_6_["table?"]
local thread_3f = _local_6_["thread?"]
local userdata_3f = _local_6_["userdata?"]
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local enum
do
  local _7_ = require("pact.lib.ruin.enum")
  enum = _7_
end
local registry = {}
local bcast_queue = {}
local function drain_queue()
  local current_queue = bcast_queue
  local _
  bcast_queue = {}
  _ = nil
  local function _8_(_241, _242)
    local _let_9_ = _242
    local topic = _let_9_["topic"]
    local payload = _let_9_["payload"]
    local targets = (registry[topic] or {})
    local function _10_(_2410)
      return _2410(enum.unpack(payload))
    end
    return enum.each(_10_, targets)
  end
  return enum.each(_8_, current_queue)
end
local __fn_2a_subscribe_dispatch = {bodies = {}, help = {}}
local subscribe
local function _13_(...)
  if (0 == #(__fn_2a_subscribe_dispatch).bodies) then
    error(("multi-arity function " .. "subscribe" .. " has no bodies"))
  else
  end
  local _15_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_subscribe_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _15_ = f_74_auto
  end
  if (nil ~= _15_) then
    local f_74_auto = _15_
    return f_74_auto(...)
  elseif (_15_ == nil) then
    local view_77_auto
    do
      local _16_, _17_ = pcall(require, "fennel")
      if ((_16_ == true) and ((_G.type(_17_) == "table") and (nil ~= (_17_).view))) then
        local view_77_auto0 = (_17_).view
        view_77_auto = view_77_auto0
      elseif ((_16_ == false) and true) then
        local __75_auto = _17_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "subscribe", view_77_auto({...}), table.concat((__fn_2a_subscribe_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
subscribe = _13_
local function _20_()
  local function _21_()
    table.insert((__fn_2a_subscribe_dispatch).help, "(where [topic-id callback] (function? callback))")
    local function _22_(...)
      if (2 == select("#", ...)) then
        local _23_ = {...}
        local function _24_(...)
          local topic_id_11_ = (_23_)[1]
          local callback_12_ = (_23_)[2]
          return function_3f(callback_12_)
        end
        if (((_G.type(_23_) == "table") and (nil ~= (_23_)[1]) and (nil ~= (_23_)[2])) and _24_(...)) then
          local topic_id_11_ = (_23_)[1]
          local callback_12_ = (_23_)[2]
          local function _25_(topic_id, callback)
            local topic = (registry[topic_id] or {})
            do end (topic)[callback] = true
            registry[topic_id] = topic
            return true
          end
          return _25_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_subscribe_dispatch).bodies, _22_)
    return subscribe
  end
  do local _ = {_21_()} end
  return subscribe
end
setmetatable({nil, nil}, {__call = _20_})()
local __fn_2a_unsubscribe_dispatch = {bodies = {}, help = {}}
local unsubscribe
local function _30_(...)
  if (0 == #(__fn_2a_unsubscribe_dispatch).bodies) then
    error(("multi-arity function " .. "unsubscribe" .. " has no bodies"))
  else
  end
  local _32_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_unsubscribe_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _32_ = f_74_auto
  end
  if (nil ~= _32_) then
    local f_74_auto = _32_
    return f_74_auto(...)
  elseif (_32_ == nil) then
    local view_77_auto
    do
      local _33_, _34_ = pcall(require, "fennel")
      if ((_33_ == true) and ((_G.type(_34_) == "table") and (nil ~= (_34_).view))) then
        local view_77_auto0 = (_34_).view
        view_77_auto = view_77_auto0
      elseif ((_33_ == false) and true) then
        local __75_auto = _34_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "unsubscribe", view_77_auto({...}), table.concat((__fn_2a_unsubscribe_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
unsubscribe = _30_
local function _37_()
  local function _38_()
    table.insert((__fn_2a_unsubscribe_dispatch).help, "(where [topic-id callback] (function? callback))")
    local function _39_(...)
      if (2 == select("#", ...)) then
        local _40_ = {...}
        local function _41_(...)
          local topic_id_28_ = (_40_)[1]
          local callback_29_ = (_40_)[2]
          return function_3f(callback_29_)
        end
        if (((_G.type(_40_) == "table") and (nil ~= (_40_)[1]) and (nil ~= (_40_)[2])) and _41_(...)) then
          local topic_id_28_ = (_40_)[1]
          local callback_29_ = (_40_)[2]
          local function _42_(topic_id, callback)
            local topic = (registry[topic_id] or {})
            do end (topic)[callback] = nil
            registry[topic_id] = topic
            return true
          end
          return _42_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_unsubscribe_dispatch).bodies, _39_)
    return unsubscribe
  end
  do local _ = {_38_()} end
  return unsubscribe
end
setmetatable({nil, nil}, {__call = _37_})()
local function broadcast(topic, ...)
  table.insert(bcast_queue, {topic = topic, payload = enum.pack(...)})
  if (1 == #bcast_queue) then
    return vim.schedule(drain_queue)
  else
    return nil
  end
end
return {subscribe = subscribe, unsubscribe = unsubscribe, broadcast = broadcast}