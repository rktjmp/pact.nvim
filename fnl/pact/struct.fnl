;; TODO it would be nicer if is-a is a string, because we can
;; just pass the is-a type from the module context
;; also just use direct strings when definining attrs


(fn struct [is-a ...]
  "A very weakly typed struct type. Really only exists to wrap asserts around
  field access and some immutability, though that's never going to flow down to
  plain old lua tables.

  (struct my-struct-name
           (const :id forever-value :show) ;; shown in (print my-struct)
           (const :foo :bar)
           (mutable :counter 0)) ;; can (tset my-struct :counter 10)
  (= :my-struct-name (typeof my-struct))"
  (let [processed (icollect [_ attr  (ipairs [...])]
                            (let [[call name value & flags] attr
                                  call (tostring call)
                                  flags (collect [_ flag (ipairs flags)]
                                                 (values (tostring flag) true))]
                              (assert (or (= :attr call)
                                          (= :const call)
                                          (= :mutable call))
                                      "struct only accepts attr/const/mutable call")
                              (tset flags call true)
                              {:name (tostring name)
                               :value value
                               :flags flags}))
        _ (print (view processed))
        attrs (collect [_ {: name : flags} (ipairs processed)]
                       (values name flags))
        context (collect [_ {: name : value} (ipairs processed)]
                         (values name value))]
    `(let [common# (require :pact.common)
           is-a# ,(tostring is-a)
           id# (common#.monotonic-id is-a#)
           attrs# ,attrs
           context# ,context
           to-string# (fn [_#]
                        (let [inner# (collect [attr# flags# (pairs attrs#)]
                                       (when (. flags# :show)
                                         (values attr# (. context# attr#))))]
                          (common#.fmt "(%s %s)" id# (common#.view inner#))))
           mt# {:__tostring to-string#
                :__fennelview to-string#
                :__index (fn [_# key#]
                           (match key#
                             :__id id#
                             :is-a is-a#
                             other# (do
                                      (if (= nil (. attrs# key#))
                                          (error (common#.fmt "%s does not have attr %s"
                                                              is-a# key#)))
                                      (. context# key#))))
                :__newindex (fn [_# key# val#]
                              (if (= nil (. attrs# key#))
                                  (error (common#.fmt "%s does not have attr %s"
                                                      is-a# key#)))
                              (if (not (. attrs# key# :mutable))
                                  (error (common#.fmt "%s.%s is not mutable"
                                                      is-a# key#)))
                              (tset context# key# val#))}]
       (setmetatable {} mt#))))

(fn typeof [x]
  ;; return structs type if given a struct, or normal type for other values.
  `(match [(type ,x) (?. ,x :is-a)]
     [:table nil] :table
     [:table is-a#] is-a#
     [t# _#] t#))

{: struct : typeof}
