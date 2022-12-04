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
local _local_16_, git_tasks, fs_tasks, enum, _local_17_, _local_18_, _local_19_, git_commit, _local_20_ = nil, nil, nil, nil, nil, nil, nil, nil, nil
do
  local _15_ = require("pact.plugin.constraint")
  local _14_ = require("pact.git.commit")
  local _13_ = require("pact.git.commit")
  local _12_ = require("pact.workflow")
  local _11_ = string
  local _10_ = require("pact.lib.ruin.enum")
  local _9_ = require("pact.workflow.exec.fs")
  local _8_ = require("pact.workflow.exec.git")
  local _7_ = require("pact.lib.ruin.result")
  _local_16_, git_tasks, fs_tasks, enum, _local_17_, _local_18_, _local_19_, git_commit, _local_20_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_, _14_, _15_
end
local _local_21_ = _local_16_
local err = _local_21_["err"]
local ok = _local_21_["ok"]
local _local_22_ = _local_17_
local fmt = _local_22_["format"]
local _local_23_ = _local_18_
local new_workflow = _local_23_["new"]
local yield = _local_23_["yield"]
local _local_24_ = _local_19_
local ref_lines__3ecommits = _local_24_["ref-lines->commits"]
local _local_25_ = _local_20_
local satisfies_constraint_3f = _local_25_["satisfies?"]
local solve_constraint = _local_25_["solve"]
do local _ = {nil, nil} end
local function absolute_path_3f(path)
  return not_nil_3f(string.match(path, "^/"))
end
local function git_dir_3f(path)
  return ("directory" == fs_tasks["what-is-at"]((path .. "/.git")))
end
local function commit_constraint_3f(c)
  local _26_ = c
  if ((_G.type(_26_) == "table") and ((_26_)[1] == "git") and ((_26_)[2] == "commit") and (nil ~= (_26_)[3])) then
    local any = (_26_)[3]
    return true
  elseif true then
    local __1_auto = _26_
    return false
  else
    return nil
  end
end
local function tag_constraint_3f(c)
  local _28_ = c
  if ((_G.type(_28_) == "table") and ((_28_)[1] == "git") and ((_28_)[2] == "tag") and (nil ~= (_28_)[3])) then
    local any = (_28_)[3]
    return true
  elseif true then
    local __1_auto = _28_
    return false
  else
    return nil
  end
end
local function branch_constraint_3f(c)
  local _30_ = c
  if ((_G.type(_30_) == "table") and ((_30_)[1] == "git") and ((_30_)[2] == "branch") and (nil ~= (_30_)[3])) then
    local any = (_30_)[3]
    return true
  elseif true then
    local __1_auto = _30_
    return false
  else
    return nil
  end
end
local function version_constraint_3f(c)
  local _32_ = c
  if ((_G.type(_32_) == "table") and ((_32_)[1] == "git") and ((_32_)[2] == "version") and (nil ~= (_32_)[3])) then
    local any = (_32_)[3]
    return true
  elseif true then
    local __1_auto = _32_
    return false
  else
    return nil
  end
end
local function same_sha_3f(a, b)
  local _34_ = {a, b}
  if ((_G.type(_34_) == "table") and ((_G.type((_34_)[1]) == "table") and (nil ~= ((_34_)[1]).sha)) and ((_G.type((_34_)[2]) == "table") and (((_34_)[1]).sha == ((_34_)[2]).sha))) then
    local sha = ((_34_)[1]).sha
    return true
  elseif true then
    local _ = _34_
    return false
  else
    return nil
  end
end
local function maybe_latest_version(remote_commits)
  return solve_constraint({"git", "version", "> 0.0.0"}, remote_commits)
end
local function maybe_newer_commit(target, remote_commits)
  local _3flatest = maybe_latest_version(remote_commits)
  if not same_sha_3f(target, _3flatest) then
    return _3flatest
  else
    return nil
  end
