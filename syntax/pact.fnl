(local {: api} vim)

(λ def-group [name root ?alter-f]
  (λ s->camel [s]
    (match [(string.match s "([%w])([%w]*)(.*)")]
      [a b nil] (.. (string.upper a) (or b ""))
      [a b rest] (.. (string.upper a) (or b "") (s->camel rest))
      _ s))
  (local name (-> (.. :pact- name) (s->camel)))
  (if ?alter-f
    (match (pcall api.nvim_get_hl_by_name root true)
      (false err) (error err)
      (true data) (do
                    (?alter-f data)
                    (api.nvim_set_hl 0 (s->camel name) data)))
    (api.nvim_set_hl 0 (s->camel name) {:link root})))

(λ def-groups []
  ;; generic groups
  (def-group :comment :Comment) ;; commenty text
  (def-group :section-title :Title) ;; Unstaged
  (def-group :package-name :Identifier) ;; x/y.nvim
  (def-group :column-title :Normal #(doto $ (tset :underline true)))
  ;; action install
  (def-group :package-can-install :Comment)
  (match (vim.version)
    (where {:major v} (< v 9)) (def-group :package-will-install :DiagnosticHint #(doto $ (tset :fg :LightGreen)))
    (where {:major v} (<= 9 v)) (def-group :package-will-install :DiagnosticOk))
  ;; action sync
  (def-group :package-can-sync :Comment)
  (def-group :package-will-sync :DiagnosticOk)
  ;; action discard
  (def-group :package-will-discard :DiagnosticWarn)
  ;; action hold
  (def-group :package-will-hold :DiagnosticHint)
  ;; health adjusters
  (def-group :package-failing :DiagnosticError)
  (def-group :package-degraded :DiagnosticWarn)
  ;; ... others?
  (def-group :package-breaking :DiagnosticWarn) ;; breaking changes
  (def-group :package-text :Normal) ;; any other text
   ;; sign-column active
  (match (vim.version)
    (where {:major v} (< v 9)) (def-group :sign-working :DiagnosticInfo)
    (where {:major v} (<= 9 v)) (def-group :sign-working :DiagnosticSignInfo))
  (def-group :sign-waiting :Comment)) ;; sign-column waiting

(when (not vim.b.current_syntax)
  (set vim.b.current_syntax :pact)
  (def-groups)
  (api.nvim_create_autocmd :ColorScheme {:buffer 0 :callback def-groups}))
