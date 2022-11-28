(import-macros {: use : relative-mod}
               (.. (or (-?> ... (string.match "(.+%.)type")) "") :use))
(local type-path (relative-mod :type &from :type))

(fn kernelise [...]
  (let [export [:seq? :assoc? :table?
                :number? :boolean? :string?
                :function? :nil? :not-nil?
                :userdata? :thread?]
        binds (collect [_ n (ipairs export) &into `{}]
                (values n (sym n)))]
    `(local ,binds (require ,type-path))))

{: kernelise}
