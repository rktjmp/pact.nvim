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
local enum, inspect, scheduler, _local_21_, _local_22_, result, api, _local_23_, orphan_find_wf, orphan_remove_fw, status_wf, clone_wf, sync_wf, diff_wf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
do
  local _20_ = require("pact.workflow.git.diff")
  local _19_ = require("pact.workflow.git.sync")
  local _18_ = require("pact.workflow.git.clone")
  local _17_ = require("pact.workflow.git.status")
  local _16_ = require("pact.workflow.orphan.remove")
  local _15_ = require("pact.workflow.orphan.find")
  local _14_ = string
  local _13_ = vim.api
  local _12_ = require("pact.lib.ruin.result")
  local _11_ = require("pact.lib.ruin.result")
  local _10_ = require("pact.pubsub")
  local _9_ = require("pact.workflow.scheduler")
  local _8_ = require("pact.inspect")
  local _7_ = require("pact.lib.ruin.enum")
  enum, inspect, scheduler, _local_21_, _local_22_, result, api, _local_23_, orphan_find_wf, orphan_remove_fw, status_wf, clone_wf, sync_wf, diff_wf = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_, _16_, _17_, _18_, _19_, _20_
end
local _local_24_ = _local_21_
local subscribe = _local_24_["subscribe"]
local unsubscribe = _local_24_["unsubscribe"]
local _local_25_ = _local_22_
local err_3f = _local_25_["err?"]
local ok_3f = _local_25_["ok?"]
local _local_26_ = _local_23_
local fmt = _local_26_["format"]
local M = {}
local function section_title(section_name)
  return (({error = "Error", waiting = "Waiting", active = "Active", held = "Held", updated = "Updated", ["up-to-date"] = "Up to date", unstaged = "Unstaged", staged = "Staged"})[section_name] or section_name)
end
local function highlight_for(section_name, field)
  local joined = table.concat({"pact", section_name, field}, "-")
  local function _27_(_241, _242, _243)
    return (_241 .. string.upper(_242) .. _243)
  end
  local function _28_()
    return string.gmatch(joined, "(%w)([%w]+)")
  end
  return enum.reduce(_27_, "", _28_)
end
local function lede()
  return {{{";; \240\159\148\170\240\159\169\184\240\159\144\144", "PactComment"}}, {{"", "PactComment"}}}
end
local function usage()
  return {{{";; usage:", "PactComment"}}, {{";;", "PactComment"}}, {{";;   s  - stage plugin for update", "PactComment"}}, {{";;   u  - unstage plugin", "PactComment"}}, {{";;   cc - commit staging and fetch updates", "PactComment"}}, {{";;   =  - view git log (staged/unstaged only)", "PactComment"}}, {{"", nil}}}
end
local function rate_limited_inc(_29_)
  local _arg_30_ = _29_
  local t = _arg_30_[1]
  local n = _arg_30_[2]
  local every_n_ms = (1000 / 6)
  local now = vim.loop.now()
  if (every_n_ms < (now - t)) then
    return {now, (n + 1)}
  else
    return {t, n}
  end
