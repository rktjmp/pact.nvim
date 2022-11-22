(fn if-let-impl [bindings if-expr ?else-expr compare]
  (fn copy [t]
    (let [out []]
      (each [_ v (ipairs t)] (table.insert out v))
      (setmetatable out (getmetatable t))))
  ;; TODO faccumulate
  (var acc `(values true ,if-expr))
  (for [i (length bindings) 1 -2]
    (let [bind-sym (gensym (tostring (. bindings (- 1 1))))
          patched-comp (let [cloned (copy compare)]
                         (doto cloned
                           (table.insert bind-sym)))]
      (set acc `(let [,bind-sym ,(. bindings i)]
                  (if ,patched-comp
                    (let [,(. bindings (- i 1)) ,bind-sym]
                      ,acc)
                    (values false))))))
  `(let [(all# val#) ,acc]
    (if all# val# ,?else-expr)))

(fn if-let [bindings if-expr ?else-expr]
  "Check `bindings` in order, if all are truthy, evaluate `if-expr`, otherwise `?else-expr` or nil.

  ```
  (if-let [a 10
           b 20]
    (+ a b)
    (print :otherwise))
  ```"
  (assert-compile (sequence? bindings) "must be a sequence" bindings)
  (assert-compile (= 0 (% (length bindings) 2)) "must provide even number of bindings" bindings)
  (assert-compile if-expr "requires a body expression and optional else expression")
  (if-let-impl bindings if-expr ?else-expr `(and)))

(fn when-let [bindings ...]
  "Check `bindings` in order, if all are truthy, evaluate `...` or nil.

  ```
  (when-let [a 10
             b 20]
    (+ a b)
    (* a b)))
  ```"
  (assert-compile (sequence? bindings) "must be a sequence" bindings)
  (assert-compile (= 0 (% (length bindings) 2)) "must provide even number of bindings" bindings)
  (assert-compile (<= 1 (select :# ...)) "must provide at least one body expression")
  `(if-let ,bindings (do ,...)))

(fn if-some-let [bindings if-expr ?else-expr]
  "Check `bindings` in order, if all are not nil, evaluate `if-expr`, otherwise `?else-expr` or nil.

  ```
  (if-let [a 10
           b 20]
    (+ a b)
    (print :otherwise))
  ```"
  (if-let-impl bindings if-expr ?else-expr `(not= nil)))

(fn when-some-let [bindings ...]
  "Check `bindings` in order, if all are not nil, evaluate `...` or nil.

  ```
  (when-let [a 10
             b 20]
    (+ a b)
    (* a b)))
  ```"
  `(if-some-let ,bindings (do ,...)))

(fn let-match [bindings body ...]
  "A mix of let-bindings and match-expressions.

  Similar to `match-try`, closer to Elixirs `with` expression in usage.

  `bindings` follows `let` but each left side expression may be a match
  expression, including `where` guards. Note that match has implicit `nil`
  checking, so if a binding may be let it shoud be `?name`.

  `body` may be one or more expressions, where the final expression may be
  `(else)` with a collection of match pattern-value pairs.

  ```
  (let-match [pat val
              (where ...) ...
              ... ...]
    body-expr
    ...
    (else
      pat val
      ... ...))
  ```"
  (fn make-else-body [...]
    (if (and (< 0 (select :# ...))
             (or (= :else (tostring (. (select -1 ...) 1)))
                 (= :catch (tostring (. (select -1 ...) 1)))))
      (let [else-expr (select -1 ...)]
        (assert-compile (< 1 (length else-expr))
                        "let-match else expression must have at least one pattern & body"
                        else-expr)
        (assert-compile (= 1 (% (length else-expr) 2))
                        "let-match else expression must have at even number of pattern & body"
                        (. else-expr (length else-expr)))
        (fcollect [i 2 (length else-expr) &into `(match ...)]
          (. else-expr i)))))

  (assert-compile (= 0 (% (length bindings) 2))
                  "let-match requires pairs of (pattern-bind) (value)"
                  bindings)
  (local seen-bindings [])
  (fn save-binding [sym]
    (assert-compile (not (in-scope? sym))
                    "Symbol previously bound in outer scope and may not be used until matchless is released" sym)
    (assert-compile (not (. seen-bindings (tostring sym)))
                    "Duplicate usage of symbol which may not be used until matchless exists"
                    sym
                    (. seen-bindings (tostring sym)))
    (tset seen-bindings (tostring sym) sym))
  (fn check-binding [bind]
    (match bind
      (where sym (sym? sym)) (save-binding sym)
      (where nest (sequence? nest)) (each [_ bind (ipairs nest)]
                                    (check-binding bind))
      (where nest (table? nest)) (each [_ bind (pairs nest)]
                            (check-binding bind))
      (where nest (and (list? nest) (not= `where (. nest 1)))) (each [_ bind (ipairs nest)]
                                                                (check-binding bind))
      (where [whr sub-bindings] (= `where whr)) (check-binding sub-bindings)))
  (let [argc (select :# ...)
        argv [...]
        else-sym (gensym :else-fn)
        else-body (make-else-body ...)
        body-expr (fcollect [i 1 (if else-body (- argc 1) argc) &into `(do ,body)]
                    (. argv i))
        reverse-bindings (fcollect [i (length bindings) 1 -2]
                           [(. bindings (- i 1)) (. bindings i)])
        _ (for [i 1 (length bindings) 2]
            (check-binding (. bindings i)))
        code (accumulate [prev-code body-expr
                          _ [pattern value] (ipairs reverse-bindings)]
               `((fn down# [...]
                   (match ...
                     ,pattern ,prev-code
                     ,(sym :_) (,else-sym ...))) ,value))]
    `(let [,else-sym (fn [...] ,(if else-body else-body `(values ...)))]
       ,code)))

{: let-match
 :match-let let-match
 : if-let
 : if-some-let
 : when-let
 : when-some-let}
