(local {:format fmt} string)

;; generate default configuration options
(let [data-path (.. (vim.fn.stdpath :data) :/pact)
      runtime-path (.. (vim.fn.stdpath :data) :/site/pack/pact)
      head-path (.. data-path :/HEAD)
      config {:lang :en
              :path {:data data-path
                     :runtime runtime-path
                     :head head-path}}]
  (tset package :preload :pact.config #config))


;; we proxy our plugin providers so we have no runtime cost until the UI is
;; actually invoked.
(var plugin-proxies [])
(fn proxy [name]
  (when (= (vim.fn.has :nvim-0.8) 0)
    (error "pact.nvim requires nvim-0.8 or later"))
  (fn [...]
    (let [plugin-id (fmt "%s/%s" name (. [...] 1))]
      (let [arg-v [...]
            arg-c (select :# ...)
            unproxy-fn #(let [mod (require :pact.package.lite)
                              f (. mod name)]
                          (f (unpack arg-v 1 arg-c)))]
        unproxy-fn))))

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

  ;; patch default config with options
  (let [config (require :pact.config)]
    (tset config :concurrency-limit (or opts.concurrency-limit
                                        opts.concurrency_limit
                                        10))
    ;; dont propagate what we dont need
    (tset opts :concurrency-limit nil))

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
  (table.insert plugin-proxies [...]))

{: open
 : make-pact
 :make_pact make-pact
 :git providers.git
 :github providers.github
 :path providers.path
 :srht providers.sourcehut
 :sourcehut providers.sourcehut}
