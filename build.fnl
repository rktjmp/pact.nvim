;; Stolen from paperplanes.nvim 03/01/2022
;; added clone file function
;; added checks against *macro[s].fnl compile

;; TODO: needs setup for macro search paths? have to use full paths fnl_spec/macro

(local fennel ((. (require :hotpot.api.fennel) :latest)))
(local uv vim.loop)

(fn compile-file [in-path out-path]
  (if (not (string.match in-path "macros?%.fnl$"))
    (with-open [f-in (io.open in-path :r)
                f-out (io.open (string.gsub out-path ".fnl$" ".lua") :w)]
               (print :compile-file in-path :-> out-path)
               (local lines (fennel.compile-string (f-in:read "*a")))
               (f-out:write lines))))

(fn clone-file [in-path out-path]
  (with-open [f-in (io.open in-path :r)
              f-out (io.open out-path :w)]
             (print :clone-file in-path :-> out-path)
             (let [lines (f-in:read "*a")]
               (f-out:write lines))))

(fn handler-for [name]
  ; if lua file, just clone over
  ; if fnl file, compile out
  (match (string.match name "%.[%w]+$")
    nil (error (: "Could not find extension in %q" :format name))
    ".lua" clone-file
    ".fnl" compile-file
    any (error (: "Could not handle file type %q" :format any))))

(fn compile-dir [in-dir out-dir]
  (print :compile-dir in-dir :=> out-dir)
  ;; TODO: No checks for missing source dirs
  (let [scanner (uv.fs_scandir in-dir)]
    (var ok true)
    (each [name type #(uv.fs_scandir_next scanner) :until (not ok)]
      (match type
        "directory" (do
                      (local out-down (.. out-dir :/ name))
                      (local in-down (.. in-dir :/ name))
                      (vim.fn.mkdir out-down :p)
                      (compile-dir in-down out-down))
        "file" (let [in-file (.. in-dir :/ name)
                     out-file (.. out-dir :/ name)
                     handler (handler-for in-file)]
                (handler in-file out-file))))))


(fn copy-file [from to]
  (print from to))

(fn make-env-proxy []
  ;; Creates an env table containing our own functions,
  ;; but also proxies out to the real _G env.
  ;; We don't want to just insert the functions as globals because they will
  ;; leak outside the build module.
  (local env {: compile-dir
              : compile-file
              : copy-file})
  (setmetatable env {:__index (fn [table key]
                                (or (. _G key) nil))}))

(local spec (fennel.dofile "hotpotfile.fnl" {:env (make-env-proxy)}))

(spec.build)

