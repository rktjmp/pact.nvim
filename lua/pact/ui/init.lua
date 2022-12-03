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
local enum, scheduler, _local_18_, _local_19_, result, api, _local_20_, status_wf, clone_wf, sync_wf, diff_wf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
do
  local _17_ = require("pact.workflow.git.diff")
  local _16_ = require("pact.workflow.git.sync")
  local _15_ = require("pact.workflow.git.clone")
  local _14_ = require("pact.workflow.git.status")
  local _13_ = string
  local _12_ = vim.api
  local _11_ = require("pact.lib.ruin.result")
  local _10_ = require("pact.lib.ruin.result")
  local _9_ = require("pact.pubsub")
  local _8_ = require("pact.workflow.scheduler")
  local _7_ = require("pact.lib.ruin.enum")
  enum, scheduler, _local_18_, _local_19_, result, api, _local_20_, status_wf, clone_wf, sync_wf, diff_wf = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_, _16_, _17_
end
local _local_21_ = _local_18_
local subscribe = _local_21_["subscribe"]
local unsubscribe = _local_21_["unsubscribe"]
local _local_22_ = _local_19_
local err_3f = _local_22_["err?"]
local ok_3f = _local_22_["ok?"]
local _local_23_ = _local_20_
local fmt = _local_23_["format"]
local M = {}
local function section_title(section_name)
  return (({error = "Error", waiting = "Waiting", active = "Active", held = "Held", updated = "Updated", ["up-to-date"] = "Up to date", unstaged = "Unstaged", staged = "Staged"})[section_name] or section_name)
end
local function highlight_for(section_name, field)
  local joined = table.concat({"pact", section_name, field}, "-")
  local function _24_(_241, _242, _243)
    return (_241 .. string.upper(_242) .. _243)
  end
  local function _25_()
    return string.gmatch(joined, "(%w)([%w]+)")
  end
  return enum.reduce(_24_, "", _25_)
end
local function lede()
  return {{{";; \240\159\148\170\240\159\144\144\240\159\169\184", "PactComment"}}, {{"", "PactComment"}}}
end
local function usage()
  return {{{";; usage:", "PactComment"}}, {{";;", "PactComment"}}, {{";;   s  - stage plugin for update", "PactComment"}}, {{";;   u  - unstage plugin", "PactComment"}}, {{";;   cc - commit staging and fetch updates", "PactComment"}}, {{";;   =  - view git log (staged/unstaged only)", "PactComment"}}, {{"", nil}}}
end
local function rate_limited_inc(_26_)
  local _arg_27_ = _26_
  local t = _arg_27_[1]
  local n = _arg_27_[2]
  local every_n_ms = (1000 / 6)
  local now = vim.loop.now()
  if (every_n_ms < (now - t)) then
    return {now, (n + 1)}
  else
    return {t, n}
  end
