local function inspect(v)
  local _1_, _2_ = pcall(require, "fennel")
  if ((_1_ == true) and ((_G.type(_2_) == "table") and (nil ~= (_2_).view))) then
    local view = (_2_).view
    return view(v, {["one-line?"] = true})
  elseif ((_1_ == false) and true) then
    local _ = _2_
    return vim.inspect(v, {newline = ""})
  else
    return nil
  end
end
return inspect