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

;;; other ideas

;;; following on from Induction, where a module may be "struct"ed, it could automatically
;;; set some functions such as ->struct (clojure constructor?) and ->type (type name)
;;; instead of having to (typeof structed-module)
;;;
;;;  (defrecord provider/git
;;;    [id url path])
;;;
;;;  (provider/git->struct
;;;    :id id ...)
;;; 
;;; or more completely
;;; 
;;;   (defmodule provider/git
;;;     ;; m* -> special syntax to push struct as module, or perhaps
;;;     ;; just infer on sym? vs sequence?
;;;     (defstruct m*
;;;       [id path url]))
;;; 
;;;   ;; if you know git-provider is a struct-module, -> type makes some sense
;;;   ;; though maybe awkward without an argument.
;;;   (let [git-provider (require :provider.git)
;;;         ;; calling a module is also a bit weird
;;;         my-struct (git-provider :id 10 :url :http...)
;;;         ;; module can have functions too so ...
;;;         supported-version (git-provider.supported-version)
;;;         ;; maybe nicer to have explicit
;;;         my-struct (git-provider.->struct :id 10 ...)
;;;         git-provider-type (git-provider.->type)]
;;;     (match (typeof my-struct)
;;;       git-provider-type :git))
;;; 
;;;   ;; vs
;;; 
;;;   ;; again, you have to know that its a struct-module, but calling
;;;   ;; (typeof module) seems like you'd expect it to return "its a module"?
;;;   (let [git-provider (require :provider.git)
;;;         my-struct (git-provider :id 10 :url :http...)
;;;         git-provider-type (typeof git-provider)]
;;;     (match (typeof my-struct)
;;;       git-provider-type :git))
;;; 
;;; ;; If you abuse Inductions """global""" struct registry idea, you could have something like
;;; 
;;;   (struct->type provider/git) ;; macro
;;; 

;;; (->struct provider/git :id 10)
;;; (->type my-struct)

;;; I also don't really like the term "defstruct" where it's actually
;;; "def-fn-that-returns-struct". If given a module system, you could use
;;; "defstruct" as elixir does, where structs are tightly linked to modules, but
;;; that does remove some of the flexibility of the type, which is probably pretty
;;; important. We might want to have 3 "actions", sync, hold, delete. These could all
;;; be their own structs with own data (sync needs commit, hold needs nothing,
;;; delete needs confirmation), so it's useful to be able to define 3 types "on the fly"
;;; vs having to create 3 modules, then define the structs inside each. Defining modules
;;; isn't **too** hard, but it is friction.
;;; (I really don't want to call it (defstructfactory ...))

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

;; TODO? This could now just be a plain function, since the instance creation
;; is separated from the definition, assuming you are ok with prefixing the name
;; and arguments as strings. This also allows for more flexible creation since
;; you can just pass in strings and tables.
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
           fields# ,fields
           ;; struct creation, expects to be called with :field val
           new# (fn [...]
                  ;; TODO: check for keys equality here, need to extract
                  ;; parse-opts or find a lib thats acceptable (cljlib broken)
                  ; (assert (= (length fields#) (select :# ...))
                  ;         (common#.fmt "%s must be called with all fields: %s" is-a# (common#.view fields#)))
                  (let [id# (common#.monotonic-id is-a#)
                        to-string# #(let [inner# (collect [_# attr# (ipairs ,describe-by-fields)]
                                                          (values attr# (or (. $1 attr#) :nil)))]
                                      (common#.fmt "(%s %s)" id# (common#.view inner#)))
                        instance-fields# {}
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
                                                   :__is-a is-a#
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
                    (values (setmetatable {} instance-mt#))))]
       (values new# {:type is-a#}))))

(fn typeof [x]
  ;; return structs type if given a struct, or normal type for other values.
  `(match [(type ,x) (?. ,x :__is-a)]
     [:table nil] :table
     [:table is-a#] is-a#
     [t# _#] t#))

{: typeof : defstruct}
