(import-macros {: relative-root} (.. (or (-?> ... (string.match "(.+%.)either")) "") :use))
(local rel-prefix (relative-root &from :either))

(fn def-bind [data]
  (local doc-string
    (string.format "If `x` is `%s`, call `f x` otherwise return `x`." data.right.name))
  (let [x (sym :x)
        f (sym :f)]
    `(fn M.bind [,x ,f]
       ,doc-string
       (if (,data.fns.right? ,x)
         (__M.enforce-type! (,f (M.unwrap ,x)))
         (values ,x)))))

(fn def-either? [data]
  (local doc-string (string.format "True if `v` is a `%s`." data.name))
  (let [v (sym :v)]
    `(fn ,data.fns.either? [,v]
       ,doc-string
       (type-is-any? ,v [,data.left.id ,data.right.id]))))

(fn def-left? [data]
  (local doc-string (string.format "True if `v` a `%s`." data.left.name))
  (let [v (sym :v)]
    `(fn ,data.fns.left? [,v]
       ,doc-string
       (type-is? ,v ,data.left.id))))

(fn def-right? [data]
  (local doc-string (string.format "True is `v` a `%s`." data.right.name))
  (let [v (sym :v)]
    `(fn ,data.fns.right? [,v]
       ,doc-string
       ,(.. "is " data.right.name "?")
       (type-is? ,v ,data.right.id))))

(fn make-unit-doc-string [docstring right-name left-name right-match left-match diff?]
  (local str
"Create an `%s` or `%s`.

%s

Match signatures:

`%s -> %s`

`%s -> %s`

See also `%s', `%s'%s.")
  (string.format str
                 right-name left-name
                 (or docstring "")
                 right-match right-name
                 left-match left-name
                 right-name left-name
                 (if diff? " which have different match specs" "")))

(fn def-unit [data]
  (fn v [side] (. data side :unit :value))
  (fn m [side] (. data side :unit :match))

  (let [left-match (m :left)
        left-value (v :left)
        right-match (m :right)
        right-value (v :right)
        doc-string (make-unit-doc-string data.docstring
                                         data.right.name data.left.name
                                         data.right.unit.match data.left.unit.match
                                         (not (= nil (or (?. data :right :cons :match)
                                                         (?. data :left :cons :match)))))]
    `(fn M.unit [...]
       ,doc-string
       (let [,(sym :arguments) (pack ...)]
         (match arguments
           ;; dont nest types.
           (where [either#] (and (= 1 arguments.n) (,data.fns.either? either#))) (values either#)
           ,left-match (,data.fns.left ,left-value)
           ,right-match (,data.fns.right ,right-value)
           _# (let [{:view view#} (require :fennel)]
                (error (string.format "attempted to create %s but did not match any spec (%q)"
                                    ,data.name (view# arguments)))))))))

(fn make-side-docstring [name m v]
  (local str
"Create `%s`, if arguments match `%s`, holds value of `%s`.

May be matched against with `[:%s ...]` or `%s?'. May also be `unwrap'ed into values.

Has `:n` key storing the number of values (after 1, the id).")
  (string.format str name m v name name))

(fn def-left [data]
  (fn v [side] (or (?. data side :cons :value) (. data side :unit :value)))
  (fn m [side] (or (?. data side :cons :match) (. data side :unit :match)))

  (let [left-match (m :left)
        left-value (v :left)
        right-match (m :right)
        doc-string (make-side-docstring data.left.name left-match left-value)]
    `(fn ,data.fns.left [...]
       ,doc-string
       (let [,(sym :arguments) (pack ...)]
         (match arguments
           ,left-match (__M.gen-type ,data.left.name ,left-value)
           ,right-match (-> (string.format "attempted to create %s but value matched %s"
                                           ,data.left.name ,data.right.name)
                            (error))
           _# (error (string.format "attempted to create %s but did not match any spec"
                                    ,data.left.name)))))))

(fn def-right [data]
  (fn v [side] (or (?. data side :cons :value) (. data side :unit :value)))
  (fn m [side] (or (?. data side :cons :match) (. data side :unit :match)))

  (let [right-match (m :right)
        right-value (v :right)
        left-match (m :left)
        doc-string (make-side-docstring data.right.name right-match right-value)]
    `(fn ,data.fns.right [...]
       ,doc-string
       (let [,(sym :arguments) (pack ...)]
         (match arguments
           ,right-match (__M.gen-type ,data.right.name ,right-value)
           ,left-match (error (string.format "attempted to create %s but value matched %s"
                                             ,data.right.name ,data.left.name))
           _# (error (string.format "attempted to create %s but did not match any spec"
                                    ,data.right.name)))))))

