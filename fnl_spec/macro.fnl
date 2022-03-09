(fn describe [name ...]
  (local c (list ...))

  (fn extract-setup [code]
    (let [[_ data & rest] code]
      (values `(fn [] ,data) rest)))

  (fn create-setup [code]
    (values `(fn [] nil) code))

  (fn make-test [code]
    (let [[call name & test] code]
      `(it ,name (fn [] ,test))))

  (local (setup tests) (match (. c 1)
                          :setup (extract-setup c)
                          _ (create-setup c)))
  (local body '(do))

  (local context (sym :context))
  (each [_ t (ipairs tests)]
    (let [t (make-test t)]
      (table.insert body `((fn []
                            (local ,context (,setup))
                            ,t)))))

  `((. (require :busted) :describe)
    ,name
    (fn [] ,body)))

{: describe}
