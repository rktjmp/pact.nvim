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
local enum, inspect, scheduler, _local_19_, _local_20_, result, api, _local_21_, status_wf, clone_wf, sync_wf, diff_wf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
do
  local _18_ = require("pact.workflow.git.diff")
  local _17_ = require("pact.workflow.git.sync")
  local _16_ = require("pact.workflow.git.clone")
  local _15_ = require("pact.workflow.git.status")
  local _14_ = string
  local _13_ = vim.api
  local _12_ = require("pact.lib.ruin.result")
  local _11_ = require("pact.lib.ruin.result")
  local _10_ = require("pact.pubsub")
  local _9_ = require("pact.workflow.scheduler")
  local _8_ = require("pact.inspect")
  local _7_ = require("pact.lib.ruin.enum")
  enum, inspect, scheduler, _local_19_, _local_20_, result, api, _local_21_, status_wf, clone_wf, sync_wf, diff_wf = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_, _16_, _17_, _18_
end
local _local_22_ = _local_19_
local subscribe = _local_22_["subscribe"]
local unsubscribe = _local_22_["unsubscribe"]
local _local_23_ = _local_20_
local err_3f = _local_23_["err?"]
local ok_3f = _local_23_["ok?"]
local _local_24_ = _local_21_
local fmt = _local_24_["format"]
local M = {}
local function section_title(section_name)
  return (({error = "Error", waiting = "Waiting", active = "Active", held = "Held", updated = "Updated", ["up-to-date"] = "Up to date", unstaged = "Unstaged", staged = "Staged"})[section_name] or section_name)
end
local function highlight_for(section_name, field)
  local joined = table.concat({"pact", section_name, field}, "-")
  local function _25_(_241, _242, _243)
    return (_241 .. string.upper(_242) .. _243)
  end
  local function _26_()
    return string.gmatch(joined, "(%w)([%w]+)")
  end
  return enum.reduce(_25_, "", _26_)
end
local function lede()
  return {{{";; \240\159\148\170\240\159\144\144\240\159\169\184", "PactComment"}}, {{"", "PactComment"}}}
end
local function usage()
  return {{{";; usage:", "PactComment"}}, {{";;", "PactComment"}}, {{";;   s  - stage plugin for update", "PactComment"}}, {{";;   u  - unstage plugin", "PactComment"}}, {{";;   cc - commit staging and fetch updates", "PactComment"}}, {{";;   =  - view git log (staged/unstaged only)", "PactComment"}}, {{"", nil}}}
end
local function rate_limited_inc(_27_)
  local _arg_28_ = _27_
  local t = _arg_28_[1]
  local n = _arg_28_[2]
  local every_n_ms = (1000 / 6)
  local now = vim.loop.now()
  if (every_n_ms < (now - t)) then
    return {now, (n + 1)}
  else
    return {t, n}
  end
