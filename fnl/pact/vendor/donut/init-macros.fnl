;; This is used in other modules in this lib, so the code here is
;; self-contained even if libdonut provides some functionality needed.

(fn is-quote? [x]
  (and (list? x)
       (= :quote (tostring (. x 1)))))

(fn is-sym? [x]
  (and (sym? x)
       true))

(fn is-binding-list? [x]
  (and (table? x)
       (not (sequence? x))))

(fn quote->name [qx]
  (if (is-quote? qx)
    (tostring (. qx 2))
    (assert-compile false "cant convert into name" qx)))

(fn calcuate-ranges [...]
  ;; Searches through all arguments for "open val opt pair opt pair" ranges
  ;; returns sequence of {start end} pairs.
  (local ranges [])
  (var search {:start nil :end nil})
  (fn set-search [start end]
    (tset search :start start)
    (tset search :end end))
  ;; we will check every second index, which should go seq, string|seq,
  ;; string|seq, where a string indicates an option and seq a new import set.
  (for [i 1 (select :# ...) 2]
    (let [v (select i ...)
          check {:acceptable-start-expression? (or (is-binding-list? v)
                                                   (is-sym? v)
                                                   (is-quote? v))
                 :have-start? (not (= nil search.start))
                 :string? (= :string (type v))
                 :final-pair? (= (select :# ...) (+ 1 i))}]
      (match check
        ;; no range start set, found sequence, set range open
        {:have-start? false :acceptable-start-expression? true}
        (set-search i)
        ;; have open range, found sequence, close range and open new
        {:have-start? true :acceptable-start-expression? true}
        (do
          (set-search search.start (- i 1))
          (table.insert ranges search)
          (set search {})
          (set-search i))
        ;; have open range, found string, just options, no action
        {:have-start? true :string? true}
        (do nil)
        ;; no start, no seq, error
        {:have-start? false :acceptable-start-expression? false}
        (let [msg "expected {:key sym} but got %s"]
          (assert-compile false (string.format msg (view v)) v))
        _
        (let [msg "did not know how to handle %s"]
          (assert-compile false (string.format msg (view [v check search])) v)))
      ;; the final pair wont be closed by the next checks because they never happen
      ;; just close the range
      (when check.final-pair?
        (set-search search.start (+ i 1))
        (table.insert ranges search)
        (set search {}))))
  (values ranges))

(fn parse-binding-table [table]
  ;; binding tables should be {:field-name user-name}, where 'user-name
  ;; indicates we are expecting a macro. When given {: func}, fennel
  ;; will automatically give us {:func func}, but {: 'mac} will give us
  ;; {(sym ":") (quote mac)} and requires extra checking.
  (icollect [mod-key user-key (pairs table)]
    (if (is-quote? user-key)
      (let [user-key (quote->name user-key)
            mod-key (if (= :string (type mod-key)) mod-key user-key)]
        [:pair :macro mod-key user-key])
      [:pair :module mod-key (tostring user-key)])))

(fn parse-binding-sym [opener]
  (if (is-quote? opener)
    [[:single :macro (quote->name opener)]]
    [[:single :module (tostring opener)]]))

(fn extract-range [start end ...]
  (let [opener (select start ...)
        bindings (if (or (sym? opener) (list? opener))
                   (parse-binding-sym opener)
                   (parse-binding-table opener))
        _ (assert-compile (< 0 (length bindings))
                          "must specify bindings"
                          (select start ...))
        modname (select (+ 1 start) ...)
        opts []
        _ (for [i (+ start 2) end]
            (tset opts (select i ...) (select (+ 1 i) ...)))]
    [bindings modname opts]))

(fn extract-sets [ranges ...]
  (icollect [_ {: start : end} (ipairs ranges)]
    (extract-range start end ...)))

(fn gen-name [name opts]
  (if opts.as
      (sym (.. (tostring opts.as) :/ name))
      (sym name)))

(fn prepare-set [a-set]
  (let [[bindings modname opts] a-set
        pair-module-binds (collect [_ [p t field-name user-name] (ipairs bindings)]
                            (when (and (= :pair p) (= :module t))
                              (values field-name (gen-name user-name opts))))
        pair-macro-binds (collect [_ [p t field-name user-name] (ipairs bindings)]
                           (when (and (= :pair p) (= :macro t))
                             (values field-name (gen-name user-name opts))))
        single-module-bind (match bindings
                             [[:single :module name]] (gen-name name opts))
        single-macro-bind (match bindings
                            [[:single :macro name]] (gen-name name opts))
        single-module-binds (collect [_ [s t user-name] (ipairs bindings)]
                              (when (and (= :single s) (= :module t))
                                (values user-name (gen-name user-name opts))))
        single-macro-binds (collect [_ [s t user-name] (ipairs bindings)]
                             (when (and (= :single s) (= :macro t))
                               (values user-name (gen-name user-name opts))))
        get-mod (if (= :string (type modname)) `(require ,modname) modname)
        safe-get-mod `(let [mod# ,get-mod
                            keys# ,(icollect [key _ (pairs pair-module-binds)] key)]
                        (each [_# key# (ipairs keys#)]
                          (assert (not (= nil (. mod# key#)))
                                  (string.format "mod did not have key %s %s" key# ,(view modname))))
                        (values mod#))
        code []]
    (if (not (= nil (next pair-macro-binds)))
      ;; import-macros already checks for field existience
      (table.insert code `(import-macros ,pair-macro-binds ,modname)))
    (if (not (= nil (next pair-module-binds)))
      (table.insert code `(local ,pair-module-binds ,safe-get-mod)))
    (if (not (= nil single-macro-bind))
      (table.insert code `(import-macros ,single-macro-bind ,modname)))
    (if (not (= nil single-module-bind))
      (table.insert code `(local ,single-module-bind ,get-mod)))
    (values code)))

(fn use [...]
  "A multi-bind table-unpack macro with key checking. Automatically treats
  strings as arguments to require.

    (use {:head hd : tail : 'over} :lib.list)

  Accepts a table of module keys to user symbol names, a module name or form
  that will return a table, and a collection of options.

  Options:

    :as sym -> bind to sym/key instead of key

  Example

    (use {: maybe-m :m-> '->} :lib.ruin.monad :as m
         {:format fmt} string
         lume :lume
         {:abc z} ((fn [] {:abc {:val 10}})) :as xy
         {: val} z)

  This will result in:

    The field maybe-m being brought into scope from lib.ruin.monand, as
    m/maybe-m.

    The macro m-> will be imported from :lib.ruin.monad, as m/->.

    lume will be bound to the :lume module.

    string.format will be bound to fmt

    The given form will be evaluated, the abc field will be bound to xy/z.

    xy/z.val will be bound to val."
  ;; we should always get an even number of arguments, as we should get at least
  ;; binding modname, we may get pairs of options to attach to that.
  (assert-compile (= 0 (% (select :# ...) 2)) "use must receive even number of arguments")
  (assert-compile (<= 2 (select :# ...)) "use must have at least two arguments")
  (let [ranges (calcuate-ranges ...)
        sets (extract-sets ranges ...)
        prepared (icollect [_ a-set (ipairs sets)]
                   (prepare-set a-set))]
    (accumulate [ft []
                 _ prep-set (ipairs prepared)]
      (icollect [_ code (ipairs prep-set) :into ft] code))))

(fn do-use [uses ...]
  (assert-compile (sequence? uses) "do-use use arguments must be inside []" uses)
  (let [use-ast (macroexpand `(use ,(unpack uses)))]
    `(do
       ,use-ast
       ,...)))

{:import-from use :do-with-import do-use
 : use : do-use}
