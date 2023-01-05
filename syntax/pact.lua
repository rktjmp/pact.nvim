-- compile = OK

local _local_1_ = vim
local api = _local_1_["api"]
local function def_group(name, root, _3falter_f)
  _G.assert((nil ~= root), "Missing argument root on hotpot-live-compile:3")
  _G.assert((nil ~= name), "Missing argument name on hotpot-live-compile:3")
  local function s__3ecamel(s)
    _G.assert((nil ~= s), "Missing argument s on hotpot-live-compile:4")
    local _2_ = {string.match(s, "([%w])([%w]*)(.*)")}
    if ((_G.type(_2_) == "table") and (nil ~= (_2_)[1]) and (nil ~= (_2_)[2]) and ((_2_)[3] == nil)) then
      local a = (_2_)[1]
      local b = (_2_)[2]
      return (string.upper(a) .. (b or ""))
    elseif ((_G.type(_2_) == "table") and (nil ~= (_2_)[1]) and (nil ~= (_2_)[2]) and (nil ~= (_2_)[3])) then
      local a = (_2_)[1]
      local b = (_2_)[2]
      local rest = (_2_)[3]
      return (string.upper(a) .. (b or "") .. s__3ecamel(rest))
    elseif true then
      local _ = _2_
      return s
    else
      return nil
    end
  end
  local name0 = s__3ecamel(("pact-" .. name))
  if _3falter_f then
    local _4_, _5_ = pcall(api.nvim_get_hl_by_name, root, true)
    if ((_4_ == false) and (nil ~= _5_)) then
      local err = _5_
      return error(err)
    elseif ((_4_ == true) and (nil ~= _5_)) then
      local data = _5_
      _3falter_f(data)
      return api.nvim_set_hl(0, s__3ecamel(name0), data)
    else
      return nil
    end
  else
    return api.nvim_set_hl(0, s__3ecamel(name0), {link = root})
  end
end
local function def_groups()
  def_group("comment", "Comment")
  def_group("section-title", "Title")
  def_group("package-name", "String")
  local function _8_(_241)
    _241["underline"] = true
    return _241
  end
  def_group("column-title", "Normal", _8_)
  def_group("package-can-install", "Comment")
  do
    local _9_ = vim.version()
    local function _10_()
      local v = (_9_).major
      return (v < 9)
    end
    if (((_G.type(_9_) == "table") and (nil ~= (_9_).major)) and _10_()) then
      local v = (_9_).major
      local function _11_(_241)
        _241["fg"] = "LightGreen"
        return _241
      end
      def_group("package-will-install", "DiagnosticHint", _11_)
    else
      local function _12_()
        local v = (_9_).major
        return (9 <= v)
      end
      if (((_G.type(_9_) == "table") and (nil ~= (_9_).major)) and _12_()) then
        local v = (_9_).major
        def_group("package-will-install", "DiagnosticOk")
      else
      end
    end
  end
  def_group("package-can-sync", "Comment")
  def_group("package-will-sync", "DiagnosticOk")
  def_group("package-will-discard", "DiagnosticWarn")
  def_group("package-will-hold", "DiagnosticHint")
  def_group("package-failing", "DiagnosticError")
  def_group("package-degraded", "DiagnosticWarn")
  def_group("package-breaking", "DiagnosticWarn")
  def_group("package-text", "Normal")
  do
    local _14_ = vim.version()
    local function _15_()
      local v = (_14_).major
      return (v < 9)
    end
    if (((_G.type(_14_) == "table") and (nil ~= (_14_).major)) and _15_()) then
      local v = (_14_).major
      def_group("sign-working", "DiagnosticInfo")
    else
      local function _16_()
        local v = (_14_).major
        return (9 <= v)
      end
      if (((_G.type(_14_) == "table") and (nil ~= (_14_).major)) and _16_()) then
        local v = (_14_).major
        def_group("sign-working", "DiagnosticSignInfo")
      else
      end
    end
  end
  return def_group("sign-waiting", "Comment")
end
if not vim.b.current_syntax then
  vim.b.current_syntax = "pact"
  def_groups()
  return api.nvim_create_autocmd("ColorScheme", {buffer = 0, callback = def_groups})
else
  return nil
end

-- Source (0,0,52,74):
-- (local {: api} vim)
-- 
-- (λ def-group [name root ?alter-f]
--     (λ s->camel [s]
--       (match [(string.match s "([%w])([%w]*)(.*)")]
--         [a b nil] (.. (string.upper a) (or b ""))
--         [a b rest] (.. (string.upper a) (or b "") (s->camel rest))
--         _ s))
--     (local name (-> (.. :pact- name)
--                     (s->camel)))
--     (if ?alter-f
--       (match (pcall api.nvim_get_hl_by_name root true)
--         (false err) (error err)
--         (true data) (do
--                       (?alter-f data)
--                       (api.nvim_set_hl 0 (s->camel name) data)))
--       (api.nvim_set_hl 0 (s->camel name) {:link root})))
-- 
-- (λ def-groups []
--   ;; generic groups
--   (def-group :comment :Comment) ;; commenty text
--   (def-group :section-title :Title) ;; Unstaged
--   (def-group :package-name :Constant) ;; x/y.nvim
--   (def-group :column-title :Normal #(doto $ (tset :underline true)))
--   ;; action install
--   (def-group :package-can-install :Comment)
--   (match (vim.version)
--     (where {:major v} (< v 9)) (def-group :package-will-install :DiagnosticHint #(doto $ (tset :fg :LightGreen)))
--     (where {:major v} (<= 9 v)) (def-group :package-will-install :DiagnosticOk))
--   ;; action sync
--   (def-group :package-can-sync :Comment)
--   (def-group :package-will-sync :DiagnosticOk)
--   ;; action discard
--   (def-group :package-will-discard :DiagnosticWarn)
--   ;; action hold
--   (def-group :package-will-hold :DiagnosticHint)
--   ;; health adjusters
--   (def-group :package-failing :DiagnosticError)
--   (def-group :package-degraded :DiagnosticWarn)
--   ;; ... others?
--   (def-group :package-breaking :DiagnosticWarn) ;; breaking changes
--   (def-group :package-text :Normal) ;; any other text
-- 
--    ;; sign-column active
--   (match (vim.version)
--     (where {:major v} (< v 9)) (def-group :sign-working :DiagnosticInfo)
--     (where {:major v} (<= 9 v)) (def-group :sign-working :DiagnosticSignInfo))
--   (def-group :sign-waiting :Comment)) ;; sign-column waiting
-- 
-- (when (not vim.b.current_syntax)
--   (set vim.b.current_syntax :pact)
--   (def-groups)
--   (api.nvim_create_autocmd :ColorScheme {:buffer 0 :callback def-groups}))