end
local function progress_symbol(progress)
  local _32_ = progress
  if (_32_ == nil) then
    return ""
  elseif ((_G.type(_32_) == "table") and true and (nil ~= (_32_)[2])) then
    local _ = (_32_)[1]
    local n = (_32_)[2]
    local symbols = {"\226\151\144", "\226\151\147", "\226\151\145", "\226\151\146"}
    return symbols[(1 + (n % #symbols))]
  else
    return nil
  end
end
local function render_section(ui, section_name, previous_lines)
  local relevant_plugins
  local function _34_(_241, _242)
    return (_241.order <= _242.order)
  end
  local function _35_(_241, _242)
    return _242
  end
  local function _36_(_241, _242)
    return (_242.state == section_name)
  end
  relevant_plugins = enum["sort$"](_34_, enum.map(_35_, enum.filter(_36_, ui["plugins-meta"])))
  local new_lines
  local function _37_(lines, i, meta)
    local name_length = #meta.plugin.name
    local line = {{meta.plugin.name, highlight_for(section_name, "name")}, {string.rep(" ", ((1 + ui.layout["max-name-length"]) - name_length)), nil}, {((meta.text or "did-not-set-text") .. progress_symbol(meta.progress)), highlight_for(section_name, "text")}}
    meta["on-line"] = (2 + #previous_lines + #lines)
    return enum["append$"](lines, line)
  end
  new_lines = enum.reduce(_37_, {}, relevant_plugins)
  if (0 < #new_lines) then
    return enum["append$"](enum["concat$"](enum["append$"](previous_lines, {{section_title(section_name), highlight_for(section_name, "title")}, {" ", nil}, {fmt("(%s)", #new_lines), "PactComment"}}), new_lines), {{"", nil}})
  else
    return previous_lines
  end
end
local function log_line_breaking_3f(log_line)
  return not_nil_3f(string.match(string.lower(log_line), "break"))
end
local function log_line__3echunks(log_line)
  local sha, log = string.match(log_line, "(%x+)%s(.+)")
  local function _39_()
    if log_line_breaking_3f(log) then
      return "DiagnosticError"
    else
      return "DiagnosticHint"
    end
  end
  return {{"  ", "comment"}, {sha, "comment"}, {" ", "comment"}, {log, _39_()}}
end
local function output(ui)
  do
    local sections = {"waiting", "error", "active", "unstaged", "staged", "updated", "held", "up-to-date"}
    local lines
    local function _40_(lines0, _, section)
      return render_section(ui, section, lines0)
    end
    lines = enum["concat$"](enum.reduce(_40_, lede(), sections), usage())
    local lines__3etext_and_extmarks
    local function _45_(_41_, _, _43_)
      local _arg_42_ = _41_
      local str = _arg_42_[1]
      local extmarks = _arg_42_[2]
      local _arg_44_ = _43_
      local txt = _arg_44_[1]
      local _3fextmarks = _arg_44_[2]
      local function _46_()
        if _3fextmarks then
          return enum["append$"](extmarks, {#str, (#str + #txt), _3fextmarks})
        else
          return extmarks
        end
      end
      return {(str .. txt), _46_()}
    end
    lines__3etext_and_extmarks = enum.reduce(_45_)
    local function _50_(_48_, _, line)
      local _arg_49_ = _48_
      local lines0 = _arg_49_[1]
      local extmarks = _arg_49_[2]
      local _let_51_ = lines__3etext_and_extmarks({"", {}}, line)
      local new_lines = _let_51_[1]
      local new_extmarks = _let_51_[2]
      return {enum["append$"](lines0, new_lines), enum["append$"](extmarks, new_extmarks)}
    end
    local _let_47_ = enum.reduce(_50_, {{}, {}}, lines)
    local text = _let_47_[1]
    local extmarks = _let_47_[2]
    local function _52_(_241, _242)
      return string.match(_242, "\n")
    end
    if enum["any?"](_52_, text) then
      print("pact.ui text had unexpected new lines")
      print(vim.inspect(text))
    else
    end
    api.nvim_buf_set_lines(ui.buf, 0, -1, false, text)
    local function _54_(i, line_marks)
      local function _57_(_, _55_)
        local _arg_56_ = _55_
        local start = _arg_56_[1]
        local stop = _arg_56_[2]
        local hl = _arg_56_[3]
        return api.nvim_buf_add_highlight(ui.buf, ui["ns-id"], hl, (i - 1), start, stop)
      end
      return enum.map(_57_, line_marks)
    end
    enum.map(_54_, extmarks)
    local function _58_(_241, _242)
      if _242["log-open"] then
        local function _59_(_2410, _2420)
          return log_line__3echunks(_2420)
        end
        return api.nvim_buf_set_extmark(ui.buf, ui["ns-id"], (_242["on-line"] - 1), 0, {virt_lines = enum.map(_59_, _242.log)})
      else
        return nil
      end
    end
    enum.map(_58_, ui["plugins-meta"])
  end
  vim.cmd.redraw()
  do end (ui)["will-render"] = false
  return nil
end
local function schedule_redraw(ui)
  if not ui["will-render"] then
    ui["will-render"] = true
    local function _61_()
      return output(ui)
    end
    return vim.schedule(_61_)
  else
    return nil
  end
end
local function exec_commit(ui)
  local function make_wf(how, plugin, action_data)
    local wf
    do
      local _63_ = how
      if (_63_ == "clone") then
        wf = clone_wf.new(plugin.id, plugin["package-path"], plugin.source[2], action_data.sha)
      elseif (_63_ == "sync") then
        wf = sync_wf.new(plugin.id, plugin["package-path"], action_data.sha)
      elseif (_63_ == "clean") then
        wf = orphan_remove_fw.new(plugin.id, action_data)
      elseif (nil ~= _63_) then
        local other = _63_
        wf = error(fmt("unknown staging action %s", other))
      else
        wf = nil
      end
    end
    local meta = ui["plugins-meta"][plugin.id]
    local handler
    local __fn_2a_handler_dispatch = {bodies = {}, help = {}}
    local handler0
    local function _69_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _71_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _71_ = f_74_auto
      end
      if (nil ~= _71_) then
        local f_74_auto = _71_
        return f_74_auto(...)
      elseif (_71_ == nil) then
        local view_77_auto
        do
          local _72_, _73_ = pcall(require, "fennel")
          if ((_72_ == true) and ((_G.type(_73_) == "table") and (nil ~= (_73_).view))) then
            local view_77_auto0 = (_73_).view
            view_77_auto = view_77_auto0
          elseif ((_72_ == false) and true) then
            local __75_auto = _73_
            view_77_auto = (_G.vim.inspect or print)
          else
            view_77_auto = nil
          end
        end
        local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "handler", view_77_auto({...}), table.concat((__fn_2a_handler_dispatch).help, "\n"))
        return error(msg_78_auto)
      else
        return nil
      end
    end
    handler0 = _69_
    local function _76_()
      local _77_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _78_(...)
          if (1 == select("#", ...)) then
            local _79_ = {...}
            local function _80_(...)
              local event_65_ = (_79_)[1]
              return ok_3f(event_65_)
            end
            if (((_G.type(_79_) == "table") and (nil ~= (_79_)[1])) and _80_(...)) then
              local event_65_ = (_79_)[1]
              local function _81_(event)
                enum["append$"](meta.events, event)
                meta.state = "updated"
                local _83_
                do
                  local _82_ = how
                  if (_82_ == "clone") then
                    _83_ = "cloned"
                  elseif (_82_ == "sync") then
                    _83_ = "synced"
                  elseif (_82_ == "clean") then
                    _83_ = "cleaned"
                  elseif true then
                    local _ = _82_
                    _83_ = how
                  else
                    _83_ = nil
                  end
                end
                meta.text = fmt("(%s %s)", _83_, action_data)
                meta.progress = nil
                local function _89_()
                  vim.cmd("packloadall!")
                  return vim.cmd("silent! helptags ALL")
                end
                vim.schedule(_89_)
                if plugin.after then
                  local _let_90_ = require("pact.workflow.after")
                  local new = _let_90_["new"]
                  local old_text = meta.text
                  local after_wf = new(wf.id, plugin.after, plugin["package-path"])
                  meta.text = "running..."
                  local function _91_(event0)
                    local _92_ = event0
                    local function _93_()
                      local _ = _92_
                      return ok_3f(event0)
                    end
                    if (true and _93_()) then
                      local _ = _92_
                      meta.text = fmt("%s after: %s", old_text, (result.unwrap(event0) or "finished with no value"))
                      meta.progress = nil
                      unsubscribe(after_wf, handler0)
                      return schedule_redraw(ui)
                    else
                      local function _94_()
                        local _ = _92_
                        return err_3f(event0)
                      end
                      if (true and _94_()) then
                        local _ = _92_
                        meta.text = (old_text .. fmt(" error: %s", inspect(result.unwrap(event0))))
                        meta.progress = nil
                        unsubscribe(after_wf, handler0)
                        return schedule_redraw(ui)
                      else
                        local function _95_()
                          local _ = _92_
                          return string_3f(event0)
                        end
                        if (true and _95_()) then
                          local _ = _92_
                          return handler0(fmt("after: %s", event0))
                        else
                          local function _96_()
                            local _ = _92_
                            return thread_3f(event0)
                          end
                          if (true and _96_()) then
                            local _ = _92_
                            return handler0(event0)
                          else
                            return nil
                          end
                        end
                      end
                    end
                  end
                  subscribe(after_wf, _91_)
                  scheduler["add-workflow"](ui.scheduler, after_wf)
                else
                end
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _81_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _78_)
        _77_ = handler0
      end
      local _101_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _102_(...)
          if (1 == select("#", ...)) then
            local _103_ = {...}
            local function _104_(...)
              local event_66_ = (_103_)[1]
              return err_3f(event_66_)
            end
            if (((_G.type(_103_) == "table") and (nil ~= (_103_)[1])) and _104_(...)) then
              local event_66_ = (_103_)[1]
              local function _105_(event)
                local _let_106_ = event
                local _ = _let_106_[1]
                local e = _let_106_[2]
                enum["append$"](meta.events, event)
                meta.state = "error"
                meta.text = e
                meta.progress = nil
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _105_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _102_)
        _101_ = handler0
      end
      local _109_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _110_(...)
          if (1 == select("#", ...)) then
            local _111_ = {...}
            local function _112_(...)
              local msg_67_ = (_111_)[1]
              return string_3f(msg_67_)
            end
            if (((_G.type(_111_) == "table") and (nil ~= (_111_)[1])) and _112_(...)) then
              local msg_67_ = (_111_)[1]
              local function _113_(msg)
                enum["append$"](meta.events, msg)
                meta.text = msg
                meta.progress = nil
                return schedule_redraw(ui)
              end
              return _113_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _110_)
        _109_ = handler0
      end
      local _116_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _117_(...)
          if (1 == select("#", ...)) then
            local _118_ = {...}
            local function _119_(...)
              local future_68_ = (_118_)[1]
              return thread_3f(future_68_)
            end
            if (((_G.type(_118_) == "table") and (nil ~= (_118_)[1])) and _119_(...)) then
              local future_68_ = (_118_)[1]
              local function _120_(future)
                meta.progress = rate_limited_inc((meta.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _120_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _117_)
        _116_ = handler0
      end
      local function _123_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _124_(...)
          if true then
            local _125_ = {...}
            local function _126_(...)
              return true
            end
            if ((_G.type(_125_) == "table") and _126_(...)) then
              local function _127_(...)
                return nil
              end
              return _127_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _124_)
        return handler0
      end
      do local _ = {_77_, _101_, _109_, _116_, _123_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _76_})()
    subscribe(wf, handler)
    return wf
  end
  local function _130_(_, meta)
    meta["state"] = "held"
    return nil
  end
  local function _131_(_241, _242)
    return ("unstaged" == _242.state)
  end
  enum.map(_130_, enum.filter(_131_, ui["plugins-meta"]))
  local function _132_(_, meta)
    local wf = make_wf(meta.action[1], meta.plugin, meta.action[2])
    scheduler["add-workflow"](ui.scheduler, wf)
    do end (meta)["state"] = "active"
    return nil
  end
  local function _133_(_241, _242)
    return ("staged" == _242.state)
  end
  enum.map(_132_, enum.filter(_133_, ui["plugins-meta"]))
  return schedule_redraw(ui)
end
local function exec_diff(ui, meta)
  local function make_wf(plugin, commit)
    local wf = diff_wf.new(plugin.id, plugin["package-path"], commit.sha)
    local previous_text = meta.text
    local meta0 = ui["plugins-meta"][plugin.id]
    local handler
    local __fn_2a_handler_dispatch = {bodies = {}, help = {}}
    local handler0
    local function _138_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _140_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _140_ = f_74_auto
      end
      if (nil ~= _140_) then
        local f_74_auto = _140_
        return f_74_auto(...)
      elseif (_140_ == nil) then
        local view_77_auto
        do
          local _141_, _142_ = pcall(require, "fennel")
          if ((_141_ == true) and ((_G.type(_142_) == "table") and (nil ~= (_142_).view))) then
            local view_77_auto0 = (_142_).view
            view_77_auto = view_77_auto0
          elseif ((_141_ == false) and true) then
            local __75_auto = _142_
            view_77_auto = (_G.vim.inspect or print)
          else
            view_77_auto = nil
          end
        end
        local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "handler", view_77_auto({...}), table.concat((__fn_2a_handler_dispatch).help, "\n"))
        return error(msg_78_auto)
      else
        return nil
      end
    end
    handler0 = _138_
    local function _145_()
      local _146_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _147_(...)
          if (1 == select("#", ...)) then
            local _148_ = {...}
            local function _149_(...)
              local event_134_ = (_148_)[1]
              return ok_3f(event_134_)
            end
            if (((_G.type(_148_) == "table") and (nil ~= (_148_)[1])) and _149_(...)) then
              local event_134_ = (_148_)[1]
              local function _150_(event)
                local _let_151_ = event
                local _ = _let_151_[1]
                local log = _let_151_[2]
                enum["append$"](meta0.events, event)
                meta0.text = previous_text
                meta0.progress = nil
                meta0.log = log
                meta0["log-open"] = true
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _150_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _147_)
        _146_ = handler0
      end
      local _154_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _155_(...)
          if (1 == select("#", ...)) then
            local _156_ = {...}
            local function _157_(...)
              local event_135_ = (_156_)[1]
              return err_3f(event_135_)
            end
            if (((_G.type(_156_) == "table") and (nil ~= (_156_)[1])) and _157_(...)) then
              local event_135_ = (_156_)[1]
              local function _158_(event)
                local _let_159_ = event
                local _ = _let_159_[1]
                local e = _let_159_[2]
                enum["append$"](meta0.events, event)
                meta0.text = e
                meta0.progress = nil
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _158_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _155_)
        _154_ = handler0
      end
      local _162_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _163_(...)
          if (1 == select("#", ...)) then
            local _164_ = {...}
            local function _165_(...)
              local msg_136_ = (_164_)[1]
              return string_3f(msg_136_)
            end
            if (((_G.type(_164_) == "table") and (nil ~= (_164_)[1])) and _165_(...)) then
              local msg_136_ = (_164_)[1]
              local function _166_(msg)
                local meta1 = ui["plugins-meta"][wf.id]
                enum["append$"](meta1.events, msg)
                do end (meta1)["text"] = msg
                return schedule_redraw(ui)
              end
              return _166_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _163_)
        _162_ = handler0
      end
      local _169_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _170_(...)
          if (1 == select("#", ...)) then
            local _171_ = {...}
            local function _172_(...)
              local future_137_ = (_171_)[1]
              return thread_3f(future_137_)
            end
            if (((_G.type(_171_) == "table") and (nil ~= (_171_)[1])) and _172_(...)) then
              local future_137_ = (_171_)[1]
              local function _173_(future)
                meta0.progress = rate_limited_inc((meta0.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _173_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _170_)
        _169_ = handler0
      end
      local function _176_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _177_(...)
          if true then
            local _178_ = {...}
            local function _179_(...)
              return true
            end
            if ((_G.type(_178_) == "table") and _179_(...)) then
              local function _180_(...)
                return nil
              end
              return _180_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _177_)
        return handler0
      end
      do local _ = {_146_, _154_, _162_, _169_, _176_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _145_})()
    subscribe(wf, handler)
    return wf
  end
  do
    local wf = make_wf(meta.plugin, meta.action[2])
    scheduler["add-workflow"](ui.scheduler, wf)
  end
  return schedule_redraw(ui)
end
local function exec_orphans(ui, meta)
  local start_root = (vim.fn.stdpath("data") .. "/site/pack/pact/start")
  local opt_root = (vim.fn.stdpath("data") .. "/site/pack/pact/opt")
  local known_paths
  local function _183_(_241, _242)
    return _242["package-path"]
  end
  known_paths = enum.map(_183_, ui.plugins)
  local function make_wf(id, root)
    local wf = orphan_find_wf.new(id, root, known_paths)
    local handler
    local __fn_2a_handler_dispatch = {bodies = {}, help = {}}
    local handler0
    local function _186_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _188_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _188_ = f_74_auto
      end
      if (nil ~= _188_) then
        local f_74_auto = _188_
        return f_74_auto(...)
      elseif (_188_ == nil) then
        local view_77_auto
        do
          local _189_, _190_ = pcall(require, "fennel")
          if ((_189_ == true) and ((_G.type(_190_) == "table") and (nil ~= (_190_).view))) then
            local view_77_auto0 = (_190_).view
            view_77_auto = view_77_auto0
          elseif ((_189_ == false) and true) then
            local __75_auto = _190_
            view_77_auto = (_G.vim.inspect or print)
          else
            view_77_auto = nil
          end
        end
        local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "handler", view_77_auto({...}), table.concat((__fn_2a_handler_dispatch).help, "\n"))
        return error(msg_78_auto)
      else
        return nil
      end
    end
    handler0 = _186_
    local function _193_()
      local _194_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _195_(...)
          if (1 == select("#", ...)) then
            local _196_ = {...}
            local function _197_(...)
              local event_184_ = (_196_)[1]
              return ok_3f(event_184_)
            end
            if (((_G.type(_196_) == "table") and (nil ~= (_196_)[1])) and _197_(...)) then
              local event_184_ = (_196_)[1]
              local function _198_(event)
                do
                  local _199_ = result.unwrap(event)
                  local function _200_()
                    local list = _199_
                    return not enum["empty?"](list)
                  end
                  if ((nil ~= _199_) and _200_()) then
                    local list = _199_
                    local function _201_(_241, _242)
                      local plugin_id = fmt("orphan-%s", _241)
                      local name = fmt("%s/%s", id, _242.name)
                      local len = #name
                      ui["plugins-meta"][plugin_id] = {plugin = {id = plugin_id, name = name}, order = (-1 * _241), events = {}, text = "(orphan) exists on disk but unknown to pact!", action = {"clean", _242.path}, state = "unstaged"}
                      if (ui.layout["max-name-length"] < len) then
                        ui.layout["max-name-length"] = len
                        return nil
                      else
                        return nil
                      end
                    end
                    enum.each(_201_, list)
                  else
                  end
                end
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _198_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _195_)
        _194_ = handler0
      end
      local _206_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _207_(...)
          if (1 == select("#", ...)) then
            local _208_ = {...}
            local function _209_(...)
              local event_185_ = (_208_)[1]
              return err_3f(event_185_)
            end
            if (((_G.type(_208_) == "table") and (nil ~= (_208_)[1])) and _209_(...)) then
              local event_185_ = (_208_)[1]
              local function _210_(event)
                vim.notify(fmt("error checking for orphans, please report: %s", result.unwrap(event)))
                return unsubscribe(wf, handler0)
              end
              return _210_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _207_)
        _206_ = handler0
      end
      local function _213_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _214_(...)
          if true then
            local _215_ = {...}
            local function _216_(...)
              return true
            end
            if ((_G.type(_215_) == "table") and _216_(...)) then
              local function _217_(...)
                return nil
              end
              return _217_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _214_)
        return handler0
      end
      do local _ = {_194_, _206_, _213_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _193_})()
    subscribe(wf, handler)
    return wf
  end
  local function _220_(_241, _242)
    return scheduler["add-workflow"](ui.scheduler, make_wf(_241, _242))
  end
  return enum.map(_220_, {start = start_root, opt = opt_root})
