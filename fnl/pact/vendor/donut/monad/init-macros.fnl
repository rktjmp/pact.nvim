(local relrequire ((fn [ddd] #(require (.. (or (string.match ddd "(.+%.)donut%.") "") $1))) ...))

(local {:chunk-every seq/chunk-every} (relrequire :donut.seq))
(local {:fwd gen/fwd
        :bkwd gen/bkwd
        :->seq gen/->seq} (relrequire :donut.gen))

(fn copy [t]
  ;; copy forms before we modify them if needed
  (let [out []]
    (each [_ v (ipairs t)] (table.insert out v))
    (setmetatable out (getmetatable t))))

(fn do-monad [monad-t bindings ...]
  "Accepts a monad-t, a list of let-like bindings and then any set of
  expressions."
  ;; Our goal form is this, which is most simply created inside out.
  ;; First we create the result form, then then function containing that,
  ;; then the function containing that ... etc.
  ;; (do-monad maybe-m
  ;;   [a 10
  ;;    b 8]
  ;;   (* a b))
  ;; (maybe-m.bind
  ;;   10 (fn [a]
  ;;        (maybe-m.bind
  ;;          8
  ;;          (fn [b]
  ;;            (maybe-m.result (* a b)))))
  ;; assert monad-t has bind and result
  (assert-compile (= 0 (% (length bindings) 2))
                  "do-monad requires even number of bindings"
                  bindings)
  (assert-compile (< 0 (select :# ...))
                  "do-monad requires at least one expression after bindings"
                  bindings)
  (let [bind-fn (sym (.. (tostring monad-t) :.bind))
        result-fn (sym (.. (tostring monad-t) :.result))
        ;; start with the inner most statement present, we will extract this
        ;; and wrap it.
        ;; ... may be one expression or many, so wrap in (do). we do this
        ;; because I kept writing multiple expressions and do/doto accept
        ;; multiple expressions.
        code `(do (,result-fn (do ,...)))]
    ;; we now work from the tail up
    (let [tail-first (-> bindings
                         (seq/chunk-every 2)
                         (gen/bkwd)
                         (gen/->seq))]
      (each [[binding value] (gen/fwd tail-first)]
        (let [tail (. code (length code))
              new-tail `(,bind-fn ,value (fn [,binding] ,tail))]
          (tset code (length code) new-tail))))
    (values code)))

;; @deprecated
(fn m-> [monad-t initial-value ...]
  "See ->, but operates via monad-t

  (m-> maybe-m 10
    (inc)
    (add 3)
    ((fn [v] (* v v))))"
  (assert-compile monad-t "m-> requires a monad-t first argument")
  (assert-compile (< 0 (select :# ...))
                  "requires at least one form after initial-value to chain through"
                  initial-value)
  (let [bind-fn (sym (.. (tostring monad-t) :.bind))
        result-fn (sym (.. (tostring monad-t) :.result))
        ;; turn (inc x) -> (fn [a] (inc a x)) so it's m-bind-able
        m-forms (icollect [i form (ipairs [...])]
                  ;; use vargs so we can avoid leaking intermediate values
                  (let [f (copy (if (list? form) form (list form)))
                        ;; arg-sym (gensym (fmt :m-thread-fn-%d-arg i))
                        _ (table.insert f 2 `...)]
                    `((fn [...] ,f) ...)))
        ;; wrap initial value in function for uniform interface
        _ (table.insert m-forms 1 `((fn [] ,initial-value)))
        code `(do (,result-fn ...))]
    ;; as with do-monad, we build tail->head
    (each [value (gen/bkwd m-forms)]
      (let [tail (. code (length code))
            new-tail `(,bind-fn ,value (fn [...] ,tail))]
        (tset code (length code) new-tail)))
    code))

(fn defmonad [...]
  ;; this can just be a function, it *was* just a function, but it feels
  ;; awkwarder having this in the regular module, so for now I guess it can
  ;; live here with the other manipulators.
  ;; this may actually becomef more of a macro where it will define maybe-> etc.
  `((fn [...]
       (fn is-string# [x#] (= :string (type x#)))
       (fn is-function# [x#] (= :function (type x#)))
       (local argc# (select :# ...))
       (assert (= 0 (% argc# 2)) "defmonad must be given even number of arguments")
       (let [mon# {}
             _# (for [i# 1 argc# 2]
                  (let [key# (select i# ...)
                        val# (select (+ i# 1) ...)]
                    (assert (is-string# key#) "defmonad keys must be strings")
                    (tset mon# key# val#)))]
         (assert (is-function# mon#.bind) "defmonad requires :bind function")
         (assert (is-function# mon#.result) "defmonad requires :result function")
         (values mon#))) ,...))

{: defmonad
 : do-monad
 : m->}
