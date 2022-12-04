;; we don't want to add the same plugins again and again, so keep track of what
;; we've seen. We manually build a key with forge-user/repo for now.
(local seen-plugins {})
(local plugin-proxies [])

;; we proxy our plugin providers so we have no runtime cost until the UI is
;; actually invoked.
(fn proxy [name]
  (when (= (vim.fn.has :nvim-0.8) 0)
    (error "pact.nvim requires nvim-0.8 or later"))
  ;; assumes ... first arg is string
  (fn id [user-repo] (.. name "/" user-repo))
  (fn [...]
    (if (= nil (. seen-plugins (id ...)))
      (let [arg-v [...]
            arg-c (select :# ...)
            real-fn #(let [mod (require :pact.plugin)
                           f (. mod name)]
                       (f (unpack arg-v 1 arg-c)))]
        (tset seen-plugins (id ...) true)
        (table.insert plugin-proxies real-fn))
      ;; ugly but .... will do TODO?
      (vim.notify "Pact ignored attempt to re-add existing plugin to plugin list and ignored it, restart nvim to apply constraint changes"))))

(local providers {:github (proxy :github)
                  :gitlab (proxy :gitlab)
                  :sourcehut (proxy :sourcehut)
                  :srht (proxy :sourcehut)
                  :git (proxy :git)})

(fn open [opts]
  "Open pact in a lower split with an optional configuration table.

  Options:

  - concurrency-limit = 5, number of simultaneous workflows to run.
                           setting this too high may trigger rate limiting
                           on remote hosts.
  - win & buf, if provided use these for UI, otherwise opens a split window."
  (when (= (vim.fn.has :nvim-0.8) 0)
    (error "pact.nvim requires nvim-0.8 or later"))
  (local opts (or opts {}))
  (doto opts
    (tset :concurrency-limit (or opts.concurrency-limit opts.concurrency_limit)))
  (let [e-str "must provide both win and buf or neither"
        (win buf) (match opts
                    {: buf :win nil} (error e-str)
                    {:buf nil : win} (error e-str)
                    {: buf : win} (values win buf)
                    _ (let [api vim.api
                            _ (vim.cmd.split)
                            win (api.nvim_get_current_win)
                            buf (api.nvim_create_buf false true)]
                        (doto win
                          (api.nvim_win_set_buf buf)
                          (api.nvim_win_set_option :wrap false))
                        (values win buf)))
        ui (require :pact.ui)
        ;; Convert proxy plugin calls to real plugins (technically ok-err values)
        ;; We pass those to the UI so it can effectively show broken plugin
        ;; configurations while still working for non-broken plugins.
        plugins (icollect [_ c (ipairs plugin-proxies)] (c))]
    (ui.attach win buf plugins opts)))

{: open
 :git providers.git
 :github providers.github
 :path providers.path
 :srht providers.sourcehut
 :sourcehut providers.sourcehut}