end
local function progress_symbol(progress)
  local _30_ = progress
  if (_30_ == nil) then
    return ""
  elseif ((_G.type(_30_) == "table") and true and (nil ~= (_30_)[2])) then
    local _ = (_30_)[1]
    local n = (_30_)[2]
    local symbols = {"\226\151\144", "\226\151\147", "\226\151\145", "\226\151\146"}
    return symbols[(1 + (n % #symbols))]
  else
    return nil
  end
end
local function render_section(ui, section_name, previous_lines)
  local relevant_plugins
  local function _32_(_241, _242)
    return (_241.order <= _242.order)
  end
  local function _33_(_241, _242)
    return _242
  end
  local function _34_(_241, _242)
    return (_242.state == section_name)
  end
  relevant_plugins = enum["sort$"](_32_, enum.map(_33_, enum.filter(_34_, ui["plugins-meta"])))
  local new_lines
  local function _35_(lines, i, meta)
    local name_length = #meta.plugin.name
    local line = {{meta.plugin.name, highlight_for(section_name, "name")}, {string.rep(" ", ((1 + ui.layout["max-name-length"]) - name_length)), nil}, {((meta.text or "did-not-set-text") .. progress_symbol(meta.progress)), highlight_for(section_name, "text")}}
    meta["on-line"] = (2 + #previous_lines + #lines)
    return enum["append$"](lines, line)
  end
  new_lines = enum.reduce(_35_, {}, relevant_plugins)
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
  local function _37_()
    if log_line_breaking_3f(log) then
      return "DiagnosticError"
    else
      return "DiagnosticHint"
    end
  end
  return {{"  ", "comment"}, {sha, "comment"}, {" ", "comment"}, {log, _37_()}}
end
local function output(ui)
  do
    local sections = {"waiting", "error", "active", "unstaged", "staged", "updated", "held", "up-to-date"}
    local lines
    local function _38_(lines0, _, section)
      return render_section(ui, section, lines0)
    end
    lines = enum["concat$"](enum.reduce(_38_, lede(), sections), usage())
    local lines__3etext_and_extmarks
    local function _43_(_39_, _, _41_)
      local _arg_40_ = _39_
      local str = _arg_40_[1]
      local extmarks = _arg_40_[2]
      local _arg_42_ = _41_
      local txt = _arg_42_[1]
      local _3fextmarks = _arg_42_[2]
      local function _44_()
        if _3fextmarks then
          return enum["append$"](extmarks, {#str, (#str + #txt), _3fextmarks})
        else
          return extmarks
        end
      end
      return {(str .. txt), _44_()}
    end
    lines__3etext_and_extmarks = enum.reduce(_43_)
    local function _48_(_46_, _, line)
      local _arg_47_ = _46_
      local lines0 = _arg_47_[1]
      local extmarks = _arg_47_[2]
      local _let_49_ = lines__3etext_and_extmarks({"", {}}, line)
      local new_lines = _let_49_[1]
      local new_extmarks = _let_49_[2]
      return {enum["append$"](lines0, new_lines), enum["append$"](extmarks, new_extmarks)}
    end
    local _let_45_ = enum.reduce(_48_, {{}, {}}, lines)
    local text = _let_45_[1]
    local extmarks = _let_45_[2]
    local function _50_(_241, _242)
      return string.match(_242, "\n")
    end
    if enum["any?"](_50_, text) then
      print("pact.ui text had unexpected new lines")
      print(vim.inspect(text))
    else
    end
    api.nvim_buf_set_lines(ui.buf, 0, -1, false, text)
    local function _52_(i, line_marks)
      local function _55_(_, _53_)
        local _arg_54_ = _53_
        local start = _arg_54_[1]
        local stop = _arg_54_[2]
        local hl = _arg_54_[3]
        return api.nvim_buf_add_highlight(ui.buf, ui["ns-id"], hl, (i - 1), start, stop)
      end
      return enum.map(_55_, line_marks)
    end
    enum.map(_52_, extmarks)
    local function _56_(_241, _242)
      if _242["log-open"] then
        local function _57_(_2410, _2420)
          return log_line__3echunks(_2420)
        end
        return api.nvim_buf_set_extmark(ui.buf, ui["ns-id"], (_242["on-line"] - 1), 0, {virt_lines = enum.map(_57_, _242.log)})
      else
        return nil
      end
    end
    enum.map(_56_, ui["plugins-meta"])
  end
  vim.cmd.redraw()
  do end (ui)["will-render"] = false
  return nil
end
local function schedule_redraw(ui)
  if not ui["will-render"] then
    ui["will-render"] = true
    local function _59_()
      return output(ui)
    end
    return vim.schedule(_59_)
  else
    return nil
  end
end
local function exec_commit(ui)
  local function make_wf(how, plugin, commit)
    local wf
    do
      local _61_ = how
      if (_61_ == "clone") then
        wf = clone_wf.new(plugin.id, plugin["package-path"], plugin.source[2], commit.sha)
      elseif (_61_ == "sync") then
        wf = sync_wf.new(plugin.id, plugin["package-path"], commit.sha)
      elseif (nil ~= _61_) then
        local other = _61_
        wf = error(fmt("unknown staging action %s", other))
      else
        wf = nil
      end
    end
    local meta = ui["plugins-meta"][plugin.id]
    local handler
    local __fn_2a_handler_dispatch = {bodies = {}, help = {}}
    local handler0
    local function _67_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _69_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _69_ = f_74_auto
      end
      if (nil ~= _69_) then
        local f_74_auto = _69_
        return f_74_auto(...)
      elseif (_69_ == nil) then
        local view_77_auto
        do
          local _70_, _71_ = pcall(require, "fennel")
          if ((_70_ == true) and ((_G.type(_71_) == "table") and (nil ~= (_71_).view))) then
            local view_77_auto0 = (_71_).view
            view_77_auto = view_77_auto0
          elseif ((_70_ == false) and true) then
            local __75_auto = _71_
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
    handler0 = _67_
    local function _74_()
      local _75_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _76_(...)
          if (1 == select("#", ...)) then
            local _77_ = {...}
            local function _78_(...)
              local event_63_ = (_77_)[1]
              return ok_3f(event_63_)
            end
            if (((_G.type(_77_) == "table") and (nil ~= (_77_)[1])) and _78_(...)) then
              local event_63_ = (_77_)[1]
              local function _79_(event)
                enum["append$"](meta.events, event)
                meta.state = "updated"
                local _81_
                do
                  local _80_ = how
                  if (_80_ == "clone") then
                    _81_ = "cloned"
                  elseif (_80_ == "sync") then
                    _81_ = "synced"
                  else
                    _81_ = nil
                  end
                end
                meta.text = fmt("(%s %s)", _81_, commit)
                meta.progress = nil
                local function _85_()
                  return vim.cmd("silent! helptags ALL")
                end
                vim.schedule(_85_)
                if plugin.run then
                  local _let_86_ = require("pact.workflow.run")
                  local new = _let_86_["new"]
                  local old_text = meta.text
                  local run_wf = new(wf.id, plugin.run, plugin["package-path"])
                  meta.text = "running..."
                  local function _87_(event0)
                    local _88_ = event0
                    local function _89_()
                      local _ = _88_
                      return ok_3f(event0)
                    end
                    if (true and _89_()) then
                      local _ = _88_
                      meta.text = (old_text .. fmt(" ran: %s", result.unwrap(event0)))
                      meta.progress = nil
                      unsubscribe(run_wf, handler0)
                      return schedule_redraw(ui)
                    else
                      local function _90_()
                        local _ = _88_
                        return err_3f(event0)
                      end
                      if (true and _90_()) then
                        local _ = _88_
                        meta.text = (old_text .. fmt(" error: %s", inspect(result.unwrap(event0))))
                        meta.progress = nil
                        unsubscribe(run_wf, handler0)
                        return schedule_redraw(ui)
                      else
                        local function _91_()
                          local _ = _88_
                          return string_3f(event0)
                        end
                        if (true and _91_()) then
                          local _ = _88_
                          print("string-event", event0)
                          return handler0(fmt("run: %s", event0))
                        else
                          local function _92_()
                            local _ = _88_
                            return thread_3f(event0)
                          end
                          if (true and _92_()) then
                            local _ = _88_
                            unsubscribe(run_wf, handler0)
                            return handler0(event0)
                          else
                            return nil
                          end
                        end
                      end
                    end
                  end
                  subscribe(run_wf, _87_)
                  scheduler["add-workflow"](ui.scheduler, run_wf)
                else
                end
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _79_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _76_)
        _75_ = handler0
      end
      local _97_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _98_(...)
          if (1 == select("#", ...)) then
            local _99_ = {...}
            local function _100_(...)
              local event_64_ = (_99_)[1]
              return err_3f(event_64_)
            end
            if (((_G.type(_99_) == "table") and (nil ~= (_99_)[1])) and _100_(...)) then
              local event_64_ = (_99_)[1]
              local function _101_(event)
                local _let_102_ = event
                local _ = _let_102_[1]
                local e = _let_102_[2]
                enum["append$"](meta.events, event)
                meta.state = "error"
                meta.text = e
                meta.progress = nil
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _101_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _98_)
        _97_ = handler0
      end
      local _105_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _106_(...)
          if (1 == select("#", ...)) then
            local _107_ = {...}
            local function _108_(...)
              local msg_65_ = (_107_)[1]
              return string_3f(msg_65_)
            end
            if (((_G.type(_107_) == "table") and (nil ~= (_107_)[1])) and _108_(...)) then
              local msg_65_ = (_107_)[1]
              local function _109_(msg)
                enum["append$"](meta.events, msg)
                meta.text = msg
                meta.progress = nil
                return schedule_redraw(ui)
              end
              return _109_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _106_)
        _105_ = handler0
      end
      local _112_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _113_(...)
          if (1 == select("#", ...)) then
            local _114_ = {...}
            local function _115_(...)
              local future_66_ = (_114_)[1]
              return thread_3f(future_66_)
            end
            if (((_G.type(_114_) == "table") and (nil ~= (_114_)[1])) and _115_(...)) then
              local future_66_ = (_114_)[1]
              local function _116_(future)
                meta.progress = rate_limited_inc((meta.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _116_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _113_)
        _112_ = handler0
      end
      local function _119_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _120_(...)
          if true then
            local _121_ = {...}
            local function _122_(...)
              return true
            end
            if ((_G.type(_121_) == "table") and _122_(...)) then
              local function _123_(...)
                return nil
              end
              return _123_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _120_)
        return handler0
      end
      do local _ = {_75_, _97_, _105_, _112_, _119_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _74_})()
    subscribe(wf, handler)
    return wf
  end
  local function _126_(_, meta)
    meta["state"] = "held"
    return nil
  end
  local function _127_(_241, _242)
    return ("unstaged" == _242.state)
  end
  enum.map(_126_, enum.filter(_127_, ui["plugins-meta"]))
  local function _128_(_, meta)
    local wf = make_wf(meta.action[1], meta.plugin, meta.action[2])
    scheduler["add-workflow"](ui.scheduler, wf)
    do end (meta)["state"] = "active"
    return nil
  end
  local function _129_(_241, _242)
    return ("staged" == _242.state)
  end
  enum.map(_128_, enum.filter(_129_, ui["plugins-meta"]))
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
    local function _134_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _136_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _136_ = f_74_auto
      end
      if (nil ~= _136_) then
        local f_74_auto = _136_
        return f_74_auto(...)
      elseif (_136_ == nil) then
        local view_77_auto
        do
          local _137_, _138_ = pcall(require, "fennel")
          if ((_137_ == true) and ((_G.type(_138_) == "table") and (nil ~= (_138_).view))) then
            local view_77_auto0 = (_138_).view
            view_77_auto = view_77_auto0
          elseif ((_137_ == false) and true) then
            local __75_auto = _138_
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
    handler0 = _134_
    local function _141_()
      local _142_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _143_(...)
          if (1 == select("#", ...)) then
            local _144_ = {...}
            local function _145_(...)
              local event_130_ = (_144_)[1]
              return ok_3f(event_130_)
            end
            if (((_G.type(_144_) == "table") and (nil ~= (_144_)[1])) and _145_(...)) then
              local event_130_ = (_144_)[1]
              local function _146_(event)
                local _let_147_ = event
                local _ = _let_147_[1]
                local log = _let_147_[2]
                enum["append$"](meta0.events, event)
                meta0.text = previous_text
                meta0.progress = nil
                meta0.log = log
                meta0["log-open"] = true
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _146_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _143_)
        _142_ = handler0
      end
      local _150_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _151_(...)
          if (1 == select("#", ...)) then
            local _152_ = {...}
            local function _153_(...)
              local event_131_ = (_152_)[1]
              return err_3f(event_131_)
            end
            if (((_G.type(_152_) == "table") and (nil ~= (_152_)[1])) and _153_(...)) then
              local event_131_ = (_152_)[1]
              local function _154_(event)
                local _let_155_ = event
                local _ = _let_155_[1]
                local e = _let_155_[2]
                enum["append$"](meta0.events, event)
                meta0.text = e
                meta0.progress = nil
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _154_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _151_)
        _150_ = handler0
      end
      local _158_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _159_(...)
          if (1 == select("#", ...)) then
            local _160_ = {...}
            local function _161_(...)
              local msg_132_ = (_160_)[1]
              return string_3f(msg_132_)
            end
            if (((_G.type(_160_) == "table") and (nil ~= (_160_)[1])) and _161_(...)) then
              local msg_132_ = (_160_)[1]
              local function _162_(msg)
                local meta1 = ui["plugins-meta"][wf.id]
                enum["append$"](meta1.events, msg)
                do end (meta1)["text"] = msg
                return schedule_redraw(ui)
              end
              return _162_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _159_)
        _158_ = handler0
      end
      local _165_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _166_(...)
          if (1 == select("#", ...)) then
            local _167_ = {...}
            local function _168_(...)
              local future_133_ = (_167_)[1]
              return thread_3f(future_133_)
            end
            if (((_G.type(_167_) == "table") and (nil ~= (_167_)[1])) and _168_(...)) then
              local future_133_ = (_167_)[1]
              local function _169_(future)
                meta0.progress = rate_limited_inc((meta0.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _169_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _166_)
        _165_ = handler0
      end
      local function _172_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _173_(...)
          if true then
            local _174_ = {...}
            local function _175_(...)
              return true
            end
            if ((_G.type(_174_) == "table") and _175_(...)) then
              local function _176_(...)
                return nil
              end
              return _176_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _173_)
        return handler0
      end
      do local _ = {_142_, _150_, _158_, _165_, _172_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _141_})()
    subscribe(wf, handler)
    return wf
  end
  do
    local wf = make_wf(meta.plugin, meta.action[2])
    scheduler["add-workflow"](ui.scheduler, wf)
  end
  return schedule_redraw(ui)
