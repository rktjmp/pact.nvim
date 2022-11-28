(import-macros {: relative-mod}
               (.. (or (-?> ... (string.match "(.+%.)use")) "") :use))
(local use-path (relative-mod :use &from :use))

(fn kernelise [...]
  (let [export [:use]
        binds (collect [_ n (ipairs export) &into `{}]
                (values n (sym n)))]
  `(import-macros ,binds ,use-path)))

{: kernelise}
