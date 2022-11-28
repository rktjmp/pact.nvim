(import-macros {: use : relative-mod}
               (.. (or (-?> ... (string.match "(.+%.)match")) "") :use))
(local match-path (relative-mod :match &from :match))

(fn kernelise [...]
  (let [export [:match?]
        binds (collect [_ n (ipairs export) &into `{}]
                (values n (sym n)))]
  `(import-macros ,binds ,match-path)))

{: kernelise}
