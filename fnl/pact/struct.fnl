;; TODO it would be nicer if is-a is a string, because we can
;; just pass the is-a type from the module context
;; also just use direct strings when definining attrs
(fn struct [is-a ...]
  "(struct my/struct (attr name :my-name mutable show)) ;; can tset, will appear in tostring"
  (let [processed (icollect [_ attr (ipairs [...])]
                    (let [[call name val & flags] attr]
                      (when (not (= :attr (tostring call)))
                        (error "struct only accepts attr call"))
                      {:name (tostring name)
                       :value val
                       :flags (collect [_ flag (ipairs flags)]
                                (values (tostring flag) true))}))
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
                             :id id#
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
