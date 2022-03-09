(import-macros {: raise : expect} :pact.error)
(import-macros {: actor} :pact.actor)
(local {: fmt : inspect : pathify} (require :pact.common))
(local uv vim.loop)

;; Snapshot Workflow UI
;;
;; Should produce something looking like this

;; <timestamp>
;;
;; # Provide a one line snapshot message or leave as given.
;; # All other lines are ignored.
;; #
;; # update hotpot.nvim master
;; # update lush.nvim   master
;; # get    feline.nvim = 0.4.3
;; #
;; # gq        = close, cancel, give up, dispair
;; # gc        = commit commands

(local api vim.api)
(local help-text-head ["# Provide a one line snapshot message or leave as given."
                       "# All other lines are ignored."
                       "#"])
(local help-text-tail ["#"
                       "# gc = commit commands"
                       "# gq = close, cancel, give up, dispair"])

(fn git-line [result]
  (let [{: plugin : current-checkout : action : args} result]
    (match [action current-checkout]
      ;; sync with no current is a clone
      [:sync nil]
      (let [[[hash ref]] args]
        [:clone plugin.id hash])
      ;; sync with current is an update
      [:sync [current-hash _]]
      (let [[[hash ref]] args]
        [:update plugin.id (fmt "%s -> %s" current-hash hash)])
      ;; otherwise ....
      other (raise internal (fmt "unknown git action %s" other)))))

(fn path-line [result]
  (let [{: plugin : action : args} result]
    (match action
      :sync [:link plugin.id plugin.pin.path]
      other (raise internal (fmt "unknown path action %s" other)))))

(fn actions->lines [actions]
  (let [pact-view (require :pact.activity.view)
        tuples (icollect [_ action (ipairs actions)]
                         (match action
                           {:method :git} (git-line action)
                           {:method :path} (path-line action)))
        lines (pact-view.columnise-data tuples)]
  (icollect [_ line (ipairs lines)]
            (.. "# " line))))

(fn receive [{: view} ...]
  (let [pact-view (require :pact.activity.view)]
    (match [...]
      [:close] (pact-view.close view)
      [:lines] (vim.api.nvim_buf_get_lines view.buf 0 -1 false)
      [:redraw state] (let [lines []]
                        (table.insert lines state.snapshot-message)
                        (table.insert lines "")
                        (each [_ l (ipairs help-text-head)]
                          (table.insert lines l))
                        (each [_ l (ipairs (actions->lines state.actions))]
                          (table.insert lines l))
                        (each [_ l (ipairs help-text-tail)]
                          (table.insert lines l))
                        (pact-view.set-content view lines)))))

(fn new [keys]
  (let [pact-view (require :pact.activity.view)
        view (pact-view.new {:n-keys keys})]
    (actor pact/activity/snapshot/view (attr view view show) (receive receive))))

{: new}