end
local function exec_status(ui)
  local function make_status_wf(plugin)
    local wf = status_wf.new(plugin.id, plugin.source[2], plugin["package-path"], plugin.constraint)
    local meta = ui["plugins-meta"][plugin.id]
    local handler
    local __fn_2a_handler_dispatch = {bodies = {}, help = {}}
    local handler0
    local function _225_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _227_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _227_ = f_74_auto
      end
      if (nil ~= _227_) then
        local f_74_auto = _227_
        return f_74_auto(...)
      elseif (_227_ == nil) then
        local view_77_auto
        do
          local _228_, _229_ = pcall(require, "fennel")
          if ((_228_ == true) and ((_G.type(_229_) == "table") and (nil ~= (_229_).view))) then
            local view_77_auto0 = (_229_).view
            view_77_auto = view_77_auto0
          elseif ((_228_ == false) and true) then
            local __75_auto = _229_
            view_77_auto = (_G.vim.inspect or print)
          else
            view_77_auto = nil
          end
        end
        local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "handler", view_77_auto({...}), table.concat((__fn_2a_handler_dispatch).help, "\n"))
        return error(msg_78_auto)
      else
        return nil
      end
    end
    handler0 = _225_
    local function _232_()
      local _233_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _234_(...)
          if (1 == select("#", ...)) then
            local _235_ = {...}
            local function _236_(...)
              local event_221_ = (_235_)[1]
              return ok_3f(event_221_)
            end
            if (((_G.type(_235_) == "table") and (nil ~= (_235_)[1])) and _236_(...)) then
              local event_221_ = (_235_)[1]
              local function _237_(event)
                local command, _3fmaybe_latest, _3fmaybe_current = result.unwrap(event)
                local text
                local function _238_(_241)
                  local _239_ = _3fmaybe_current
                  if (nil ~= _239_) then
                    local commit = _239_
                    return fmt("%s, current: %s)", _241, commit)
                  elseif (_239_ == nil) then
                    return fmt("%s)", _241)
                  else
                    return nil
                  end
                end
                local function _241_(_241)
                  local _242_ = _3fmaybe_latest
                  if (nil ~= _242_) then
                    local commit = _242_
                    return fmt("%s, latest: %s", _241, commit)
                  elseif (_242_ == nil) then
                    return fmt("%s", _241)
                  else
                    return nil
                  end
                end
                local function _245_()
                  local _244_ = command
                  if ((_G.type(_244_) == "table") and ((_244_)[1] == "hold") and (nil ~= (_244_)[2])) then
                    local commit = (_244_)[2]
                    return fmt("(at %s", commit)
                  elseif ((_G.type(_244_) == "table") and (nil ~= (_244_)[1]) and (nil ~= (_244_)[2])) then
                    local action = (_244_)[1]
                    local commit = (_244_)[2]
                    return fmt("(%s %s", action, commit)
                  else
                    return nil
                  end
                end
                text = _238_(_241_(_245_()))
                enum["append$"](meta.events, event)
                meta.text = text
                meta.progress = nil
                do
                  local _247_ = command
                  if ((_G.type(_247_) == "table") and ((_247_)[1] == "hold") and (nil ~= (_247_)[2])) then
                    local commit = (_247_)[2]
                    meta.state = "up-to-date"
                  elseif ((_G.type(_247_) == "table") and (nil ~= (_247_)[1]) and (nil ~= (_247_)[2])) then
                    local action = (_247_)[1]
                    local commit = (_247_)[2]
                    meta.state = "unstaged"
                    meta.action = {action, commit}
                  else
                  end
                end
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _237_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _234_)
        _233_ = handler0
      end
      local _251_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _252_(...)
          if (1 == select("#", ...)) then
            local _253_ = {...}
            local function _254_(...)
              local event_222_ = (_253_)[1]
              return err_3f(event_222_)
            end
            if (((_G.type(_253_) == "table") and (nil ~= (_253_)[1])) and _254_(...)) then
              local event_222_ = (_253_)[1]
              local function _255_(event)
                meta.state = "error"
                enum["append$"](meta.events, event)
                meta.progress = nil
                meta.text = result.unwrap(event)
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _255_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _252_)
        _251_ = handler0
      end
      local _258_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _259_(...)
          if (1 == select("#", ...)) then
            local _260_ = {...}
            local function _261_(...)
              local msg_223_ = (_260_)[1]
              return string_3f(msg_223_)
            end
            if (((_G.type(_260_) == "table") and (nil ~= (_260_)[1])) and _261_(...)) then
              local msg_223_ = (_260_)[1]
              local function _262_(msg)
                enum["append$"](meta.events, msg)
                meta.progress = nil
                meta.text = msg
                return schedule_redraw(ui)
              end
              return _262_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _259_)
        _258_ = handler0
      end
      local _265_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _266_(...)
          if (1 == select("#", ...)) then
            local _267_ = {...}
            local function _268_(...)
              local future_224_ = (_267_)[1]
              return thread_3f(future_224_)
            end
            if (((_G.type(_267_) == "table") and (nil ~= (_267_)[1])) and _268_(...)) then
              local future_224_ = (_267_)[1]
              local function _269_(future)
                meta.progress = rate_limited_inc((meta.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _269_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _266_)
        _265_ = handler0
      end
      local function _272_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _273_(...)
          if true then
            local _274_ = {...}
            local function _275_(...)
              return true
            end
            if ((_G.type(_274_) == "table") and _275_(...)) then
              local function _276_(...)
                return nil
              end
              return _276_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _273_)
        return handler0
      end
      do local _ = {_233_, _251_, _258_, _265_, _272_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _232_})()
    subscribe(wf, handler)
    return wf
  end
  schedule_redraw(ui)
  local function _279_(_, plugin)
    return scheduler["add-workflow"](ui.scheduler, make_status_wf(plugin))
  end
  return enum.map(_279_, ui.plugins)