end
local function progress_symbol(progress)
  local _29_ = progress
  if (_29_ == nil) then
    return ""
  elseif ((_G.type(_29_) == "table") and true and (nil ~= (_29_)[2])) then
    local _ = (_29_)[1]
    local n = (_29_)[2]
    local symbols = {"\226\151\144", "\226\151\147", "\226\151\145", "\226\151\146"}
    return symbols[(1 + (n % #symbols))]
  else
    return nil
  end
end
local function render_section(ui, section_name, previous_lines)
  local relevant_plugins
  local function _31_(_241, _242)
    return (_241.order <= _242.order)
  end
  local function _32_(_241, _242)
    return _242
  end
  local function _33_(_241, _242)
    return (_242.state == section_name)
  end
  relevant_plugins = enum["sort$"](_31_, enum.map(_32_, enum.filter(_33_, ui["plugins-meta"])))
  local new_lines
  local function _34_(lines, i, meta)
    local name_length = #meta.plugin.name
    local line = {{meta.plugin.name, highlight_for(section_name, "name")}, {string.rep(" ", ((1 + ui.layout["max-name-length"]) - name_length)), nil}, {((meta.text or "did-not-set-text") .. progress_symbol(meta.progress)), highlight_for(section_name, "text")}}
    meta["on-line"] = (2 + #previous_lines + #lines)
    return enum["append$"](lines, line)
  end
  new_lines = enum.reduce(_34_, {}, relevant_plugins)
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
  local function _36_()
    if log_line_breaking_3f(log) then
      return "DiagnosticError"
    else
      return "DiagnosticHint"
    end
  end
  return {{"  ", "comment"}, {sha, "comment"}, {" ", "comment"}, {log, _36_()}}
end
local function output(ui)
  do
    local sections = {"waiting", "error", "active", "unstaged", "staged", "updated", "held", "up-to-date"}
    local lines
    local function _37_(lines0, _, section)
      return render_section(ui, section, lines0)
    end
    lines = enum["concat$"](enum.reduce(_37_, lede(), sections), usage())
    local lines__3etext_and_extmarks
    local function _42_(_38_, _, _40_)
      local _arg_39_ = _38_
      local str = _arg_39_[1]
      local extmarks = _arg_39_[2]
      local _arg_41_ = _40_
      local txt = _arg_41_[1]
      local _3fextmarks = _arg_41_[2]
      local function _43_()
        if _3fextmarks then
          return enum["append$"](extmarks, {#str, (#str + #txt), _3fextmarks})
        else
          return extmarks
        end
      end
      return {(str .. txt), _43_()}
    end
    lines__3etext_and_extmarks = enum.reduce(_42_)
    local function _47_(_45_, _, line)
      local _arg_46_ = _45_
      local lines0 = _arg_46_[1]
      local extmarks = _arg_46_[2]
      local _let_48_ = lines__3etext_and_extmarks({"", {}}, line)
      local new_lines = _let_48_[1]
      local new_extmarks = _let_48_[2]
      return {enum["append$"](lines0, new_lines), enum["append$"](extmarks, new_extmarks)}
    end
    local _let_44_ = enum.reduce(_47_, {{}, {}}, lines)
    local text = _let_44_[1]
    local extmarks = _let_44_[2]
    local function _49_(_241, _242)
      return string.match(_242, "\n")
    end
    if enum["any?"](_49_, text) then
      print("pact.ui text had unexpected new lines")
      print(vim.inspect(text))
    else
    end
    api.nvim_buf_set_lines(ui.buf, 0, -1, false, text)
    local function _51_(i, line_marks)
      local function _54_(_, _52_)
        local _arg_53_ = _52_
        local start = _arg_53_[1]
        local stop = _arg_53_[2]
        local hl = _arg_53_[3]
        return api.nvim_buf_add_highlight(ui.buf, ui["ns-id"], hl, (i - 1), start, stop)
      end
      return enum.map(_54_, line_marks)
    end
    enum.map(_51_, extmarks)
    local function _55_(_241, _242)
      if _242["log-open"] then
        local function _56_(_2410, _2420)
          return log_line__3echunks(_2420)
        end
        return api.nvim_buf_set_extmark(ui.buf, ui["ns-id"], (_242["on-line"] - 1), 0, {virt_lines = enum.map(_56_, _242.log)})
      else
        return nil
      end
    end
    enum.map(_55_, ui["plugins-meta"])
  end
  vim.cmd.redraw()
  do end (ui)["will-render"] = false
  return nil
end
local function schedule_redraw(ui)
  if not ui["will-render"] then
    ui["will-render"] = true
    local function _58_()
      return output(ui)
    end
    return vim.schedule(_58_)
  else
    return nil
  end
end
local function exec_commit(ui)
  local function make_wf(how, plugin, commit)
    local wf
    do
      local _60_ = how
      if (_60_ == "clone") then
        wf = clone_wf.new(plugin.id, plugin["package-path"], plugin.source[2], commit.sha)
      elseif (_60_ == "sync") then
        wf = sync_wf.new(plugin.id, plugin["package-path"], commit.sha)
      elseif (nil ~= _60_) then
        local other = _60_
        wf = error(fmt("unknown staging action %s", other))
      else
        wf = nil
      end
    end
    local meta = ui["plugins-meta"][plugin.id]
    local handler
    local __fn_2a_handler_dispatch = {bodies = {}, help = {}}
    local handler0
    local function _66_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _68_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _68_ = f_74_auto
      end
      if (nil ~= _68_) then
        local f_74_auto = _68_
        return f_74_auto(...)
      elseif (_68_ == nil) then
        local view_77_auto
        do
          local _69_, _70_ = pcall(require, "fennel")
          if ((_69_ == true) and ((_G.type(_70_) == "table") and (nil ~= (_70_).view))) then
            local view_77_auto0 = (_70_).view
            view_77_auto = view_77_auto0
          elseif ((_69_ == false) and true) then
            local __75_auto = _70_
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
    handler0 = _66_
    local function _73_()
      local _74_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _75_(...)
          if (1 == select("#", ...)) then
            local _76_ = {...}
            local function _77_(...)
              local event_62_ = (_76_)[1]
              return ok_3f(event_62_)
            end
            if (((_G.type(_76_) == "table") and (nil ~= (_76_)[1])) and _77_(...)) then
              local event_62_ = (_76_)[1]
              local function _78_(event)
                enum["append$"](meta.events, event)
                meta.state = "updated"
                local _80_
                do
                  local _79_ = how
                  if (_79_ == "clone") then
                    _80_ = "cloned"
                  elseif (_79_ == "sync") then
                    _80_ = "synced"
                  else
                    _80_ = nil
                  end
                end
                meta.text = fmt("(%s %s)", _80_, commit)
                meta.progress = nil
                local function _84_()
                  return vim.cmd("silent! helptags ALL")
                end
                vim.schedule(_84_)
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _78_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _75_)
        _74_ = handler0
      end
      local _87_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _88_(...)
          if (1 == select("#", ...)) then
            local _89_ = {...}
            local function _90_(...)
              local event_63_ = (_89_)[1]
              return err_3f(event_63_)
            end
            if (((_G.type(_89_) == "table") and (nil ~= (_89_)[1])) and _90_(...)) then
              local event_63_ = (_89_)[1]
              local function _91_(event)
                local _let_92_ = event
                local _ = _let_92_[1]
                local e = _let_92_[2]
                enum["append$"](meta.events, event)
                meta.state = "error"
                meta.text = e
                meta.progress = nil
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _91_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _88_)
        _87_ = handler0
      end
      local _95_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _96_(...)
          if (1 == select("#", ...)) then
            local _97_ = {...}
            local function _98_(...)
              local msg_64_ = (_97_)[1]
              return string_3f(msg_64_)
            end
            if (((_G.type(_97_) == "table") and (nil ~= (_97_)[1])) and _98_(...)) then
              local msg_64_ = (_97_)[1]
              local function _99_(msg)
                enum["append$"](meta.events, msg)
                meta.text = msg
                meta.progress = nil
                return schedule_redraw(ui)
              end
              return _99_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _96_)
        _95_ = handler0
      end
      local _102_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _103_(...)
          if (1 == select("#", ...)) then
            local _104_ = {...}
            local function _105_(...)
              local future_65_ = (_104_)[1]
              return thread_3f(future_65_)
            end
            if (((_G.type(_104_) == "table") and (nil ~= (_104_)[1])) and _105_(...)) then
              local future_65_ = (_104_)[1]
              local function _106_(future)
                meta.progress = rate_limited_inc((meta.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _106_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _103_)
        _102_ = handler0
      end
      local function _109_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _110_(...)
          if true then
            local _111_ = {...}
            local function _112_(...)
              return true
            end
            if ((_G.type(_111_) == "table") and _112_(...)) then
              local function _113_(...)
                return nil
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
        return handler0
      end
      do local _ = {_74_, _87_, _95_, _102_, _109_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _73_})()
    subscribe(wf, handler)
    return wf
  end
  local function _116_(_, meta)
    meta["state"] = "held"
    return nil
  end
  local function _117_(_241, _242)
    return ("unstaged" == _242.state)
  end
  enum.map(_116_, enum.filter(_117_, ui["plugins-meta"]))
  local function _118_(_, meta)
    local wf = make_wf(meta.action[1], meta.plugin, meta.action[2])
    scheduler["add-workflow"](ui.scheduler, wf)
    do end (meta)["state"] = "active"
    return nil
  end
  local function _119_(_241, _242)
    return ("staged" == _242.state)
  end
  enum.map(_118_, enum.filter(_119_, ui["plugins-meta"]))
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
    local function _124_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _126_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _126_ = f_74_auto
      end
      if (nil ~= _126_) then
        local f_74_auto = _126_
        return f_74_auto(...)
      elseif (_126_ == nil) then
        local view_77_auto
        do
          local _127_, _128_ = pcall(require, "fennel")
          if ((_127_ == true) and ((_G.type(_128_) == "table") and (nil ~= (_128_).view))) then
            local view_77_auto0 = (_128_).view
            view_77_auto = view_77_auto0
          elseif ((_127_ == false) and true) then
            local __75_auto = _128_
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
    handler0 = _124_
    local function _131_()
      local _132_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _133_(...)
          if (1 == select("#", ...)) then
            local _134_ = {...}
            local function _135_(...)
              local event_120_ = (_134_)[1]
              return ok_3f(event_120_)
            end
            if (((_G.type(_134_) == "table") and (nil ~= (_134_)[1])) and _135_(...)) then
              local event_120_ = (_134_)[1]
              local function _136_(event)
                local _let_137_ = event
                local _ = _let_137_[1]
                local log = _let_137_[2]
                enum["append$"](meta0.events, event)
                meta0.text = previous_text
                meta0.progress = nil
                meta0.log = log
                meta0["log-open"] = true
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _136_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _133_)
        _132_ = handler0
      end
      local _140_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _141_(...)
          if (1 == select("#", ...)) then
            local _142_ = {...}
            local function _143_(...)
              local event_121_ = (_142_)[1]
              return err_3f(event_121_)
            end
            if (((_G.type(_142_) == "table") and (nil ~= (_142_)[1])) and _143_(...)) then
              local event_121_ = (_142_)[1]
              local function _144_(event)
                local _let_145_ = event
                local _ = _let_145_[1]
                local e = _let_145_[2]
                enum["append$"](meta0.events, event)
                meta0.text = e
                meta0.progress = nil
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _144_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _141_)
        _140_ = handler0
      end
      local _148_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _149_(...)
          if (1 == select("#", ...)) then
            local _150_ = {...}
            local function _151_(...)
              local msg_122_ = (_150_)[1]
              return string_3f(msg_122_)
            end
            if (((_G.type(_150_) == "table") and (nil ~= (_150_)[1])) and _151_(...)) then
              local msg_122_ = (_150_)[1]
              local function _152_(msg)
                local meta1 = ui["plugins-meta"][wf.id]
                enum["append$"](meta1.events, msg)
                do end (meta1)["text"] = msg
                return schedule_redraw(ui)
              end
              return _152_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _149_)
        _148_ = handler0
      end
      local _155_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _156_(...)
          if (1 == select("#", ...)) then
            local _157_ = {...}
            local function _158_(...)
              local future_123_ = (_157_)[1]
              return thread_3f(future_123_)
            end
            if (((_G.type(_157_) == "table") and (nil ~= (_157_)[1])) and _158_(...)) then
              local future_123_ = (_157_)[1]
              local function _159_(future)
                meta0.progress = rate_limited_inc((meta0.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _159_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _156_)
        _155_ = handler0
      end
      local function _162_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _163_(...)
          if true then
            local _164_ = {...}
            local function _165_(...)
              return true
            end
            if ((_G.type(_164_) == "table") and _165_(...)) then
              local function _166_(...)
                return nil
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
        return handler0
      end
      do local _ = {_132_, _140_, _148_, _155_, _162_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _131_})()
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
    local function _173_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _175_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _175_ = f_74_auto
      end
      if (nil ~= _175_) then
        local f_74_auto = _175_
        return f_74_auto(...)
      elseif (_175_ == nil) then
        local view_77_auto
        do
          local _176_, _177_ = pcall(require, "fennel")
          if ((_176_ == true) and ((_G.type(_177_) == "table") and (nil ~= (_177_).view))) then
            local view_77_auto0 = (_177_).view
            view_77_auto = view_77_auto0
          elseif ((_176_ == false) and true) then
            local __75_auto = _177_
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
    handler0 = _173_
    local function _180_()
      local _181_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _182_(...)
          if (1 == select("#", ...)) then
            local _183_ = {...}
            local function _184_(...)
              local event_169_ = (_183_)[1]
              return ok_3f(event_169_)
            end
            if (((_G.type(_183_) == "table") and (nil ~= (_183_)[1])) and _184_(...)) then
              local event_169_ = (_183_)[1]
              local function _185_(event)
                local command, _3fmaybe_latest = result.unwrap(event)
                local text
                local function _186_(_241)
                  local _187_ = _3fmaybe_latest
                  if (nil ~= _187_) then
                    local commit = _187_
                    return fmt("%s, latest: %s)", _241, commit)
                  elseif (_187_ == nil) then
                    return fmt("%s)", _241)
                  else
                    return nil
                  end
                end
                local function _190_()
                  local _189_ = command
                  if ((_G.type(_189_) == "table") and ((_189_)[1] == "hold") and (nil ~= (_189_)[2])) then
                    local commit = (_189_)[2]
                    return fmt("(at %s", commit)
                  elseif ((_G.type(_189_) == "table") and (nil ~= (_189_)[1]) and (nil ~= (_189_)[2])) then
                    local action = (_189_)[1]
                    local commit = (_189_)[2]
                    return fmt("(%s %s", action, commit)
                  else
                    return nil
                  end
                end
                text = _186_(_190_())
                enum["append$"](meta.events, event)
                meta.text = text
                meta.progress = nil
                do
                  local _192_ = command
                  if ((_G.type(_192_) == "table") and ((_192_)[1] == "hold") and (nil ~= (_192_)[2])) then
                    local commit = (_192_)[2]
                    meta.state = "up-to-date"
                  elseif ((_G.type(_192_) == "table") and (nil ~= (_192_)[1]) and (nil ~= (_192_)[2])) then
                    local action = (_192_)[1]
                    local commit = (_192_)[2]
                    meta.state = "unstaged"
                    meta.action = {action, commit}
                  else
                  end
                end
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _185_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _182_)
        _181_ = handler0
      end
      local _196_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _197_(...)
          if (1 == select("#", ...)) then
            local _198_ = {...}
            local function _199_(...)
              local event_170_ = (_198_)[1]
              return err_3f(event_170_)
            end
            if (((_G.type(_198_) == "table") and (nil ~= (_198_)[1])) and _199_(...)) then
              local event_170_ = (_198_)[1]
              local function _200_(event)
                meta.state = "error"
                enum["append$"](meta.events, event)
                meta.progress = nil
                meta.text = result.unwrap(event)
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _200_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _197_)
        _196_ = handler0
      end
      local _203_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _204_(...)
          if (1 == select("#", ...)) then
            local _205_ = {...}
            local function _206_(...)
              local msg_171_ = (_205_)[1]
              return string_3f(msg_171_)
            end
            if (((_G.type(_205_) == "table") and (nil ~= (_205_)[1])) and _206_(...)) then
              local msg_171_ = (_205_)[1]
              local function _207_(msg)
                enum["append$"](meta.events, msg)
                meta.progress = nil
                meta.text = msg
                return schedule_redraw(ui)
              end
              return _207_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _204_)
        _203_ = handler0
      end
      local _210_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _211_(...)
          if (1 == select("#", ...)) then
            local _212_ = {...}
            local function _213_(...)
              local future_172_ = (_212_)[1]
              return thread_3f(future_172_)
            end
            if (((_G.type(_212_) == "table") and (nil ~= (_212_)[1])) and _213_(...)) then
              local future_172_ = (_212_)[1]
              local function _214_(future)
                meta.progress = rate_limited_inc((meta.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _214_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _211_)
        _210_ = handler0
      end
      local function _217_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _218_(...)
          if true then
            local _219_ = {...}
            local function _220_(...)
              return true
            end
            if ((_G.type(_219_) == "table") and _220_(...)) then
              local function _221_(...)
                return nil
              end
              return _221_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _218_)
        return handler0
      end
      do local _ = {_181_, _196_, _203_, _210_, _217_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _180_})()
    subscribe(wf, handler)
    return wf
  end
  schedule_redraw(ui)
  local function _224_(_, plugin)
    return scheduler["add-workflow"](ui.scheduler, make_status_wf(plugin))
  end
  return enum.map(_224_, ui.plugins)
