(local {: hash-map : kvseq} (require :pact.vendor.cljlib))
;; (print (hash-map :open false :close false))

;; This concept (an actor is a struct) worked better with the older struct style
;; it's a bit awkward now and a bit less safe in construction, but for now we will
;; leave it as it is. it may make more sense to define an actor/responder type
;; that includes a state that is a struct, slightly separating the concepts.
;; Instead of actor having all state *on the actor* it could have an explicit
;; *state* field which is a struct with the fields as given. That would mean a bit
;; of code duplication in terms of id, metatables, etc. 

(fn defactor [actor-name fields ...]
  `(do
     (import-macros {: defstruct} :pact.struct)
     (fn [...]
       (var actor# nil)
       (fn loop# [...]
         (match [(actor#.receive actor# ...)]
           [:halt val#] #(values val#)
           val# (loop# (coroutine.yield (unpack val#)))))
       (let [thread# (coroutine.create loop#)
             struct-type# (defstruct ,actor-name
                            ;; inject our always present fields
                            ,(doto fields (table.insert `thread) (table.insert `receive))
                            ;; everything else as normal
                            ,...)]
         (let [len# (select :# ...)
               ;; inject our known value, because we may be given :attr nil, we
               ;; have to insert at the "true" last index
               args# (doto [...]
                           (table.insert (+ len# 1) :thread)
                           (table.insert (+ len# 2) thread#))
               ;; check for required values
               ok?# (accumulate [ok?# false _# x# (pairs args#) :until ok?#]
                                (= :receive x#))]
           (assert ok?# "must provide :receive by ((defactor ...) :receive fn)")
           ;; note we must force unpack to run past any nil values by going from
           ;; 1 -> (len ...) + our 2 additions
           (set actor# (struct-type# (unpack args# 1 (+ len# 2))))
           (values actor#))))))

(fn actor [actor-name fields ...]
  "wraps some state in a `persistent` [sic] process that can handle messages"
  ; (print actor-name)
  (let [attrs fields
        opts (hash-map ...)
        receive opts.receive]
    (assert receive "actor must be given at least (receive (fn [] nil))")
    `(do
       (import-macros {: struct} :pact.struct)
       (var actor# nil)
       (var receive# ,receive)

       (fn loop# [...]
         (match [(receive# actor# ...)]
           [:halt val#] #(values val#)
           val# (loop# (coroutine.yield (unpack val#)))))

       (let [thread# (coroutine.create loop#)]
         (set actor# (struct :neo ,actor-name
                             ,(doto attrs
                                    (table.insert `const)
                                    (table.insert `:thread)
                                    (table.insert `thread#))
                             ,...))
         (values actor#)))))

{: actor : defactor}
