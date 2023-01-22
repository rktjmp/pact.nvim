 local function inspect(v, _3fone_line)

 local _1_, _2_ = pcall(require, "fennel") if ((_1_ == true) and ((_G.type(_2_) == "table") and (nil ~= (_2_).view))) then local view = (_2_).view
 return view(v, {["one-line?"] = _3fone_line}) elseif ((_1_ == false) and true) then local _ = _2_
 local _3_ if _3fone_line then _3_ = "" else _3_ = "\n" end return vim.inspect(v, {newline = _3_}) else return nil end end return inspect