end
local __fn_2a_status_new_repo_impl_dispatch = {bodies = {}, help = {}}
local status_new_repo_impl
local function _37_(...)
  if (0 == #(__fn_2a_status_new_repo_impl_dispatch).bodies) then
    error(("multi-arity function " .. "status-new-repo-impl" .. " has no bodies"))
  else
  end
  local _39_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_status_new_repo_impl_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _39_ = f_74_auto
  end
  if (nil ~= _39_) then
    local f_74_auto = _39_
    return f_74_auto(...)
  elseif (_39_ == nil) then
    local view_77_auto
    do
      local _40_, _41_ = pcall(require, "fennel")
      if ((_40_ == true) and ((_G.type(_41_) == "table") and (nil ~= (_41_).view))) then
        local view_77_auto0 = (_41_).view
        view_77_auto = view_77_auto0
      elseif ((_40_ == false) and true) then
        local __75_auto = _41_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "status-new-repo-impl", view_77_auto({...}), table.concat((__fn_2a_status_new_repo_impl_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
status_new_repo_impl = _37_
local function _44_()
  do local _ = {} end
  return status_new_repo_impl
end
setmetatable({nil, nil}, {__call = _44_})()
do
  table.insert((__fn_2a_status_new_repo_impl_dispatch).help, "(where [repo-url constraint] (commit-constraint? constraint))")
  local function _47_(...)
    if (2 == select("#", ...)) then
      local _48_ = {...}
      local function _49_(...)
        local repo_url_45_ = (_48_)[1]
        local constraint_46_ = (_48_)[2]
        return commit_constraint_3f(constraint_46_)
      end
      if (((_G.type(_48_) == "table") and (nil ~= (_48_)[1]) and (nil ~= (_48_)[2])) and _49_(...)) then
        local repo_url_45_ = (_48_)[1]
        local constraint_46_ = (_48_)[2]
        local function _50_(repo_url, constraint)
          return ok({"clone", git_commit.commit(constraint[3])})
        end
        return _50_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_status_new_repo_impl_dispatch).bodies, _47_)
end
do
  table.insert((__fn_2a_status_new_repo_impl_dispatch).help, "(where [repo-url constraint] (or (tag-constraint? constraint) (branch-constraint? constraint) (version-constraint? constraint)))")
  local function _55_(...)
    if (2 == select("#", ...)) then
      local _56_ = {...}
      local function _57_(...)
        local repo_url_53_ = (_56_)[1]
        local constraint_54_ = (_56_)[2]
        return (tag_constraint_3f(constraint_54_) or branch_constraint_3f(constraint_54_) or version_constraint_3f(constraint_54_))
      end
      if (((_G.type(_56_) == "table") and (nil ~= (_56_)[1]) and (nil ~= (_56_)[2])) and _57_(...)) then
        local repo_url_53_ = (_56_)[1]
        local constraint_54_ = (_56_)[2]
        local function _58_(repo_url, constraint)
          local _let_59_ = require("pact.lib.ruin.result")
          local bind_15_auto = _let_59_["bind"]
          local unit_16_auto = _let_59_["unit"]
          local bind_60_ = bind_15_auto
          local unit_61_ = unit_16_auto
          local function _62_(_)
            local function _63_()
              local _let_64_ = require("pact.lib.ruin.result")
              local map_ok_24_auto = _let_64_["map-ok"]
              local result_25_auto = _let_64_["result"]
              local unwrap_26_auto = _let_64_["unwrap"]
              local function _65_(_241)
                return ref_lines__3ecommits(_241)
              end
              return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _65_)
            end
            local function _66_(remote_commits)
              local function _67_()
                yield("solving for constraint")
                local all_1_auto, val_2_auto = nil, nil
                do
                  local nil_68_ = solve_constraint(constraint, remote_commits)
                  if (nil ~= nil_68_) then
                    local target_commit = nil_68_
                    all_1_auto, val_2_auto = true, ok({"clone", target_commit}, maybe_latest_version(remote_commits))
                  else
                    all_1_auto, val_2_auto = false
                  end
                end
                if all_1_auto then
                  return val_2_auto
                else
                  return err(fmt("no commit satisfies %s", constraint))
                end
              end
              return unit_61_(_67_())
            end
            return unit_61_(bind_60_(unit_61_(_63_()), _66_))
          end
          return bind_60_(unit_61_(yield("fetching remote refs")), _62_)
        end
        return _58_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_status_new_repo_impl_dispatch).bodies, _55_)
