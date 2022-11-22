(import-macros {: use}
               (.. (or (-?> ... (string.match "(.+%.)result")) "") :use))

(use {: type-of} :type &from :result
     enum :enum &from :result
     {: 'def-either} :either &from :result)

;; Transplant from original unit() TODO rewrite to be relevant-er
;;
;; result/unit has to accept multiple values to be functionally useful
;; in the lua ecosystem where functions may return `nil err ...`, othewise
;; calls would always have to be surrounded by `[(call)]` to capture values
;; into one table. Some functions will return muliple error details (libluv)
;; so we also have to capture them all.
;; Because we accept multi values in that case, we also collect multi values
;; for the ok type.
;; This does have the side effect that we must retain our "wrapped value"
;; inside a table, which also makes it less ergonomic to expose the value
;; for pattern matching.

(local M
  (def-either {:name :result
               :docstring "An `err' is strictly matched against `[nil any ...]`, while `ok' is anything else.

This allows for correctly matching *non-error* `nil` values where that is appropriate.

Ex,

`(result nil :broken) -> err`

`(result nil) -> ok`

`(result nil nil) -> ok`

"
               :left {:id :ruin.result.ERR_TYPE
                      :name :err
                      ;; strictly matches [nil ...]
                      :unit {:match (where [nil] (<= 2 arguments.n))
                             :value (unpack arguments 2)}
                      :cons {:match arguments
                             :value (unpack arguments)}}
               :right {:id :ruin.result.OK_TYPE
                       :name :ok
                       ;; nil -> ok, :str -> ok, nil _ ...-> err
                       :unit {:match (where _ (not (and (<= 2 arguments.n)
                                                        (= nil (. arguments 1)))))
                              :value (unpack arguments)}
                       ;; allow exact creation of (ok nil ...) if required
                       :cons {:match arguments
                              :value (unpack arguments)}}}))

(fn M.join [r1 r2]
  (assert (and (M.result? r1) (M.result? r2))
          (.. "result#join argument was not a result type" (type-of r1) (type-of r2)))
  (fn package [how a b]
    ;; act carefully so we don't drop any sparse nils
    (let [a (enum.pack (M.unwrap a))
          b (enum.pack (M.unwrap b))]
      (-> [(enum.unpack a 1 a.n)]
          (enum.append$ (enum.unpack b 1 b.n))
          (#(how (enum.unpack $1 1 (+ a.n b.n)))))))
  (match [(M.ok? r1) (M.ok? r2)]
      ;; ok + ok -> ok-ok
      [true true] (package M.ok r1 r2)
      ;; ok + err -> err
      [true false] r2
      ;; err + ok -> err
      [false true] r1
      ;; err + err -> err-err
      [false false] (package M.err r1 r2)))

(fn M.unwrap-or-raise [result]
  "Call `(error ...)` if `result` is an `err` otherwise return `(unwrap result)`"
  (if (M.err? result)
    (error (M.unwrap result))
    (M.unwrap result)))
(tset M :unwrap! M.unwrap-or-raise)

;; validate??
; (fn validate [v p e]
;   (fn [...]
;     (if (p ...)
;       (values ...)
;       (err e))))
;; probably best served by the end user as it's a bit ambiguous around whehere
;; we accept a result, or a value, or both, and maybe call a function on e, or
;; ... etc. vs just defining the wanted behaviour in the downstream code or at
;; least another module.

; (fn M.or [result pred when-false]
;   (if pred result (when-false result)))

; (fn M.or-err [f e]
;   "Accepts a function and an error value. Returns a function that calls `f`
;   with the any arguments and returns `ok ...` if `f` returns true, or `err e`
;   if `f` returns false. Most useful with `->' when simpilfying validation
;   pipelines."
;   (fn [...] (if (f ...) (ok ...) (err e))))

; (fn M.or-err* [f e]
;   "See `or-err', but unwraps the final `ok`/`err` value."
;   (fn [...]
;     (let [ff (M.or-err f e)
;           r (ff ...)]
;       (M.unwrap r))))

;; As a side effect of using the macro, (err ...) requires (err nil val ...)
;; which isn't great ergonomics as (err) already implies the nil.
;; But because the pattern match is generic-ish and used inside unit to
;; detect which type to use, we get this effect.
;;
;; Maybe.none is able to detect nil or nothing, so you can call (none), but we
;; don't want (none :x) to work (it's a some value) so it does need the same or
;; similar test.
;;
;; We could add two match/value expressions one for unit and one for the
;; constructor, where unit will extract generic args to specific (eg nil x -> x)

; (local _err M.err)
; (fn M.err [...]
;   "Accepts any value and wraps it in a `err` type. Note that for ergonomic
;   resons, the 'error type match' is not applied here and any value is accepted.
;   Eg: `(err nil :error)` will result in `err<nil :error>`. Instead you should
;   use `(err :error)` or if you are accepting unknown arguments, use `unit'
;   instead which will convert `nil ...` into `err<...>` when appropriate.
;   Note that (err nil nil) will be converted into `err<nil>`."
;   (_err nil ...))

(values M)

; (local relrequire ((fn [ddd] #(require (.. (or (string.match ddd "(.+%.)ruin%.") "") $1))) ...))

; (local {: type-is-any? : type-is? : set-type : type-of} (relrequire :ruin.type))
; (local {: no-missing-access} (relrequire :ruin.table))
; (local unpack (or _G.unpack table.unpack))

; (local constants (no-missing-access {:OK_TYPE :ruin.result.OK
;                                      :ERR_TYPE :ruin.result.ERR}))
; (local opaque-unwrap [:get-value])

; ;; type checking and enforcement

; (fn result? [result]
;   (type-is-any? result [constants.OK_TYPE constants.ERR_TYPE]))

; (fn ok? [result]
;   "true for ok, false for any other value"
;   (type-is? result constants.OK_TYPE))

; (fn err? [result]
;   "true for err, false for any other value"
;   (type-is? result constants.ERR_TYPE))

; (fn enforce-type! [result]
;   ;; internally check for valid type and raise if not
;   (if (result? result)
;     (values result)
;     (error (string.format "Expected result-type but was given %s<%s>"
;                           (type-of result)
;                           (tostring result)))))

; ;; public unwrap

; (fn unwrap [result]
;   "return value of result"
;   (when (enforce-type! result)
;     (result opaque-unwrap)))

; ;; type creation

; (fn gen-type [type-name val n]
;   (let [tos #(.. type-name :< (table.concat val ",") :>)
;         type-t (match type-name
;                  :ok constants.OK_TYPE
;                  :err constants.ERR_TYPE
;                  _ (error (.. "result-construction: invalid type name " type-name)))
;         mt {:__tostring tos
;             :__call #(match $2
;                        opaque-unwrap (unpack val 1 n)
;                        _ (error (.. "nedry.gif")))}]
;     (doto [type-name (unpack val 1 n)]
;       (tset :n n)
;       (setmetatable mt)
;       (set-type type-t))))

; (fn ok [...]
;   "Create an ok with given values"
;   (gen-type :ok [...] (select :# ...)))

; (fn err [...]
;   "Create an err with given values"
;   (gen-type :err [...] (select :# ...)))


; ;; monad stuff

; (fn unit [...]
;   "Create an ok or err container depending on given arguments."
;   ;; result/unit has to accept multiple values to be functionally useful
;   ;; in the lua ecosystem where functions may return `nil err ...`, othewise
;   ;; calls would always have to be surrounded by `[(call)]` to capture values
;   ;; into one table. Some functions will return muliple error details (libluv)
;   ;; so we also have to capture them all.
;   ;; Because we accept multi values in that case, we also collect multi values
;   ;; for the ok type.
;   ;; This does have the side effect that we must retain our "wrapped value"
;   ;; inside a table, which also makes it less ergonomic to expose the value
;   ;; for pattern matching.
;   (let [argc (select :# ...)]
;     (match ...
;       ;; dont nest types
;       (where result (and (= 1 argc) (result? result))) (values result)
;       ;; nil _any -> error, but we only keep _any onwards
;       (where nil (<= 2 argc)) (err (select 2 ...))
;       ;; any other set of values is ok
;       _ (ok ...))))

; (fn bind [x f]
;   (if (ok? x)
;     (enforce-type! (f (unwrap x)))
;     (values x)))

; (fn map-ok [result f]
;   "If result is ok, call f v, otherwise return result."
;   (if (ok? result)
;     (unit (f (unwrap result)))
;     (values result)))

; (fn map-err [result fun]
;   "If result is err, call f e, otherwise return result."
;   (if (ok? result)
;     (values result)
;     (unit (fun (unwrap result)))))

; (fn map [result ok-fn ?err-fn]
;   "If result is ok, call ok-fn with value.
;   If result is err, call err-fn if given or return result.
;   Called functions *may alter original type* if they return `nil ...` or `val`."
;   (if (ok? result)
;     (map-ok result ok-fn)
;     (map-err result (or ?err-fn #(values $...)))))

; {: bind
;  : unwrap
;  : unit
;  :result unit
;  : map
;  : map-err
;  : map-ok
;  : ok?
;  : err?
;  : result?
;  : ok
;  : err}
