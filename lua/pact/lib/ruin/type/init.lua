local next = _G.next
local ruin_type_key = "__ruin__type"
local M = {}
M.of = function(value)
  local _1_ = getmetatable(value)
  if ((_G.type(_1_) == "table") and (nil ~= (_1_)[ruin_type_key])) then
    local dt = (_1_)[ruin_type_key]
    return dt
  elseif true then
    local _ = _1_
    return type(value)
  else
    return nil
  end
end
M["set-type"] = function(value, type_id)
  assert(type_id, "type#set-type requires non-nil type-id")
  local mt = (getmetatable(value) or {})
  do end (mt)[ruin_type_key] = type_id
  return setmetatable(value, mt)
end
M["is-any?"] = function(value, valid_types)
  local want_type = M.of(value)
  local _in = false
  for _, type_id in ipairs(valid_types) do
    if _in then break end
    _in = (type_id == want_type)
  end
  return _in
end
M["is?"] = function(value, type_id)
  return M["is-any?"](value, {type_id})
end
M["seq?"] = function(v)
  if ("table" == type(v)) then
    local _3_ = {v[1], #v, next(v)}
    if ((_G.type(_3_) == "table") and (nil ~= (_3_)[1]) and true and true) then
      local not_nil = (_3_)[1]
      local _ = (_3_)[2]
      local _0 = (_3_)[3]
      return true
    elseif ((_G.type(_3_) == "table") and ((_3_)[1] == nil) and ((_3_)[2] == 0) and ((_3_)[3] == nil)) then
      return true
    elseif ((_G.type(_3_) == "table") and ((_3_)[1] == nil) and ((_3_)[2] == 0) and ((_3_)[3] == "n")) then
      return (nil == next(v, "n"))
    elseif true then
      local _ = _3_
      return false
    else
      return nil
    end
  else
    return false
  end
end
M["assoc?"] = function(v)
  return (("table" == type(v)) and (nil == v[1]))
end
M["table?"] = function(v)
  return ("table" == type(v))
end
M["number?"] = function(v)
  return ("number" == type(v))
end
M["boolean?"] = function(v)
  return ("boolean" == type(v))
end
M["bool?"] = M["boolean?"]
M["string?"] = function(v)
  return ("string" == type(v))
end
M["function?"] = function(v)
  return ("function" == type(v))
end
M["nil?"] = function(v)
  return ("nil" == type(v))
end
M["not-nil?"] = function(v)
  return not M["nil?"](v)
end
M["userdata?"] = function(v)
  return ("userdata" == type(v))
end
M["thread?"] = function(v)
  return ("thread" == type(v))
end
M["type-is?"] = M["is?"]
M["type-of"] = M.of
M["type-is-any?"] = M["is-any?"]
return M