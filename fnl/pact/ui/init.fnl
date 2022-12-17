(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     Render :pact.ui.render
     Package :pact.package
     Runtime :pact.runtime
     Log :pact.log
     inspect :pact.inspect
     scheduler :pact.workflow.scheduler
     {: subscribe : unsubscribe} :pact.pubsub
     {: ok? : err?} :pact.lib.ruin.result
     R :pact.lib.ruin.result
     api vim.api
     FS :pact.workflow.exec.fs
     {:format fmt} string
     {: abbrev-sha} :pact.git.commit
     orphan-find-wf :pact.workflow.orphan.find
     orphan-remove-fw :pact.workflow.orphan.remove
     status-wf :pact.workflow.git.status
     clone-wf :pact.workflow.git.clone
     sync-wf :pact.workflow.git.sync
     diff-wf :pact.workflow.git.diff)

(local M {})

(fn log-line-breaking? [log-line]
  ;; matches break breaking, might be over-eager
  (not-nil? (string.match (string.lower log-line) :break)))

(fn log-line->chunks [log-line]
  (let [(sha log) (string.match log-line "(%x+)%s(.+)")]
    [["  " :comment]
     [(abbrev-sha sha) :comment]
     [" " :comment]
     [log (if (log-line-breaking? log) :DiagnosticError :DiagnosticHint)]]))

(fn schedule-redraw [ui]
  ;; asked to render, we only want to hit 60fps otherwise we can really pin
  ;; with lots of workflows pinging back to us.
  (local rate (/ 1000 30))
  (when (< (or ui.will-render 0) (vim.loop.now))
    (tset ui :will-render (+ rate (vim.loop.now)))
    (vim.defer_fn #(Render.output ui) rate)))

(fn exec-keymap-cc [ui]
  ;; TODO dont try if no staged
  (->> (Runtime.Command.run-transaction)
      (Runtime.dispatch ui.runtime)))

(fn exec-keymap-<cr> [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (E.find-value #(= line $2.on-line) ui.plugins-meta)]
    (match [meta (?. meta :plugin :path :package)]
      [any path] (do
                   (print path)
                   (vim.cmd (fmt ":new %s" path)))
      [any nil] (vim.notify (fmt "%s has no path to open" any.plugin.name))
      _ nil)))

(fn cursor->package [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        line (- line 1)]
    (match (api.nvim_buf_get_extmarks ui.buf ui.ns-meta-id [line 0] [line 0] {})
      [[extmark-id]] (E.find #(= $1.uid (. ui.extmarks extmark-id))
                             #(Package.iter ui.runtime.packages)))))

(fn exec-keymap-s [ui]
  (match (cursor->package ui)
    package (->> (Runtime.Command.stage-package-tree package)
                 (Runtime.dispatch ui.runtime))
    nil (print :no-package-under-cursor)))

(fn exec-keymap-u [ui]
  (match (cursor->package ui)
    package (->> (Runtime.Command.unstage-package-tree package)
                 (Runtime.dispatch ui.runtime))
    nil (print :no-package-under-cursor)))

(fn exec-keymap-= [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (E.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta
             (or (= :staged meta.state) (= :unstaged meta.state))
             (= :sync (. meta.action 1)))
      (if meta.log
        (do
          (set meta.log-open (not meta.log-open))
          (schedule-redraw ui))
        (do
          #nil));(exec-diff ui meta)))
      (vim.notify "May only view diff of staged or unstaged sync-able plugins"))))

(fn prepare-interface [ui]
  (doto ui.win
        (api.nvim_win_set_option :wrap false))
  (doto ui.buf
        (api.nvim_buf_set_option :modifiable false)
        (api.nvim_buf_set_option :buftype :nofile)
        (api.nvim_buf_set_option :bufhidden :hide)
        (api.nvim_buf_set_option :buflisted false)
        (api.nvim_buf_set_option :swapfile false)
        (api.nvim_buf_set_option :ft :pact))
  (doto ui.buf
        (api.nvim_buf_set_keymap :n := "" {:callback #(exec-keymap-= ui)})
        (api.nvim_buf_set_keymap :n :<cr> "" {:callback #(exec-keymap-<cr> ui)})
        (api.nvim_buf_set_keymap :n :cc "" {:callback #(exec-keymap-cc ui)})
        (api.nvim_buf_set_keymap :n :s "" {:callback #(exec-keymap-s ui)})
        (api.nvim_buf_set_keymap :n :u "" {:callback #(exec-keymap-u ui)}))
  ui)

(fn M.attach [win buf proxies opts]
  "Attach user-provided win+buf to pact view"
  (let [opts (or opts {})
        ;; todo get real buf id if 0
        Runtime (require :pact.runtime)
        runtime (-> (Runtime.new {:concurrency-limit opts.concurrency-limit})
                    (Runtime.add-proxied-plugins proxies))
        ui (-> {: runtime
                : win
                : buf
                :extmarks []
                :ns-id (api.nvim_create_namespace :pact-ui)
                :ns-meta-id (api.nvim_create_namespace :pact-ui-meta)
                :package->line {}
                :errors []}
               (prepare-interface))]
    (Log.new-log-file :pact.log) ;; TODO real path
    ;; TODO unsub all on win close
    (E.each #(subscribe $1 #(schedule-redraw ui))
            #(Package.iter ui.runtime.packages))
    (->> (Runtime.Command.discover-status)
         (Runtime.dispatch runtime))
    (schedule-redraw ui)))


(values M)
