 local id = 0

 local function gen_id(_3fprefix)
 id = (id + 1)
 if _3fprefix then
 return string.format("%s#%d", _3fprefix, id) else
 return string.format("%s", id) end end

 return gen_id