end
local __fn_2a_status_existing_repo_impl_dispatch = {bodies = {}, help = {}}
local status_existing_repo_impl
local function _73_(...)
  if (0 == #(__fn_2a_status_existing_repo_impl_dispatch).bodies) then
    error(("multi-arity function " .. "status-existing-repo-impl" .. " has no bodies"))
  else
  end
  local _75_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_status_existing_repo_impl_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _75_ = f_74_auto
  end
  if (nil ~= _75_) then
    local f_74_auto = _75_
    return f_74_auto(...)
  elseif (_75_ == nil) then
    local view_77_auto
    do
      local _76_, _77_ = pcall(require, "fennel")
      if ((_76_ == true) and ((_G.type(_77_) == "table") and (nil ~= (_77_).view))) then
        local view_77_auto0 = (_77_).view
        view_77_auto = view_77_auto0
      elseif ((_76_ == false) and true) then
        local __75_auto = _77_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "status-existing-repo-impl", view_77_auto({...}), table.concat((__fn_2a_status_existing_repo_impl_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
status_existing_repo_impl = _73_
local function _80_()
  do local _ = {} end
  return status_existing_repo_impl
end
setmetatable({nil, nil}, {__call = _80_})()
do
  table.insert((__fn_2a_status_existing_repo_impl_dispatch).help, "(where [path repo-url constraint] (commit-constraint? constraint))")
  local function _84_(...)
    if (3 == select("#", ...)) then
      local _85_ = {...}
      local function _86_(...)
        local path_81_ = (_85_)[1]
        local repo_url_82_ = (_85_)[2]
        local constraint_83_ = (_85_)[3]
        return commit_constraint_3f(constraint_83_)
      end
      if (((_G.type(_85_) == "table") and (nil ~= (_85_)[1]) and (nil ~= (_85_)[2]) and (nil ~= (_85_)[3])) and _86_(...)) then
        local path_81_ = (_85_)[1]
        local repo_url_82_ = (_85_)[2]
        local constraint_83_ = (_85_)[3]
        local function _87_(path, repo_url, constraint)
          local _let_88_ = require("pact.lib.ruin.result")
          local bind_15_auto = _let_88_["bind"]
          local unit_16_auto = _let_88_["unit"]
          local bind_89_ = bind_15_auto
          local unit_90_ = unit_16_auto
          local function _91_(_)
            local function _92_(HEAD_sha)
              local function _93_(_0)
                local function _94_()
                  local _let_95_ = require("pact.lib.ruin.result")
                  local map_ok_24_auto = _let_95_["map-ok"]
                  local result_25_auto = _let_95_["result"]
                  local unwrap_26_auto = _let_95_["unwrap"]
                  local function _96_(_241)
                    return ref_lines__3ecommits(_241)
                  end
                  return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _96_)
                end
                local function _97_(remote_commits)
                  local function _98_(_1)
                    local function _99_(HEAD_commit)
                      local function _100_()
                        if satisfies_constraint_3f(constraint, HEAD_commit) then
                          return ok({"hold", HEAD_commit}, maybe_latest_version(remote_commits))
                        else
                          return ok({"sync", git_commit.commit(constraint[3])}, maybe_latest_version(remote_commits))
                        end
                      end
                      return unit_90_(_100_())
                    end
                    return unit_90_(bind_89_(unit_90_(git_commit.commit(HEAD_sha)), _99_))
                  end
                  return unit_90_(bind_89_(unit_90_(yield("reticulating splines")), _98_))
                end
                return unit_90_(bind_89_(unit_90_(_94_()), _97_))
              end
              return unit_90_(bind_89_(unit_90_(yield("fetching remote refs")), _93_))
            end
            return unit_90_(bind_89_(unit_90_(git_tasks["HEAD-sha"](path)), _92_))
          end
          return bind_89_(unit_90_(yield("checking local sha")), _91_)
        end
        return _87_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_status_existing_repo_impl_dispatch).bodies, _84_)
