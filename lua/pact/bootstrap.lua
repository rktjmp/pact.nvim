




 local pact = require("pact")

 local fmt = string.format

 local function mkdir(path) _G.assert((nil ~= path), "Missing argument path on ./fnl/pact/bootstrap.fnl:10")
 local p = vim.fs.normalize(path)


 return assert((1 == vim.fn.mkdir(p, "p")), fmt("Could not create dir %s", p)) end

 local function symlink(target, name) _G.assert((nil ~= name), "Missing argument name on ./fnl/pact/bootstrap.fnl:16") _G.assert((nil ~= target), "Missing argument target on ./fnl/pact/bootstrap.fnl:16")


 return assert(vim.loop.fs_symlink(target, name)) end

 local function bootstrap(pactstrap_path) _G.assert((nil ~= pactstrap_path), "Missing argument pactstrap-path on ./fnl/pact/bootstrap.fnl:21")
 local config = require("pact.config")
 local pactstrap_path0 = vim.fs.normalize(pactstrap_path)
 local t_1_path = (config.path.data .. "/1")
 local start_path = (t_1_path .. "/start")
 local opt_path = (t_1_path .. "/opt") local source_path
 do local _1_ = vim.fs.find("pact.nvim", {path = pactstrap_path0, type = "directory"}) if ((_G.type(_1_) == "table") and (nil ~= (_1_)[1])) then local path = (_1_)[1]

 source_path = path elseif true then local _ = _1_
 source_path = error(fmt(("Could not find pact.nvim dir " .. "inside %s to bootstrap with"), pactstrap_path0)) else source_path = nil end end





 assert(vim.loop.fs_stat(source_path), fmt("Source path did not exist: %s. Unable to bootstrap.", source_path))

 for _, p in ipairs({config.path.data, config.path.runtime, start_path}) do
 mkdir(p) end


 symlink(t_1_path, config.path.head)


 for _, fix in ipairs({"/start", "/opt"}) do
 symlink((config.path.head .. fix), (config.path.runtime .. fix)) end



 do local src = source_path
 local dest = fmt("%s/start/pact.nvim", t_1_path)


 vim.fn.system({"cp", "-r", src, dest}) end


 do local src = pactstrap_path0


 vim.fn.system({"rm", "-rf", src}) end

 vim.cmd("packloadall!")

 return vim.notify(("pact.nvim was bootstrapped!\n" .. "You will be prompted to install pact the first time you run :Pact to finalise the installation\n"), vim.log.levels.INFO) end return bootstrap