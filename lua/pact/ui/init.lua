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
      local _86_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _87_(...)
          if (1 == select("#", ...)) then
            local _88_ = {...}
            local function _89_(...)
              local event_63_ = (_88_)[1]
              return err_3f(event_63_)
            end
            if (((_G.type(_88_) == "table") and (nil ~= (_88_)[1])) and _89_(...)) then
              local event_63_ = (_88_)[1]
              local function _90_(event)
                local _let_91_ = event
                local _ = _let_91_[1]
                local e = _let_91_[2]
                enum["append$"](meta.events, event)
                meta.state = "error"
                meta.text = e
                meta.progress = nil
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _90_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _87_)
        _86_ = handler0
      end
      local _94_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _95_(...)
          if (1 == select("#", ...)) then
            local _96_ = {...}
            local function _97_(...)
              local msg_64_ = (_96_)[1]
              return string_3f(msg_64_)
            end
            if (((_G.type(_96_) == "table") and (nil ~= (_96_)[1])) and _97_(...)) then
              local msg_64_ = (_96_)[1]
              local function _98_(msg)
                enum["append$"](meta.events, msg)
                meta.text = msg
                meta.progress = nil
                return schedule_redraw(ui)
              end
              return _98_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _95_)
        _94_ = handler0
      end
      local _101_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _102_(...)
          if (1 == select("#", ...)) then
            local _103_ = {...}
            local function _104_(...)
              local future_65_ = (_103_)[1]
              return thread_3f(future_65_)
            end
            if (((_G.type(_103_) == "table") and (nil ~= (_103_)[1])) and _104_(...)) then
              local future_65_ = (_103_)[1]
              local function _105_(future)
                meta.progress = rate_limited_inc((meta.progress or {0, 0}))
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
      local function _108_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _109_(...)
          if true then
            local _110_ = {...}
            local function _111_(...)
              return true
            end
            if ((_G.type(_110_) == "table") and _111_(...)) then
              local function _112_(...)
                return nil
              end
              return _112_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _109_)
        return handler0
      end
      do local _ = {_74_, _86_, _94_, _101_, _108_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _73_})()
    subscribe(wf, handler)
    return wf
  end
  local function _115_(_, meta)
    meta["state"] = "held"
    return nil
  end
  local function _116_(_241, _242)
    return ("unstaged" == _242.state)
  end
  enum.map(_115_, enum.filter(_116_, ui["plugins-meta"]))
  local function _117_(_, meta)
    local wf = make_wf(meta.action[1], meta.plugin, meta.action[2])
    scheduler["add-workflow"](ui.scheduler, wf)
    do end (meta)["state"] = "active"
    return nil
  end
  local function _118_(_241, _242)
    return ("staged" == _242.state)
  end
  enum.map(_117_, enum.filter(_118_, ui["plugins-meta"]))
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
    local function _123_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _125_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _125_ = f_74_auto
      end
      if (nil ~= _125_) then
        local f_74_auto = _125_
        return f_74_auto(...)
      elseif (_125_ == nil) then
        local view_77_auto
        do
          local _126_, _127_ = pcall(require, "fennel")
          if ((_126_ == true) and ((_G.type(_127_) == "table") and (nil ~= (_127_).view))) then
            local view_77_auto0 = (_127_).view
            view_77_auto = view_77_auto0
          elseif ((_126_ == false) and true) then
            local __75_auto = _127_
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
    handler0 = _123_
    local function _130_()
      local _131_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _132_(...)
          if (1 == select("#", ...)) then
            local _133_ = {...}
            local function _134_(...)
              local event_119_ = (_133_)[1]
              return ok_3f(event_119_)
            end
            if (((_G.type(_133_) == "table") and (nil ~= (_133_)[1])) and _134_(...)) then
              local event_119_ = (_133_)[1]
              local function _135_(event)
                local _let_136_ = event
                local _ = _let_136_[1]
                local log = _let_136_[2]
                enum["append$"](meta0.events, event)
                meta0.text = previous_text
                meta0.progress = nil
                meta0.log = log
                meta0["log-open"] = true
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _135_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _132_)
        _131_ = handler0
      end
      local _139_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _140_(...)
          if (1 == select("#", ...)) then
            local _141_ = {...}
            local function _142_(...)
              local event_120_ = (_141_)[1]
              return err_3f(event_120_)
            end
            if (((_G.type(_141_) == "table") and (nil ~= (_141_)[1])) and _142_(...)) then
              local event_120_ = (_141_)[1]
              local function _143_(event)
                local _let_144_ = event
                local _ = _let_144_[1]
                local e = _let_144_[2]
                enum["append$"](meta0.events, event)
                meta0.text = e
                meta0.progress = nil
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _143_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _140_)
        _139_ = handler0
      end
      local _147_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _148_(...)
          if (1 == select("#", ...)) then
            local _149_ = {...}
            local function _150_(...)
              local msg_121_ = (_149_)[1]
              return string_3f(msg_121_)
            end
            if (((_G.type(_149_) == "table") and (nil ~= (_149_)[1])) and _150_(...)) then
              local msg_121_ = (_149_)[1]
              local function _151_(msg)
                local meta1 = ui["plugins-meta"][wf.id]
                enum["append$"](meta1.events, msg)
                do end (meta1)["text"] = msg
                return schedule_redraw(ui)
              end
              return _151_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _148_)
        _147_ = handler0
      end
      local _154_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _155_(...)
          if (1 == select("#", ...)) then
            local _156_ = {...}
            local function _157_(...)
              local future_122_ = (_156_)[1]
              return thread_3f(future_122_)
            end
            if (((_G.type(_156_) == "table") and (nil ~= (_156_)[1])) and _157_(...)) then
              local future_122_ = (_156_)[1]
              local function _158_(future)
                meta0.progress = rate_limited_inc((meta0.progress or {0, 0}))
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
      local function _161_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _162_(...)
          if true then
            local _163_ = {...}
            local function _164_(...)
              return true
            end
            if ((_G.type(_163_) == "table") and _164_(...)) then
              local function _165_(...)
                return nil
              end
              return _165_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _162_)
        return handler0
      end
      do local _ = {_131_, _139_, _147_, _154_, _161_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _130_})()
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
    local function _172_(...)
      if (0 == #(__fn_2a_handler_dispatch).bodies) then
        error(("multi-arity function " .. "handler" .. " has no bodies"))
      else
      end
      local _174_
      do
        local f_74_auto = nil
        for __75_auto, match_3f_76_auto in ipairs((__fn_2a_handler_dispatch).bodies) do
          if f_74_auto then break end
          f_74_auto = match_3f_76_auto(...)
        end
        _174_ = f_74_auto
      end
      if (nil ~= _174_) then
        local f_74_auto = _174_
        return f_74_auto(...)
      elseif (_174_ == nil) then
        local view_77_auto
        do
          local _175_, _176_ = pcall(require, "fennel")
          if ((_175_ == true) and ((_G.type(_176_) == "table") and (nil ~= (_176_).view))) then
            local view_77_auto0 = (_176_).view
            view_77_auto = view_77_auto0
          elseif ((_175_ == false) and true) then
            local __75_auto = _176_
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
    handler0 = _172_
    local function _179_()
      local _180_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (ok? event))")
        local function _181_(...)
          if (1 == select("#", ...)) then
            local _182_ = {...}
            local function _183_(...)
              local event_168_ = (_182_)[1]
              return ok_3f(event_168_)
            end
            if (((_G.type(_182_) == "table") and (nil ~= (_182_)[1])) and _183_(...)) then
              local event_168_ = (_182_)[1]
              local function _184_(event)
                local command, _3fmaybe_latest = result.unwrap(event)
                local text
                local function _185_(_241)
                  local _186_ = _3fmaybe_latest
                  if (nil ~= _186_) then
                    local commit = _186_
                    return fmt("%s, latest: %s)", _241, commit)
                  elseif (_186_ == nil) then
                    return fmt("%s)", _241)
                  else
                    return nil
                  end
                end
                local function _189_()
                  local _188_ = command
                  if ((_G.type(_188_) == "table") and ((_188_)[1] == "hold") and (nil ~= (_188_)[2])) then
                    local commit = (_188_)[2]
                    return fmt("(at %s", commit)
                  elseif ((_G.type(_188_) == "table") and (nil ~= (_188_)[1]) and (nil ~= (_188_)[2])) then
                    local action = (_188_)[1]
                    local commit = (_188_)[2]
                    return fmt("(%s %s", action, commit)
                  else
                    return nil
                  end
                end
                text = _185_(_189_())
                enum["append$"](meta.events, event)
                meta.text = text
                meta.progress = nil
                do
                  local _191_ = command
                  if ((_G.type(_191_) == "table") and ((_191_)[1] == "hold") and (nil ~= (_191_)[2])) then
                    local commit = (_191_)[2]
                    meta.state = "up-to-date"
                  elseif ((_G.type(_191_) == "table") and (nil ~= (_191_)[1]) and (nil ~= (_191_)[2])) then
                    local action = (_191_)[1]
                    local commit = (_191_)[2]
                    meta.state = "unstaged"
                    meta.action = {action, commit}
                  else
                  end
                end
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _184_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _181_)
        _180_ = handler0
      end
      local _195_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [event] (err? event))")
        local function _196_(...)
          if (1 == select("#", ...)) then
            local _197_ = {...}
            local function _198_(...)
              local event_169_ = (_197_)[1]
              return err_3f(event_169_)
            end
            if (((_G.type(_197_) == "table") and (nil ~= (_197_)[1])) and _198_(...)) then
              local event_169_ = (_197_)[1]
              local function _199_(event)
                meta.state = "error"
                enum["append$"](meta.events, event)
                meta.progress = nil
                meta.text = result.unwrap(event)
                unsubscribe(wf, handler0)
                return schedule_redraw(ui)
              end
              return _199_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _196_)
        _195_ = handler0
      end
      local _202_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [msg] (string? msg))")
        local function _203_(...)
          if (1 == select("#", ...)) then
            local _204_ = {...}
            local function _205_(...)
              local msg_170_ = (_204_)[1]
              return string_3f(msg_170_)
            end
            if (((_G.type(_204_) == "table") and (nil ~= (_204_)[1])) and _205_(...)) then
              local msg_170_ = (_204_)[1]
              local function _206_(msg)
                enum["append$"](meta.events, msg)
                meta.progress = nil
                meta.text = msg
                return schedule_redraw(ui)
              end
              return _206_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _203_)
        _202_ = handler0
      end
      local _209_
      do
        table.insert((__fn_2a_handler_dispatch).help, "(where [future] (thread? future))")
        local function _210_(...)
          if (1 == select("#", ...)) then
            local _211_ = {...}
            local function _212_(...)
              local future_171_ = (_211_)[1]
              return thread_3f(future_171_)
            end
            if (((_G.type(_211_) == "table") and (nil ~= (_211_)[1])) and _212_(...)) then
              local future_171_ = (_211_)[1]
              local function _213_(future)
                meta.progress = rate_limited_inc((meta.progress or {0, 0}))
                return schedule_redraw(ui)
              end
              return _213_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _210_)
        _209_ = handler0
      end
      local function _216_()
        table.insert((__fn_2a_handler_dispatch).help, "(where _)")
        local function _217_(...)
          if true then
            local _218_ = {...}
            local function _219_(...)
              return true
            end
            if ((_G.type(_218_) == "table") and _219_(...)) then
              local function _220_(...)
                return nil
              end
              return _220_
            else
              return nil
            end
          else
            return nil
          end
        end
        table.insert((__fn_2a_handler_dispatch).bodies, _217_)
        return handler0
      end
      do local _ = {_180_, _195_, _202_, _209_, _216_()} end
      return handler0
    end
    handler = setmetatable({nil, nil}, {__call = _179_})()
    subscribe(wf, handler)
    return wf
  end
  schedule_redraw(ui)
  local function _223_(_, plugin)
    return scheduler["add-workflow"](ui.scheduler, make_status_wf(plugin))
  end
  return enum.map(_223_, ui.plugins)
