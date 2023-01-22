
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local inspect, _local_11_, _local_12_, _local_13_ = nil, nil, nil, nil do local _10_ = string local _9_ = vim local _8_ = require("pact.exec") local _7_ = require("pact.inspect") inspect, _local_11_, _local_12_, _local_13_ = _7_, _8_, _9_, _10_ end local _local_14_ = _local_11_
 local cb__3eawait = _local_14_["cb->await"] local run = _local_14_["run"] local _local_15_ = _local_12_
 local uv = _local_15_["loop"] local _local_16_ = _local_13_
 local fmt = _local_16_["format"] do local _ = {nil, nil} end

 local const = {ENV = {"GIT_TERMINAL_PROMPT=0"}}
 local M = {}

 local function dump_err(code, err)
 return fmt("git-error: return-code: %s std-err: %s", code, inspect(err)) end

 M["create-stub-clone"] = function(repo_url, repo_path)


 local _17_, _18_, _19_ = cb__3eawait(run, {"git clone --no-checkout --filter=tree:0 $repo-url $repo-path", {["repo-url"] = repo_url, ["repo-path"] = repo_path, env = const.ENV}}) if ((_17_ == 0) and (nil ~= _18_) and (nil ~= _19_)) then local stdout_7_auto = _18_ local stderr_8_auto = _19_ local _20_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_20_) == "table") and true and (nil ~= (_20_)[2]) and true) then local _ = (_20_)[1] local lines = (_20_)[2] local _0 = (_20_)[3]

 return true elseif true then local __13_auto = _20_ return error(string.format("Unhandled success case for %s %s", "git clone --no-checkout --filter=tree:0 $repo-url $repo-path", inspect(__13_auto))) else return nil end elseif ((nil ~= _17_) and (nil ~= _18_) and (nil ~= _19_)) then local code_14_auto = _17_ local stdout_7_auto = _18_ local stderr_8_auto = _19_ local _22_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_22_) == "table") and (nil ~= (_22_)[1]) and (nil ~= (_22_)[2]) and (nil ~= (_22_)[3])) then local code = (_22_)[1] local out = (_22_)[2] local err = (_22_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _22_ return error(string.format("Unhandled success case for %s", "git clone --no-checkout --filter=tree:0 $repo-url $repo-path")) else return nil end elseif ((_17_ == nil) and (nil ~= _18_)) then local err_20_auto = _18_ return nil, err_20_auto else return nil end end

 M["update-refs"] = function(repo_path)



 local _25_, _26_, _27_ = cb__3eawait(run, {"git fetch --filter=tree:0", {cwd = repo_path, env = const.ENV}}) if ((_25_ == 0) and (nil ~= _26_) and (nil ~= _27_)) then local stdout_7_auto = _26_ local stderr_8_auto = _27_ local _28_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_28_) == "table") and true and (nil ~= (_28_)[2]) and true) then local _ = (_28_)[1] local lines = (_28_)[2] local _0 = (_28_)[3]
 return true elseif true then local __13_auto = _28_ return error(string.format("Unhandled success case for %s %s", "git fetch --filter=tree:0", inspect(__13_auto))) else return nil end elseif ((nil ~= _25_) and (nil ~= _26_) and (nil ~= _27_)) then local code_14_auto = _25_ local stdout_7_auto = _26_ local stderr_8_auto = _27_ local _30_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_30_) == "table") and (nil ~= (_30_)[1]) and (nil ~= (_30_)[2]) and (nil ~= (_30_)[3])) then local code = (_30_)[1] local out = (_30_)[2] local err = (_30_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _30_ return error(string.format("Unhandled success case for %s", "git fetch --filter=tree:0")) else return nil end elseif ((_25_ == nil) and (nil ~= _26_)) then local err_20_auto = _26_ return nil, err_20_auto else return nil end end

 local function verify_ref(repo_path, commit_ref)
 local _33_, _34_, _35_ = cb__3eawait(run, {"git show --format=%H -s $commit-ref", {["commit-ref"] = commit_ref, cwd = repo_path, env = const.ENV}}) if ((_33_ == 0) and (nil ~= _34_) and (nil ~= _35_)) then local stdout_7_auto = _34_ local stderr_8_auto = _35_ local _36_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_36_) == "table") and true and ((_G.type((_36_)[2]) == "table") and (nil ~= ((_36_)[2])[1])) and true) then local _ = (_36_)[1] local line = ((_36_)[2])[1] local _0 = (_36_)[3]

 return line elseif true then local __13_auto = _36_ return error(string.format("Unhandled success case for %s %s", "git show --format=%H -s $commit-ref", inspect(__13_auto))) else return nil end elseif ((nil ~= _33_) and (nil ~= _34_) and (nil ~= _35_)) then local code_14_auto = _33_ local stdout_7_auto = _34_ local stderr_8_auto = _35_ local _38_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_38_) == "table") and (nil ~= (_38_)[1]) and (nil ~= (_38_)[2]) and (nil ~= (_38_)[3])) then local code = (_38_)[1] local out = (_38_)[2] local err = (_38_)[3]
 return false elseif true then local __19_auto = _38_ return error(string.format("Unhandled success case for %s", "git show --format=%H -s $commit-ref")) else return nil end elseif ((_33_ == nil) and (nil ~= _34_)) then local err_20_auto = _34_ return nil, err_20_auto else return nil end end

 M["verify-commit"] = function(repo_path, sha)

 return verify_ref(repo_path, sha) end

 M["verify-branch"] = function(repo_path, branch)



 return verify_ref(repo_path, ("refs/remotes/origin/" .. branch)) end

 M["verify-tag"] = function(repo_path, tag)



 return verify_ref(repo_path, ("refs/tags/" .. tag)) end

 M["ls-local"] = function(repo_path)
 local _41_, _42_, _43_ = cb__3eawait(run, {"git show-ref --dereference", {cwd = repo_path, env = const.ENV}}) if ((_41_ == 0) and (nil ~= _42_) and (nil ~= _43_)) then local stdout_7_auto = _42_ local stderr_8_auto = _43_ local _44_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_44_) == "table") and true and (nil ~= (_44_)[2]) and true) then local _ = (_44_)[1] local lines = (_44_)[2] local _0 = (_44_)[3]
 return lines elseif true then local __13_auto = _44_ return error(string.format("Unhandled success case for %s %s", "git show-ref --dereference", inspect(__13_auto))) else return nil end elseif ((nil ~= _41_) and (nil ~= _42_) and (nil ~= _43_)) then local code_14_auto = _41_ local stdout_7_auto = _42_ local stderr_8_auto = _43_ local _46_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_46_) == "table") and (nil ~= (_46_)[1]) and (nil ~= (_46_)[2]) and (nil ~= (_46_)[3])) then local code = (_46_)[1] local out = (_46_)[2] local err = (_46_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _46_ return error(string.format("Unhandled success case for %s", "git show-ref --dereference")) else return nil end elseif ((_41_ == nil) and (nil ~= _42_)) then local err_20_auto = _42_ return nil, err_20_auto else return nil end end

 M["ls-remote"] = function(repo_path_or_url)

 local function url_3f(str)
 local str0 = string.lower(str)
 local http = string.match(str0, "^http")
 local ssh = string.match(str0, "^ssh")
 return not (function(_49_,_50_,_51_) return (_49_ == _50_) and (_50_ == _51_) end)(nil,http,ssh) end
 local cmd, cwd = nil, nil do local _52_ = url_3f(repo_path_or_url) if (_52_ == true) then
 cmd, cwd = "git ls-remote $repo-path-or-url tags/* heads/* HEAD", "." elseif (_52_ == false) then
 cmd, cwd = "git ls-remote origin tags/* heads/* HEAD", repo_path_or_url else cmd, cwd = nil end end
 local _54_, _55_, _56_ = cb__3eawait(run, {cmd, {["repo-path-or-url"] = repo_path_or_url, cwd = cwd, env = const.ENV}}) if ((_54_ == 0) and (nil ~= _55_) and (nil ~= _56_)) then local stdout_7_auto = _55_ local stderr_8_auto = _56_ local _57_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_57_) == "table") and true and (nil ~= (_57_)[2]) and true) then local _ = (_57_)[1] local lines = (_57_)[2] local _0 = (_57_)[3]
 return lines elseif true then local __13_auto = _57_ return error(string.format("Unhandled success case for %s %s", cmd, inspect(__13_auto))) else return nil end elseif ((nil ~= _54_) and (nil ~= _55_) and (nil ~= _56_)) then local code_14_auto = _54_ local stdout_7_auto = _55_ local stderr_8_auto = _56_ local _59_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_59_) == "table") and (nil ~= (_59_)[1]) and (nil ~= (_59_)[2]) and (nil ~= (_59_)[3])) then local code = (_59_)[1] local out = (_59_)[2] local err = (_59_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _59_ return error(string.format("Unhandled success case for %s", cmd)) else return nil end elseif ((_54_ == nil) and (nil ~= _55_)) then local err_20_auto = _55_ return nil, err_20_auto else return nil end end

 M["sha-timestamp"] = function(repo_root, sha) _G.assert((nil ~= sha), "Missing argument sha on ./fnl/pact/package/git/exec.fnl:72") _G.assert((nil ~= repo_root), "Missing argument repo-root on ./fnl/pact/package/git/exec.fnl:72")
 local _62_, _63_, _64_ = cb__3eawait(run, {"git show --format=%at -s $sha", {cwd = repo_root, sha = sha, env = const.ENV}}) if ((_62_ == 0) and (nil ~= _63_) and (nil ~= _64_)) then local stdout_7_auto = _63_ local stderr_8_auto = _64_ local _65_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_65_) == "table") and ((_65_)[1] == 0) and ((_G.type((_65_)[2]) == "table") and (nil ~= ((_65_)[2])[1])) and true) then local ts = ((_65_)[2])[1] local _ = (_65_)[3]
 return ts elseif true then local __13_auto = _65_ return error(string.format("Unhandled success case for %s %s", "git show --format=%at -s $sha", inspect(__13_auto))) else return nil end elseif ((nil ~= _62_) and (nil ~= _63_) and (nil ~= _64_)) then local code_14_auto = _62_ local stdout_7_auto = _63_ local stderr_8_auto = _64_ local _67_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_67_) == "table") and (nil ~= (_67_)[1]) and (nil ~= (_67_)[2]) and (nil ~= (_67_)[3])) then local code = (_67_)[1] local out = (_67_)[2] local err = (_67_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _67_ return error(string.format("Unhandled success case for %s", "git show --format=%at -s $sha")) else return nil end elseif ((_62_ == nil) and (nil ~= _63_)) then local err_20_auto = _63_ return nil, err_20_auto else return nil end end

 M["HEAD-sha"] = function(repo_root)
 assert(repo_root, "must provide repo root")

 local _70_, _71_, _72_ = cb__3eawait(run, {"git rev-parse --sq HEAD", {cwd = repo_root, env = const.ENV}}) if ((_70_ == 0) and (nil ~= _71_) and (nil ~= _72_)) then local stdout_7_auto = _71_ local stderr_8_auto = _72_ local _73_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_73_) == "table") and ((_73_)[1] == 0) and ((_G.type((_73_)[2]) == "table") and (nil ~= ((_73_)[2])[1])) and true) then local line = ((_73_)[2])[1] local _ = (_73_)[3]
 local _74_ = string.match(line, "([%x]+)") if (_74_ == nil) then
 return nil, "could not find SHA in command output" elseif (nil ~= _74_) then local sha = _74_
 return sha else return nil end elseif true then local __13_auto = _73_ return error(string.format("Unhandled success case for %s %s", "git rev-parse --sq HEAD", inspect(__13_auto))) else return nil end elseif ((nil ~= _70_) and (nil ~= _71_) and (nil ~= _72_)) then local code_14_auto = _70_ local stdout_7_auto = _71_ local stderr_8_auto = _72_ local _77_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_77_) == "table") and (nil ~= (_77_)[1]) and (nil ~= (_77_)[2]) and (nil ~= (_77_)[3])) then local code = (_77_)[1] local out = (_77_)[2] local err = (_77_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _77_ return error(string.format("Unhandled success case for %s", "git rev-parse --sq HEAD")) else return nil end elseif ((_70_ == nil) and (nil ~= _71_)) then local err_20_auto = _71_ return nil, err_20_auto else return nil end end

 M["checkout-sha"] = function(repo_path, sha)
 local _80_, _81_, _82_ = cb__3eawait(run, {"git checkout $sha", {sha = sha, cwd = repo_path, env = const.ENV}}) if ((_80_ == 0) and (nil ~= _81_) and (nil ~= _82_)) then local stdout_7_auto = _81_ local stderr_8_auto = _82_ local _83_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_83_) == "table") and true and true and true) then local _ = (_83_)[1] local _0 = (_83_)[2] local _1 = (_83_)[3]
 return true elseif true then local __13_auto = _83_ return error(string.format("Unhandled success case for %s %s", "git checkout $sha", inspect(__13_auto))) else return nil end elseif ((nil ~= _80_) and (nil ~= _81_) and (nil ~= _82_)) then local code_14_auto = _80_ local stdout_7_auto = _81_ local stderr_8_auto = _82_ local _85_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_85_) == "table") and (nil ~= (_85_)[1]) and (nil ~= (_85_)[2]) and (nil ~= (_85_)[3])) then local code = (_85_)[1] local out = (_85_)[2] local err = (_85_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _85_ return error(string.format("Unhandled success case for %s", "git checkout $sha")) else return nil end elseif ((_80_ == nil) and (nil ~= _81_)) then local err_20_auto = _81_ return nil, err_20_auto else return nil end end

 M["update-submodules"] = function(repo_path)
 local _88_, _89_, _90_ = cb__3eawait(run, {"git submodule update --init --recursive", {cwd = repo_path, env = const.ENV}}) if ((_88_ == 0) and (nil ~= _89_) and (nil ~= _90_)) then local stdout_7_auto = _89_ local stderr_8_auto = _90_ local _91_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_91_) == "table") and true and (nil ~= (_91_)[2]) and true) then local _ = (_91_)[1] local lines = (_91_)[2] local _0 = (_91_)[3]
 return lines elseif true then local __13_auto = _91_ return error(string.format("Unhandled success case for %s %s", "git submodule update --init --recursive", inspect(__13_auto))) else return nil end elseif ((nil ~= _88_) and (nil ~= _89_) and (nil ~= _90_)) then local code_14_auto = _88_ local stdout_7_auto = _89_ local stderr_8_auto = _90_ local _93_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_93_) == "table") and (nil ~= (_93_)[1]) and (nil ~= (_93_)[2]) and (nil ~= (_93_)[3])) then local code = (_93_)[1] local out = (_93_)[2] local err = (_93_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _93_ return error(string.format("Unhandled success case for %s", "git submodule update --init --recursive")) else return nil end elseif ((_88_ == nil) and (nil ~= _89_)) then local err_20_auto = _89_ return nil, err_20_auto else return nil end end










 M["log-diff"] = function(repo_path, old_sha, new_sha)


 local _96_, _97_, _98_ = cb__3eawait(run, {"git log --oneline --no-abbrev-commit --decorate $range", {range = fmt("%s..%s", old_sha, new_sha), cwd = repo_path, env = const.ENV}}) if ((_96_ == 0) and (nil ~= _97_) and (nil ~= _98_)) then local stdout_7_auto = _97_ local stderr_8_auto = _98_ local _99_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_99_) == "table") and true and (nil ~= (_99_)[2]) and true) then local _ = (_99_)[1] local log = (_99_)[2] local _0 = (_99_)[3]



 return log elseif true then local __13_auto = _99_ return error(string.format("Unhandled success case for %s %s", "git log --oneline --no-abbrev-commit --decorate $range", inspect(__13_auto))) else return nil end elseif ((nil ~= _96_) and (nil ~= _97_) and (nil ~= _98_)) then local code_14_auto = _96_ local stdout_7_auto = _97_ local stderr_8_auto = _98_ local _101_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_101_) == "table") and (nil ~= (_101_)[1]) and (nil ~= (_101_)[2]) and (nil ~= (_101_)[3])) then local code = (_101_)[1] local out = (_101_)[2] local err = (_101_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _101_ return error(string.format("Unhandled success case for %s", "git log --oneline --no-abbrev-commit --decorate $range")) else return nil end elseif ((_96_ == nil) and (nil ~= _97_)) then local err_20_auto = _97_ return nil, err_20_auto else return nil end end

 M["log-breaking"] = function(repo_path, old_sha, new_sha)
 local _104_, _105_, _106_ = cb__3eawait(run, {"git log --oneline --no-abbrev-commit --format=%H --grep=breaking --regexp-ignore-case $range", {range = fmt("%s..%s", old_sha, new_sha), cwd = repo_path, env = const.ENV}}) if ((_104_ == 0) and (nil ~= _105_) and (nil ~= _106_)) then local stdout_7_auto = _105_ local stderr_8_auto = _106_ local _107_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_107_) == "table") and true and (nil ~= (_107_)[2]) and true) then local _ = (_107_)[1] local log = (_107_)[2] local _0 = (_107_)[3]



 return log elseif true then local __13_auto = _107_ return error(string.format("Unhandled success case for %s %s", "git log --oneline --no-abbrev-commit --format=%H --grep=breaking --regexp-ignore-case $range", inspect(__13_auto))) else return nil end elseif ((nil ~= _104_) and (nil ~= _105_) and (nil ~= _106_)) then local code_14_auto = _104_ local stdout_7_auto = _105_ local stderr_8_auto = _106_ local _109_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_109_) == "table") and (nil ~= (_109_)[1]) and (nil ~= (_109_)[2]) and (nil ~= (_109_)[3])) then local code = (_109_)[1] local out = (_109_)[2] local err = (_109_)[3]
 return nil, dump_err(code, {out, err}) elseif true then local __19_auto = _109_ return error(string.format("Unhandled success case for %s", "git log --oneline --no-abbrev-commit --format=%H --grep=breaking --regexp-ignore-case $range")) else return nil end elseif ((_104_ == nil) and (nil ~= _105_)) then local err_20_auto = _105_ return nil, err_20_auto else return nil end end

 M.clone = function(url, repo_path)
 local _112_, _113_, _114_ = cb__3eawait(run, {"git clone --no-checkout --filter=tree:0 $url $repo-path", {url = url, ["repo-path"] = repo_path, env = const.ENV}}) if ((_112_ == 0) and (nil ~= _113_) and (nil ~= _114_)) then local stdout_7_auto = _113_ local stderr_8_auto = _114_ local _115_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_115_) == "table") and true and (nil ~= (_115_)[2]) and (nil ~= (_115_)[3])) then local _ = (_115_)[1] local lines = (_115_)[2] local e = (_115_)[3]


 return true elseif true then local __13_auto = _115_ return error(string.format("Unhandled success case for %s %s", "git clone --no-checkout --filter=tree:0 $url $repo-path", inspect(__13_auto))) else return nil end elseif ((nil ~= _112_) and (nil ~= _113_) and (nil ~= _114_)) then local code_14_auto = _112_ local stdout_7_auto = _113_ local stderr_8_auto = _114_ local _117_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_117_) == "table") and (nil ~= (_117_)[1]) and (nil ~= (_117_)[2]) and (nil ~= (_117_)[3])) then local code = (_117_)[1] local o = (_117_)[2] local e = (_117_)[3]

 return nil, dump_err(code, o, e) elseif true then local __19_auto = _117_ return error(string.format("Unhandled success case for %s", "git clone --no-checkout --filter=tree:0 $url $repo-path")) else return nil end elseif ((_112_ == nil) and (nil ~= _113_)) then local err_20_auto = _113_ return nil, err_20_auto else return nil end end

 M["add-worktree"] = function(repo_path, worktree_path, sha)


 local _120_, _121_, _122_ = cb__3eawait(run, {"git worktree add --no-checkout --detach $worktree-path $sha", {["worktree-path"] = worktree_path, sha = sha, cwd = repo_path, env = const.ENV}}) if ((_120_ == 0) and (nil ~= _121_) and (nil ~= _122_)) then local stdout_7_auto = _121_ local stderr_8_auto = _122_ local _123_ = {0, stdout_7_auto, stderr_8_auto} if ((_G.type(_123_) == "table") and true and (nil ~= (_123_)[2]) and (nil ~= (_123_)[3])) then local _ = (_123_)[1] local lines = (_123_)[2] local e = (_123_)[3]


 return true elseif true then local __13_auto = _123_ return error(string.format("Unhandled success case for %s %s", "git worktree add --no-checkout --detach $worktree-path $sha", inspect(__13_auto))) else return nil end elseif ((nil ~= _120_) and (nil ~= _121_) and (nil ~= _122_)) then local code_14_auto = _120_ local stdout_7_auto = _121_ local stderr_8_auto = _122_ local _125_ = {code_14_auto, stdout_7_auto, stderr_8_auto} if ((_G.type(_125_) == "table") and (nil ~= (_125_)[1]) and (nil ~= (_125_)[2]) and (nil ~= (_125_)[3])) then local code = (_125_)[1] local o = (_125_)[2] local e = (_125_)[3]

 return nil, dump_err(code, {o, e}) elseif true then local __19_auto = _125_ return error(string.format("Unhandled success case for %s", "git worktree add --no-checkout --detach $worktree-path $sha")) else return nil end elseif ((_120_ == nil) and (nil ~= _121_)) then local err_20_auto = _121_ return nil, err_20_auto else return nil end end

 return M