(fn def-enforce-type! [data]
  (let [v (sym :v)]
    `(fn __M.enforce-type! [,v]
       ;; internally check for valid type and raise if not
       (if (,data.fns.either? ,v)
         (values ,v)
         (error (string.format (.. "Expected " ,data.name " but was given %s<%s>")
                               (type-of ,v)
                               (tostring ,v)))))))

(fn def-gen-type [data]
  (let [type-name (sym :type-name)]
    `(fn __M.gen-type [,type-name ...]
       (let [val# (pack ...)
             tos# #(let [{:view view#} (require :fennel)
                         val-str# (fcollect [i# 1 val#.n]
                                    (view# (. val# i#) {:prefer-colon? true}))]
                     (.. "@" ,type-name "<" (table.concat val-str# ",") :>))
             type-t# (match ,type-name
                       ,data.left.name ,data.left.id
                       ,data.right.name ,data.right.id
                       _# (error (.. ,data.name " construction: invalid type name " ,type-name)))
             mt# {:__tostring tos#
                  :__fennelview tos#
                  :__call #(match $2
                             ,data.syms.protect-call (unpack val#)
                             _# (error (.. "nedry.gif")))}]
         ;; we unpack the value into our seq so you can pattern match on
         ;; [:my-type true 1 :a]  instead of [:my-type [true 1 a]]
         (doto [,type-name (unpack val#)]
           (tset :n val#.n)
           (setmetatable mt#)
           (set-type type-t#))))))

(fn def-map [data]
  (let [either (sym data.name)
        right-f (sym (.. data.right.name :-f))
        ?left-f (sym (.. :? data.left.name :-f))]
    (local doc-string
      (string.format "If %s is %s, call `%s` with value.
                     If %s is %s, call `%s` if given or return `%s`.
                     Called functions *may alter original type* if they return an alternate match value."
                     data.name data.right.name right-f
                     data.name data.left.name ?left-f data.name))
    `(fn M.map [,either ,right-f ,?left-f]
       ,doc-string
       (if (,data.fns.right? ,either)
         (,data.fns.map-right ,either ,right-f)
         ;; explicitly check because any default fn we provide may alter the type
         (if ,?left-f
           (,data.fns.map-left ,either ,?left-f)
           (values ,either))))))

(fn def-map-left [data]
  (let [either (sym data.name)
        f (sym :f)]
    (local doc-string
      (string.format "If `%s` is `%s`, call `%s` with value, othewise return `%s`."
                     either data.left.name f either))
    `(fn ,data.fns.map-left [,either ,f]
       ,doc-string
       (if (,data.fns.left? ,either)
         (M.unit (,f (M.unwrap ,either)))
         (values ,either)))))

(fn def-map-right [data]
  (let [either (sym data.name)
        f (sym :f)]
    (local doc-string
      (string.format "If `%s` is `%s`, call `%s` with value, othewise return `%s`."
                     either data.right.name f either))
    `(fn ,data.fns.map-right [,either ,f]
       ,doc-string
       (if (,data.fns.right? ,either)
         (M.unit (,f (M.unwrap ,either)))
         (values ,either)))))

(fn def-unwrap [data]
  (let [either (sym data.name)]
    `(fn M.unwrap [,either]
       ,(string.format "Unwrap `%s` into values." data.name)
       (when (__M.enforce-type! ,either)
         (,either ,data.syms.protect-call)))))



(fn def-macro [opts]
  "Generic left-right monad generator. See Maybe and Result for example usage
  and this macros comments"
  ;; TODO: this will need actual options check/enforcement.
  (match opts
    ;; base/container name (maybe)
    {:name either-name
     ;; optional docstring to add to function
     ;; :docstring "..."
     :left {;; type id, user visible, (ok, none)
            :id left-id
            ;; name (ok, none), used for function generation
            :name left-name
            ;; optional docstring to add to function
            ;; :docstring "..."
            ;; unit is called with (match arguments) where
            ;; arguments is a packed sequence of all values passed
            ;; to unit function.
            :unit {;; what to look for in arguments
                   ;; [nil]
                   :match left-match
                   ;; value passed to constructor from unit function
                   ;; note that [true & rest] may not capture all values if nils are present
                   ;; so better to operate directly on the arguments
                   ;; nil
                   :value left-value}}
     ;; cons is similar to above but used in specific type constructor, if not
     ;; given then the same values as unit are used.
     ;;
     ;; This distinction exists to allow (unit ...) to generate types while
     ;; (my-type ...) can be more or less strict.
     ;;
     ;; no pattern as we want to allow construction of (ok false) or (ok nil)
     ;; but (unit false :err) should give us (err :err)
     ;; :cons {;; here we have a broad match on anything given
     ;;        :match arguments
     ;;        ;; value should match what we want back when we
     ;;        ;; unwrap, in this case we want all the
     ;;        ;; arguments but not in a sequence.
     ;;        :value (unpack arguments)}}}))
     ;;
     ;; in-scope: pack, unpack, arguments
     :right {:id right-id
             :name right-name
             :unit {:match right-match
                    :value right-value}}}
    true
    _ (error :missing-options))

  (local {:name either-name
          :left {:id left-id
                 :name left-name}
          :right {:id right-id
                  :name right-name}} opts)
  (local fns {:unit (sym (.. :M.unit))
              :either (sym (.. :M. either-name))
              :left (sym (.. :M. left-name))
              :right (sym (.. :M. right-name))
              :either? (sym (.. :M. either-name :?))
              :right? (sym (.. :M. right-name :?))
              :left? (sym (.. :M. left-name :?))
              :map (sym (.. "M.map"))
              :map-left (sym (.. "M.map-" left-name))
              :map-right (sym (.. "M.map-" right-name))})
  (local syms {:protect-call (sym (.. :__protect-call))})
  (tset opts :fns fns)
  (tset opts :syms syms)

  `(do
     (local {:type-is-any? ,(sym :type-is-any?)
             :type-is? ,(sym :type-is?)
             :set-type ,(sym :set-type)
             :type-of ,(sym :type-of)} (require ,(.. rel-prefix :.type)))
     (local {:unpack ,(sym :unpack) :pack ,(sym :pack)} (require ,(.. rel-prefix :.enum)))
     (local ,opts.syms.protect-call [:password])
     (local ,(sym :M) {})
     (local ,(sym :__M) {})

    ;; type checking and enforcement

    ,(def-either? opts)
    ,(def-left? opts)
    ,(def-right? opts)
    ,(def-enforce-type! opts)
    ,(def-gen-type opts)

    ,(def-unit opts)
    (tset M ,opts.name ,(sym :M.unit))
    ,(def-unwrap opts)
    ,(def-bind opts)

    ,(def-left opts)
    ,(def-right opts)

    ,(def-map opts)
    ,(def-map-left opts)
    ,(def-map-right opts)

    (values M)))

{:def-either def-macro}
