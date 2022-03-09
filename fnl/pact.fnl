(import-macros {: raise : expect} :pact.error)
(import-macros {: struct} :pact.struct)

(local co (require :pact.coroutine))
(local uv vim.loop)
(local {: fmt : inspect : pathify} (require :pact.common))
(local providers (let [{: git} (require :pact.provider.git)
                       {: github} (require :pact.provider.github)
                       {: sourcehut} (require :pact.provider.sourcehut)
                       {: path} (require :pact.provider.path)]
                   {: git : github : path : sourcehut}))
(local {: send} (require :pact.pubsub))

(local state {:plugin-groups {}})

; (local config {:package-root })
; (local config {:package-root :/home/soup/projects/scratch/fake-pack})

(local config (struct pact/config
                      ;; pact puts each group inside its own pack folder, so this points
                      ;; to nvims "package root" not any kind of "pact root".
                      ;; (attr package-root (.. (vim.fn.stdpath :data) :/site/pack) show)
                      (attr package-root :/home/soup/projects/scratch/fake-pack show)
                      ;; 10 seemed to cause git ls-remote failures, maybe rate limit
                      ;; events from gh?
                      (attr concurrency-limit 5 mutable show)))

(local runtime (let [{: new} (require :pact.runtime)]
                 (new config)))

(fn setup [opts]
  "Configure pact, currently accepts no configurable options."
  (when (= (vim.fn.has :nvim-0.7) 0)
    (error "pact.nvim needs nvim v0.7.0-dev+1212-gbce1fd221 or later")))

(fn has? [group-name]
  (not (= nil (. state :plugin-groups group-name))))

(fn get [group-name ?plugin-id]
  (let [group (. state :plugin-groups group-name)]
    (match [group ?plugin-id]
      [nil nil] (values nil)
      [group nil] (values group)
      [group id] (accumulate [found nil _ plugin (ipairs group.plugins) :until found]
                   (when (= id plugin.id)
                     plugin)))))

(fn define [group-name ...]
  ;; TODO check that all plugins have unique id
  (match (has? group-name)
    true (error (fmt "attempt to redefine group %s" group-name))
    false (tset state.plugin-groups group-name
                {:name group-name :plugins [...]})))

(fn command [input]
  "Process user input from the vim command line"
  ;; very dirty tricks for now but write this as an eater later
  (if (or (string.match input "^st ")
            (string.match input "^status "))
    (let [group-name (string.match input "^st.* (.+)")]
      (if group-name
        (send runtime :command :status group-name)
        (vim.notify "could not extract group name")))
    (vim.notify (.. "dont know how to " input))))

{;; required for :Pact ...
 : command
 ;; ergonomic access to providers
 :git providers.git
 :github providers.github
 :path providers.path
 :srht providers.sourcehut
 :sourcehut providers.sourcehut
 ;; group and plugin access
 : define
 : has?
 : get}
