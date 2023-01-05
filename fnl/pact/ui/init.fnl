(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     Render :pact.ui.render
     Package :pact.package
     Runtime :pact.runtime
     Log :pact.log
     FS :pact.fs
     inspect :pact.inspect
     {: subscribe : unsubscribe} :pact.pubsub
     R :pact.lib.ruin.result
     {: api} vim
     {:format fmt} string)

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
  (let [buf (api.nvim_create_buf false true)
        win (api.nvim_open_win buf false {:relative :win
                                          :win ui.win
                                          :anchor :SW
                                          :row (api.nvim_win_get_height ui.win)
                                          :col 1
                                          :width (api.nvim_win_get_width ui.win)
                                          :height 1
                                          :focusable false
                                          :style :minimal})
        x {:open true}
        update-win (fn [waiting running done after-waiting after-running after-done]
                     (if x.open
                       (if (and (= done (+ waiting running done))
                                (= after-done (+ after-waiting after-running after-done)))
                         (api.nvim_buf_set_lines buf 0 -1 false ["transaction: finished"])
                         (let [text (fmt "transaction: apply %s/%s after %s/%s"
                                         done (+ waiting running done)
                                         after-done (+ after-waiting after-running after-done))]
                           (api.nvim_buf_set_lines buf 0 -1 false [text])))))
        _ (api.nvim_create_autocmd :BufHidden {:buffer ui.buf
                                               :once true
                                               :callback (fn []
                                                           (set x.open false)
                                                           (api.nvim_win_close win true))})]
    (-> (Runtime.Command.run-transaction ui.runtime update-win)
        (R.map-err #(vim.notify $ vim.log.levels.ERROR)))))

(fn exec-keymap-<cr> [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (E.find #(= line $.on-line) ui.plugins-meta)]
    (match [meta (?. meta :plugin :path :package)]
      [any path] (do
                   (print path)
                   (vim.cmd (fmt ":new %s" path)))
      [any nil] (vim.notify (fmt "%s has no path to open" any.plugin.name))
      _ nil)))

(fn exec-keymap-p [ui]
  (match (cursor->package ui)
    package (vim.notify (inspect package)
                        vim.log.levels.DEBUG)
    nil (vim.notify "No package under cursor"
                    vim.log.levels.INFO))
  (schedule-redraw ui))

(fn exec-keymap-s [ui]
  (match (cursor->package ui)
    package (if (Package.aligned? package)
              (vim.notify (fmt "%s already aligned" package.name)
                          vim.log.levels.INFO)
              (-> (Runtime.Command.align-package-tree ui.runtime package)
                  (R.map-err #(vim.notify $ vim.log.levels.ERROR))))
    nil (vim.notify "No package under cursor"
                    vim.log.levels.INFO))
  (schedule-redraw ui))

(fn exec-keymap-u [ui]
  (match (cursor->package ui)
    package (do
              (-> (Runtime.Command.unstage-package-tree ui.runtime package)
                  (R.map-err #(vim.notify $ vim.log.levels.ERROR)))
              (schedule-redraw ui))
    nil (vim.notify "No package under cursor"
                    vim.log.levels.INFO)))

(fn exec-keymap-d [ui]
  (match (cursor->package ui)
    package (do
              (-> (Runtime.Command.discard-package-tree ui.runtime package)
                  (R.map-err #(vim.notify $ vim.log.levels.ERROR)))
              (schedule-redraw ui))
    nil (vim.notify "No package under cursor"
                    vim.log.levels.INFO)))

(fn exec-keymap-= [ui]
  (match (cursor->package ui)
    package (match (?. package :git :target :logs)
              nil (do
                    (-> (Runtime.Command.get-logs ui.runtime package)
                        (R.map-err #(vim.notify $ vim.log.levels.ERROR)))
                    (schedule-redraw ui))
              any (do
                    (tset package :git :target :logs nil)
                    (schedule-redraw ui)))
    nil (vim.notify "No package under cursor"
                    vim.log.levels.INFO)))

(fn prepare-interface [ui]
  (fn map [buf mode key cb]
    (api.nvim_buf_set_keymap buf mode key "" {:callback cb
                                             :nowait true}))
  (doto ui.win
        (api.nvim_win_set_option :wrap false)
        (api.nvim_win_set_option :list false))
  (doto ui.buf
        (api.nvim_buf_set_option :modifiable false)
        (api.nvim_buf_set_option :buftype :nofile)
        (api.nvim_buf_set_option :bufhidden :hide)
        (api.nvim_buf_set_option :buflisted false)
        (api.nvim_buf_set_option :swapfile false)
        (api.nvim_buf_set_option :ft :pact))
  (doto ui.buf
        (map :n := #(exec-keymap-= ui))
        ; (map :n :<cr> #(exec-keymap-<cr> ui))
        (map :n :cc #(exec-keymap-cc ui))
        (map :n :s #(exec-keymap-s ui))
        (map :n :p #(exec-keymap-p ui))
        (map :n :u #(exec-keymap-u ui))
        (map :n :d #(exec-keymap-d ui)))
  ui)

(fn M.attach [win buf proxies opts]
  "Attach user-provided win+buf to pact view"
  (let [opts (or opts {})
        ;; todo get real buf id if 0
        Runtime (require :pact.runtime)
        config (require :pact.config)
        runtime (-> (Runtime.new {:concurrency-limit config.concurrency-limit})
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
    (Log.new-log-file (FS.join-path config.path.data :pact.log))
    ;; TODO unsub all on win close
    (let [{: default-scheduler} (require :pact.task.scheduler)]
      (subscribe default-scheduler #(schedule-redraw ui)))
    (Runtime.Command.initial-load runtime)
    (schedule-redraw ui)))

(values M)
