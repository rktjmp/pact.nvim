
 local _local_6_ = require("pact.lib.ruin.type") local assoc_3f = _local_6_["assoc?"] local boolean_3f = _local_6_["boolean?"] local function_3f = _local_6_["function?"] local nil_3f = _local_6_["nil?"] local not_nil_3f = _local_6_["not-nil?"] local number_3f = _local_6_["number?"] local seq_3f = _local_6_["seq?"] local string_3f = _local_6_["string?"] local table_3f = _local_6_["table?"] local thread_3f = _local_6_["thread?"] local userdata_3f = _local_6_["userdata?"] do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end

 local E, R, FS, Package, Datastore, _local_14_, _local_15_ = nil, nil, nil, nil, nil, nil, nil do local _13_ = string local _12_ = require("pact.task") local _11_ = require("pact.datastore") local _10_ = require("pact.package") local _9_ = require("pact.fs") local _8_ = require("pact.lib.ruin.result") local _7_ = require("pact.lib.ruin.enum") E, R, FS, Package, Datastore, _local_14_, _local_15_ = _7_, _8_, _9_, _10_, _11_, _12_, _13_ end local _local_16_ = _local_14_





 local task_2fawait = _local_16_["await"] local task_2frun = _local_16_["run"] local trace = _local_16_["trace"] local _local_17_ = _local_15_
 local fmt = _local_17_["format"] do local _ = {nil, nil} end

 local Transaction = {}

 local function new_transaction(id, datastore, prefix) _G.assert((nil ~= prefix), "Missing argument prefix on ./fnl/pact/runtime/transaction/init.fnl:15") _G.assert((nil ~= datastore), "Missing argument datastore on ./fnl/pact/runtime/transaction/init.fnl:15") _G.assert((nil ~= id), "Missing argument id on ./fnl/pact/runtime/transaction/init.fnl:15")
 return {id = id, datastore = datastore, progress = {packages = {waiting = 0, running = 0, done = 0}, afters = {waiting = 0, running = 0, done = 0}}, path = {root = FS["join-path"](prefix, id), head = FS["join-path"](prefix, "HEAD")}} end










 Transaction["packages-waiting"] = function(t, n) _G.assert((nil ~= n), "Missing argument n on ./fnl/pact/runtime/transaction/init.fnl:27") _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:27")
 t.progress.packages.waiting = n
 return t end

 Transaction["package-waiting->package-running"] = function(t) _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:31")
 t.progress.packages.waiting = (t.progress.packages.waiting - 1)
 t.progress.packages.running = (t.progress.packages.running + 1)
 return t end

 Transaction["package-running->package-done"] = function(t) _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:36")
 t.progress.packages.running = (t.progress.packages.running - 1)
 t.progress.packages.done = (t.progress.packages.done + 1)
 return t end

 Transaction.new = function(datastore, transactions_prefix) _G.assert((nil ~= transactions_prefix), "Missing argument transactions-prefix on ./fnl/pact/runtime/transaction/init.fnl:41") _G.assert((nil ~= datastore), "Missing argument datastore on ./fnl/pact/runtime/transaction/init.fnl:41")


 return new_transaction(vim.loop.gettimeofday(), datastore, transactions_prefix) end

 Transaction.latest = function(datastore, transactions_prefix) _G.assert((nil ~= transactions_prefix), "Missing argument transactions-prefix on ./fnl/pact/runtime/transaction/init.fnl:46") _G.assert((nil ~= datastore), "Missing argument datastore on ./fnl/pact/runtime/transaction/init.fnl:46")
 local existing
 local function _18_(_241) if (("directory" == _241.kind) and string.match(_241.name, "^%d+$")) then

 return tonumber(_241.name) else return nil end end existing = E.last(E["sort$"](E.map(_18_, FS["ls-path"](transactions_prefix))))


 if existing then
 return new_transaction(existing, datastore, transactions_prefix) else
 return nil end end

 Transaction.prepare = function(t) _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:57")
 local _let_21_ = require("pact.lib.ruin.result") local bind_15_auto = _let_21_["bind"] local unit_16_auto = _let_21_["unit"] local bind_22_ = bind_15_auto local unit_23_ = unit_16_auto local function _24_(_) local function _25_(_0) local function _26_(_1) local function _27_()


 trace("created transaction %s paths: %s/start|opt", t.id, t.path.root)
 return R.ok(t) end return unit_23_(_27_()) end return unit_23_(bind_22_(unit_23_(FS["make-path"](FS["join-path"](t.path.root, "opt"))), _26_)) end return unit_23_(bind_22_(unit_23_(FS["make-path"](FS["join-path"](t.path.root, "start"))), _25_)) end return bind_22_(unit_23_(FS["make-path"](t.path.root)), _24_) end

 Transaction["package-path"] = function(t, package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/runtime/transaction/init.fnl:64") _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:64")
 return FS["join-path"](t.path.root, package.install.path) end

 local function use_package(t, package, commit) _G.assert((nil ~= commit), "Missing argument commit on ./fnl/pact/runtime/transaction/init.fnl:67") _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/runtime/transaction/init.fnl:67") _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:67")
 local _let_28_ = require("pact.lib.ruin.result") local bind_15_auto = _let_28_["bind"] local unit_16_auto = _let_28_["unit"] local bind_29_ = bind_15_auto local unit_30_ = unit_16_auto local function _31_(canonical_id) local function _32_(dsp) local function _33_(_) local function _34_(_0) local function _35_(files_path) local function _36_(link_path) local function _37_(_1) local function _38_(_2) local function _39_()









 return R.ok() end return unit_30_(_39_()) end return unit_30_(bind_29_(unit_30_(Package["decrement-tasks-active"](package)), _38_)) end return unit_30_(bind_29_(unit_30_(FS.symlink(files_path, link_path)), _37_)) end return unit_30_(bind_29_(unit_30_(FS["join-path"](t.path.root, package.install.path)), _36_)) end return unit_30_(bind_29_(unit_30_(task_2fawait(task_2frun(Datastore.Git["setup-commit"](dsp, commit)))), _35_)) end return unit_30_(bind_29_(unit_30_(Package["increment-tasks-active"](package)), _34_)) end return unit_30_(bind_29_(unit_30_(Package["decrement-tasks-waiting"](package)), _33_)) end return unit_30_(bind_29_(unit_30_(Datastore["package-by-canonical-id"](t.datastore, canonical_id)), _32_)) end return bind_29_(unit_30_(package["canonical-id"]), _31_) end

 Transaction["retain-package"] = function(t, package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/runtime/transaction/init.fnl:80") _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:80")
 if package.git.current.commit then
 return use_package(t, package, package.git.current.commit) else
 return Transaction["discard-package"](t, package) end end


 Transaction["align-package"] = function(t, package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/runtime/transaction/init.fnl:86") _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:86")
 if package.git.target.commit then
 return use_package(t, package, package.git.target.commit) else
 return R.err(fmt("package %s had no target commit to sync", package["canonical-id"])) end end

 Transaction["discard-package"] = function(t, package) _G.assert((nil ~= package), "Missing argument package on ./fnl/pact/runtime/transaction/init.fnl:91") _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:91")
 Package["decrement-tasks-waiting"](package)
 return R.ok() end

 Transaction.commit = function(t) _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:95")

 vim.loop.fs_unlink(t.path.head)
 return FS.symlink(t.path.root, t.path.head) end

 Transaction.cancel = function(t) _G.assert((nil ~= t), "Missing argument t on ./fnl/pact/runtime/transaction/init.fnl:100")
 return FS["remove-path"](t.path.root) end

 return Transaction