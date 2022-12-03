local function tap(x, f)
  f(x)
  return x
end
local function _then(x, f)
  return f(x)
end
return {tap = tap, ["then"] = _then}