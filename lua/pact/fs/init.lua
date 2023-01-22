
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, _local_10_, _local_11_ = nil, nil, nil do local _9_ = vim local _8_ = string local _7_ = require("pact.lib.ruin.enum") E, _local_10_, _local_11_ = _7_, _8_, _9_ end local _local_12_ = _local_10_
 local fmt = _local_12_["format"] local _local_13_ = _local_11_
 local uv = _local_13_["loop"]

 local function join_path(...)
 local _14_ local function _15_(_241, _242) return (_241 .. "/" .. _242) end _14_ = string.gsub(E.reduce(_15_, {...}), "//+", "/") return _14_ end


 local function what_is_at(path)

 local _16_, _17_, _18_ = uv.fs_stat(path) if ((_G.type(_16_) == "table") and (nil ~= (_16_).type)) then local type = (_16_).type
 return type elseif ((_16_ == nil) and true and (_18_ == "ENOENT")) then local _ = _17_
 return "nothing" elseif ((_16_ == nil) and (nil ~= _17_) and true) then local err = _17_ local _ = _18_
 return nil, fmt("uv.fs_stat error %s", err) elseif ((_16_ == nil) and (nil ~= _17_)) then local err = _17_
 return nil, err else return nil end end

 local function lstat(path)
 local _20_, _21_, _22_ = uv.fs_lstat(path) if ((_G.type(_20_) == "table") and (nil ~= (_20_).type)) then local type = (_20_).type
 return type elseif ((_20_ == nil) and true and (_22_ == "ENOENT")) then local _ = _21_
 return "nothing" elseif ((_20_ == nil) and (nil ~= _21_) and true) then local err = _21_ local _ = _22_
 return nil, fmt("uv.fs_stat error %s", err) elseif ((_20_ == nil) and (nil ~= _21_)) then local err = _21_
 return nil, err else return nil end end

 local function make_path(path)
 local _24_, _25_ = what_is_at(path) if (_24_ == "nothing") then
 local _26_ local function _27_(_241, _242) local target = (_241 .. "/" .. _242)
 local _28_, _29_ = what_is_at(target) if (_28_ == "nothing") then
 return (uv.fs_mkdir(target, 493) and target) elseif (_28_ == "directory") then
 return target elseif (nil ~= _28_) then local other = _28_
 return E.reduced({nil, fmt("could not create directory %q exists, already %q", target, other)}) elseif ((_28_ == nil) and (nil ~= _29_)) then local err = _29_



 return E.reduced({nil, err}) else return nil end end
 local function _31_() return string.gmatch(path, "/([^/]+)") end _26_ = E.reduce(_27_, "/", _31_) if ((_G.type(_26_) == "table") and ((_26_)[1] == nil) and (nil ~= (_26_)[2])) then local err = (_26_)[2]
 return nil, err else return nil end elseif (_24_ == "directory") then
 return path elseif ((_24_ == nil) and (nil ~= _25_)) then local err = _25_
 return nil, fmt("could not ensure %q exists, %q", path, err) elseif (nil ~= _24_) then local any = _24_
 return nil, fmt("could not ensure directory %q exists, already %q", path, any) else return nil end end


 local function ls_path(path)
 local iter local function _34_(path0)
 local fs = uv.fs_scandir(path0)
 local function _35_() return uv.fs_scandir_next(fs) end return _35_, path0, 0 end iter = _34_
 local function _36_(_241, _242) return {kind = _242, name = _241} end local function _37_() return iter(path) end return E.map(_36_, _37_) end

 local function remove_path(path)
 local contents = ls_path(path)
 local function _38_(_241) local full_path = join_path(path, _241.name)
 print("rm", full_path)
 local _39_ = _241 if ((_G.type(_39_) == "table") and ((_39_).kind == "directory")) then
 return remove_path(full_path) elseif true then local _ = _39_
 return uv.fs_unlink(full_path) else return nil end end E.each(_38_, contents)

 return uv.fs_rmdir(path) end

 local function absolute_path_3f(path)
 return not_nil_3f(string.match(path, "^/")) end

 local function git_dir_3f(path)
 local _41_ = what_is_at((path .. "/.git")) if (_41_ == "directory") then return true elseif (_41_ == "file") then return true elseif true then local _ = _41_ return false else return nil end end




 local function dir_exists_3f(path)
 return ("directory" == what_is_at(path)) end

 local function symlink(target, link_name)
 return uv.fs_symlink(target, link_name) end

 return {["what-is-at"] = what_is_at, ["ls-path"] = ls_path, lstat = lstat, symlink = symlink, ["make-path"] = make_path, ["remove-path"] = remove_path, ["absolute-path?"] = absolute_path_3f, ["git-dir?"] = git_dir_3f, ["dir-exists?"] = dir_exists_3f, ["join-path"] = join_path}