;;; Donut Type management
;;;
;;; Mark a table as having a type (id'd by any value) with `set-type`, check
;;; value against this type with `of` or `type-of`.

(local next _G.next)
(local ruin-type-key :__ruin__type)

(local M {})

;; generic type actions

(fn M.of [value]
  "ruin-type aware (type x) function"
  (match (getmetatable value)
    {ruin-type-key dt} (values dt)
    _ (type value)))

(fn M.set-type [value type-id]
  "set ruin-type"
  (assert type-id "type#set-type requires non-nil type-id")
  (let [mt (or (getmetatable value) {})]
    (tset mt ruin-type-key type-id)
    (setmetatable value mt)))

(fn M.is-any? [value valid-types]
  "is the type of value in the list valid-types?"
  (let [want-type (M.of value)]
    (accumulate [in false _ type-id (ipairs valid-types) :until in]
        (= type-id want-type))))

(fn M.is? [value type-id]
  "is the type of value t?"
  (M.is-any? value [type-id]))


;; specific type checks

(fn M.seq? [v]
  "Checks if v is a has at least t[1], is an empty table or {:n 0} (packed table with zero values)"
  (if (= :table (type v))
    (match [(. v 1) (length v) (next v)]
      ;; Has v[1] value (so ipairs-able), this will over match but that's lua.
      [not-nil _ _] true
      ;; truely empty
      [nil 0 nil] true
      ;; possibly packed table with no values, where :n is the only key
      [nil 0 :n] (= nil (next v :n))
      _ false)
    false))

(fn M.assoc? [v]
  "Is `v` an associative table? Does not have t[1] or is {}."
  ;; This does exclude mixed tables, and really we can probably relax this
  ;; conceptually since seqs are assocs to some degree, and we are more
  ;; interested in knowing when a table is specifically a sequence over seq vs
  ;; assoc. TODO: maybe remove assoc?
  ;; Technically is :table and t[1] == nil is enough.
  (and (= :table (type v))
       (= nil (. v 1))))

(fn M.table? [v]
  "Is `v` a table - sequence or associative?"
  (= :table (type v)))

(fn M.number? [v]
  "Is `v` a number?"
  (= :number (type v)))

(fn M.boolean? [v]
  "Is `v` a boolean?"
  (= :boolean (type v)))
(tset M :bool? M.boolean?)

(fn M.string? [v]
  "Is `v` a string?"
  (= :string (type v)))

(fn M.function? [v]
  "Is `v` a function?"
  (= :function (type v)))

(fn M.nil? [v]
  "Is `v` nil?"
  (= :nil (type v)))

(fn M.userdata? [v]
  "Is `v` userdata?"
  (= :userdata (type v)))

(fn M.thread? [v]
  "Is `v` a thread?"
  (= :thread (type v)))

;; functions are "type-" prefixed as generally you probably pull one or two of
;; these out in to the module namespace, so this lets you easly use `type-of`
;; instead of `t.of` or `type.of` (if you want to clobber the built-in `type`
;; function...)

(tset M :type-is? M.is?)
(tset M :type-of M.of)
(tset M :type-is-any? M.is-any?)

(values M)

