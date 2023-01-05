(fn match-run [[cmd opts] ...]
  (let [arg-v [...]
        arg-c (select :# ...)
        ok-bodies (fcollect [i 1 arg-c 2]
                    (if (= `where-ok? (. arg-v i 1))
                      [(. arg-v i 2) (. arg-v (+ 1 i))]))
        err-bodies (fcollect [i 1 arg-c 2]
                    (if (= `where-err? (. arg-v i 1))
                      [(. arg-v i 2) (. arg-v (+ 1 i))]))]
    `(do
       (match (cb->await run [,cmd ,opts])
         (0 stdout# stderr#) ,(doto (accumulate [body `(match [0 stdout# stderr#])
                                                 _ [pat bod] (ipairs ok-bodies)]
                                      (doto body
                                            (table.insert pat)
                                            (table.insert bod)))
                                    (table.insert `_#)
                                    (table.insert `(error (string.format "Unhandled success case for %s %s"
                                                                         ,cmd
                                                                         (inspect _#)))))
         (code# stdout# stderr#) ,(doto (accumulate [body `(match [code# stdout# stderr#])
                                                     _ [pat bod] (ipairs err-bodies)]
                                          (doto body
                                                (table.insert pat)
                                                (table.insert bod)))
                                        (table.insert `_#)
                                        (table.insert `(error (string.format "Unhandled success case for %s" ,cmd))))
       (nil err#) (values nil err#)))))

{: match-run}
