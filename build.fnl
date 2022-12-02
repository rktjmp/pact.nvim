(let [{: build} (require :hotpot.api.make)]
  (build "./fnl" {:atomic? true :force? true}
         "(.+)/fnl/(.+)"
         (fn default [head tail {: join-path}]
           (if (string.match tail "ruin")
             ;; only compile module files in ruin
             (if (string.match tail "init.fnl$")
               (join-path head :lua tail))
             (if (and (not (string.match tail "test"))
                      (not (string.match tail "macro")))
               (join-path head :lua tail))))))
nil