end
local function exec_status(ui)
  local function make_status_wf(plugin)
    local wf = status_wf.new(plugin.id, plugin.source[2], plugin["package-path"], plugin.constraint)
    local meta = ui["plugins-meta"][plugin.id]
    local handler
    local __fn_2a_handler_dispatch = {bodies = {}, help = {}}
    local handler0
    local function _183_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _185_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _185_ = f_74_auto
      end
      if (nil ~= _185_) then
        local f_74_auto = _185_
        return f_74_auto(...)
      elseif (_185_ == nil) then
        local view_77_auto
        do
          local _186_, _187_ = pcall(require, "fennel")
          if ((_186_ == true) and ((_G.type(_187_) == "table") and (nil ~= (_187_).view))) then
            local view_77_auto0 = (_187_).view
            view_77_auto = view_77_auto0
          elseif ((_186_ == false) and true) then
            local __75_auto = _187_
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
    handler0 = _183_
    local function _190_()
      local _191_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _192_(...)
          if (1 == select("#", ...)) then
            local _193_ = {...}
            local function _194_(...)
              local event_179_ = (_193_)[1]
              return ok_3f(event_179_)
            end
            if (((_G.type(_193_) == "table") and (nil ~= (_193_)[1])) and _194_(...)) then
              local event_179_ = (_193_)[1]
              local function _195_(event)
                local command, _3fmaybe_latest = result.unwrap(event)
                local text
                local function _196_(_241)
                  local _197_ = _3fmaybe_latest
                  if (nil ~= _197_) then
                    local commit = _197_
                    return fmt("%s, latest: %s)", _241, commit)
                  elseif (_197_ == nil) then
                    return fmt("%s)", _241)
                  else
                    return nil
                  end
                end
                local function _200_()
                  local _199_ = command
                  if ((_G.type(_199_) == "table") and ((_199_)[1] == "hold") and (nil ~= (_199_)[2])) then
                    local commit = (_199_)[2]
                    return fmt("(at %s", commit)
                  elseif ((_G.type(_199_) == "table") and (nil ~= (_199_)[1]) and (nil ~= (_199_)[2])) then
                    local action = (_199_)[1]
                    local commit = (_199_)[2]
                    return fmt("(%s %s", action, commit)
                  else
                    return nil
                  end
                end
                text = _196_(_200_())
                enum["append$"](meta.events, event)
                meta.text = text
                meta.progress = nil
                do
                  local _202_ = command
                  if ((_G.type(_202_) == "table") and ((_202_)[1] == "hold") and (nil ~= (_202_)[2])) then
                    local commit = (_202_)[2]
                    meta.state = "up-to-date"
                  elseif ((_G.type(_202_) == "table") and (nil ~= (_202_)[1]) and (nil ~= (_202_)[2])) then
                    local action = (_202_)[1]
                    local commit = (_202_)[2]
                    meta.state = "unstaged"
                    meta.action = {action, commit}
                  else
                  end
                end
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _195_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _192_)
        _191_ = handler0
      end
      local _206_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _207_(...)
          if (1 == select("#", ...)) then
            local _208_ = {...}
            local function _209_(...)
              local event_180_ = (_208_)[1]
              return err_3f(event_180_)
            end
            if (((_G.type(_208_) == "table") and (nil ~= (_208_)[1])) and _209_(...)) then
              local event_180_ = (_208_)[1]
              local function _210_(event)
                meta.state = "error"
                enum["append$"](meta.events, event)
                meta.progress = nil
                meta.text = result.unwrap(event)
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
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
      local _213_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _214_(...)
          if (1 == select("#", ...)) then
            local _215_ = {...}
            local function _216_(...)
              local msg_181_ = (_215_)[1]
              return string_3f(msg_181_)
            end
            if (((_G.type(_215_) == "table") and (nil ~= (_215_)[1])) and _216_(...)) then
              local msg_181_ = (_215_)[1]
              local function _217_(msg)
                enum["append$"](meta.events, msg)
                meta.progress = nil
                meta.text = msg
                return schedule_redraw(ui)
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
        _213_ = handler0
      end
      local _220_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _221_(...)
          if (1 == select("#", ...)) then
            local _222_ = {...}
            local function _223_(...)
              local future_182_ = (_222_)[1]
              return thread_3f(future_182_)
            end
            if (((_G.type(_222_) == "table") and (nil ~= (_222_)[1])) and _223_(...)) then
              local future_182_ = (_222_)[1]
              local function _224_(future)
                meta.progress = rate_limited_inc((meta.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _224_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _221_)
        _220_ = handler0
      end
      local function _227_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _228_(...)
          if true then
            local _229_ = {...}
            local function _230_(...)
              return true
            end
            if ((_G.type(_229_) == "table") and _230_(...)) then
              local function _231_(...)
                return nil
              end
              return _231_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _228_)
        return handler0
      end
      do local _ = {_191_, _206_, _213_, _220_, _227_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _190_})()
    subscribe(wf, handler)
    return wf
  end
  schedule_redraw(ui)
  local function _234_(_, plugin)
    return scheduler["add-workflow"](ui.scheduler, make_status_wf(plugin))
  end
  return enum.map(_234_, ui.plugins)
