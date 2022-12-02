
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local enum, scheduler, _local_17_, result, api, _local_18_, status_wf, clone_wf, sync_wf, diff_wf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil do local _16_ = require("pact.workflow.git.diff") local _15_ = require("pact.workflow.git.sync") local _14_ = require("pact.workflow.git.clone") local _13_ = require("pact.workflow.git.status") local _12_ = string local _11_ = vim.api local _10_ = require("pact.lib.ruin.result") local _9_ = require("pact.pubsub") local _8_ = require("pact.workflow.scheduler") local _7_ = require("pact.lib.ruin.enum") enum, scheduler, _local_17_, result, api, _local_18_, status_wf, clone_wf, sync_wf, diff_wf = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_, _16_ end local _local_19_ = _local_17_

 local subscribe = _local_19_["subscribe"] local unsubscribe = _local_19_["unsubscribe"] local _local_20_ = _local_18_


 local fmt = _local_20_["format"]





 local M = {}

 local function section_title(section_name)
 return (({error = "Error", waiting = "Waiting", active = "Active", held = "Held", updated = "Updated", ["up-to-date"] = "Up to date", unstaged = "Unstaged", staged = "Staged"})[section_name] or section_name) end









 local function highlight_for(section_name, field)

 local joined = table.concat({"pact", section_name, field}, "-")
 local function _21_(_241, _242, _243) return (_241 .. string.upper(_242) .. _243) end
 local function _22_() return string.gmatch(joined, "(%w)([%w]+)") end return enum.reduce(_21_, "", _22_) end

 local function lede()
 return {{{";; \240\159\148\170\240\159\144\144\240\159\169\184", "PactComment"}}, {{"", "PactComment"}}} end


 local function usage()
 return {{{";; usage:", "PactComment"}}, {{";;", "PactComment"}}, {{";;   s  - stage plugin for update", "PactComment"}}, {{";;   u  - unstage plugin", "PactComment"}}, {{";;   cc - commit staging and fetch updates", "PactComment"}}, {{";;   =  - view git log (staged/unstaged only)", "PactComment"}}, {{"", nil}}} end







 local function render_section(ui, section_name, previous_lines)
 local relevant_plugins

 local function _23_(_241, _242) return (_241.order <= _242.order) end local function _24_(_241, _242) return _242 end local function _25_(_241, _242) return (_242.state == section_name) end relevant_plugins = enum["sort$"](_23_, enum.map(_24_, enum.filter(_25_, ui["plugins-meta"]))) local new_lines
 local function _26_(lines, i, meta)
 local name_length = #meta.plugin.name
 local line = {{meta.plugin.name, highlight_for(section_name, "name")}, {string.rep(" ", ((1 + ui.layout["max-name-length"]) - name_length)), nil}, {enum.last(meta.events), highlight_for(section_name, "text")}}



 meta["on-line"] = (2 + #previous_lines + #lines)
 return enum["append$"](lines, line) end new_lines = enum.reduce(_26_, {}, relevant_plugins)

 if (0 < #new_lines) then
 return enum["append$"](enum["concat$"](enum["append$"](previous_lines, {{section_title(section_name), highlight_for(section_name, "title")}, {" ", nil}, {fmt("(%s)", #new_lines), "PactComment"}}), new_lines), {{"", nil}}) else






 return previous_lines end end

 local function log_line_breaking_3f(log_line)

 return not_nil_3f(string.match(string.lower(log_line), "break")) end

 local function log_line__3echunks(log_line)
 local sha, log = string.match(log_line, "(%x+)%s(.+)")



 local function _28_() if log_line_breaking_3f(log) then return "DiagnosticError" else return "DiagnosticHint" end end return {{"  ", "comment"}, {sha, "comment"}, {" ", "comment"}, {log, _28_()}} end

 local function output(ui)
 local sections = {"waiting", "error", "active", "unstaged", "staged", "updated", "held", "up-to-date"} local lines
 local function _29_(lines0, _, section) return render_section(ui, section, lines0) end lines = enum["concat$"](enum.reduce(_29_, lede(), sections), usage()) local lines__3etext_and_extmarks






 local function _34_(_30_, _, _32_) local _arg_31_ = _30_ local str = _arg_31_[1] local extmarks = _arg_31_[2] local _arg_33_ = _32_ local txt = _arg_33_[1] local _3fextmarks = _arg_33_[2]

 local function _35_() if _3fextmarks then
 return enum["append$"](extmarks, {#str, (#str + #txt), _3fextmarks}) else
 return extmarks end end return {(str .. txt), _35_()} end lines__3etext_and_extmarks = enum.reduce(_34_)
 local function _39_(_37_, _, line) local _arg_38_ = _37_ local lines0 = _arg_38_[1] local extmarks = _arg_38_[2]
 local _let_40_ = lines__3etext_and_extmarks({"", {}}, line) local new_lines = _let_40_[1] local new_extmarks = _let_40_[2]
 return {enum["append$"](lines0, new_lines), enum["append$"](extmarks, new_extmarks)} end local _let_36_ = enum.reduce(_39_, {{}, {}}, lines) local text = _let_36_[1] local extmarks = _let_36_[2]


 api.nvim_buf_set_lines(ui.buf, 0, -1, false, text)
 local function _41_(i, line_marks)
 local function _44_(_, _42_) local _arg_43_ = _42_ local start = _arg_43_[1] local stop = _arg_43_[2] local hl = _arg_43_[3]
 return api.nvim_buf_add_highlight(ui.buf, ui["ns-id"], hl, (i - 1), start, stop) end return enum.map(_44_, line_marks) end enum.map(_41_, extmarks)


 local function _45_(_241, _242) if _242["log-open"] then

 local function _46_(_2410, _2420) return log_line__3echunks(_2420) end return api.nvim_buf_set_extmark(ui.buf, ui["ns-id"], (_242["on-line"] - 1), 0, {virt_lines = enum.map(_46_, _242.log)}) else return nil end end return enum.map(_45_, ui["plugins-meta"]) end




 local function exec_commit(ui)
 local function make_wf(how, plugin, commit)
 local wf do local _48_ = how if (_48_ == "clone") then
 wf = clone_wf.new(plugin.id, plugin["package-path"], plugin.source[2], commit.sha) elseif (_48_ == "sync") then
 wf = sync_wf.new(plugin.id, plugin["package-path"], commit.sha) elseif (nil ~= _48_) then local other = _48_
 wf = error(fmt("unknown staging action %s", other)) else wf = nil end end local handler
 local __fn_2a_handler_dispatch = {bodies = {}, help = {}} local handler0 local function _52_(...) if (0 == #(__fn_2a_handler_dispatch).bodies) then error(("multi-arity function " .. "handler" .. " has no bodies")) else end local _54_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _54_ = f_74_auto end if (nil ~= _54_) then local f_74_auto = _54_ return f_74_auto(...) elseif (_54_ == nil) then local view_77_auto do local _55_, _56_ = pcall(require, "fennel") if ((_55_ == true) and ((_G.type(_56_) == "table") and (nil ~= (_56_).view))) then local view_77_auto0 = (_56_).view view_77_auto = view_77_auto0 elseif ((_55_ == false) and true) then local __75_auto = _56_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "handler", view_77_auto({...}), table.concat((__fn_2a_handler_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end handler0 = _52_ local function _59_() local _60_ do table.insert((__fn_2a_handler_dispatch).help, "(where [[\"ok\"]])") local function _61_(...) if (1 == select("#", ...)) then local _62_ = {...} local function _63_(...) return true end if (((_G.type(_62_) == "table") and ((_G.type((_62_)[1]) == "table") and (((_62_)[1])[1] == "ok"))) and _63_(...)) then local function _66_(_64_)
 local _arg_65_ = _64_ local _ = _arg_65_[1]
 local meta = ui["plugins-meta"][plugin.id]
 meta["state"] = "updated"

 local _68_ do local _67_ = how if (_67_ == "clone") then _68_ = "cloned" elseif (_67_ == "sync") then _68_ = "synced" else _68_ = nil end end enum["append$"](meta.events, fmt("(%s %s)", _68_, commit))

 unsubscribe(wf, handler0)
 return output(ui) end return _66_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _61_) _60_ = handler0 end local _74_ do table.insert((__fn_2a_handler_dispatch).help, "(where [[\"err\" e]])") local function _75_(...) if (1 == select("#", ...)) then local _76_ = {...} local function _77_(...) local e_50_ = ((_76_)[1])[2] return true end if (((_G.type(_76_) == "table") and ((_G.type((_76_)[1]) == "table") and (((_76_)[1])[1] == "err") and (nil ~= ((_76_)[1])[2]))) and _77_(...)) then local e_50_ = ((_76_)[1])[2] local function _80_(_78_)

 local _arg_79_ = _78_ local _ = _arg_79_[1] local e = _arg_79_[2]
 local meta = ui["plugins-meta"][plugin.id] meta.state = "error"

 enum["append$"](meta.events, e)
 unsubscribe(wf, handler0)
 return output(ui) end return _80_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _75_) _74_ = handler0 end local _83_ do table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))") local function _84_(...) if (1 == select("#", ...)) then local _85_ = {...} local function _86_(...) local msg_51_ = (_85_)[1] return string_3f(msg_51_) end if (((_G.type(_85_) == "table") and (nil ~= (_85_)[1])) and _86_(...)) then local msg_51_ = (_85_)[1] local function _87_(msg)


 local meta = ui["plugins-meta"][wf.id]
 enum["append$"](meta.events, msg)
 return output(ui) end return _87_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _84_) _83_ = handler0 end local function _90_() table.insert((__fn_2a_handler_dispatch).help, "(where _)") local function _91_(...) if true then local _92_ = {...} local function _93_(...) return true end if ((_G.type(_92_) == "table") and _93_(...)) then local function _94_(...)

 return nil end return _94_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _91_) return handler0 end do local _ = {_60_, _74_, _83_, _90_()} end return handler0 end handler = setmetatable({nil, nil}, {__call = _59_})()
 subscribe(wf, handler)
 return wf end


 local function _97_(_, meta) meta["state"] = "held" return nil end local function _98_(_241, _242) return ("unstaged" == _242.state) end enum.map(_97_, enum.filter(_98_, ui["plugins-meta"]))

 local function _99_(_, meta)
 local wf = make_wf(meta.action[1], meta.plugin, meta.action[2])
 scheduler["add-workflow"](ui.scheduler, wf)
 do end (meta)["state"] = "active" return nil end local function _100_(_241, _242) return ("staged" == _242.state) end enum.map(_99_, enum.filter(_100_, ui["plugins-meta"]))
 return output(ui) end

 local function exec_diff(ui, meta)
 local function make_wf(plugin, commit)
 local wf = diff_wf.new(plugin.id, plugin["package-path"], commit.sha) local handler
 local __fn_2a_handler_dispatch = {bodies = {}, help = {}} local handler0 local function _104_(...) if (0 == #(__fn_2a_handler_dispatch).bodies) then error(("multi-arity function " .. "handler" .. " has no bodies")) else end local _106_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _106_ = f_74_auto end if (nil ~= _106_) then local f_74_auto = _106_ return f_74_auto(...) elseif (_106_ == nil) then local view_77_auto do local _107_, _108_ = pcall(require, "fennel") if ((_107_ == true) and ((_G.type(_108_) == "table") and (nil ~= (_108_).view))) then local view_77_auto0 = (_108_).view view_77_auto = view_77_auto0 elseif ((_107_ == false) and true) then local __75_auto = _108_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "handler", view_77_auto({...}), table.concat((__fn_2a_handler_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end handler0 = _104_ local function _111_() local _112_ do table.insert((__fn_2a_handler_dispatch).help, "(where [[\"ok\" log]])") local function _113_(...) if (1 == select("#", ...)) then local _114_ = {...} local function _115_(...) local log_101_ = ((_114_)[1])[2] return true end if (((_G.type(_114_) == "table") and ((_G.type((_114_)[1]) == "table") and (((_114_)[1])[1] == "ok") and (nil ~= ((_114_)[1])[2]))) and _115_(...)) then local log_101_ = ((_114_)[1])[2] local function _118_(_116_)
 local _arg_117_ = _116_ local _ = _arg_117_[1] local log = _arg_117_[2]
 local meta0 = ui["plugins-meta"][plugin.id]
 meta0["log"] = log
 meta0["log-open"] = true
 unsubscribe(wf, handler0)
 return output(ui) end return _118_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _113_) _112_ = handler0 end local _121_ do table.insert((__fn_2a_handler_dispatch).help, "(where [[\"err\" e]])") local function _122_(...) if (1 == select("#", ...)) then local _123_ = {...} local function _124_(...) local e_102_ = ((_123_)[1])[2] return true end if (((_G.type(_123_) == "table") and ((_G.type((_123_)[1]) == "table") and (((_123_)[1])[1] == "err") and (nil ~= ((_123_)[1])[2]))) and _124_(...)) then local e_102_ = ((_123_)[1])[2] local function _127_(_125_)

 local _arg_126_ = _125_ local _ = _arg_126_[1] local e = _arg_126_[2]
 local meta0 = ui["plugins-meta"][plugin.id]

 enum["append$"](meta0.events, e)
 unsubscribe(wf, handler0)
 return output(ui) end return _127_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _122_) _121_ = handler0 end local _130_ do table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))") local function _131_(...) if (1 == select("#", ...)) then local _132_ = {...} local function _133_(...) local msg_103_ = (_132_)[1] return string_3f(msg_103_) end if (((_G.type(_132_) == "table") and (nil ~= (_132_)[1])) and _133_(...)) then local msg_103_ = (_132_)[1] local function _134_(msg)


 local meta0 = ui["plugins-meta"][wf.id]
 enum["append$"](meta0.events, msg)
 return output(ui) end return _134_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _131_) _130_ = handler0 end local function _137_() table.insert((__fn_2a_handler_dispatch).help, "(where _)") local function _138_(...) if true then local _139_ = {...} local function _140_(...) return true end if ((_G.type(_139_) == "table") and _140_(...)) then local function _141_(...)

 return nil end return _141_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _138_) return handler0 end do local _ = {_112_, _121_, _130_, _137_()} end return handler0 end handler = setmetatable({nil, nil}, {__call = _111_})()
 subscribe(wf, handler)
 return wf end
 do local wf = make_wf(meta.plugin, meta.action[2])
 scheduler["add-workflow"](ui.scheduler, wf) end
 return output(ui) end

 local function exec_keymap_cc(ui)

 return exec_commit(ui) end

 local function exec_keymap_s(ui)
 local _let_144_ = api.nvim_win_get_cursor(ui.win) local line = _let_144_[1] local _ = _let_144_[2] local meta
 local function _145_(_241, _242) return (line == _242["on-line"]) end meta = enum["find-value"](_145_, ui["plugins-meta"])
 if (meta and ("unstaged" == meta.state)) then

 meta["state"] = "staged"
 return output(ui) else
 return vim.notify("May only stage unstaged plugins") end end

 local function exec_keymap_u(ui)
 local _let_147_ = api.nvim_win_get_cursor(ui.win) local line = _let_147_[1] local _ = _let_147_[2] local meta
 local function _148_(_241, _242) return (line == _242["on-line"]) end meta = enum["find-value"](_148_, ui["plugins-meta"])
 if (meta and ("staged" == meta.state)) then

 meta["state"] = "unstaged"
 return output(ui) else
 return vim.notify("May only unstage staged plugins") end end


 local function exec_keymap__3d(ui)
 local _let_150_ = api.nvim_win_get_cursor(ui.win) local line = _let_150_[1] local _ = _let_150_[2] local meta
 local function _151_(_241, _242) return (line == _242["on-line"]) end meta = enum["find-value"](_151_, ui["plugins-meta"])
 if (meta and (("staged" == meta.state) or ("unstaged" == meta.state)) and ("sync" == meta.action[1])) then


 if meta.log then

 meta["log-open"] = not meta["log-open"]
 return output(ui) else
 return exec_diff(ui, meta) end else
 return vim.notify("May only view diff of staged or unstaged sync-able plugins") end end

 local function exec_status(ui)
 local function make_status_wf(plugin)
 local wf = status_wf.new(plugin.id, plugin.source[2], plugin["package-path"], plugin.constraint) local handler



 local __fn_2a_handler_dispatch = {bodies = {}, help = {}} local handler0 local function _159_(...) if (0 == #(__fn_2a_handler_dispatch).bodies) then error(("multi-arity function " .. "handler" .. " has no bodies")) else end local _161_ do local f_74_auto = nil for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do if f_74_auto then break end f_74_auto = match_3f_76_auto(...) end _161_ = f_74_auto end if (nil ~= _161_) then local f_74_auto = _161_ return f_74_auto(...) elseif (_161_ == nil) then local view_77_auto do local _162_, _163_ = pcall(require, "fennel") if ((_162_ == true) and ((_G.type(_163_) == "table") and (nil ~= (_163_).view))) then local view_77_auto0 = (_163_).view view_77_auto = view_77_auto0 elseif ((_162_ == false) and true) then local __75_auto = _163_ view_77_auto = (_G.vim.inspect or print) else view_77_auto = nil end end local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "handler", view_77_auto({...}), table.concat((__fn_2a_handler_dispatch).help, "\n")) return error(msg_78_auto) else return nil end end handler0 = _159_ local function _166_() local _167_ do table.insert((__fn_2a_handler_dispatch).help, "(where [[\"ok\" [\"hold\" commit]]])") local function _168_(...) if (1 == select("#", ...)) then local _169_ = {...} local function _170_(...) local commit_154_ = (((_169_)[1])[2])[2] return true end if (((_G.type(_169_) == "table") and ((_G.type((_169_)[1]) == "table") and (((_169_)[1])[1] == "ok") and ((_G.type(((_169_)[1])[2]) == "table") and ((((_169_)[1])[2])[1] == "hold") and (nil ~= (((_169_)[1])[2])[2])))) and _170_(...)) then local commit_154_ = (((_169_)[1])[2])[2] local function _174_(_171_)
 local _arg_172_ = _171_ local _ = _arg_172_[1] local _arg_173_ = _arg_172_[2] local _0 = _arg_173_[1] local commit = _arg_173_[2]
 local meta = ui["plugins-meta"][plugin.id]
 meta["state"] = "up-to-date"
 enum["append$"](meta.events, fmt("(at %s)", commit))
 unsubscribe(wf, handler0)
 return output(ui) end return _174_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _168_) _167_ = handler0 end local _177_ do table.insert((__fn_2a_handler_dispatch).help, "(where [[\"ok\" [action commit]]])") local function _178_(...) if (1 == select("#", ...)) then local _179_ = {...} local function _180_(...) local action_155_ = (((_179_)[1])[2])[1] local commit_156_ = (((_179_)[1])[2])[2] return true end if (((_G.type(_179_) == "table") and ((_G.type((_179_)[1]) == "table") and (((_179_)[1])[1] == "ok") and ((_G.type(((_179_)[1])[2]) == "table") and (nil ~= (((_179_)[1])[2])[1]) and (nil ~= (((_179_)[1])[2])[2])))) and _180_(...)) then local action_155_ = (((_179_)[1])[2])[1] local commit_156_ = (((_179_)[1])[2])[2] local function _184_(_181_)

 local _arg_182_ = _181_ local _ = _arg_182_[1] local _arg_183_ = _arg_182_[2] local action = _arg_183_[1] local commit = _arg_183_[2]
 local meta = ui["plugins-meta"][plugin.id]
 meta["action"] = {action, commit}
 meta["state"] = "unstaged"
 enum["append$"](meta.events, fmt("(%s %s)", action, commit))
 unsubscribe(wf, handler0)
 return output(ui) end return _184_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _178_) _177_ = handler0 end local _187_ do table.insert((__fn_2a_handler_dispatch).help, "(where [[\"err\" e]])") local function _188_(...) if (1 == select("#", ...)) then local _189_ = {...} local function _190_(...) local e_157_ = ((_189_)[1])[2] return true end if (((_G.type(_189_) == "table") and ((_G.type((_189_)[1]) == "table") and (((_189_)[1])[1] == "err") and (nil ~= ((_189_)[1])[2]))) and _190_(...)) then local e_157_ = ((_189_)[1])[2] local function _193_(_191_)

 local _arg_192_ = _191_ local _ = _arg_192_[1] local e = _arg_192_[2]
 local meta = ui["plugins-meta"][plugin.id] meta.state = "error"

 enum["append$"](meta.events, e)
 unsubscribe(wf, handler0)
 return output(ui) end return _193_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _188_) _187_ = handler0 end local _196_ do table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))") local function _197_(...) if (1 == select("#", ...)) then local _198_ = {...} local function _199_(...) local msg_158_ = (_198_)[1] return string_3f(msg_158_) end if (((_G.type(_198_) == "table") and (nil ~= (_198_)[1])) and _199_(...)) then local msg_158_ = (_198_)[1] local function _200_(msg)


 local meta = ui["plugins-meta"][wf.id]
 enum["append$"](meta.events, msg)
 return output(ui) end return _200_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _197_) _196_ = handler0 end local function _203_() table.insert((__fn_2a_handler_dispatch).help, "(where _)") local function _204_(...) if true then local _205_ = {...} local function _206_(...) return true end if ((_G.type(_205_) == "table") and _206_(...)) then local function _207_(...)

 return nil end return _207_ else return nil end else return nil end end table.insert((__fn_2a_handler_dispatch).bodies, _204_) return handler0 end do local _ = {_167_, _177_, _187_, _196_, _203_()} end return handler0 end handler = setmetatable({nil, nil}, {__call = _166_})()
 subscribe(wf, handler)
 return wf end
 output(ui)
 local function _210_(_, plugin)
 return scheduler["add-workflow"](ui.scheduler, make_status_wf(plugin)) end return enum.map(_210_, ui.plugins) end


 M.attach = function(win, buf, plugins)

 local function _212_(_241, _242) return result["ok?"](_242), result.unwrap(_242) end local _let_211_ = enum["group-by"](_212_, plugins) local ok_plugins = _let_211_[true] local err_plugins = _let_211_[false]


 if err_plugins then
 local function _213_(lines, _, _242)
 return enum["append$"](lines, fmt("  - %s", _242)) end api.nvim_err_writeln((table.concat(enum.reduce(_213_, {"Some Pact plugins had configuration errors and wont be processed!"}, err_plugins), "\n") .. "\n")) else end







 if ok_plugins then
 local plugins_meta local function _215_(_241, _242) return {_242.id, {events = {"waiting for scheduler"}, order = _241, state = "waiting", actions = {}, action = nil, plugin = _242}} end plugins_meta = enum["pairs->table"](enum.map(_215_, ok_plugins)) local max_name_length







 local function _216_(_241, _242, _243) return math.max(_241, #_243.name) end max_name_length = enum.reduce(_216_, 0, ok_plugins)
 local ui = {plugins = ok_plugins, ["plugins-meta"] = plugins_meta, win = win, buf = buf, ["ns-id"] = api.nvim_create_namespace("pact-ui"), layout = {["max-name-length"] = max_name_length}, scheduler = scheduler.new()}






 do api.nvim_buf_set_option(buf, "ft", "pact")


 local function _217_() return exec_keymap__3d(ui) end api.nvim_buf_set_keymap(buf, "n", "=", "", {callback = _217_})
 local function _218_() return exec_keymap_cc(ui) end api.nvim_buf_set_keymap(buf, "n", "cc", "", {callback = _218_})
 local function _219_() return exec_keymap_s(ui) end api.nvim_buf_set_keymap(buf, "n", "s", "", {callback = _219_})
 local function _220_() return exec_keymap_u(ui) end api.nvim_buf_set_keymap(buf, "n", "u", "", {callback = _220_}) end



 exec_status(ui)
 return ui else return nil end end

 return M