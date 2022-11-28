(import-macros {: use : relative-mod}
               (.. (or (-?> ... (string.match "(.+%.)fn")) "") :use))
(local fn-path (relative-mod :fn &from :fn))

(fn kernelise [...]
  (let [exports [:fn* :fn+]
        binds (collect [_ n (ipairs exports) &into `{}]
                (values n (sym n)))]
    `(import-macros ,binds ,fn-path)))

{: kernelise}