end
local function exec_keymap_cc(ui)
  local function _280_(_241, _242)
    return ("staged" == _242.state)
  end
  if enum["any?"](_280_, ui["plugins-meta"]) then
    return exec_commit(ui)
  else
    return vim.notify("Nothing staged, refusing to commit")
  end
end
local function exec_keymap_s(ui)
  local _let_282_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_282_[1]
  local _ = _let_282_[2]
  local meta
  local function _283_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_283_, ui["plugins-meta"])
  if (meta and ("unstaged" == meta.state)) then
    meta["state"] = "staged"
    return schedule_redraw(ui)
  else
    return vim.notify("May only stage unstaged plugins")
  end
end
local function exec_keymap_u(ui)
  local _let_285_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_285_[1]
  local _ = _let_285_[2]
  local meta
  local function _286_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_286_, ui["plugins-meta"])
  if (meta and ("staged" == meta.state)) then
    meta["state"] = "unstaged"
    return schedule_redraw(ui)
  else
    return vim.notify("May only unstage staged plugins")
  end
end
local function exec_keymap__3d(ui)
  local _let_288_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_288_[1]
  local _ = _let_288_[2]
  local meta
  local function _289_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_289_, ui["plugins-meta"])
  if (meta and (("staged" == meta.state) or ("unstaged" == meta.state)) and ("sync" == meta.action[1])) then
    if meta.log then
      meta["log-open"] = not meta["log-open"]
      return schedule_redraw(ui)
    else
      return exec_diff(ui, meta)
    end
  else
    return vim.notify("May only view diff of staged or unstaged sync-able plugins")
  end