end
do
  table.insert((__fn_2a_status_existing_repo_impl_dispatch).help, "(where [path repo-url constraint] (or (tag-constraint? constraint) (branch-constraint? constraint)))")
  local function _107_(...)
    if (3 == select("#", ...)) then
      local _108_ = {...}
      local function _109_(...)
        local path_104_ = (_108_)[1]
        local repo_url_105_ = (_108_)[2]
        local constraint_106_ = (_108_)[3]
        return (tag_constraint_3f(constraint_106_) or branch_constraint_3f(constraint_106_))
      end
      if (((_G.type(_108_) == "table") and (nil ~= (_108_)[1]) and (nil ~= (_108_)[2]) and (nil ~= (_108_)[3])) and _109_(...)) then
        local path_104_ = (_108_)[1]
        local repo_url_105_ = (_108_)[2]
        local constraint_106_ = (_108_)[3]
        local function _110_(path, repo_url, constraint)
          local _let_111_ = require("pact.lib.ruin.result")
          local bind_15_auto = _let_111_["bind"]
          local unit_16_auto = _let_111_["unit"]
          local bind_112_ = bind_15_auto
          local unit_113_ = unit_16_auto
          local function _114_(_)
            local function _115_(HEAD_sha)
              local function _116_(_0)
                local function _117_()
                  local _let_118_ = require("pact.lib.ruin.result")
                  local map_ok_24_auto = _let_118_["map-ok"]
                  local result_25_auto = _let_118_["result"]
                  local unwrap_26_auto = _let_118_["unwrap"]
                  local function _119_(_241)
                    return ref_lines__3ecommits(_241)
                  end
                  return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _119_)
                end
                local function _120_(remote_commits)
                  local function _121_(_1)
                    local function _122_(_241, _242)
                      return satisfies_constraint_3f(constraint, _242)
                    end
                    local function _123_(_241, _242)
                      return ((not_nil_3f(_242.branch) or not_nil_3f(_242.tag)) and (HEAD_sha == _242.sha))
                    end
                    local function _124_(HEAD_commits)
                      local function _125_()
                        if enum.hd(HEAD_commits) then
                          return ok({"hold", enum.hd(HEAD_commits)}, maybe_latest_version(remote_commits))
                        else
                          local all_1_auto, val_2_auto = nil, nil
                          do
                            local nil_126_ = solve_constraint(constraint, remote_commits)
                            if (nil ~= nil_126_) then
                              local target_commit = nil_126_
                              all_1_auto, val_2_auto = true, ok({"sync", target_commit}, maybe_latest_version(remote_commits))
                            else
                              all_1_auto, val_2_auto = false
                            end
                          end
                          if all_1_auto then
                            return val_2_auto
                          else
                            return err(fmt("no commit satisfies %s", constraint))
                          end
                        end
                      end
                      return unit_113_(_125_())
                    end
                    return unit_113_(bind_112_(unit_113_(enum.filter(_122_, enum.filter(_123_, remote_commits))), _124_))
                  end
                  return unit_113_(bind_112_(unit_113_(yield("reticulating splines")), _121_))
                end
                return unit_113_(bind_112_(unit_113_(_117_()), _120_))
              end
              return unit_113_(bind_112_(unit_113_(yield("fetching remote refs")), _116_))
            end
            return unit_113_(bind_112_(unit_113_(git_tasks["HEAD-sha"](path)), _115_))
          end
          return bind_112_(unit_113_(yield("checking local sha")), _114_)
        end
        return _110_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_status_existing_repo_impl_dispatch).bodies, _107_)
