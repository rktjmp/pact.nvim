;;; This has been through a lot of iterations, none of them that great.
;;;
;;;   (struct my-struct
;;;           (attr fixed val)
;;;           (attr attribute val show mutable))
;;;
;;;   (struct my-struct
;;;           (const fixed val)
;;;           (mutable attribute val show))
;;;
;;;   (struct my-struct
;;;           (const fixed val)
;;;           (mutable attribute val)
;;;           (describe-by :attribute))
;;;
;;; Some issues with these:
;;;
;;; "Localised" attr/const/mutable/etc forms that only exist in the macro.
;;; Non-string keys look like values on returning from not reading the code for
;;; a while, it felt "too surprising". Adding (const :fixed val) helps a bit
;;; but adding additional options (describe-by) is a bit sticky in that format.
;;;
;;;   (struct :my-struct
;;;           [const :fixed val
;;;            mutable :attribute val]
;;;           :describe-by [:attribute])
;;;
;;; Adding options here is pretty simple, adding extra fields for actors is a
;;; bit weird but managable. Ideally we would not need the `const` specifier
;;; (default to being immutable) but requiring it makes parsing the fields list
;;; simpler.
;;;
;;; This does give the impression you could just pass a list to the form, but
;;; we need to be able to see `mutable :later nil` key so we can identify them
;;; as fields, if given as a list directly, lua essentially discards the
;;; `:later` key, so an actual table is an invalid argument.
;;;
;;; For whatever it's worth, clojure has
;;;
;;;   (defstruct person :name :age)
;;;   (struct person "george" 22)
;;;
;;; and (more recently?)
;;;
;;;   (defrecord Person [name age] opts)
;;;   (def costanza (Person. "george" 22))
;;;
;;; Which would be an interesting way to do it. (defrecord) would probably end
;;; up sticking something on _G and we would have (new-record) or something
;;; instead of def. It does set some kind of precedence for having non-string
;;; field names, but also separates the type definition from the creation which
;;; may be unsuitable in our case.
;;;
;;;  (let [t (defstruct
;;;            pact/runtime
;;;            [groups scheduler config active-activity state]
;;;            :mutable [state active-activity]
;;;            :describe-by [state])]
;;;    (t :groups [] ;; strings for documentation, pref over (t [] sched nil)
;;;       :scheduler scheduler
;;;       :config config
;;;       :state states.READY
;;;       :active-activity nil)))
;;;
;;; defstruct would return a metatable with call and is-a so we could call
;;; (= (typeof struct) (typeof struct-fn)).

(fn parse-fields [fields]
  (let [len (select :# (unpack fields))
        generator (coroutine.wrap #(for [i 0 len 3]
                                     (let [kind (. $1 (+ i 1))
                                           name (. $1 (+ i 2))
                                           val (. $1 (+ i 3))]
                                       (coroutine.yield kind name val))))]
    (icollect [kind name val (values generator fields)]
              {:mutable (= :mutable (tostring kind))
               :name name
               :value val})))

(fn parse-opts [opts]
  (let [len (select :# (unpack opts))
        generator (coroutine.wrap #(for [i 0 len 2]
                                     (let [opt (. $1 (+ i 1))
                                           val (. $1 (+ i 2))]
                                       (coroutine.yield opt val))))]
    (collect [name val (values generator opts)]
             (values name val))))