end
local function exec_keymap_cc(ui)
  local function _235_(_241, _242)
    return ("staged" == _242.state)
  end
  if enum["any?"](_235_, ui["plugins-meta"]) then
    return exec_commit(ui)
  else
    return vim.notify("Nothing staged, refusing to commit")
  end
end
local function exec_keymap_s(ui)
  local _let_237_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_237_[1]
  local _ = _let_237_[2]
  local meta
  local function _238_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_238_, ui["plugins-meta"])
  if (meta and ("unstaged" == meta.state)) then
    meta["state"] = "staged"
    return schedule_redraw(ui)
  else
    return vim.notify("May only stage unstaged plugins")
  end
end
local function exec_keymap_u(ui)
  local _let_240_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_240_[1]
  local _ = _let_240_[2]
  local meta
  local function _241_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_241_, ui["plugins-meta"])
  if (meta and ("staged" == meta.state)) then
    meta["state"] = "unstaged"
    return schedule_redraw(ui)
  else
    return vim.notify("May only unstage staged plugins")
  end
end
local function exec_keymap__3d(ui)
  local _let_243_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_243_[1]
  local _ = _let_243_[2]
  local meta
  local function _244_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_244_, ui["plugins-meta"])
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
  local function _248_(_241, _242)
    return result["ok?"](_242), result.unwrap(_242)
  end
  local _let_247_ = enum["group-by"](_248_, plugins)
  local ok_plugins = _let_247_[true]
  local err_plugins = _let_247_[false]
  if err_plugins then
    local function _249_(lines, _, _242)
      return enum["append$"](lines, fmt("  - %s", _242))
    end
    api.nvim_err_writeln((table.concat(enum.reduce(_249_, {"Some Pact plugins had configuration errors and wont be processed!"}, err_plugins), "\n") .. "\n"))
  else
  end
  if ok_plugins then
    local plugins_meta
    local function _251_(_241, _242)
      return {_242.id, {events = {}, text = "waiting for scheduler", order = _241, state = "waiting", action = nil, plugin = _242}}
    end
    plugins_meta = enum["pairs->table"](enum.map(_251_, ok_plugins))
    local max_name_length
    local function _252_(_241, _242, _243)
      return math.max(_241, #_243.name)
    end
    max_name_length = enum.reduce(_252_, 0, ok_plugins)
    local ui = {plugins = ok_plugins, ["plugins-meta"] = plugins_meta, win = win, buf = buf, ["ns-id"] = api.nvim_create_namespace("pact-ui"), layout = {["max-name-length"] = max_name_length}, scheduler = scheduler.new({["concurrency-limit"] = opts0["concurrency-limit"]}), opts = opts0}
    do
      api.nvim_buf_set_option(buf, "ft", "pact")
      local function _253_()
        return exec_keymap__3d(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "=", "", {callback = _253_})
      local function _254_()
        return exec_keymap_cc(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "cc", "", {callback = _254_})
      local function _255_()
        return exec_keymap_s(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "s", "", {callback = _255_})
      local function _256_()
        return exec_keymap_u(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "u", "", {callback = _256_})
    end
    exec_status(ui)
    return ui
  else
    return nil
  end
end
return M