(local {:format fmt} string)
;; we don't want to add the same plugins again and again, so keep track of what
;; we've seen. We manually build a key with forge-user/repo for now.
(local seen-plugins {})
(var plugin-proxies [])

;; we proxy our plugin providers so we have no runtime cost until the UI is
;; actually invoked.
(fn proxy [name]
  (when (= (vim.fn.has :nvim-0.8) 0)
    (error "pact.nvim requires nvim-0.8 or later"))
  ;; assumes ... first arg is string
  (fn id [user-repo] (.. name "/" user-repo))
  (fn [...]
    (let [plugin-id (fmt "%s/%s" name (. [...] 1))
          ?existing (. seen-plugins plugin-id)]
      ;; (print "proxinging" plugin-id)
      ; (when ?existing
      ;   (vim.notify (fmt "Replacing existing plugin %s with new configuration" plugin-id))
      ;   (tset seen-plugins plugin-id nil))
      (let [arg-v [...]
            arg-c (select :# ...)
            real-fn #(let [mod (require :pact.plugin)
                           f (. mod name)]
                       (f (unpack arg-v 1 arg-c)))]
        (tset seen-plugins plugin-id true)
        ; (table.insert plugin-proxies real-fn)
        real-fn))))

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
        ui (require :pact.ui)]
    (ui.attach win buf plugin-proxies opts)))

(fn make-pact [...]
  (table.insert plugin-proxies [...])
  ; (vim.pretty_print plugin-proxies)
  
  )

{: open
 : make-pact
 :git providers.git
 :github providers.github
 :path providers.path
 :srht providers.sourcehut
 :sourcehut providers.sourcehut}