end
do
  table.insert((__fn_2a_status_existing_repo_impl_dispatch).help, "(where [path repo-url constraint] (version-constraint? constraint))")
  local function _135_(...)
    if (3 == select("#", ...)) then
      local _136_ = {...}
      local function _137_(...)
        local path_132_ = (_136_)[1]
        local repo_url_133_ = (_136_)[2]
        local constraint_134_ = (_136_)[3]
        return version_constraint_3f(constraint_134_)
      end
      if (((_G.type(_136_) == "table") and (nil ~= (_136_)[1]) and (nil ~= (_136_)[2]) and (nil ~= (_136_)[3])) and _137_(...)) then
        local path_132_ = (_136_)[1]
        local repo_url_133_ = (_136_)[2]
        local constraint_134_ = (_136_)[3]
        local function _138_(path, repo_url, constraint)
          local _let_139_ = require("pact.lib.ruin.result")
          local bind_15_auto = _let_139_["bind"]
          local unit_16_auto = _let_139_["unit"]
          local bind_140_ = bind_15_auto
          local unit_141_ = unit_16_auto
          local function _142_(_)
            local function _143_(HEAD_sha)
              local function _144_(_0)
                local function _145_()
                  local _let_146_ = require("pact.lib.ruin.result")
                  local map_ok_24_auto = _let_146_["map-ok"]
                  local result_25_auto = _let_146_["result"]
                  local unwrap_26_auto = _let_146_["unwrap"]
                  local function _147_(_241)
                    return ref_lines__3ecommits(_241)
                  end
                  return map_ok_24_auto(result_25_auto(git_tasks["ls-remote"](repo_url)), _147_)
                end
                local function _148_(remote_commits)
                  local function _149_(_1)
                    local function _150_()
                      local all_1_auto, val_2_auto = nil, nil
                      do
                        local nil_152_ = solve_constraint(constraint, remote_commits)
                        if (nil ~= nil_152_) then
                          local target_commit = nil_152_
                          local nil_151_
                          local function _153_(_241, _242)
                            return satisfies_constraint_3f(constraint, _242)
                          end
                          local function _154_(_241, _242)
                            return (not_nil_3f(_242.version) and (HEAD_sha == _242.sha))
                          end
                          nil_151_ = enum.filter(_153_, enum.filter(_154_, remote_commits))
                          if (nil ~= nil_151_) then
                            local HEAD_commits = nil_151_
                            local function _156_()
                              local function _155_(_241, _242)
                                return (target_commit.sha == _242.sha)
                              end
                              if enum["any?"](_155_, HEAD_commits) then
                                return ok({"hold", target_commit}, maybe_newer_commit(target_commit, remote_commits))
                              else
                                return ok({"sync", target_commit}, maybe_newer_commit(target_commit, remote_commits), solve_constraint({"git", "version", "> 0.0.0"}, HEAD_commits))
                              end
                            end
                            all_1_auto, val_2_auto = true, _156_()
                          else
                            all_1_auto, val_2_auto = false
                          end
                        else
                          all_1_auto, val_2_auto = false
                        end
                      end
                      if all_1_auto then
                        return val_2_auto
                      else
                        return err(fmt("no commit satisfies %s", constraint))
                      end
                    end
                    return unit_141_(_150_())
                  end
                  return unit_141_(bind_140_(unit_141_(yield("reticulating splines")), _149_))
                end
                return unit_141_(bind_140_(unit_141_(_145_()), _148_))
              end
              return unit_141_(bind_140_(unit_141_(yield("fetching remote refs")), _144_))
            end
            return unit_141_(bind_140_(unit_141_(git_tasks["HEAD-sha"](path)), _143_))
          end
          return bind_140_(unit_141_(yield("checking local sha")), _142_)
        end
        return _138_
      else
        return nil
      end
    else
      return nil
    end
  end
  table.insert((__fn_2a_status_existing_repo_impl_dispatch).bodies, _135_)
