(fn clone [t]
  (let [out []]
    (each [_ v (ipairs t)]
      (match (type v)
        (where (or :number :string :function :boolean)) (table.insert out v)
        :table (table.insert out (clone v))))
    (setmetatable out (getmetatable t))
    (values out)))

(fn gen-dispatch-sym [name]
  (let [safe-name (-> (tostring name)
                      (string.gsub "%." "__"))]
    (sym (.. :__fn*- safe-name :-dispatch))))

(fn make-fn-head-expr [name ?docstring]
  "creates callable function under `name` which dispatches via the dispatch
  table to matching function"
  (let [dispatch-sym (gen-dispatch-sym name)
        dispatch `{:bodies [] :help []}
        dispatch-fn `(fn [...]
                       ,(or ?docstring nil)
                      ;; automatic fail if we have no bodies registered
                      (if (= 0 (length (. ,dispatch-sym :bodies)))
                        (error (.. "multi-arity function " ,(tostring name) " has no bodies")))
                      ;; look for matching callable or die
                      (match (accumulate [f# nil _# match?# (ipairs (. ,dispatch-sym :bodies)) &until f#]
                               (match?# ...))
                        f# (f# ...)
                        nil (let [{:view view#} (require :fennel)
                                  msg# (string.format (.. "Multi-arity function %s had no matching head "
                                                          "or default defined.\nCalled with: %s\nHeads:\n%s")
                                                      ,(tostring name)
                                                      (view# [...])
                                                      (table.concat (. ,dispatch-sym :help) "\n"))]
                              (error msg#))))]
    (values `(local ,dispatch-sym ,dispatch)
            `(,(if (multi-sym? name) `set `local) ,name ,dispatch-fn))))

(fn depth-walk [f ast]
  (fn walk [f depth i ast parent]
    (match ast
      (where ast (sequence? ast)) (each [i node (ipairs ast)]
                                    (walk f (+ depth 1) i node ast))
      (where ast (table? ast)) (each [i node (pairs ast)]
                                 (walk f (+ depth 1) i node ast))
      (where ast (list? ast)) (each [i node (ipairs ast)]
                                 (walk f (+ depth 1) i node ast))
      _ (f [depth i] ast parent)))
  (walk f 0 1 ast nil))

(fn fn+-impl [name pattern ...]
  ;; Actual fn+ without checks for in-scope, otherwise we could never define
  ;; bodies attached to fn*.
  ;;
  ;; We should accept anything that `match` accepts, but args must always be
  ;; given inside a sequence `(where [x])` since we call the function with
  ;; `(match [...] ...)`, we can't also match on `...` otherwise the
  ;; existing-in-scope-binding effect will make that expression never match.
  ;;
  ;; To handle that case, we can:
  ;;
  ;; 1. enforce ... is always the last argument (or only argument)
  ;; 2. strip ... from argument list (`[x ...]` matches the same as `[x]`)
  ;;    as the `...` is 0->n, so optional.
  ;; 3. replace all other instances of `...` in the AST with `(select pos-after-... ...)`
  ;;    which should effectively behave the same.
  ;;
  ;; Similarly, [x & rest], `& rest` must always be at the end and is also 0->n. We do not
  ;; need to strip this however.
  ;;
  ;; The presence of `...` or `& rest` turns the fixed-arity check into an
  ;; at-least-arity check.
  (let [dispatch-sym (gen-dispatch-sym name)
        ;; Save clean user-pattern for help
        user-pattern (tostring pattern)
        ;; Check for solo `_` argument which indicates that the function head is
        ;; a "wild" match and has no arity check.
        ;; Note: not [_] which would be 1 arity any-value!
        ;; We will also pull out the bindings as its proximal.
        (bindings clauses) (match pattern
                             ;; (where [something] ...)
                             (where [whr binds] (and (= `where whr) (sequence? binds)))
                             (values binds (. pattern 3))
                             ;; [something]
                             (where binds (sequence? binds))
                             (values binds nil)
                             ;; _ on its own is ok for default
                             (where binds (= `_ binds))
                             (values binds nil)
                             ;; but we support `(where _)` for fn* which requires
                             ;; all argument matches wrap in `(where)`.
                             (where [whr binds] (and (= `where whr) (= `_ binds)))
                             (values binds (. pattern 3))
                             ;; invalid guard format
                             (where _)
                             (assert-compile false "must provide [args ...], (where [args ...] ...) or _" pattern))
        ;; check for ... (must be at end) or `& x` and cant mix both
        _ (depth-walk (fn [[depth index] ast]
                        ;; is ... that isn't at top depth and at the end
                        (if (and (varg? ast) (not= 0 depth) (not= index (length bindings)))
                          (assert-compile false "... may only occur at end of arguments" ast)))
                      bindings)
        _ (depth-walk (fn [[depth index] ast]
                        ;; is & that is at top depth but is not at the second from end
                        (if (and (= `& ast) (= 0 depth) (and (not= index (- (length bindings) 1))
                                                             (sym? (. bindings (length bindings)))))
                          (assert-compile false "& rest must occur at arguments" ast)))
                      bindings)
        ;; walk all bindings and check if symbols exist in scope already, which
        ;; is an error unless they are pinned with `^`.
        ;; TODO: cant just be ^, cant ^& ^...
        _ (depth-walk (fn [[depth index] ast]
                        (fn pinned? [s] (and true (string.match (tostring s) "^%^")))
                        (fn depin [s]
                          (assert-compile (pinned? s) "Tried to depin unpinned")
                          (let [ss (-> (tostring s)
                                       (string.gsub "^%^" ""))
                                clean (sym ss)]
                            (values clean)))
                        (fn need-pin-msg [s]
                          (string.format (.. "Argument %s exists in current scope "
                                             "and Fennel match semantics may not "
                                             "behave as you expect. Use ^%s if you "
                                             "intentionally want to match against it "
                                             "or a different argument name.") s s))
                        (match (or (and (multi-sym? ast) (. (multi-sym? ast) 1)) (sym? ast))
                          ;; flat out wrong, ^& or ^ nothing
                          ;; todo ^nil?
                          (where _ (or (= `^& ast) (= `^ ast)))
                          (assert-compile false
                                          (string.format "Invalid usage of ^ symbol, must be ^in-scope-sym." ast)
                                          ast)
                          ;; Symbol pinnned but its not in scope.
                          ;; we're intentionally pretty strict here, if the user attempts to pin
                          ;; an outer symbol but its not in scope, we consider it an error.
                          (where bind (and (pinned? bind) (not (in-scope? (depin bind)))))
                          (assert-compile false "Attempted to pin non-existing symbol, please remove `^` pin." bind)
                          ;; Symbol is not pinned but is in scope.
                          (where bind (and (not (pinned? bind)) (in-scope? bind)))
                          (assert-compile false (need-pin-msg bind) bind)
                          ;; Symbol is pinned and is in scope.
                          ;; Drop pin symbol from ast so it actually binds correctly
                          (where bind (and (pinned? bind) (in-scope? (depin bind))))
                          (tset ast 1 (string.gsub (tostring ast) "^%^" ""))))
                      bindings)
        bindings (if (= `_ bindings)
                   ;; wild `_`, `(where _)` is captured directly, so dont iterate it and set no arity limit
                   {:arity [:free 255] :bound bindings}
                   ;; check bindings for special symbols that will alter our
                   ;; arity, also build clean binds list without `...` and
                   ;; track some positional data.
                   (accumulate [bs {:arity [:fixed (length bindings)] :bound [] :... nil :& nil}
                                i bind (ipairs bindings)]
                     (match bind
                       (where _ (varg? bind)) (do
                                                (doto bs
                                                  (tset :arity [:at-least (length bs.bound)])
                                                  (tset :... i)))
                       (where _ (= `& bind)) (do
                                               (table.insert bs.bound bind)
                                               (doto bs
                                                 (tset :arity [:at-least (- (length bs.bound) 1)])
                                                 (tset :& i)))
                       (where bind) (do
                                      (table.insert bs.bound bind)
                                      (values bs)))))
        ;; modify clauses if we have any, replacing all `...` with `(select pos-... ...)`
        _ (depth-walk (fn [[depth index] ast parent]
                        (if (varg? ast)
                          (do
                            ;; can't use ... in clause if not in pattern,
                            ;; technically possible but out of line with lua
                            ;; regular behaviour which checks for ... in
                            ;; signature before you can use it.
                            (assert-compile (. bindings :...)
                                            "Cannot use ... in clause without using in argument list"
                                            ast)
                            (doto parent
                              (tset index `(select ,(or (. bindings :...) 1) ...))))))
                      (or clauses []))
        arity-check (match bindings.arity
                      [:free _] `true
                      [:at-least n] `(<= ,n (select :# ...))
                      [:fixed n] `(= ,n (select :# ...)))
        f-args (let [n-bound (-> (length bindings.bound)
                                 ;; we dont want to modify the binding list and drop the &,
                                 ;; but technically it's not in the function arg list
                                 (#(if bindings.& (- $1 1) $1)))
                     f-args (fcollect [i 1 n-bound &into `[]]
                              (gensym :_))
                     _ (if (. bindings :...) (table.insert f-args `...))]
                 (values f-args))]
    ; (print (view `(fn [...]
    ;                 (if ,arity-check
    ;                   (match [...] (where ,bindings.bound ,clauses) (fn ,f-args ,...))))))
    `(do
       (table.insert (. ,dispatch-sym :help) ,user-pattern)
       (table.insert (. ,dispatch-sym :bodies)
                     (fn [...]
                       (if ,arity-check
                         (match [...] (where ,bindings.bound ,clauses) (fn ,f-args ,...)))))
       (values ,name))))

;; TODO? this sounds useful but as yet not used that much? It adds some
;; compilcations in terms of code generation & we can post-fact add additional
;; patterns to doc arglists.
(fn fn+ [name pattern ...]
  {:fnl/arglist (name pattern expr ...)
   :fnl/docstring "Attach new function body to `name`. `name` must have been defined via `fn*'
  before calling.

  Functions similarly to `fn*' except:

  - `pattern` may ommit `(where)` if desired.
  - all expressions after the guard are included into the function body.

  ```fennel
  (fn* map)
  (fn+ map [a]
    (print a)
    (* a a))
  ```

  See also `fn*'."}
  (assert-compile name "fn+ requires fn* created name")
  (assert-compile pattern "fn+ requires argument list" name)
  (assert-compile (< 0 (select :# ...)) "fn+ requires at least one body expression")
  (assert-compile (in-scope? (gen-dispatch-sym name))
                  (string.format "Can't use fn+ without first defining (fn* %s)" (tostring name))
                  name)
  (fn+-impl name pattern ...))

(fn fn* [...]
  {:fnl/arglist (?name ?docstring (?where ...) (?expr ...) ...)
   :fnl/docstring
"Create a new pattern-matched & arity-matched function.

```
(fn* x
  (where [a])
  (print :one-argument a)
  (where [100 name] (= :string (type name)))
  (print :100-hello name)
  (where _)
  (print :otherwise))
```

When called, `fn*' functions (termed *matched functions*) compare the arguments
recieved against the patterns defined and executes the matching function body.

Patterns are checked in the order they are defined and have strict arity
checks (unless `...` or `& x` are in the argument list, then the arity is
defined as *at least n* where *n* is the number of other arguments).

Matched functions may be anonymous, which requires all match heads and bodies
to be defined at once, or they may be named. Named functions may have zero
match heads and body pairs, able to be defined later by `fn+'.

`?name` may be a symbol or multisym to attach to existing tables.

After `name`, sequential pairs of `(where [arg arg ...] (?clauses ...))
(expression)` can be provided. The `where` clauses define the function pattern
match and the expression is the function body.

Matches are checked in the order given, so higher specificity patterns should
be first.

Arguments follow `(match)` semantics and may be symbols or values, or
destructing expressions. Arguments may not be nil unless defined as nil-able by
prefixing with `?` or with the explicit value (eg: `[a b nil]`).

As with `(match)`, values in clauses may match previously defined in-scope
symbols. This is explicity opt-in for `fn*', if a symbol name matches an
existing symbol, an error is raised. If the match is intentional the symbol may
be prefixed with `^` to *pin* the value.

See also `fn+' to add additional patterns to an existing function.

```
(local var 10)
(fn* x
  ;;    (x 100)
  ;; => matches-var
  (where [^var])
  (print :matches-var)

  ;;    (x 10)
  ;; => one-argument 10
  (where [a])
  (print :one-argument a)

  ;;    (x 100 :fen)
  ;; => 100-hello fen
  ;; note we define this before the next as the pattern ahead would also match
  (where [100 name] (= :string (type name)))
  (print :100-hello name)

  ;;   (x 10 20)
  ;;=> two-arguments 10 20
  (where [a b])
  (print :two-arguments a b)

  ;;    (x 1 2 3)
  ;; => 1 2 3
  ;; => and-rest 0
  ;;    (x 1 2 3 10 11 12)
  ;; => 1 2 3
  ;; => and-rest 3
  (where [a b c & rest])
  (do
    (print a b c)
    (print :and-rest (length rest)))

  ;; anything else that does not match will call this
  (where _)
  (print :no-match ...))
  ```"}
  ;; We accept the following forms
  ;;
  ;; Just the header, for use with fn+
  ;;  (fn* name)
  ;;
  ;; Header with docstring
  ;;  (fn* name "docstring")
  ;;
  ;; Header with and bodies
  ;;  (fn* name (where ...) (expr ...) ...)
  ;;
  ;; Header with docstring and bodies
  ;;  (fn* name "docstring" (where ...) (expr ...) ...)
  ;;
  ;; Anonymous, must have bodies
  ;;  (fn* (where ...) (expr ...) ...)
  ;;
  ;; Anonymous with docstring, must have bodies
  ;;  (fn* "docstring" (where ...) (expr ...) ...)
  (var (opts opt-n) (values [...] (select :# ...)))
  (local name (match opts
                (where [name] (sym? name))
                (do
                  (table.remove opts 1)
                  (set opt-n (- opt-n 1))
                  (values name))
                _ (gensym :fn*__anonymous__)))
  (local ?docstring (match (?. opts 1)
                      (where str (= :string (type str)))
                      (do
                        (table.remove opts 1)
                        (set opt-n (- opt-n 1))
                        (values str))
                      (where tab (and (?. tab :fnl/docstring)))
                      (do
                        (table.remove opts 1)
                        (set opt-n (- opt-n 1))
                        (values tab))))
  (local (bodies n-bodies) (values opts opt-n))

  (assert-compile (or (= 0 n-bodies) (= 0 (% n-bodies 2)))
                  "fn* must be given zero bodies or (where []) (body) pairs" ...)
  (for [i 1 n-bodies 2]
    (assert-compile (and (list? (. bodies i)) (= `where (. bodies i 1)))
                    (.. "fn* must have fn body arguments in (where) clause: "
                        (tostring (. bodies i))) name))
  ;; must generate arg-list (and clone) before running fn+-impl because it will
  ;; alter the ast in some cases.
  (let [auto-arglist (let [container `[]
                           arg-lists (fcollect [i 1 n-bodies 2] (clone (. bodies i)))]
                       (if (<= 2 (length arg-lists))
                         (for [i (length arg-lists) 2 -1]
                           (table.insert arg-lists i (sym "|"))))
                       (doto arg-lists
                         (table.insert 1 (sym "["))
                         (table.insert (sym "]"))))
        fn+-bodies (fcollect [i 1 n-bodies 2]
                     (fn+-impl name (. bodies i) (. bodies (+ i 1))))
        ?docstring (match ?docstring
                     nil {:fnl/arglist auto-arglist}
                     (where s (= :string (type s)))
                     {:fnl/arglist auto-arglist
                      :fnl/docstring s}
                     {:fnl/docstring s :fnl/arglist nil}
                     {:fnl/docstring s :fnl/arglist auto-arglist}
                     _ ?docstring)
        (locals callable) (make-fn-head-expr name ?docstring) ]
    ;; so we can only return one expression from a macro, but we want to
    ;; define a whole bunch then return the callable-function under name so
    ;; that gets passed around, put in arrays, etc.
    ;; So we stick it all in a seq, which gets broken out into statements
    ;; then the return values of the statements are put in the list, then we
    ;; make that seq callable and return the name fn when called, and
    ;; immediately call it. EASY.
    `((setmetatable [,locals
                     ,callable
                     ,fn+-bodies]
                    {:__call #(values ,name)}))))

{: fn+ : fn*}
