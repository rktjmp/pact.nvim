(import-macros {: use : do-use} :pact.vendor.donut)
(import-macros {: raise : expect} :pact.error)
(import-macros {: defactor} :pact.actor)
(local {: fmt : inspect : pathify} (require :pact.common))
(local uv vim.loop)
(use {: 'typeof} :pact.struct)


;; Status Workflow UI
;;
;; Should produce something looking like this

;; my-group
;; timer: 100ms
;;
;; think hotpot.nvim (master)   :: getting remote refs
;; hold  hotpot.nvim (>= 1.2.0) :: up to date (latest: = 2.0.0)
;; hold  lush.nvim   (main)     :: up do date
;;
;; # commands:
;; # hold   = take no action
;; # sync   = sync to highest matching pin/version/type/???
;; # delete = remove from package dir, shown when plugin is
;; #          no longer in pact definition, no effect if dir still exits
;; #          (delete from pact config instead)
;; # g, get    = clone from remote, shown when plugin is newly
;; #             added to pact definition
;; #
;; # bindings:
;; # gu        = set command to sync (under cursor)
;; # gh        = set command to hold (under cursor)
;; # gd        = set command to delete (under cursor)
;; # gg        = set command to get (under cursor)
;; # ga        = set any hold to sync, get remains get, delete remains delete
;; # gq        = close, cancel, give up, dispair
;; # gc        = commit commands

;; UI should not be interactive until workflow has completed though
;; it should be stoppable via gq (or window close?).

(local help-text ["# commands:"
                  "# hold   = take no action"
                  "# sync   = sync to latest valid pin"
                  "# delete = remove from package dir, shown when plugin is"
                  "#          no longer in pact definition, no effect if"
                  "#          plugin still exists (delete from pact config first)"
                  "# get    = clone from remote, shown when plugin is newly"
                  "#          added to pact definition"
                  "#"
                  "# bindings:"
                  "# gs     = set command to sync (under cursor)"
                  "# gh     = set command to hold (under cursor)"
                  "# gd     = set command to delete (under cursor) (TODO)"
                  "# gg     = set command to get (under cursor) (TODO)"
                  "# ga     = set any hold to sync,"
                  "#          get remains get,"
                  "#          delete remains delete (TODO)"
                  "# .      = repeat last command (TODO)"
                  "# gc     = commit commands"
                  "# gq     = close, cancel, give up, dispair"])

(fn git-result->line [plugin result]
  (fn maybe-latest [l]
    (match l
      nil ""
      [hash ref] (fmt " (latest: %s)" ref)))

  (let [{: plugin : current-checkout : latest-version : action : actions} result
        latest (maybe-latest latest-version)]
    (match [current-checkout action actions]
      ;; no current checkout and sync command is conceptually a clone
      [nil :sync {:sync [[hash ref]]}]
      [:clone
       plugin.id
       (fmt "(%s)" plugin.pin)
       :clone
       (fmt "(%s)%s" ref latest)]
      [nil :hold {:sync [[hash ref]]}]
      [:hold
       plugin.id
       (fmt "(%s)" plugin.pin)
       :can-clone
       (fmt "(%s)%s" ref latest)]
      ;; current checkout and a target checkout,
      ;; adjust message by user action.
      [[c-hash c-ref] action {:sync [[t-hash t-ref]]}]
      [action
       plugin.id
       (fmt "(%s)" plugin.pin)
       (match action
         :sync :will-sync
         :hold :can-sync
         _ action)
       (fmt "(%s) (at %s)%s" t-ref c-ref latest)]
      ;; no sync option, so it's only hold and in sync
      [[c-hash c-ref] :hold {:hold [] :sync nil}]
      [:hold
       plugin.id
       (fmt "(%s)" plugin.pin)
       :in-sync
       (fmt "(%s)%s" c-ref latest)]
      ;; catch all else
      any
      (let [{: view} (require :fennel)]
        (raise internal (fmt "unknown git-result->line %s" (view any)))))))

(fn path-result->line [plugin result]
  (let [{: plugin : action} result]
    (match action
      :hold [:hold plugin.id "(link)" :has-link  plugin.path]
      :sync [:link plugin.id "(link)" :create-link plugin.path])))

(fn result->line [plugin action result]
  (use {: result-types} :pact.activity.status.git-workflow :as git
       {: result-types} :pact.activity.status.path-workflow :as path
       {: result-types} :pact.workflow :as wf
       {: git-actions} :pact.activity.status
       {: path-actions} :pact.activity.status
       {: HOLD : LINK} path-actions :as path-actions
       {: HOLD : UPDATE : CLONE} git-actions :as git-actions
       {: CAN-SYNC : NEEDS-CLONE : NEEDS-SYNC : IN-SYNC} git/result-types :as git
       {: EXISTS : MISSING} path/result-types :as path
       {: ERROR} wf/result-types :as wf)
  (fn fmt-pin [plugin] (fmt "(%s)" plugin.pin))
  (fn msg-with-latest [str result]
    (match result.latest
      latest (fmt "%s (latest: %s)" str latest)
      nil str))
  (match [(typeof result) action]
    ;; format is selected-action plugin-name plugin-pin recommended-action descriptive-string
    ; [git/IN-SYNC git/HOLD] [:hold plugin.id (fmt-pin plugin) (msg-with-latest "up to date" result)]
    ; [git/NEEDS-SYNC git/HOLD] [:hold plugin.id "can-sync" "out of date" :abc]
    ; [git/NEEDS-SYNC git/UPDATE] [:sync plugin.id "sync" "out of date" :abc]
    ; [git/CAN-SYNC git/HOLD] [:hold plugin.id "can-sync" "can update" :abc]
    ; [git/CAN-SYNC git/UPDATE] [:sync plugin.id "sync" "can update" :abc]
    [git/NEEDS-CLONE git/HOLD] [:hold plugin.id (fmt-pin plugin) (msg-with-latest "can-clone" result)]
    [git/NEEDS-CLONE git/CLONE] [:sync plugin.id (fmt-pin plugin) (msg-with-latest "clone" result)]
    ; [path/EXISTS path/HOLD] [:hold plugin.id "exists" :has-link :abc]
    ; [path/MISSING _] [:hold plugin.id "missing" :has-link :abc]
    [wf/ERROR _] [:error plugin.id (fmt-pin plugin) result.reason]
    any (do
          (print :any (vim.inspect any))
          [:hold plugin.id "er" "any"])))

(fn state->lines [{: results}]
  (let [pact-view (require :pact.activity.view)
        tuples (icollect [_ [workflow tag plugin action data] (ipairs results)]
                 (match tag
                   :incomplete [:busy plugin.id (fmt "(%s)" plugin.pin) data]
                   :error [:error plugin.id (fmt "(%s)" plugin.pin) data]
                   :complete (result->line plugin action data)))]
    (table.insert tuples 1 ["------" "------" "---" "-------"])
    (table.insert tuples 1 ["action" "plugin" "pin" "if-sync"])
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
      (let [[row _] (vim.api.nvim_win_get_cursor view.win)
            ;; subtract the header, elapsed and gap line
            index (- row 3)
            data (. state.results index)]
        (match data
          nil (values nil)
          any (values (. any 1)))))))

{: receive}