end
local function detect_kind(repo_url, path, constraint)
  local _let_162_ = require("pact.lib.ruin.result")
  local map_ok_24_auto = _let_162_["map-ok"]
  local result_25_auto = _let_162_["result"]
  local unwrap_26_auto = _let_162_["unwrap"]
  local function _163_(_241)
    return (_241 or absolute_path_3f(path) or nil or fmt("plugin path must be absolute, got %s", path))
  end
  local function _164_(_241)
    local function _165_()
      if git_dir_3f(path) then
        return status_existing_repo_impl(path, repo_url, constraint)
      else
        return status_new_repo_impl(repo_url, constraint)
      end
    end
    return _165_(_241)
  end
  return map_ok_24_auto(map_ok_24_auto(result_25_auto(yield("starting git-status workflow")), _163_), _164_)
end
local __fn_2a_new_dispatch = {bodies = {}, help = {}}
local new
local function _171_(...)
  if (0 == #(__fn_2a_new_dispatch).bodies) then
    error(("multi-arity function " .. "new" .. " has no bodies"))
  else
  end
  local _173_
  do
    local f_74_auto = nil
    for __75_auto, match_3f_76_auto in ipairs((__fn_2a_new_dispatch).bodies) do
      if f_74_auto then break end
      f_74_auto = match_3f_76_auto(...)
    end
    _173_ = f_74_auto
  end
  if (nil ~= _173_) then
    local f_74_auto = _173_
    return f_74_auto(...)
  elseif (_173_ == nil) then
    local view_77_auto
    do
      local _174_, _175_ = pcall(require, "fennel")
      if ((_174_ == true) and ((_G.type(_175_) == "table") and (nil ~= (_175_).view))) then
        local view_77_auto0 = (_175_).view
        view_77_auto = view_77_auto0
      elseif ((_174_ == false) and true) then
        local __75_auto = _175_
        view_77_auto = (_G.vim.inspect or print)
      else
        view_77_auto = nil
      end
    end
    local msg_78_auto = string.format(("Multi-arity function %s had no matching head " .. "or default defined.\nCalled with: %s\nHeads:\n%s"), "new", view_77_auto({...}), table.concat((__fn_2a_new_dispatch).help, "\n"))
    return error(msg_78_auto)
  else
    return nil
  end
end
new = _171_
local function _178_()
  local function _179_()
    table.insert((__fn_2a_new_dispatch).help, "(where [id repo-url path constraint])")
    local function _180_(...)
      if (4 == select("#", ...)) then
        local _181_ = {...}
        local function _182_(...)
          local id_167_ = (_181_)[1]
          local repo_url_168_ = (_181_)[2]
          local path_169_ = (_181_)[3]
          local constraint_170_ = (_181_)[4]
          return true
        end
        if (((_G.type(_181_) == "table") and (nil ~= (_181_)[1]) and (nil ~= (_181_)[2]) and (nil ~= (_181_)[3]) and (nil ~= (_181_)[4])) and _182_(...)) then
          local id_167_ = (_181_)[1]
          local repo_url_168_ = (_181_)[2]
          local path_169_ = (_181_)[3]
          local constraint_170_ = (_181_)[4]
          local function _183_(id, repo_url, path, constraint)
            local function _184_()
              return detect_kind(repo_url, path, constraint)
            end
            return new_workflow(id, _184_)
          end
          return _183_
        else
          return nil
        end
      else
        return nil
      end
    end
    table.insert((__fn_2a_new_dispatch).bodies, _180_)
    return new
  end
  do local _ = {_179_()} end
  return new
end
setmetatable({nil, nil}, {__call = _178_})()
return {new = new}