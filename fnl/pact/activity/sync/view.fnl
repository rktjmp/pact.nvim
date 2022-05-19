(import-macros {: raise : expect} :pact.error)
(import-macros {: actor} :pact.actor)
(local {: fmt : inspect : pathify} (require :pact.common))
(local uv vim.loop)

;; Sync Workflow UI
;;
;; Should produce something looking like this

;; my-group
;; timer: 100ms
;;
;; get     hotpot.nvim (master)   :: getting remote refs
;; update  hotpot.nvim (>= 1.2.0) :: getting ..
;;
;; # bindings:
;; # gq        = close, cancel, give up, dispair
;; # gq        = close, cancel, give up, dispair

(local help-text ["# bindings:"
                  "# gc = gq"
                  "# gq = close, cancel, give up, dispair"])

(fn result->line [action result]
  (let [{: plugin : method} action]
    (match method
      :git (let [{:args [[hash ref]]} action]
             [:done plugin.id (fmt "(%s)" plugin.pin) ref])
      :path [:done plugin.id (fmt "(%s)" plugin.pin) plugin.path])))

(fn state->lines [{: results}]
  (let [pact-view (require :pact.activity.view)
        tuples (icollect [_ [workflow tag [action data]] (ipairs results)]
                         (let [{: plugin} action]
                           (match tag
                             :incomplete [:busy plugin.id (fmt "(%s)" plugin.pin) data]
                             :error [:error plugin.id (fmt "(%s)" plugin.pin) data]
                             :complete (result->line action data))))]
    (pact-view.columnise-data tuples)))

(fn receive [{: view} ...]
  (let [pact-view (require :pact.activity.view)]
    (match [...]
      [:close]
      (pact-view.close view)
      [:redraw state]
      (let [header [(fmt "# pact: %s" state.group-name)
                    (fmt "# elapsed: %.2fs" (* 0.001 state.elapsed))]
            footer help-text
            lines []]
        (each [_ l (ipairs header)]
          (table.insert lines l))
        (table.insert lines "")
        (each [_ l (pairs (state->lines state))]
          (table.insert lines l))
        (table.insert lines "")
        (each [_ l (ipairs footer)]
          (table.insert lines l))
        (pact-view.set-content view lines))
      [:workflow-at-cursor state]
      (let [[row _] (vim.api.nvim_win_get_cursor win)
            ;; subtract the header, elapsed and gap line
            index (- row 3)
            data (. state.results index)]
        (match data
          nil (values nil)
          any (values (. any 1)))))))

(fn new [opts]
  (let [pact-view (require :pact.activity.view)]
    (pact-view.new receive opts)))

{: new}