end
local function exec_keymap_cc(ui)
  local function _224_(_241, _242)
    return ("staged" == _242.state)
  end
  if enum["any?"](_224_, ui["plugins-meta"]) then
    return exec_commit(ui)
  else
    return vim.notify("Nothing staged, refusing to commit")
  end
end
local function exec_keymap_s(ui)
  local _let_226_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_226_[1]
  local _ = _let_226_[2]
  local meta
  local function _227_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_227_, ui["plugins-meta"])
  if (meta and ("unstaged" == meta.state)) then
    meta["state"] = "staged"
    return schedule_redraw(ui)
  else
    return vim.notify("May only stage unstaged plugins")
  end
end
local function exec_keymap_u(ui)
  local _let_229_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_229_[1]
  local _ = _let_229_[2]
  local meta
  local function _230_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_230_, ui["plugins-meta"])
  if (meta and ("staged" == meta.state)) then
    meta["state"] = "unstaged"
    return schedule_redraw(ui)
  else
    return vim.notify("May only unstage staged plugins")
  end
end
local function exec_keymap__3d(ui)
  local _let_232_ = api.nvim_win_get_cursor(ui.win)
  local line = _let_232_[1]
  local _ = _let_232_[2]
  local meta
  local function _233_(_241, _242)
    return (line == _242["on-line"])
  end
  meta = enum["find-value"](_233_, ui["plugins-meta"])
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
  local function _237_(_241, _242)
    return result["ok?"](_242), result.unwrap(_242)
  end
  local _let_236_ = enum["group-by"](_237_, plugins)
  local ok_plugins = _let_236_[true]
  local err_plugins = _let_236_[false]
  if err_plugins then
    local function _238_(lines, _, _242)
      return enum["append$"](lines, fmt("  - %s", _242))
    end
    api.nvim_err_writeln((table.concat(enum.reduce(_238_, {"Some Pact plugins had configuration errors and wont be processed!"}, err_plugins), "\n") .. "\n"))
  else
  end
  if ok_plugins then
    local plugins_meta
    local function _240_(_241, _242)
      return {_242.id, {events = {}, text = "waiting for scheduler", order = _241, state = "waiting", action = nil, plugin = _242}}
    end
    plugins_meta = enum["pairs->table"](enum.map(_240_, ok_plugins))
    local max_name_length
    local function _241_(_241, _242, _243)
      return math.max(_241, #_243.name)
    end
    max_name_length = enum.reduce(_241_, 0, ok_plugins)
    local ui = {plugins = ok_plugins, ["plugins-meta"] = plugins_meta, win = win, buf = buf, ["ns-id"] = api.nvim_create_namespace("pact-ui"), layout = {["max-name-length"] = max_name_length}, scheduler = scheduler.new()}
    do
      api.nvim_buf_set_option(buf, "ft", "pact")
      local function _242_()
        return exec_keymap__3d(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "=", "", {callback = _242_})
      local function _243_()
        return exec_keymap_cc(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "cc", "", {callback = _243_})
      local function _244_()
        return exec_keymap_s(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "s", "", {callback = _244_})
      local function _245_()
        return exec_keymap_u(ui)
      end
      api.nvim_buf_set_keymap(buf, "n", "u", "", {callback = _245_})
    end
    exec_status(ui)
    return ui
  else
    return nil
  end
end
return M