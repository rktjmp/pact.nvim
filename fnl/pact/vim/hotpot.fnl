;; Because you cant call vim functions from a uv loop callback, when we
;; try to run the scheduler (which hooks into the uv loop) we end up trying to
;; compile code via hotpot, inside the loop callback. To get around this, before
;; starting any scheduler stuff, we will walk the entire pact tree and require
;; all the files to build/refresh its cache.
;;
;; This obviously has performance implications but ... oh well. It's possible
;; at some point to ship compiled lua but for development its kind of annoying.

(let [{: cache-path-for-module : cache-prefix} (require :hotpot.api.cache)
      {: pathify} (require :pact.common)
      uv vim.loop
      pact-dir (-> (cache-path-for-module :pact)
                   (string.gsub (.. "^" (cache-prefix)) "/")
                   (string.gsub "pact.lua$" ""))]
  ;; for every file we find, just require it to get it into cache
  (fn walk-dir [req-path dir]
    (let [scanner (uv.fs_scandir dir)]
      (each [name type #(uv.fs_scandir_next scanner)]
        (match type
          :directory (walk-dir (.. req-path "." name) (pathify dir name))
          :file (when (string.match name ".fnl$")
                  (let [modname (-> (.. req-path "." name)
                                    (string.sub 2 -5))]
                    (when (and (string.match modname "^pact")
                               (not (= :pact.vendor.cljlib.init-macros modname))
                               (not (= :pact.vim.hotpot modname))
                               (not (= :pact.struct modname))
                               (not (= :pact.actor modname))
                               (not (= :pact.error modname))
                               (not (= :pact.async_await modname)))
                      (require modname))))))))

  (walk-dir "" pact-dir))
