;; note relrequire check path is slightly different here than other modules, as
;; ruin is not postfixed with a dot. It should really check for .init also

(import-macros {: arg?! : def-rel-require}
               (.. (or (-?> ... (string.match "(.+)")) "") :._internal))
(def-rel-require rel-require "")

(local aliases {:iter :iter
                :maybe :maybe
                :result :result
                :type :type
                :table :table})

(fn lazyload [t k]
  (let [mod (-?> (. aliases k)
                 (rel-require))]
    (when mod
      (tset t k mod)
      (tset aliases k nil)
      (values mod))))

(-> {:__submodules_are_lazyloaded aliases}
   (setmetatable {:__index lazyload}))
