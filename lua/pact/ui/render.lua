


 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, R, Log, Package, Constraint, Commit, inspect, api, _local_17_, _local_18_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil do local _16_ = string local _15_ = require("pact.ui.layout") local _14_ = vim.api local _13_ = require("pact.inspect") local _12_ = require("pact.package.git.commit") local _11_ = require("pact.package.git.constraint") local _10_ = require("pact.package") local _9_ = require("pact.log") local _8_ = require("pact.lib.ruin.result") local _7_ = require("pact.lib.ruin.enum") E, R, Log, Package, Constraint, Commit, inspect, api, _local_17_, _local_18_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_, _16_ end local _local_19_ = _local_18_









 local fmt = _local_19_["format"] local _local_20_ = _local_17_ local mk_basic_row = _local_20_["mk-basic-row"] local mk_chunk = _local_20_["mk-chunk"] local mk_col = _local_20_["mk-col"] local mk_content = _local_20_["mk-content"] local mk_row = _local_20_["mk-row"] local rows__3eextmarks = _local_20_["rows->extmarks"] local rows__3elines = _local_20_["rows->lines"]

 local Render = {} local last_time = 0 local spinner_frame = 0





 local function package_configuration_error_3f(package)

 local function _21_(_241) return R["err?"](_241) end
 local function _22_() return Package.iter({package}, {["include-err?"] = true}) end return (R["err?"](package) or E["any?"](_21_, _22_)) end

 local function package_loading_3f(package)
 local function _23_(_241) return not Package["ready?"](_241) end
 local function _24_() return Package.iter({package}) end return E["any?"](_23_, _24_) end



 local function package_staged_3f(package)

 local function _25_(_241) return ((not Package["installed?"](_241) and Package["aligning?"](_241)) or (Package["installed?"](_241) and (Package["aligning?"](_241) or Package["discarding?"](_241)))) end




 local function _26_() return Package.iter({package}) end return E["any?"](_25_, _26_) end

 local function package_unstaged_3f(package)


 local function _27_(_241) return not Package["aligned?"](_241) end
 local function _28_() return Package.iter({package}) end return (not package_staged_3f(package) and E["any?"](_27_, _28_)) end

 local function package_up_to_date_3f(package)

 local function _29_(_241) return Package["aligned?"](_241) end
 local function _30_() return Package.iter({package}) end return (not package_unstaged_3f(package) and E["all?"](_29_, _30_)) end

 local function rate_limited_inc(value)


 local every_n_ms = (1000 / 30)
 local now = vim.loop.now()
 if (every_n_ms < (now - last_time)) then

 last_time = now
 return (value + 1) else
 return value end end

 local function workflow_active_symbol(progress)
 local symbols = {"\226\151\144", "\226\151\147", "\226\151\145", "\226\151\146"}
 return symbols[(1 + (progress % #symbols))] end

 local function workflow_waiting_symbol() return "\226\167\150" end

 local function package_tree__3eui_data(packages, section_id)

 local Package0, Runtime = nil, nil do local _33_ = require("pact.runtime") local _32_ = require("pact.package") Package0, Runtime = _32_, _33_ end



 local configuration_error local function _34_(_241, _242) return {uid = "error", name = R.unwrap(_241), health = Package0.Health.failing(""), indent = #_242} end configuration_error = _34_ local package_data



 local function _35_(node, history)







 local _36_ do
 local _38_ do local t_37_ = node if (nil ~= t_37_) then t_37_ = (t_37_).events else end if (nil ~= t_37_) then t_37_ = (t_37_)[1] else end if (nil ~= t_37_) then t_37_ = (t_37_)[2] else end _38_ = t_37_ end _36_ = table.concat(E.map(string.gmatch(inspect(_38_, true), "([^\n]+)"), node), " ") end




 local _43_ do local _42_ = E.last(node.events) local function _44_() local e = _42_ return R["err?"](e) end if ((nil ~= _42_) and _44_()) then local e = _42_
 _43_ = R.unwrap(e) elseif true then local _ = _42_
 _43_ = nil else _43_ = nil end end return setmetatable(E["set$"]({["working?"] = (0 < node.tasks.active), ["waiting?"] = (0 < node.tasks.waiting), ["last-event"] = _36_, indent = #history, error = _43_, ["error?"] = false, ["loading?"] = false, ["staged?"] = false, ["unstaged?"] = false, ["up-to-date?"] = false}, (section_id .. "?"), true), {__index = node}) end package_data = _35_


 local function _48_(node, history)
 if R["err?"](node) then
 return configuration_error(node, history) else
 return package_data(node, history) end end
 local function _50_() return Package0.iter(packages, {["include-err?"] = true}) end return E.map(_48_, _50_) end

 local function ui_data__3erows(ui_data, section_id)
 local function indent_with(n)
 local _51_ = n if (_51_ == 0) then return "" elseif (_51_ == 1) then return " \226\148\148" elseif (_51_ == n) then


 return fmt(" %s\226\148\148", string.rep(" ", (n - 0))) else return nil end end

 local function indent_width(n)

 local _53_ = indent_with(n) if (_53_ == "") then return 0 elseif (nil ~= _53_) then local s = _53_

 return (#s - 2) else return nil end end


 local __fn_2a_package__3ecolumns_dispatch = {bodies = {}, help = {}} local package__3ecolumns local function _55_(...) if (0 == #(__fn_2a_package__3ecolumns_dispatch).bodies) then error(("multi-arity function " .. "package->columns" .. " has no bodies")) else end local _57_ do local f_78_auto = nil for __79_auto, match_3f_80_auto in ipairs((__fn_2a_package__3ecolumns_dispatch).bodies) do if f_78_auto then break end f_78_auto = match_3f_80_auto(...) end _57_ = f_78_auto end if (nil ~= _57_) then local f_78_auto = _57_ return f_78_auto(...) elseif (_57_ == nil) then local view_81_auto do local _58_, _59_ = pcall(require, "fennel") if ((_58_ == true) and ((_G.type(_59_) == "table") and (nil ~= (_59_).view))) then local view_81_auto0 = (_59_).view view_81_auto = view_81_auto0 elseif ((_58_ == false) and true) then local __79_auto = _59_ view_81_auto = (_G.vim.inspect or print) else view_81_auto = nil end end local msg_82_auto local _61_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_83_auto = 1, select("#", ...) do local val_19_auto = view_81_auto(({...})[i_83_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _61_ = tbl_17_auto end msg_82_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "package->columns", table.concat(_61_, ", "), table.concat((__fn_2a_package__3ecolumns_dispatch).help, "\n")) return error(msg_82_auto) else return nil end end package__3ecolumns = _55_ local function _64_() do local _ = {} end return package__3ecolumns end setmetatable({nil, nil}, {__call = _64_})()

 do table.insert((__fn_2a_package__3ecolumns_dispatch).help, "(where [err] (= err.uid \"error\"))") local function _66_(...) if (1 == select("#", ...)) then local _67_ = {...} local function _68_(...) local err_65_ = (_67_)[1] return (err_65_.uid == "error") end if (((_G.type(_67_) == "table") and (nil ~= (_67_)[1])) and _68_(...)) then local err_65_ = (_67_)[1] local function _69_(err)
 return mk_row(mk_content(mk_col(), mk_col(mk_chunk(indent_with(err.indent), "PactComment", indent_width(err.indent)), mk_chunk(err.name, "PactPackageFailing"))), {error = true}) end return _69_ else return nil end else return nil end end table.insert((__fn_2a_package__3ecolumns_dispatch).bodies, _66_) end









 do table.insert((__fn_2a_package__3ecolumns_dispatch).help, "(where [package])") local function _73_(...) if (1 == select("#", ...)) then local _74_ = {...} local function _75_(...) local package_72_ = (_74_)[1] return true end if (((_G.type(_74_) == "table") and (nil ~= (_74_)[1])) and _75_(...)) then local package_72_ = (_74_)[1] local function _76_(package)




















 local _local_78_ do local _77_ = Package _local_78_ = _77_ end local _local_79_ = _local_78_ local aligned_3f = _local_79_["aligned?"] local installed_3f = _local_79_["installed?"]
 local function action_data(package0)
 local _80_ local _81_ if installed_3f(package0) then _81_ = "existing" else _81_ = "new" end _80_ = {section_id, _81_, package0.action} if ((_G.type(_80_) == "table") and ((_80_)[1] == "staged") and ((_80_)[2] == "existing") and ((_80_)[3] == "retain")) then
 return {"will", "hold"} elseif ((_G.type(_80_) == "table") and ((_80_)[1] == "staged") and ((_80_)[2] == "existing") and ((_80_)[3] == "discard")) then
 return {"will", "discard"} elseif ((_G.type(_80_) == "table") and ((_80_)[1] == "staged") and ((_80_)[2] == "existing") and ((_80_)[3] == "align")) then
 return {"will", "sync"} elseif ((_G.type(_80_) == "table") and ((_80_)[1] == "unstaged") and ((_80_)[2] == "existing") and ((_80_)[3] == "retain")) then

 return {"can", "sync"} elseif ((_G.type(_80_) == "table") and ((_80_)[1] == "unstaged") and ((_80_)[2] == "existing") and ((_80_)[3] == "align")) then

 return {"can", "sync"} elseif ((_G.type(_80_) == "table") and ((_80_)[1] == "up-to-date") and ((_80_)[2] == "existing") and ((_80_)[3] == "retain")) then

 return {"will", "hold"} elseif ((_G.type(_80_) == "table") and ((_80_)[1] == "staged") and ((_80_)[2] == "new") and ((_80_)[3] == "discard")) then




 return {"can", "install"} elseif ((_G.type(_80_) == "table") and ((_80_)[1] == "staged") and ((_80_)[2] == "new") and ((_80_)[3] == "align")) then
 return {"will", "install"} elseif ((_G.type(_80_) == "table") and ((_80_)[1] == "unstaged") and ((_80_)[2] == "new") and ((_80_)[3] == "discard")) then


 return {"can", "install"} elseif ((_G.type(_80_) == "table") and ((_80_)[1] == "unstaged") and ((_80_)[2] == "new") and ((_80_)[3] == "align")) then
 return {"can", "install"} elseif ((_G.type(_80_) == "table") and true and true and (nil ~= (_80_)[3])) then local _ = (_80_)[1] local _0 = (_80_)[2] local action = (_80_)[3]
 return {"will", ("_" .. action .. "_")} else return nil end end
 local function s__3ecamel(s)
 local _84_ = {string.match(s, "([%w])([%w]*)(.*)")} if ((_G.type(_84_) == "table") and (nil ~= (_84_)[1]) and (nil ~= (_84_)[2]) and ((_84_)[3] == nil)) then local a = (_84_)[1] local b = (_84_)[2]
 return (string.upper(a) .. (b or "")) elseif ((_G.type(_84_) == "table") and (nil ~= (_84_)[1]) and (nil ~= (_84_)[2]) and (nil ~= (_84_)[3])) then local a = (_84_)[1] local b = (_84_)[2] local rest = (_84_)[3]
 return (string.upper(a) .. (b or "") .. s__3ecamel(rest)) elseif true then local _ = _84_
 return s else return nil end end
 local function nice_action(package0)
 local _let_86_ = action_data(package0) local verb = _let_86_[1] local name = _let_86_[2]
 local hl = ("Pact" .. "Package" .. s__3ecamel(verb) .. s__3ecamel(name))
 return mk_chunk(name, hl) end
 local function highlight_for_health(h) _G.assert((nil ~= h), "Missing argument h on ./fnl/pact/ui/render.fnl:187")
 local _87_ = h if ((_G.type(_87_) == "table") and ((_87_)[1] == "degraded")) then return "PactPackageDegraded" elseif ((_G.type(_87_) == "table") and ((_87_)[1] == "failing")) then return "PactPackageFailing" else return nil end end




 local commits_col
 local function _112_() if package.git then
 local from do local t_89_ = package.git.current.commit if (nil ~= t_89_) then t_89_ = (t_89_)["short-sha"] else end from = t_89_ end local to
 do local t_91_ = package.git.target.commit if (nil ~= t_91_) then t_91_ = (t_91_)["short-sha"] else end to = t_91_ end
 local distance = package.git.target.distance local direction
 if (distance and (0 < distance)) then direction = "ahead" else direction = "behind" end local breaking_3f
 do local t_94_ = package.git.target if (nil ~= t_94_) then t_94_ = (t_94_)["breaking?"] else end breaking_3f = t_94_ end
 local constraint = package.constraint local name
 do local _96_ = Constraint.type(constraint) if (_96_ == "version") then
 local function _97_(_241) return _241 end local function _98_()
 local t_99_ = package.git.target if (nil ~= t_99_) then t_99_ = (t_99_).commit else end if (nil ~= t_99_) then t_99_ = (t_99_).versions else end return t_99_ end name = table.concat(E.map(_97_, (_98_() or {})), ",") elseif (_96_ == "head") then name = "HEAD" elseif (_96_ == "commit") then


 name = Commit["abbrev-sha"](Constraint.value(constraint)) elseif true then local _ = _96_
 name = Constraint.value(constraint) else name = nil end end local hl
 local function _103_() if breaking_3f then return "PactPackageBreaking" else return "PactPackageText" end end hl = _103_ local warn
 local function _105_() if breaking_3f then return "\226\154\160 " else return "" end end warn = _105_
 local _107_ = {from, to, distance} if ((_G.type(_107_) == "table") and ((_107_)[1] == nil) and ((_107_)[2] == nil) and true) then local _ = (_107_)[3]
 return mk_chunk(fmt("%s", "..."), "PactComment") elseif ((_G.type(_107_) == "table") and ((_107_)[1] == nil) and ((_107_)[2] == to) and true) then local _ = (_107_)[3]
 return mk_chunk(fmt("%s", name), "PactPackageText") elseif ((_G.type(_107_) == "table") and (nil ~= (_107_)[1]) and ((_107_)[1] == (_107_)[2]) and true) then local same = (_107_)[1] local _ = (_107_)[3]
 return mk_chunk(fmt("%s", name), "PactPackageText") elseif ((_G.type(_107_) == "table") and ((_107_)[1] == from) and ((_107_)[2] == to) and (nil ~= (_107_)[3])) then local count = (_107_)[3]
 local x = fmt("%s%s (%s %s)", warn(), name, math.abs(count), direction) local len

 local function _109_() local _108_ = warn() if (_108_ == "") then return 0 elseif true then local _ = _108_ return -2 else return nil end end len = (#x + _109_())
 return mk_chunk(x, hl(), len) else return nil end else
 return mk_chunk("") end end commits_col = mk_col(_112_()) local name_col





 local function _114_() local _113_ = highlight_for_health(package.health) if (nil ~= _113_) then local hl = _113_
 return hl elseif (_113_ == nil) then return "PactPackageName" else return nil end end

 local function _117_() local _116_ = package.transaction if (nil ~= _116_) then local any = _116_
 return mk_chunk(fmt(" (t %s)", any)) elseif true then local _ = _116_
 return mk_chunk("") else return nil end end name_col = mk_col(mk_chunk(indent_with(package.indent), "PactComment", indent_width(package.indent)), mk_chunk(package.name, _114_()), _117_()) local constraint_col

 local function _120_() local _119_ = Constraint.type(package.constraint) if (_119_ == "version") then
 return Constraint.value(package.constraint) elseif (_119_ == "head") then return "HEAD" elseif (_119_ == "commit") then

 return ("^" .. Commit["abbrev-sha"](Constraint.value(package.constraint))) elseif (_119_ == "tag") then
 return ("#" .. Constraint.value(package.constraint)) elseif true then local _ = _119_
 return Constraint.value(package.constraint) else return nil end end constraint_col = mk_col(mk_chunk(_120_()))
 local action_col = mk_col(nice_action(package)) local latest_col


 local function _133_() local _122_ local _124_ do local t_123_ = package if (nil ~= t_123_) then t_123_ = (t_123_).git else end if (nil ~= t_123_) then t_123_ = (t_123_).latest else end if (nil ~= t_123_) then t_123_ = (t_123_).commit else end _124_ = t_123_ end
 local function _129_() local t_128_ = package if (nil ~= t_128_) then t_128_ = (t_128_).git else end if (nil ~= t_128_) then t_128_ = (t_128_).target else end if (nil ~= t_128_) then t_128_ = (t_128_).commit else end return t_128_ end _122_ = {_124_, _129_()} if ((_G.type(_122_) == "table") and ((_G.type((_122_)[1]) == "table") and (nil ~= ((_122_)[1]).sha)) and ((_G.type((_122_)[2]) == "table") and (((_122_)[1]).sha == ((_122_)[2]).sha))) then local sha = ((_122_)[1]).sha
 return mk_chunk("") elseif ((_G.type(_122_) == "table") and (nil ~= (_122_)[1]) and true) then local a = (_122_)[1] local _ = (_122_)[2]
 return mk_chunk(fmt("(%s)", table.concat(a.versions, ","))) elseif true then local _ = _122_
 return mk_chunk("") else return nil end end latest_col = mk_col(_133_())







 local _136_ do local _135_ = {package["working?"], package["waiting?"]} if ((_G.type(_135_) == "table") and ((_135_)[1] == true) and true) then local _ = (_135_)[2]
 _136_ = {text = workflow_active_symbol(spinner_frame), highlight = "PactSignWorking"} elseif ((_G.type(_135_) == "table") and true and ((_135_)[2] == true)) then local _ = (_135_)[1]

 _136_ = {text = workflow_waiting_symbol(vim.loop.gettimeofday()), highlight = "PactSignWaiting"} else _136_ = nil end end

 local _141_ do local _140_ do local t_142_ = package if (nil ~= t_142_) then t_142_ = (t_142_).git else end if (nil ~= t_142_) then t_142_ = (t_142_).target else end if (nil ~= t_142_) then t_142_ = (t_142_).logs else end _140_ = t_142_ end if (nil ~= _140_) then local logs = _140_
 local function _147_(line)
 local _148_, _149_ = string.match(line, "^(%x+)%s+(.+)$") if ((nil ~= _148_) and (nil ~= _149_)) then local sha = _148_ local message = _149_
 return {{Commit["abbrev-sha"](sha), "PactComment"}, {" ", "Normal"}, {message, "PactPackageText"}} elseif true then local _ = _148_


 return {{line, "PactComment"}} else return nil end end _141_ = E.map(_147_, logs) else _141_ = nil end end



 local _153_ do local _152_ = package.action if true then local _ = _152_







 _153_ = nil else _153_ = nil end end





 local _157_ do local _156_ = package.health if ((_G.type(_156_) == "table") and ((_156_)[1] == "healthy")) then
 _157_ = nil elseif ((_G.type(_156_) == "table") and ((_156_)[1] == "degraded") and (nil ~= (_156_)[2])) then local msg = (_156_)[2]
 _157_ = {text = tostring(msg), highlight = "PactPackageDegraded"} elseif ((_G.type(_156_) == "table") and ((_156_)[1] == "failing") and (nil ~= (_156_)[2])) then local msg = (_156_)[2]
 _157_ = {text = tostring(msg), highlight = "PactPackageFailing"} else _157_ = nil end end return {content = mk_content(action_col, name_col, constraint_col, commits_col, latest_col), meta = {uid = package.uid, workflow = _136_, logs = _141_, ["last-event"] = package["last-event"], error = package.error, action = _153_, health = _157_}} end return _76_ else return nil end else return nil end end table.insert((__fn_2a_package__3ecolumns_dispatch).bodies, _73_) end


 local function _164_(_241) return package__3ecolumns(_241) end return E.map(_164_, ui_data) end

 local function inject_padding_chunks(rows, widths)





 local sum_col_chunk_widths local function _165_(_241)
 local function _166_(_2410, _2420) local _let_167_ = _2420 local text = _let_167_["text"] local len = _let_167_["length"]
 local _168_ = {text, len} if ((_G.type(_168_) == "table") and ((_168_)[1] == nil) and ((_168_)[2] == nil)) then
 return _2410 elseif ((_G.type(_168_) == "table") and (nil ~= (_168_)[1]) and ((_168_)[2] == nil)) then local any = (_168_)[1]
 return (_2410 + #text) elseif ((_G.type(_168_) == "table") and true and (nil ~= (_168_)[2])) then local _ = (_168_)[1] local any = (_168_)[2]
 return (_2410 + len) elseif true then local _ = _168_
 return _2410 else return nil end end return E.reduce(_166_, 0, _241) end sum_col_chunk_widths = _165_


 local function _170_(row)

 local function _171_(column, col_n)
 local cur_width = sum_col_chunk_widths(column)
 local padding = ((widths[col_n] or 0) - cur_width)

 if (0 < padding) then
 return E["concat$"]({}, column, {{text = string.rep(" ", padding), highlight = "None"}}) else

 return E["concat$"]({}, column) end end return {meta = row.meta, content = E.map(_171_, row.content)} end return E.map(_170_, rows) end



 local function intersperse_column_gutters(rows) _G.assert((nil ~= rows), "Missing argument rows on ./fnl/pact/ui/render.fnl:317")

 local function _173_(_241) return {meta = _241.meta, content = E.intersperse(_241.content, {{text = " ", highlight = "PactComment"}})} end return E.map(_173_, rows) end



 local function row__3ecolumn_widths(row)
 local function width_of_column(column)
 local function _174_(_241, _242) local _let_175_ = _242 local text = _let_175_["text"] local len = _let_175_["length"]
 local _176_ = {text, len} if ((_G.type(_176_) == "table") and ((_176_)[1] == nil) and ((_176_)[2] == nil)) then
 return _241 elseif ((_G.type(_176_) == "table") and (nil ~= (_176_)[1]) and ((_176_)[2] == nil)) then local any = (_176_)[1]
 return (_241 + #text) elseif ((_G.type(_176_) == "table") and true and (nil ~= (_176_)[2])) then local _ = (_176_)[1] local any = (_176_)[2]
 return (_241 + len) elseif true then local _ = _176_
 return _241 else return nil end end return E.reduce(_174_, 0, column) end

 return E.map(width_of_column, row.content) end

 local function widths__3emaximum_widths(widths)
 local function _178_(col_max, col_widths)


 local function _179_(width, col_n)
 return E["set$"](col_max, col_n, math.max((col_max[col_n] or 0), width)) end E.each(_179_, col_widths)


 return col_max end return E.reduce(_178_, {}, widths) end

 local function find_maximum_column_widths(rows)
 return widths__3emaximum_widths(E.map(row__3ecolumn_widths, rows)) end





 local const = {lede = {mk_basic_row(";; \240\159\148\170\240\159\169\184\240\159\144\144"), mk_basic_row(";; (some things are ugly right now, sorry)"), mk_basic_row("")}, blank = {mk_basic_row("")}, ["no-plugins"] = {mk_basic_row(";;"), mk_basic_row(";; Whoops!"), mk_basic_row(";;"), mk_basic_row(";; pact has no plugins defined! See `:h pact-usage`"), mk_basic_row(";;"), mk_basic_row(";; Since 0.0.10 you need to wrap your plugins inside `make-pact`/`make_pact`!"), mk_basic_row(";; You may also have to reinstall your plugins."), mk_basic_row(";;")}, usage = {mk_basic_row(""), mk_basic_row(";; Usage:"), mk_basic_row(";;"), mk_basic_row(";;   s  - Stage package tree in transaction"), mk_basic_row(";;   u  - Unstage package tree in transaction"), mk_basic_row(";;   d  - Discard package tree in transaction"), mk_basic_row(";;   cc - Commit transaction"), mk_basic_row(";;   =  - View git log (staged/unstaged only)")}}




















 local function group_packages_by_section(packages) _G.assert((nil ~= packages), "Missing argument packages on ./fnl/pact/ui/render.fnl:372")


 local function _182_(grouped, _180_) local _arg_181_ = _180_ local f = _arg_181_[1] local key = _arg_181_[2]
 local _let_183_ = E["group-by"](f, grouped.rest) local g = _let_183_[true] local r = _let_183_[false]
 grouped[key] = (g or {}) do end (grouped)["rest"] = (r or {}) return grouped end return E.reduce(_182_, {rest = packages}, {{package_configuration_error_3f, "error"}, {package_loading_3f, "loading"}, {package_staged_3f, "staged"}, {package_unstaged_3f, "unstaged"}, {package_up_to_date_3f, "up-to-date"}}) end











 Render.output = function(ui)























 local Runtime do local _184_ = require("pact.runtime") Runtime = _184_ end
 spinner_frame = rate_limited_inc(spinner_frame)
 local sections = group_packages_by_section(ui.runtime.packages) local rows


 local function _185_(acc, section, id)
 return E["set$"](acc, id, ui_data__3erows(package_tree__3eui_data(section, id), id)) end rows = E.reduce(_185_, {}, sections)



 local header_rows = {mk_row(mk_content(mk_col(mk_chunk("action", "PactColumnTitle")), mk_col(mk_chunk("package", "PactColumnTitle")), mk_col(mk_chunk("target", "PactColumnTitle")), mk_col(mk_chunk("solved", "PactColumnTitle")), mk_col(mk_chunk("(latest)", "PactColumnTitle"))))} local column_widths













 local function _186_(_241) return widths__3emaximum_widths(E.map(row__3ecolumn_widths, _241)) end

 local function _187_(_241) local _189_ do local t_188_ = _241 if (nil ~= t_188_) then t_188_ = (t_188_).meta else end if (nil ~= t_188_) then t_188_ = (t_188_).error else end _189_ = t_188_ end return not _189_ end column_widths = widths__3emaximum_widths(E["concat$"](E.map(row__3ecolumn_widths, header_rows), E.map(_186_, E.filter(_187_, rows)))) local rows0




 local function _192_(acc, section, id)
 return E["set$"](acc, id, intersperse_column_gutters(inject_padding_chunks(section, column_widths))) end rows0 = E.reduce(_192_, {}, rows)



 local header_rows0 = intersperse_column_gutters(inject_padding_chunks(header_rows, column_widths)) local titles




 local function _193_(acc, section, id)
 return E["set$"](acc, id, {mk_row(mk_content(mk_col(mk_chunk(string.upper(id), "PactSectionTitle"), mk_chunk(fmt(" (%s)", #section), "PactComment"))))}) end titles = E.reduce(_193_, {}, rows0)






 ui.extmarks = {} local cursor_line = 0



 local function write_rows(rows1)
 local function write_lines(lines)
 local len = #lines
 api.nvim_buf_set_lines(ui.buf, cursor_line, (cursor_line + len), false, lines)
 cursor_line = (cursor_line + len) return nil end
 local function draw_extmarks(lines, offset)
 local function _194_(marks, line)
 local function _195_(mark)
 local line0 = ((offset + line) - 1)

 if mark.uid then

 local function _196_(_241) ui.extmarks[_241] = mark.uid return nil end _196_(api.nvim_buf_set_extmark(ui.buf, ui["ns-meta-id"], line0, 0, {})) else end


 if mark.health then
 api.nvim_buf_set_extmark(ui.buf, ui["ns-meta-id"], line0, 0, {sign_text = "\226\154\160", sign_hl_group = mark.health.highlight, priority = 200, virt_text = {{mark.health.text, mark.health.highlight}}}) else end





 if mark.workflow then
 api.nvim_buf_set_extmark(ui.buf, ui["ns-meta-id"], line0, 0, {sign_text = mark.workflow.text, priority = 110, sign_hl_group = mark.workflow.highlight}) else end




 if mark.action then
 api.nvim_buf_set_extmark(ui.buf, ui["ns-meta-id"], line0, 0, {sign_text = mark.action.text, priority = 100, sign_hl_group = mark.action.highlight}) else end




 if mark["last-event"] then
 api.nvim_buf_set_extmark(ui.buf, ui["ns-meta-id"], line0, 0, {virt_text = {{mark["last-event"], "PactComment"}}}) else end

 if mark.logs then
 api.nvim_buf_set_extmark(ui.buf, ui["ns-meta-id"], line0, 0, {virt_lines = mark.logs}) else end




 local _203_ = mark if ((_G.type(_203_) == "table") and (nil ~= (_203_).start) and (nil ~= (_203_).stop) and (nil ~= (_203_).highlight)) then local start = (_203_).start local stop = (_203_).stop local highlight = (_203_).highlight

 return api.nvim_buf_add_highlight(ui.buf, ui["ns-id"], highlight, line0, start, stop) else return nil end end return E.each(_195_, marks) end return E.each(_194_, lines) end



 write_lines(rows__3elines(rows1))

 return draw_extmarks(rows__3eextmarks(rows1), (cursor_line - #rows1)) end


 local function write_section(title, section)
 if not E["empty?"](section) then
 write_rows(title)
 write_rows(header_rows0)
 write_rows(section)
 return write_rows(const.blank) else return nil end end

 api.nvim_buf_set_option(ui.buf, "modifiable", true)

 write_rows(const.lede)

 local function _206_(_241) return (0 == #_241) end if E["all?"](_206_, rows0) then
 write_rows(const["no-plugins"]) else

 write_section(titles.error, rows0.error)
 write_section(titles.rest, rows0.rest)
 write_section(titles.loading, rows0.loading)
 write_section(titles.unstaged, rows0.unstaged)
 write_section(titles.staged, rows0.staged)
 write_section(titles["up-to-date"], rows0["up-to-date"]) end

 write_rows(const.usage)


 api.nvim_buf_set_lines(ui.buf, cursor_line, -1, false, {})
 return api.nvim_buf_set_option(ui.buf, "modifiable", false) end

 return Render