end
M.attach = function(win, buf, plugins, opts)
  local opts0 = (opts or {})
  local function _293_(_241, _242)
    return result["ok?"](_242), result.unwrap(_242)
  end
  local _let_292_ = enum["group-by"](_293_, plugins)
  local ok_plugins = _let_292_[true]
  local err_plugins = _let_292_[false]
  if err_plugins then
    local function _294_(lines, _, _242)
      return enum["append$"](lines, fmt("  - %s", _242))
    end
    api.nvim_err_writeln((table.concat(enum.reduce(_294_, {"Some Pact plugins had configuration errors and wont be processed!"}, err_plugins), "\n") .. "\n"))
  else
  end
  if ok_plugins then
    local plugins_meta
    local function _296_(_241, _242)
      return {_242.id, {events = {}, text = "waiting for scheduler", order = _241, state = "waiting", plugin = _242}}
    end
    plugins_meta = enum["pairs->table"](enum.map(_296_, ok_plugins))
    local max_name_length
    local function _297_(_241, _242, _243)
      return math.max(_241, #_243.name)
    end
    max_name_length = enum.reduce(_297_, 0, ok_plugins)
    local ui = {plugins = ok_plugins, ["plugins-meta"] = plugins_meta, win = win, buf = buf, ["ns-id"] = api.nvim_create_namespace("pact-ui"), layout = {["max-name-length"] = max_name_length}, scheduler = scheduler.new({["concurrency-limit"] = opts0["concurrency-limit"]}), opts = opts0}
    do
      api.nvim_buf_set_option(buf, "ft", "pact")
      local function _298_()
        return exec_keymap__3d(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "=", "", {callback = _298_})
      local function _299_()
        return exec_keymap_cc(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "cc", "", {callback = _299_})
      local function _300_()
        return exec_keymap_s(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "s", "", {callback = _300_})
      local function _301_()
        return exec_keymap_u(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "u", "", {callback = _301_})
    end
    exec_orphans(ui)
    exec_status(ui)
    return ui
  else
    return nil
  end
end
return M