(import-macros {: use : relative-mod}
               (.. (or (-?> ... (string.match "(.+%.)let")) "") :use))
(local let-path (relative-mod :let &from :let))

(fn kernelise [...]
  (let [export [:match-let :if-let :if-some-let :when-let :when-some-let]
        binds (collect [_ n (ipairs export) &into `{}]
                (values n (sym n)))]
  `(import-macros ,binds ,let-path)))

{: kernelise}
