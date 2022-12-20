
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local enum, inspect, scheduler, _local_21_, _local_22_, result, api, _local_23_, orphan_find_wf, orphan_remove_fw, status_wf, clone_wf, sync_wf, diff_wf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil do local _20_ = require("pact.workflow.git.diff") local _19_ = require("pact.workflow.git.sync") local _18_ = require("pact.workflow.git.clone") local _17_ = require("pact.workflow.git.status") local _16_ = require("pact.workflow.orphan.remove") local _15_ = require("pact.workflow.orphan.find") local _14_ = string local _13_ = vim.api local _12_ = require("pact.lib.ruin.result") local _11_ = require("pact.lib.ruin.result") local _10_ = require("pact.pubsub") local _9_ = require("pact.workflow.scheduler") local _8_ = require("pact.inspect") local _7_ = require("pact.lib.ruin.enum") enum, inspect, scheduler, _local_21_, _local_22_, result, api, _local_23_, orphan_find_wf, orphan_remove_fw, status_wf, clone_wf, sync_wf, diff_wf = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_, _16_, _17_, _18_, _19_, _20_ end local _local_24_ = _local_21_


 local subscribe = _local_24_["subscribe"] local unsubscribe = _local_24_["unsubscribe"] local _local_25_ = _local_22_
 local err_3f = _local_25_["err?"] local ok_3f = _local_25_["ok?"] local _local_26_ = _local_23_


 local fmt = _local_26_["format"]







 local M = {}

 local function section_title(section_name)
 return (({error = "Error", waiting = "Waiting", active = "Active", held = "Held", updated = "Updated", ["up-to-date"] = "Up to date", unstaged = "Unstaged", staged = "Staged"})[section_name] or section_name) end









 local function highlight_for(section_name, field)

 local joined = table.concat({"pact", section_name, field}, "-")
 local function _27_(_241, _242, _243) return (_241 .. string.upper(_242) .. _243) end
 local function _28_() return string.gmatch(joined, "(%w)([%w]+)") end return enum.reduce(_27_, "", _28_) end

 local function lede()
 return {{{";; \240\159\148\170\240\159\169\184\240\159\144\144", "PactComment"}}, {{"", "PactComment"}}} end


 local function usage()
 return {{{";; usage:", "PactComment"}}, {{";;", "PactComment"}}, {{";;   s  - stage plugin for update", "PactComment"}}, {{";;   u  - unstage plugin", "PactComment"}}, {{";;   cc - commit staging and fetch updates", "PactComment"}}, {{";;   =  - view git log (staged/unstaged only)", "PactComment"}}, {{"", nil}}} end







 local function rate_limited_inc(_29_) local _arg_30_ = _29_ local t = _arg_30_[1] local n = _arg_30_[2]


 local every_n_ms = (1000 / 6)
 local now = vim.loop.now()
 if (every_n_ms < (now - t)) then
 return {now, (n + 1)} else
 return {t, n} end end

 local function progress_symbol(progress)
 local _32_ = progress if (_32_ == nil) then return " " elseif ((_G.type(_32_) == "table") and true and (nil ~= (_32_)[2])) then local _ = (_32_)[1] local n = (_32_)[2]

 local symbols = {"\226\151\144", "\226\151\147", "\226\151\145", "\226\151\146"}
 return (symbols[(1 + (n % #symbols))] .. " ") else return nil end end

 local function render_section(ui, section_name, previous_lines)
 local relevant_plugins

 local function _34_(_241, _242) return (_241.order <= _242.order) end local function _35_(_241, _242) return _242 end local function _36_(_241, _242) return (_242.state == section_name) end relevant_plugins = enum["sort$"](_34_, enum.map(_35_, enum.filter(_36_, ui["plugins-meta"]))) local new_lines
 local function _37_(lines, i, meta)
 local name_length = #meta.plugin.name
 local line = {{meta.plugin.name, highlight_for(section_name, "name")}, {string.rep(" ", ((1 + ui.layout["max-name-length"]) - name_length)), nil}, {progress_symbol(meta.progress), highlight_for(section_name, "name")}, {(meta.text or "did-not-set-text"), highlight_for(section_name, "text")}}








 meta["on-line"] = (2 + #previous_lines + #lines)
 return enum["append$"](lines, line) end new_lines = enum.reduce(_37_, {}, relevant_plugins)

 if (0 < #new_lines) then
 return enum["append$"](enum["concat$"](enum["append$"](previous_lines, {{("" .. section_title(section_name)), highlight_for(section_name, "title")}, {" ", nil}, {fmt("(%s)", #new_lines), "PactComment"}}), new_lines), {{"", nil}}) else






 return previous_lines end end

 local function log_line_breaking_3f(log_line)

 return not_nil_3f(string.match(string.lower(log_line), "break")) end

 local function log_line__3echunks(log_line)
 local sha, log = string.match(log_line, "(%x+)%s(.+)")



 local function _39_() if log_line_breaking_3f(log) then return "DiagnosticError" else return "DiagnosticHint" end end return {{"  ", "comment"}, {sha, "comment"}, {" ", "comment"}, {log, _39_()}} end

 local function output(ui)
 local sections = {"waiting", "error", "active", "unstaged", "staged", "updated", "held", "up-to-date"} local lines
 local function _40_(lines0, _, section) return render_section(ui, section, lines0) end lines = enum["concat$"](enum.reduce(_40_, lede(), sections), usage()) local lines__3etext_and_extmarks






 local function _45_(_41_, _, _43_) local _arg_42_ = _41_ local str = _arg_42_[1] local extmarks = _arg_42_[2] local _arg_44_ = _43_ local txt = _arg_44_[1] local _3fextmarks = _arg_44_[2]

 local function _46_() if _3fextmarks then
 return enum["append$"](extmarks, {#str, (#str + #txt), _3fextmarks}) else
 return extmarks end end return {(str .. txt), _46_()} end lines__3etext_and_extmarks = enum.reduce(_45_)
 local function _50_(_48_, _, line) local _arg_49_ = _48_ local lines0 = _arg_49_[1] local extmarks = _arg_49_[2]
 local _let_51_ = lines__3etext_and_extmarks({"", {}}, line) local new_lines = _let_51_[1] local new_extmarks = _let_51_[2]
 return {enum["append$"](lines0, new_lines), enum["append$"](extmarks, new_extmarks)} end local _let_47_ = enum.reduce(_50_, {{}, {}}, lines) local text = _let_47_[1] local extmarks = _let_47_[2]


 local function _52_(_241, _242) return string.match(_242, "\n") end if enum["any?"](_52_, text) then
 print("pact.ui text had unexpected new lines")
 print(vim.inspect(text)) else end
 api.nvim_buf_set_lines(ui.buf, 0, -1, false, text)
 local function _54_(i, line_marks)
 local function _57_(_, _55_) local _arg_56_ = _55_ local start = _arg_56_[1] local stop = _arg_56_[2] local hl = _arg_56_[3]
 return api.nvim_buf_add_highlight(ui.buf, ui["ns-id"], hl, (i - 1), start, stop) end return enum.map(_57_, line_marks) end enum.map(_54_, extmarks)


 local function _58_(_241, _242) if _242["log-open"] then

 local function _59_(_2410, _2420) return log_line__3echunks(_2420) end return api.nvim_buf_set_extmark(ui.buf, ui["ns-id"], (_242["on-line"] - 1), 0, {virt_lines = enum.map(_59_, _242.log)}) else return nil end end return enum.map(_58_, ui["plugins-meta"]) end



 local function schedule_redraw(ui)


 local rate = (1000 / 30)
 if ((ui["will-render"] or 0) < vim.loop.now()) then
 ui["will-render"] = (rate + vim.loop.now())
 local function _61_() return output(ui) end return vim.defer_fn(_61_, rate) else return nil end end

 local function exec_commit(ui)
 local function make_wf(how, plugin, action_data)
 local wf do local _63_ = how if (_63_ == "clone") then
 wf = clone_wf.new(plugin.id, plugin["package-path"], plugin.source[2], action_data.sha) elseif (_63_ == "sync") then
 wf = sync_wf.new(plugin.id, plugin["package-path"], action_data.sha) elseif (_63_ == "clean") then
 wf = orphan_remove_fw.new(plugin.id, action_data) elseif (nil ~= _63_) then local other = _63_
 wf = error(fmt("unknown staging action %s", other)) else wf = nil end end
 local meta = ui["plugins-meta"][plugin.id] local handler
 local __fn_2a_handler_dispatch = {bodies = {}, help = {}} local handler0 local function _69_(...) if (0 == #(__fn_2a_handler_dispatch).bodies) then error(("multi-arity function " .. "handler" .. " has no bodies")) else end local _71_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _71_ = f_74_auto end if (nil ~= _71_) then local f_74_auto = _71_ return f_74_auto(...) elseif (_71_ == nil) then local view_77_auto do local _72_, _73_ = pcall(require, "fennel") if ((_72_ == true) and ((_G.type(_73_) == "table") and (nil ~= (_73_).view))) then local view_77_auto0 = (_73_).view view_77_auto = view_77_auto0 elseif ((_72_ == false) and true) then local __75_auto = _73_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _75_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _75_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "handler", table.concat(_75_, ", "), table.concat((__fn_2a_handler_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end handler0 = _69_ local function _78_() local _79_ do table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))") local function _80_(...) if (1 == select("#", ...)) then local _81_ = {...} local function _82_(...) local event_65_ = (_81_)[1] return ok_3f(event_65_) end if (((_G.type(_81_) == "table") and (nil ~= (_81_)[1])) and _82_(...)) then local event_65_ = (_81_)[1] local function _83_(event)


 enum["append$"](meta.events, event) meta.state = "updated"


 local _85_ do local _84_ = how if (_84_ == "clone") then _85_ = "cloned" elseif (_84_ == "sync") then _85_ = "synced" elseif (_84_ == "clean") then _85_ = "cleaned" elseif true then local _ = _84_



 _85_ = how else _85_ = nil end end meta.text = fmt("(%s %s)", _85_, action_data)

 meta.progress = nil
 local function _91_()
 vim.cmd("packloadall!")
 return vim.cmd("silent! helptags ALL") end vim.schedule(_91_)
 if plugin.after then
 local _let_92_ = require("pact.workflow.after") local new = _let_92_["new"]
 local old_text = meta.text
 local after_wf = new(wf.id, plugin.after, plugin["package-path"]) meta.text = "running..."


 local function _93_(event0)
 local _94_ = event0 local function _95_() local _ = _94_ return ok_3f(event0) end if (true and _95_()) then local _ = _94_




 meta.text = fmt("%s after: %s", old_text, (result.unwrap(event0) or "finished with no value"))



 meta.progress = nil
 unsubscribe(after_wf, handler0)
 return schedule_redraw(ui) else local function _96_() local _ = _94_ return err_3f(event0) end if (true and _96_()) then local _ = _94_


 meta.text = (old_text .. fmt(" error: %s", inspect(result.unwrap(event0))))
 meta.progress = nil
 unsubscribe(after_wf, handler0)
 return schedule_redraw(ui) else local function _97_() local _ = _94_ return string_3f(event0) end if (true and _97_()) then local _ = _94_





 return handler0(fmt("after: %s", event0)) else local function _98_() local _ = _94_ return thread_3f(event0) end if (true and _98_()) then local _ = _94_

 return handler0(event0) else return nil end end end end end subscribe(after_wf, _93_)
 scheduler["add-workflow"](ui.scheduler, after_wf) else end
 unsubscribe(wf, handler0)
 return schedule_redraw(ui) end return _83_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _80_) _79_ = handler0 end local _103_ do table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))") local function _104_(...) if (1 == select("#", ...)) then local _105_ = {...} local function _106_(...) local event_66_ = (_105_)[1] return err_3f(event_66_) end if (((_G.type(_105_) == "table") and (nil ~= (_105_)[1])) and _106_(...)) then local event_66_ = (_105_)[1] local function _107_(event)


 local _let_108_ = event local _ = _let_108_[1] local e = _let_108_[2]
 enum["append$"](meta.events, event) meta.state = "error"

 meta.text = e
 meta.progress = nil
 unsubscribe(wf, handler0)
 return schedule_redraw(ui) end return _107_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _104_) _103_ = handler0 end local _111_ do table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))") local function _112_(...) if (1 == select("#", ...)) then local _113_ = {...} local function _114_(...) local msg_67_ = (_113_)[1] return string_3f(msg_67_) end if (((_G.type(_113_) == "table") and (nil ~= (_113_)[1])) and _114_(...)) then local msg_67_ = (_113_)[1] local function _115_(msg)



 enum["append$"](meta.events, msg)
 meta.text = msg
 meta.progress = nil
 return schedule_redraw(ui) end return _115_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _112_) _111_ = handler0 end local _118_ do table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))") local function _119_(...) if (1 == select("#", ...)) then local _120_ = {...} local function _121_(...) local future_68_ = (_120_)[1] return thread_3f(future_68_) end if (((_G.type(_120_) == "table") and (nil ~= (_120_)[1])) and _121_(...)) then local future_68_ = (_120_)[1] local function _122_(future)



 meta.progress = rate_limited_inc((meta.progress or {0, 0}))
 return schedule_redraw(ui) end return _122_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _119_) _118_ = handler0 end local function _125_() table.insert((__fn_2a_handler_dispatch).help, "(where _)") local function _126_(...) if true then local _127_ = {...} local function _128_(...) return true end if ((_G.type(_127_) == "table") and _128_(...)) then local function _129_(...)


 return nil end return _129_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _126_) return handler0 end do local _ = {_79_, _103_, _111_, _118_, _125_()} end return handler0 end handler = setmetatable({nil, nil}, {__call = _78_})()
 subscribe(wf, handler)
 return wf end


 local function _132_(_, meta) meta["state"] = "held" return nil end local function _133_(_241, _242) return ("unstaged" == _242.state) end enum.map(_132_, enum.filter(_133_, ui["plugins-meta"]))

 local function _134_(_, meta)
 local wf = make_wf(meta.action[1], meta.plugin, meta.action[2])
 scheduler["add-workflow"](ui.scheduler, wf)
 do end (meta)["state"] = "active" return nil end local function _135_(_241, _242) return ("staged" == _242.state) end enum.map(_134_, enum.filter(_135_, ui["plugins-meta"]))
 return schedule_redraw(ui) end

 local function exec_diff(ui, meta)
 local function make_wf(plugin, commit)
 local wf = diff_wf.new(plugin.id, plugin["package-path"], commit.sha)
 local previous_text = meta.text
 local meta0 = ui["plugins-meta"][plugin.id] local handler
 local __fn_2a_handler_dispatch = {bodies = {}, help = {}} local handler0 local function _140_(...) if (0 == #(__fn_2a_handler_dispatch).bodies) then error(("multi-arity function " .. "handler" .. " has no bodies")) else end local _142_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _142_ = f_74_auto end if (nil ~= _142_) then local f_74_auto = _142_ return f_74_auto(...) elseif (_142_ == nil) then local view_77_auto do local _143_, _144_ = pcall(require, "fennel") if ((_143_ == true) and ((_G.type(_144_) == "table") and (nil ~= (_144_).view))) then local view_77_auto0 = (_144_).view view_77_auto = view_77_auto0 elseif ((_143_ == false) and true) then local __75_auto = _144_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _146_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _146_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "handler", table.concat(_146_, ", "), table.concat((__fn_2a_handler_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end handler0 = _140_ local function _149_() local _150_ do table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))") local function _151_(...) if (1 == select("#", ...)) then local _152_ = {...} local function _153_(...) local event_136_ = (_152_)[1] return ok_3f(event_136_) end if (((_G.type(_152_) == "table") and (nil ~= (_152_)[1])) and _153_(...)) then local event_136_ = (_152_)[1] local function _154_(event)

 local _let_155_ = event local _ = _let_155_[1] local log = _let_155_[2]
 enum["append$"](meta0.events, event)
 meta0.text = previous_text
 meta0.progress = nil
 meta0.log = log meta0["log-open"] = true

 unsubscribe(wf, handler0)
 return schedule_redraw(ui) end return _154_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _151_) _150_ = handler0 end local _158_ do table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))") local function _159_(...) if (1 == select("#", ...)) then local _160_ = {...} local function _161_(...) local event_137_ = (_160_)[1] return err_3f(event_137_) end if (((_G.type(_160_) == "table") and (nil ~= (_160_)[1])) and _161_(...)) then local event_137_ = (_160_)[1] local function _162_(event)


 local _let_163_ = event local _ = _let_163_[1] local e = _let_163_[2]
 enum["append$"](meta0.events, event)
 meta0.text = e
 meta0.progress = nil
 unsubscribe(wf, handler0)
 return schedule_redraw(ui) end return _162_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _159_) _158_ = handler0 end local _166_ do table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))") local function _167_(...) if (1 == select("#", ...)) then local _168_ = {...} local function _169_(...) local msg_138_ = (_168_)[1] return string_3f(msg_138_) end if (((_G.type(_168_) == "table") and (nil ~= (_168_)[1])) and _169_(...)) then local msg_138_ = (_168_)[1] local function _170_(msg)


 local meta1 = ui["plugins-meta"][wf.id]
 enum["append$"](meta1.events, msg)
 do end (meta1)["text"] = msg
 return schedule_redraw(ui) end return _170_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _167_) _166_ = handler0 end local _173_ do table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))") local function _174_(...) if (1 == select("#", ...)) then local _175_ = {...} local function _176_(...) local future_139_ = (_175_)[1] return thread_3f(future_139_) end if (((_G.type(_175_) == "table") and (nil ~= (_175_)[1])) and _176_(...)) then local future_139_ = (_175_)[1] local function _177_(future)



 meta0.progress = rate_limited_inc((meta0.progress or {0, 0}))
 return schedule_redraw(ui) end return _177_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _174_) _173_ = handler0 end local function _180_() table.insert((__fn_2a_handler_dispatch).help, "(where _)") local function _181_(...) if true then local _182_ = {...} local function _183_(...) return true end if ((_G.type(_182_) == "table") and _183_(...)) then local function _184_(...)


 return nil end return _184_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _181_) return handler0 end do local _ = {_150_, _158_, _166_, _173_, _180_()} end return handler0 end handler = setmetatable({nil, nil}, {__call = _149_})()
 subscribe(wf, handler)
 return wf end
 do local wf = make_wf(meta.plugin, meta.action[2])
 scheduler["add-workflow"](ui.scheduler, wf) end
 return schedule_redraw(ui) end

 local function exec_orphans(ui, meta)
 local start_root = (vim.fn.stdpath("data") .. "/site/pack/pact/start")
 local opt_root = (vim.fn.stdpath("data") .. "/site/pack/pact/opt") local known_paths
 local function _187_(_241, _242) return _242["package-path"] end known_paths = enum.map(_187_, ui.plugins)
 local function make_wf(id, root)
 local wf = orphan_find_wf.new(id, root, known_paths) local handler
 local __fn_2a_handler_dispatch = {bodies = {}, help = {}} local handler0 local function _190_(...) if (0 == #(__fn_2a_handler_dispatch).bodies) then error(("multi-arity function " .. "handler" .. " has no bodies")) else end local _192_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _192_ = f_74_auto end if (nil ~= _192_) then local f_74_auto = _192_ return f_74_auto(...) elseif (_192_ == nil) then local view_77_auto do local _193_, _194_ = pcall(require, "fennel") if ((_193_ == true) and ((_G.type(_194_) == "table") and (nil ~= (_194_).view))) then local view_77_auto0 = (_194_).view view_77_auto = view_77_auto0 elseif ((_193_ == false) and true) then local __75_auto = _194_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _196_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _196_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "handler", table.concat(_196_, ", "), table.concat((__fn_2a_handler_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end handler0 = _190_ local function _199_() local _200_ do table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))") local function _201_(...) if (1 == select("#", ...)) then local _202_ = {...} local function _203_(...) local event_188_ = (_202_)[1] return ok_3f(event_188_) end if (((_G.type(_202_) == "table") and (nil ~= (_202_)[1])) and _203_(...)) then local event_188_ = (_202_)[1] local function _204_(event)


 do local _205_ = result.unwrap(event) local function _206_() local list = _205_ return not enum["empty?"](list) end if ((nil ~= _205_) and _206_()) then local list = _205_

 local function _207_(_241, _242) local plugin_id = fmt("orphan-%s", _241)
 local name = fmt("%s/%s", id, _242.name)
 local len = #name
 ui["plugins-meta"][plugin_id] = {plugin = {id = plugin_id, name = name}, order = (-1 * _241), events = {}, text = "(orphan) exists on disk but unknown to pact!", action = {"clean", _242.path}, state = "unstaged"}








 if (ui.layout["max-name-length"] < len) then
 ui.layout["max-name-length"] = len return nil else return nil end end enum.each(_207_, list) else end end

 unsubscribe(wf, handler0)
 return schedule_redraw(ui) end return _204_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _201_) _200_ = handler0 end local _212_ do table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))") local function _213_(...) if (1 == select("#", ...)) then local _214_ = {...} local function _215_(...) local event_189_ = (_214_)[1] return err_3f(event_189_) end if (((_G.type(_214_) == "table") and (nil ~= (_214_)[1])) and _215_(...)) then local event_189_ = (_214_)[1] local function _216_(event)



 vim.notify(fmt("error checking for orphans, please report: %s", result.unwrap(event)))
 return unsubscribe(wf, handler0) end return _216_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _213_) _212_ = handler0 end local function _219_() table.insert((__fn_2a_handler_dispatch).help, "(where _)") local function _220_(...) if true then local _221_ = {...} local function _222_(...) return true end if ((_G.type(_221_) == "table") and _222_(...)) then local function _223_(...)


 return nil end return _223_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _220_) return handler0 end do local _ = {_200_, _212_, _219_()} end return handler0 end handler = setmetatable({nil, nil}, {__call = _199_})()
 subscribe(wf, handler)
 return wf end
 local function _226_(_241, _242) return scheduler["add-workflow"](ui.scheduler, make_wf(_241, _242)) end return enum.map(_226_, {start = start_root, opt = opt_root}) end



 local function exec_status(ui)
 local function make_status_wf(plugin)
 local wf = status_wf.new(plugin.id, plugin.source[2], plugin["package-path"], plugin.constraint)



 local meta = ui["plugins-meta"][plugin.id] local handler
 local __fn_2a_handler_dispatch = {bodies = {}, help = {}} local handler0 local function _231_(...) if (0 == #(__fn_2a_handler_dispatch).bodies) then error(("multi-arity function " .. "handler" .. " has no bodies")) else end local _233_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _233_ = f_74_auto end if (nil ~= _233_) then local f_74_auto = _233_ return f_74_auto(...) elseif (_233_ == nil) then local view_77_auto do local _234_, _235_ = pcall(require, "fennel") if ((_234_ == true) and ((_G.type(_235_) == "table") and (nil ~= (_235_).view))) then local view_77_auto0 = (_235_).view view_77_auto = view_77_auto0 elseif ((_234_ == false) and true) then local __75_auto = _235_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto local _237_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i_79_auto = 1, select("#", ...) do local val_19_auto = view_77_auto(({...})[i_79_auto]) if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _237_ = tbl_17_auto end msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: [%s]\nHeads:\n%s"), "handler", table.concat(_237_, ", "), table.concat((__fn_2a_handler_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end handler0 = _231_ local function _240_() local _241_ do table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))") local function _242_(...) if (1 == select("#", ...)) then local _243_ = {...} local function _244_(...) local event_227_ = (_243_)[1] return ok_3f(event_227_) end if (((_G.type(_243_) == "table") and (nil ~= (_243_)[1])) and _244_(...)) then local event_227_ = (_243_)[1] local function _245_(event)

 local command, _3fmaybe_latest, _3fmaybe_current = result.unwrap(event) local text






 local function _246_(_241) local _247_ = _3fmaybe_current if (nil ~= _247_) then local commit = _247_
 return fmt("%s, current: %s)", _241, commit) elseif (_247_ == nil) then
 return fmt("%s)", _241) else return nil end end local function _249_(_241) local _250_ = _3fmaybe_latest if (nil ~= _250_) then local commit = _250_ return fmt("%s, latest: %s", _241, commit) elseif (_250_ == nil) then return fmt("%s", _241) else return nil end end local function _253_() local _252_ = command if ((_G.type(_252_) == "table") and ((_252_)[1] == "hold") and (nil ~= (_252_)[2])) then local commit = (_252_)[2] return fmt("(at %s", commit) elseif ((_G.type(_252_) == "table") and (nil ~= (_252_)[1]) and (nil ~= (_252_)[2])) then local action = (_252_)[1] local commit = (_252_)[2] return fmt("(%s %s", action, commit) else return nil end end text = _246_(_249_(_253_()))
 enum["append$"](meta.events, event)
 meta.text = text
 meta.progress = nil
 do local _255_ = command if ((_G.type(_255_) == "table") and ((_255_)[1] == "hold") and (nil ~= (_255_)[2])) then local commit = (_255_)[2] meta.state = "up-to-date" elseif ((_G.type(_255_) == "table") and (nil ~= (_255_)[1]) and (nil ~= (_255_)[2])) then local action = (_255_)[1] local commit = (_255_)[2] meta.state = "unstaged"




 meta.action = {action, commit} else end end
 unsubscribe(wf, handler0)
 return schedule_redraw(ui) end return _245_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _242_) _241_ = handler0 end local _259_ do table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))") local function _260_(...) if (1 == select("#", ...)) then local _261_ = {...} local function _262_(...) local event_228_ = (_261_)[1] return err_3f(event_228_) end if (((_G.type(_261_) == "table") and (nil ~= (_261_)[1])) and _262_(...)) then local event_228_ = (_261_)[1] local function _263_(event) meta.state = "error"




 enum["append$"](meta.events, event)
 meta.progress = nil
 meta.text = result.unwrap(event)
 unsubscribe(wf, handler0)
 return schedule_redraw(ui) end return _263_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _260_) _259_ = handler0 end local _266_ do table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))") local function _267_(...) if (1 == select("#", ...)) then local _268_ = {...} local function _269_(...) local msg_229_ = (_268_)[1] return string_3f(msg_229_) end if (((_G.type(_268_) == "table") and (nil ~= (_268_)[1])) and _269_(...)) then local msg_229_ = (_268_)[1] local function _270_(msg)



 enum["append$"](meta.events, msg)
 meta.progress = nil
 meta.text = msg
 return schedule_redraw(ui) end return _270_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _267_) _266_ = handler0 end local _273_ do table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))") local function _274_(...) if (1 == select("#", ...)) then local _275_ = {...} local function _276_(...) local future_230_ = (_275_)[1] return thread_3f(future_230_) end if (((_G.type(_275_) == "table") and (nil ~= (_275_)[1])) and _276_(...)) then local future_230_ = (_275_)[1] local function _277_(future)



 meta.progress = rate_limited_inc((meta.progress or {0, 0}))
 return schedule_redraw(ui) end return _277_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _274_) _273_ = handler0 end local function _280_() table.insert((__fn_2a_handler_dispatch).help, "(where _)") local function _281_(...) if true then local _282_ = {...} local function _283_(...) return true end if ((_G.type(_282_) == "table") and _283_(...)) then local function _284_(...)


 return nil end return _284_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _281_) return handler0 end do local _ = {_241_, _259_, _266_, _273_, _280_()} end return handler0 end handler = setmetatable({nil, nil}, {__call = _240_})()
 subscribe(wf, handler)
 return wf end
 schedule_redraw(ui)
 local function _287_(_241, _242) return scheduler["add-workflow"](ui.scheduler, make_status_wf(_242)) end return enum.map(_287_, ui.plugins) end


 local function exec_keymap_cc(ui)
 local function _288_(_241, _242) return ("staged" == _242.state) end if enum["any?"](_288_, ui["plugins-meta"]) then
 return exec_commit(ui) else
 return vim.notify("Nothing staged, refusing to commit") end end

 local function exec_keymap_s(ui)
 local _let_290_ = api.nvim_win_get_cursor(ui.win) local line = _let_290_[1] local _ = _let_290_[2] local meta
 local function _291_(_241, _242) return (line == _242["on-line"]) end meta = enum["find-value"](_291_, ui["plugins-meta"])
 if (meta and ("unstaged" == meta.state)) then

 meta["state"] = "staged"
 return schedule_redraw(ui) else
 return vim.notify("May only stage unstaged plugins") end end

 local function exec_keymap_u(ui)
 local _let_293_ = api.nvim_win_get_cursor(ui.win) local line = _let_293_[1] local _ = _let_293_[2] local meta
 local function _294_(_241, _242) return (line == _242["on-line"]) end meta = enum["find-value"](_294_, ui["plugins-meta"])
 if (meta and ("staged" == meta.state)) then

 meta["state"] = "unstaged"
 return schedule_redraw(ui) else
 return vim.notify("May only unstage staged plugins") end end


 local function exec_keymap__3d(ui)
 local _let_296_ = api.nvim_win_get_cursor(ui.win) local line = _let_296_[1] local _ = _let_296_[2] local meta
 local function _297_(_241, _242) return (line == _242["on-line"]) end meta = enum["find-value"](_297_, ui["plugins-meta"])
 if (meta and (("staged" == meta.state) or ("unstaged" == meta.state)) and ("sync" == meta.action[1])) then


 if meta.log then

 meta["log-open"] = not meta["log-open"]
 return schedule_redraw(ui) else
 return exec_diff(ui, meta) end else
 return vim.notify("May only view diff of staged or unstaged sync-able plugins") end end

 M.attach = function(win, buf, plugins, opts)

 local opts0 = (opts or {})
 local function _301_(_241, _242) return result["ok?"](_242), result.unwrap(_242) end local _let_300_ = enum["group-by"](_301_, plugins) local ok_plugins = _let_300_[true] local err_plugins = _let_300_[false]


 if err_plugins then
 local function _302_(lines, _, _242)
 return enum["append$"](lines, fmt("  - %s", _242)) end api.nvim_err_writeln((table.concat(enum.reduce(_302_, {"Some Pact plugins had configuration errors and wont be processed!"}, err_plugins), "\n") .. "\n")) else end







 if ok_plugins then
 local plugins_meta local function _304_(_241, _242) return {_242.id, {events = {}, text = "waiting for scheduler", order = _241, state = "waiting", plugin = _242}} end plugins_meta = enum["pairs->table"](enum.map(_304_, ok_plugins)) local max_name_length






 local function _305_(_241, _242, _243) return math.max(_241, #_243.name) end max_name_length = enum.reduce(_305_, 0, ok_plugins)
 local ui = {plugins = ok_plugins, ["plugins-meta"] = plugins_meta, win = win, buf = buf, ["ns-id"] = api.nvim_create_namespace("pact-ui"), layout = {["max-name-length"] = max_name_length}, scheduler = scheduler.new({["concurrency-limit"] = opts0["concurrency-limit"]}), opts = opts0}







 do api.nvim_buf_set_option(buf, "ft", "pact")


 local function _306_() return exec_keymap__3d(ui) end api.nvim_buf_set_keymap(buf, "n", "=", "", {callback = _306_})
 local function _307_() return exec_keymap_cc(ui) end api.nvim_buf_set_keymap(buf, "n", "cc", "", {callback = _307_})
 local function _308_() return exec_keymap_s(ui) end api.nvim_buf_set_keymap(buf, "n", "s", "", {callback = _308_})
 local function _309_() return exec_keymap_u(ui) end api.nvim_buf_set_keymap(buf, "n", "u", "", {callback = _309_}) end



 exec_orphans(ui)
 exec_status(ui)
 return ui else return nil end end

 return M