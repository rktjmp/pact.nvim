;; (local {: compile-dir} ...)

(local watch {:fnl :build})

(fn build []
  (compile-dir "fnl" "lua")
  (compile-dir "fnl_spec" "spec"))

; (fn clean []
;   (clean-dir "lua"))

{: watch
 : build
 : clean}