(fn defstruct [name fields ...]
  (assert (sym? name) "struct name must be given as a symbol")
  (local struct-name (tostring name))
  (assert (sequence? fields) (.. struct-name " fields must be a sequence"))
  (assert (< 0 (select :# (unpack fields))) (.. struct-name " struct must have at least one field"))
  ;; we blindly assume opts is correctly :opt val :opt val without nils
  (let [opts (parse-opts [...])
        ;; extract field names -> flags and default to immutable
        fields (collect [_ field (ipairs fields)] (values (tostring field) {:mutable false}))
        ;; update any mutable field flags
        mutable-fields (each [_ field (ipairs (or opts.mutable []))]
                         (do
                           (assert (. fields (tostring field))
                                   (.. struct-name " cant mark mutable, field does not exist: " (tostring field)))
                           (tset fields (tostring field) :mutable true)))
        ;; extract descriptor field names
        describe-by-fields (icollect [_ field (ipairs (or opts.describe-by []))] (tostring field))]
    `(let [common# (require :pact.common)
           is-a# ,struct-name
           id# (common#.monotonic-id is-a#)
           fields# ,fields
           to-string# #(let [inner# (collect [_# attr# (ipairs ,describe-by-fields)]
                                             (values attr# (or (. $1 attr#) :nil)))]
                         (common#.fmt "(%s %s)" id# (common#.view inner#)))
           ;; struct creation, expects to be called with :field val
           new# (fn [...]
                  ;; TODO: check for keys equality here, need to extract parse-opts or find a lib thats acceptable (cljlib broken)
                  ; (assert (= (length fields#) (select :# ...))
                  ;         (common#.fmt "%s must be called with all fields: %s" is-a# (common#.view fields#)))
                  (let [instance-fields# {}
                        _# (for [i# 1 (select :# ...) 2]
                             (let [key# (. [...] i#)
                                   value# (. [...] (+ i# 1))]
                               (assert (. fields# key#) (common#.fmt "%s does not have field %s" is-a# key#))
                               (tset instance-fields# key# value#)))
                        instance-mt# {:__tostring to-string#
                                      :__fennelview to-string#
                                      :__index (fn [_# key#]
                                                 (match key#
                                                   :__id id#
                                                   :is-a is-a#
                                                   other# (match (. fields# key#)
                                                            nil (error (common#.fmt "%s does not have field %s"
                                                                                    is-a# key#))
                                                            val# (. instance-fields# key#))))
                                      :__newindex (fn [_# key# val#]
                                                    (match (. fields# key#)
                                                      nil (error (common#.fmt "%s does not have attr %s"
                                                                              is-a# key#))
                                                      {:mutable false} (error (common#.fmt "%s.%s is not mutable"
                                                                                           is-a# key#))
                                                      {:mutable true} (tset instance-fields# key# val#)))}]
                    (values (setmetatable {} instance-mt#))))
           type-def-mt# {:__index (fn [_# key#]
                                    (if (= :is-a key#)
                                      (values is-a#)
                                      (error (common#.fmt "struct-def %s should be called or indexed for :is-a, got %s" is-a# key#))))
                         :__call (fn [_# ...] (new# ...))}]
       (setmetatable {} type-def-mt#))))

(fn typeof [x]
  ;; return structs type if given a struct, or normal type for other values.
  `(match [(type ,x) (?. ,x :is-a)]
     [:table nil] :table
     [:table is-a#] is-a#
     [t# _#] t#))

;; (fn struct [struct-name fields ...]
;;   (struct :pact/struct
;;           [const :group g-name
;;            const :color red
;;            mutable :age nil]
;;          :describe-by [:color :age])

(fn neostruct [struct-name fields ...]
  ; (assert (= :string (type struct-name)) "struct name must be given as a string")
  (assert (sequence? fields) (.. :struct-name " fields must be a sequence"))
  (assert (< 0 (select :# (unpack fields))) (.. :struct-name " struct must have at least one field"))
  (assert (= 0 (% (select :# (unpack fields)) 3)) (.. :struct-name " fields must be given in 3-set"))
  ;; parse fields which should match [const|mutable :name value|nil ...]
  (let [opts (parse-opts [...])
        fields (parse-fields fields)
        attributes (collect [_ {: name : mutable} (ipairs fields)]
                            (values name {:mutable mutable}))
        in-memory (collect [_ {: name : value} (ipairs fields)]
                         (values name value))
        describe-by-fields (or opts.describe-by [])]
    `(let [common# (require :pact.common)
           is-a# ,struct-name
           _# (assert (= :string (type is-a#)) "struct name must be a string")
           id# (common#.monotonic-id is-a#)
           ;; all attributes as given originally
           attrs# ,attributes
           ;; the table as it exists, and will exist, in memory
           in-memory# ,in-memory
           to-string# (fn [_#]
                        (let [inner# (collect [_# attr# (ipairs ,describe-by-fields)]
                                              (values attr# (or (. in-memory# attr#) :nil)))]
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
                                      (. in-memory# key#))))
                :__newindex (fn [_# key# val#]
                              (if (= nil (. attrs# key#))
                                (error (common#.fmt "%s does not have attr %s"
                                                    is-a# key#)))
                              (if (not (. attrs# key# :mutable))
                                (error (common#.fmt "%s.%s is not mutable"
                                                    is-a# key#)))
                              (tset in-memory# key# val#))}]
       (setmetatable {} mt#))))

(fn struct [is-a ...]
  "A very weakly typed struct type. Really only exists to wrap asserts around
  field access and some immutability, though that's never going to flow down to
  plain old lua tables.

  (struct my-struct-name
          (describe-by :id :counter) ;; (print my-struct) => my-struct#10{:id x :counter y}
          (const :id forever-value)
          (const :foo :bar)
          (mutable :counter 0)) ;; can (tset my-struct :counter 10)
  (= :my-struct-name (typeof my-struct))"
  (if (= :neo is-a)
    (neostruct ...)
    (let [fields (icollect [_ attr  (ipairs [...])]
                           (let [[call name value & flags] attr
                                 call (tostring call)
                                 flags (collect [_ flag (ipairs flags)]
                                                (values (tostring flag) true))]
                             (when (or (= :const call) (= :mutable call))
                               (tset flags call true)
                               {:name name
                                :value value
                                :flags flags})))
          describe-by-fields (accumulate [found nil _ [call & args] (ipairs [...]) :until found]
                                         (when (= (tostring call) :describe-by) args))
          _ (print (view describe-by-fields))
          attrs (collect [_ {: name : flags} (ipairs fields)]
                         (values name flags))
          context (collect [_ {: name : value} (ipairs fields)]
                           (values name value))]
      `(let [common# (require :pact.common)
             is-a# ,(tostring is-a)
             id# (common#.monotonic-id is-a#)
             attrs# ,attrs
             context# ,context
             describe-by-fields# (or ,describe-by-fields [])
             to-string# (fn [_#]
                          (let [inner# (collect [_# attr# (ipairs describe-by-fields#)]
                                                (values attr# (or (. context# attr#) :nil)))]
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
         (setmetatable {} mt#)))))

  {: struct : typeof : neostruct : defstruct}
