





 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, _local_9_ = nil, nil do local _8_ = string local _7_ = require("pact.lib.ruin.enum") E, _local_9_ = _7_, _8_ end local _local_10_ = _local_9_
 local fmt = _local_10_["format"]

 local Layout = {}

 Layout["mk-chunk"] = function(text, _3fhl, _3flen) return {text = text, highlight = (_3fhl or "PactComment"), length = (_3flen or #(text or ""))} end



 Layout["mk-col"] = function(...) return {...} end

 Layout["mk-content"] = function(...) return {...} end

 Layout["mk-row"] = function(content, _3fmeta) return {content = content, meta = (_3fmeta or {})} end

 Layout["mk-basic-row"] = function(text)

 return Layout["mk-row"](Layout["mk-content"](Layout["mk-col"](Layout["mk-chunk"](text, "PactComment")))) end




 Layout["rows->lines"] = function(rows)

 local function decomp_line(line_chunks)

 local function _11_(_241) local function _14_(_12_) local _arg_13_ = _12_ local text = _arg_13_["text"] return text end return table.concat(E.map(_14_, _241), "") end return table.concat(E.map(_11_, line_chunks), "") end



 local function _15_(_241) return decomp_line(_241.content) end return E.map(_15_, rows) end

 Layout["rows->extmarks"] = function(rows) local cursor = 0


 local function decomp_column(column)

 local function _18_(data, _16_) local _arg_17_ = _16_ local text = _arg_17_["text"] local highlight = _arg_17_["highlight"]
 local start = cursor

 local stop = (cursor + #(text or ""))
 cursor = stop
 return E["append$"](data, {start = start, stop = stop, highlight = highlight}) end return E.reduce(_18_, {}, column) end



 local function decomp_line(line) cursor = 0


 return E["append$"](E.flatten(E.map(decomp_column, line.content)), E["merge$"](line.meta, {meta = true})) end



 return E.map(decomp_line, rows) end

 return Layout