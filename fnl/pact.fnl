(import-macros {: raise : expect} :pact.error)
(import-macros {: defstruct} :pact.struct)

(local providers (let [{: git} (require :pact.provider.git)
                       {: github} (require :pact.provider.github)
                       {: sourcehut} (require :pact.provider.sourcehut)
                       {: path} (require :pact.provider.path)]
                   {: git : github : path : sourcehut}))

;; will be set in setup
(var runtime nil)

(fn setup [opts]
  "Configure pact, currently accepts no configurable options."
  (when (= (vim.fn.has :nvim-0.7) 0)
    (error "pact.nvim needs nvim v0.7.0-dev+1212-gbce1fd221 or later"))
  (local opts (or opts {}))

  (let [{: new} (require :pact.runtime)
        config ((defstruct pact/config
                  [package-root concurrency-limit]
                  :describe-by [package-root concurrency-limit])
                ;; pact puts each group inside its own pack folder, so this points
                ;; to nvims "package root" not any kind of "pact root".
                :package-root (or opts.package-root (.. (vim.fn.stdpath :data) :/site/pack))
                ;; 10 seemed to cause git ls-remote failures, maybe rate limit
                ;; events from gh?
                :concurrency-limit (or opts.concurrency-limit 5))]
    (set runtime (new config))))

(fn define [group-name ...]
  (expect (not (= nil runtime))
          internal "runtime was nil, did you call setup?")

  (let [{: define-plugin-group} (require :pact.runtime)]
    (define-plugin-group runtime group-name ...)))

(fn command [input]
  "Process user input from the vim command line"
  (local {: send} (require :pact.pubsub))
  ;; very dirty tricks for now but write this as an eater later
  (if (or (string.match input "^st ")
          (string.match input "^status "))
    (let [group-name (string.match input "^st.* (.+)")]
      (if group-name
        (send runtime :command :status group-name)
        (vim.notify "could not extract group name")))
    (vim.notify (.. "dont know how to " input))))

(fn command-completion [arg-lead cmd-line cursor-pos]
  (icollect [name _ (pairs runtime.groups)]
           (values name)))

{;; required for :Pact ...
 : command
 : command-completion
 ;; ... setup
 : setup
 ;; ergonomic access to providers
 :git providers.git
 :github providers.github
 :path providers.path
 :srht providers.sourcehut
 :sourcehut providers.sourcehut
 ;; group and plugin access
 : define}
