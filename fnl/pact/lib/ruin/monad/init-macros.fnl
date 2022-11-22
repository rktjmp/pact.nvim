(fn copy [t]
  (let [out []]
    (each [_ v (ipairs t)] (table.insert out v))
    (setmetatable out (getmetatable t))))

(fn monad-let [{: bind : unit} bindings ...]
  "Looks like a (let) but automatically wrap results in the given monad,
  returns a monad. Each 'right-side' of the let binding is wrapped by `unit`."
  (let [bind-fn-sym (gensym :bind)
        unit-fn-sym (gensym :unit)
        ;; we construct our form inside out, so we start with our inner most
        ;; expression, the body, which we should wrap via the unit fn.
        ;; this is double do nested so we can insert inside a valid expression while
        ;; still correctly encapsulating the body expression.
        ;; note we insert (do) but on first iteration of the binding construction we
        ;; wrap this list in a call to unit.
        code `(let [,bind-fn-sym ,bind
                    ,unit-fn-sym ,unit]
                (do ,...))]
    ;; we now work from the tail up with each binding (from the last)
    ;; encapsulating the bindings already output.
    (let [tail-first (fcollect [i (length bindings) 1 -2]
                       [(. bindings (- i 1)) (. bindings i)])]
      ;; create each binding step, and insert the previously generated code
      ;; inside that. each expression is assumed to *not* return a monad type,
      ;; that behaviour is implicitly "taken care of" by the macro.
      ;; this does mean we must wrap the expression in a call to unit, and also
      ;; wrap the return value in unit, because the values derived, and such the values
      ;; given to bind, are likely to be non-monadic (we wrap the return to satisify the bind
      ;; rule that the given functin must return monadic).
      (each [_ [binding value-expr] (ipairs tail-first)]
        (let [tail (. code (length code))
              ;; generate function call, which may or may not have multiple arguments depending
              ;; on whether the binding is one or more values.
              call `(fn [,(if (list? binding) (unpack binding) binding)]
                      (,unit-fn-sym ,tail))
              new-tail `(,bind-fn-sym (,unit-fn-sym ,value-expr) ,call)]
          (tset code (length code) new-tail))))
    (values code)))

(fn monad-let* [monad ...]
  "Same as `monad-let' but unwraps the final result into the monad value."
  (let [{: unwrap} monad]
    `(let [unwrap# ,unwrap
           val# ,(monad-let monad ...)]
       (unwrap# val#))))

(fn monad->-impl [{:map-right map-right-sym :unit unit-sym} insert-args initial ...]
  (assert-compile initial "must provide initial value")
  ; TODO faccumulate
  (fn ensure-callable [ast]
    (if (list? ast)
      ;; given (x 10), turn into function that map-ok can call and inject
      ;; the arg in the correct position
      `#,(doto ast (table.insert (unpack insert-args)))
      ;; given x, assume callable function and map-ok will work naturally
      ast))
  (fcollect [i 1 (select :# ...) &into `(-> (,unit-sym ,initial))]
    (let [expr (-> (copy (. [...] i))
                   (ensure-callable))]
      `(,map-right-sym ,expr))))

(fn monad-> [opts ...]
  (monad->-impl opts [2 `$1] ...))

(fn monad->> [opts ...]
  (monad->-impl opts [`$1] ...))

{: monad-let
 : monad-let*
 : monad->
 : monad->>}
