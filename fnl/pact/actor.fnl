(fn actor [is-a ...]
  "wraps some state in a `persistent` [sic] process that can handle messages"
  (let [attrs (icollect [_ [call & args] (ipairs [...]) :into []]
                        (when (= (tostring call) :attr) `(attr ,(unpack args))))
        [receive] (accumulate [found nil _ [call & args] (ipairs [...]) :until found]
                              (when (= (tostring call) :receive)
                                args))]
    (if (= nil receive)
        (error "actor must be given at least (receive (fn [] nil))"))

    `(do
       (import-macros {: struct} :pact.struct)
       (var actor# nil)
       (var receive# ,receive)

       (fn loop# [...]
         (match [(receive# actor# ...)]
           [:halt val#] #(values val#)
           val# (loop# (coroutine.yield (unpack val#)))))

       (let [thread# (coroutine.create loop#)]
         (set actor# (struct ,is-a
                             (attr thread thread#)
                             ,(unpack attrs)))
         (values actor#)))))

{: actor}
