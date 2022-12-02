;; string match slightly different here as we're in the root mod
;; and it's simpler to just build most things manually.
(import-macros {: relative-root}
               (.. (or (-?> ... (string.match "(.+)")) "") :.use))

(local root (.. (relative-root &from "ruin") :ruin.))
(local aliases {:iter (.. root :iter)
                :type (.. root :type)
                :enum (.. root :enum)})

(fn tap [v f]
  (f v)
  (values v))

(fn lazyload [t k]
  (or (. t k)
      (-?> (. aliases k)
           (require)
           (tap #(do
                   (tset t k $1)
                   (tset aliases k nil))))))

(-> {:__submodules_are_lazyloaded aliases}
   (setmetatable {:__index lazyload}))