end
local function exec_keymap_cc(ui)
  local function _225_(_241, _242)
    return ("staged" == _242.state)
  end
  if enum["any?"](_225_, ui["plugins-meta"]) then
    return exec_commit(ui)
  else
    return vim.notify("Nothing staged, refusing to commit")
  end
end
local function exec_keymap_s(ui)
  local _let_227_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_227_[1]
  local _ = _let_227_[2]
  local meta
  local function _228_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_228_, ui["plugins-meta"])
  if (meta and ("unstaged" == meta.state)) then
    meta["state"] = "staged"
    return schedule_redraw(ui)
  else
    return vim.notify("May only stage unstaged plugins")
  end
end
local function exec_keymap_u(ui)
  local _let_230_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_230_[1]
  local _ = _let_230_[2]
  local meta
  local function _231_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_231_, ui["plugins-meta"])
  if (meta and ("staged" == meta.state)) then
    meta["state"] = "unstaged"
    return schedule_redraw(ui)
  else
    return vim.notify("May only unstage staged plugins")
  end
end
local function exec_keymap__3d(ui)
  local _let_233_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_233_[1]
  local _ = _let_233_[2]
  local meta
  local function _234_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_234_, ui["plugins-meta"])
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
M.attach = function(win, buf, plugins)
  local function _238_(_241, _242)
    return result["ok?"](_242), result.unwrap(_242)
  end
  local _let_237_ = enum["group-by"](_238_, plugins)
  local ok_plugins = _let_237_[true]
  local err_plugins = _let_237_[false]
  if err_plugins then
    local function _239_(lines, _, _242)
      return enum["append$"](lines, fmt("  - %s", _242))
    end
    api.nvim_err_writeln((table.concat(enum.reduce(_239_, {"Some Pact plugins had configuration errors and wont be processed!"}, err_plugins), "\n") .. "\n"))
  else
  end
  if ok_plugins then
    local plugins_meta
    local function _241_(_241, _242)
      return {_242.id, {events = {}, text = "waiting for scheduler", order = _241, state = "waiting", action = nil, plugin = _242}}
    end
    plugins_meta = enum["pairs->table"](enum.map(_241_, ok_plugins))
    local max_name_length
    local function _242_(_241, _242, _243)
      return math.max(_241, #_243.name)
    end
    max_name_length = enum.reduce(_242_, 0, ok_plugins)
    local ui = {plugins = ok_plugins, ["plugins-meta"] = plugins_meta, win = win, buf = buf, ["ns-id"] = api.nvim_create_namespace("pact-ui"), layout = {["max-name-length"] = max_name_length}, scheduler = scheduler.new()}
    do
      api.nvim_buf_set_option(buf, "ft", "pact")
      local function _243_()
        return exec_keymap__3d(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "=", "", {callback = _243_})
      local function _244_()
        return exec_keymap_cc(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "cc", "", {callback = _244_})
      local function _245_()
        return exec_keymap_s(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "s", "", {callback = _245_})
      local function _246_()
        return exec_keymap_u(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "u", "", {callback = _246_})
    end
    exec_status(ui)
    return ui
  else
    return nil
  end
end
return M