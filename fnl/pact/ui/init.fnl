(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     Render :pact.ui.render
     Package :pact.package
     Runtime :pact.runtime
     Log :pact.log
     inspect :pact.inspect
     {: subscribe : unsubscribe} :pact.pubsub
     R :pact.lib.ruin.result
     {: api} vim
     {:format fmt} string
     {: abbrev-sha} :pact.git.commit)

(local M {})

(fn schedule-redraw [ui]
  ;; asked to render, we only want to hit 60fps otherwise we can really pin
  ;; with lots of workflows pinging back to us.
  (local rate (/ 1000 60))
  (when (< (or ui.will-render 0) (vim.loop.now))
    (tset ui :will-render (+ rate (vim.loop.now)))
    (vim.defer_fn #(Render.output ui) rate)))

(fn cursor->package [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        line (- line 1)]
    (match (api.nvim_buf_get_extmarks ui.buf ui.ns-meta-id [line 0] [line 0] {})
      [[extmark-id]] (E.find #(= $1.uid (. ui.extmarks extmark-id))
                             #(Package.iter ui.runtime.packages)))))

(fn exec-keymap-cc [ui]
  ;; TODO dont try if no staged
  (-> (Runtime.Command.run-transaction ui.runtime)
      (R.map-err #(vim.notify $ vim.log.levels.ERROR))))

(fn exec-keymap-<cr> [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (E.find #(= line $.on-line) ui.plugins-meta)]
    (match [meta (?. meta :plugin :path :package)]
      [any path] (do
                   (print path)
                   (vim.cmd (fmt ":new %s" path)))
      [any nil] (vim.notify (fmt "%s has no path to open" any.plugin.name))
      _ nil)))

(fn exec-keymap-s [ui]
  (match (cursor->package ui)
    package (do
              (-> (Runtime.Command.sync-package-tree ui.runtime package)
                  (R.map-err #(vim.notify $ vim.log.levels.ERROR)))
              (print package.canonical-id package.action)
              (schedule-redraw ui))
    nil (vim.notify "No package under cursor"
                    vim.log.levels.INFO)))

(fn exec-keymap-u [ui]
  (match (cursor->package ui)
    package (do
              (-> (Runtime.Command.hold-package-tree ui.runtime package)
                  (R.map-err #(vim.notify $ vim.log.levels.ERROR)))
              (print package.canonical-id package.action)
              (schedule-redraw ui))
    nil (vim.notify "No package under cursor"
                    vim.log.levels.INFO)))

(fn exec-keymap-= [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (E.find #(= line $.on-line) ui.plugins-meta)]
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
    (let [{: default-scheduler} (require :pact.task.scheduler)]
      (subscribe default-scheduler #(schedule-redraw ui)))
    ; (E.each #(subscribe $1 #(schedule-redraw ui))
    ;         #(Package.iter ui.runtime.packages))
    (Runtime.Command.initial-load runtime)
    (schedule-redraw ui)))

(values M)
