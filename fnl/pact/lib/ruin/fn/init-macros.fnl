(fn clone [t]
  (let [out []]
    (each [i v (pairs t)]
      (match (type v)
        :table (tset out i (clone v))
        _ (tset out i v)))
    (setmetatable out (getmetatable t))
    (values out)))

(fn gen-dispatch-sym [name]
  ;; This gets called from multiple entries, so it uses sym instead of gensym.
  ;; This also allows redefinition of a function by recalling fn*
  (let [safe-name (-> (tostring name)
                      (string.gsub "%." "__"))]
    (sym (.. :__fn*- safe-name :-dispatch))))

(fn depth-walk [f ast]
  (fn walk [f depth i ast parent]
    (match ast
      (where ast (sequence? ast)) (each [i node (ipairs ast)]
                                    (walk f (+ depth 1) i node ast))
      (where ast (table? ast)) (each [key node (pairs ast)]
                                 ;; NOTE: key passed as index, but otherwise we can't iterate {:x 1}
                                 ;; TODO this is kinda ugly but ... how else?
                                 (walk f (+ depth 1) key node ast))
      (where ast (list? ast)) (each [i node (ipairs ast)]
                                 (walk f (+ depth 1) i node ast))
      _ (f [depth i] ast parent)))
  (walk f 0 1 ast nil))

(fn sym-pinned? [s]
  (not= nil (string.match (tostring s) "^%^")))

(fn depin-sym [s]
  (assert-compile (sym-pinned? s) "Tried to depin unpinned")
  (let [ss (-> (tostring s)
               (string.gsub "^%^" ""))
        clean (sym ss)]
    (values clean)))

(fn translate-multi-sym [ast]
  (if (varg? ast) (assert-compile false "internal-error: cannot translate ..., please report" ast))
  ;; multi-sym only makes sense when pinned
  (if (sym-pinned? ast)
    (let [depinned (depin-sym ast)]
      ;; we can only check the head of a multi-sym is in scope and the rest
      ;; will just have to nil-out in the match if its wrong.
      (assert-compile (in-scope? (. (multi-sym? depinned) 1)) "pinned but not in scope" ast)
      ;; match against the depinned but it is an invalid argument name, so just
      ;; use a blank slot. The value will be avaliable via the upvalue anyway.
      (values depinned))
    (assert-compile ast "multi-sym arguments must be pinned with the ^ prefix" ast)))

(fn translate-sym [ast]
  (if (varg? ast) (assert-compile false "internal-error: cannot translate ..., please report" ast))
  (if (sym-pinned? ast)
    ;; pinned so we need to match the upval and we'll also pass a blank fn arg
    ;; as upval can be used in place.
    (let [depinned (depin-sym ast)]
      (assert-compile (in-scope? depinned) "pinned but not in scope" ast)
      (values depinned))
    ;; not pinned, so we need a clean match sym and retain the user-name for fn arg
    (let [trans (gensym (tostring ast))]
      (values trans))))

(fn validate-bindings [bindings]
  (depth-walk (fn [[depth index] ast]
                ;; ... must be not nested and at the end of the argument list
                (if (and (varg? ast) (not= 0 depth) (not= index (length bindings)))
                  (assert-compile false "... may only occur at end of arguments" ast))
                (if (= `& ast)
                  (assert-compile false "`& rest` syntax not supported in function arg lists" ast))
                (if (=  `^ ast)
                  (assert-compile false "^ requires symbol" ast)))
              bindings)
  (values true))


(fn fn+-impl [name pattern ...]
  ;; Actual fn+ without checks for in-scope, otherwise we could never define
  ;; bodies attached to fn*.
  ;;
  ;; We should accept anything that `match` accepts except `& rest` because
  ;; it's not possible to translate it into an fn arg list, and `...` can stand
  ;; in while also being more standard.
  ;;
  ;; We *do* require that matches are always inside a `[x]` both to standardise and
  ;; to more look like normal fn arg lists.
  ;;
  ;; To handle `...` in match lists, while technically not being allowed in
  ;; regular match expressions, we have to do some magic:
  ;;
  ;; 1. enforce ... is always the last argument (or only argument)
  ;; 2. strip ... from argument list (`[x ...]` matches the same as `[x]`)
  ;;    as the `...` is 0->n, so optional.
  ;; 3. replace all other instances of `...` in the AST with `(select pos-after-... ...)`
  ;;    which should effectively behave the same.
  ;;
  ;; The presence of `...`  turns the fixed-arity check into an at-least-arity check.
  (let [dispatch-sym (gen-dispatch-sym name)
        ;; Save clean user-pattern for help/docstring
        pattern-as-given (tostring pattern)
        ;; Extract (where [*bindings*] *clauses*) for more processing, flag if
        ;; all we got was _ for some special cases.
        (bindings clauses just-_) (match pattern
                                    ;; (where [something] ...)
                                    (where [whr binds] (and (= `where whr) (sequence? binds)))
                                    (values binds (. pattern 3) false)
                                    ;; _ on its own is ok for default
                                    (where binds (= `_ binds))
                                    (values [`...] nil true)
                                    ;; but we support `(where _)` for fn* which requires
                                    ;; all argument matches wrap in `(where)`.
                                    (where [whr binds] (and (= `where whr) (= `_ binds)))
                                    (values [`...] (. pattern 3) true)
                                    ;; invalid guard format
                                    (where _)
                                    (assert-compile false "must provide [args ...], (where [args ...] ...) or _" pattern))
        _ (validate-bindings bindings)
        ;; Translate fn+ arguments into gensym bindings to avoid unintentional
        ;; outer scope matches.
        ;;
        ;; We have two sets, one for the match expression, which should be all
        ;; gensym'd to avoid unintentional in-scope matching -- unless ^ pinned!
        ;;
        ;; The other set is for the function head, which should be kept as-is except for
        ;; multi-sym's which are replaced with `_` (because otherwise they're invalid)
        ;; and the value itself will be avaliable as an upvalue as it's been translated.
        match-bindings (clone bindings)
        renamed-match-bindings {}
        _ (depth-walk (fn [[_depth index] ast parent]
                        ;; Plain syms should be translated to an gensym (with same _/? prefix)
                        ;; to avoid scope issues.
                        ;; Pinned ^sym should match an in-scope sym.
                        ;; multi-sym's must be pinned.
                        (let [trans-fn (or (and (sym? ast) (multi-sym? ast) translate-multi-sym)
                                           (and (sym? ast) translate-sym)
                                           nil)]
                          ;; sym can be translated and is not nil or $x
                          (when (and trans-fn
                                     (not= `nil ast)
                                     (not (or (string.match (tostring ast) "^%$")
                                              (string.match (tostring ast) "^_G%."))))
                            (if (and (sym-pinned? ast)
                                     (and (table? parent) (not (sequence? parent)))
                                     ;; we know parent is an assoc, so index is actually a key name here
                                     ;; which should be the key used in the table
                                     (= (tostring ast) (tostring index)))
                              (assert-compile false
                                              (string.format
                                                "%s used in assoc table, must set source key manually, eg: {:%s %s}" 
                                                ast (depin-sym ast) ast)
                                              ast))
                            (let [safe (trans-fn ast)]
                              (tset renamed-match-bindings (tostring ast) safe)))))
                      match-bindings)
        ;; update clauses to match new renamed-match-bindings names
        _ (depth-walk (fn [loc ast parent]
                        (when (and (sym? ast) ;; must be a sym
                                   ;; and if we're in a list, the sym should
                                   ;; not be the first element in the list eg:
                                   ;; the call name
                                   (not (and (list? parent) (= ast (. parent 1))))
                                   ;; but leave nil, $1 and _G.xyz alone
                                   (not= `nil ast)
                                   (not (or (string.match (tostring ast) "^%$")
                                            (string.match (tostring ast) "^_G%."))))
                          ;; If here, we know we have to patch the name, but we
                          ;; only want to change the first part of a multisym,
                          ;; or all of a sym.
                          (let [patch-ast-with (fn [new-name]
                                                 (let [sym-name (if (multi-sym? ast)
                                                                  (let [[head & rest] (multi-sym? ast)]
                                                                    (table.insert rest 1 (tostring new-name))
                                                                    (table.concat rest "."))
                                                                  (tostring new-name))]
                                                   (tset ast 1 sym-name)))
                                ;; make sure we only check name in `name` or `name._._._"
                                root-sym (or (and (multi-sym? ast) (. (multi-sym? ast) 1))
                                             ast)]
                            (match [(sym-pinned? root-sym) (. renamed-match-bindings (tostring root-sym))]
                              ;; clause sym is pinned and we have no rename
                              [true nil] (let [depinned (depin-sym root-sym)]
                                           (assert-compile (in-scope? depinned)
                                                           (string.format "unable to depin %q, not in scope"
                                                                          (tostring (depin-sym ast)))
                                                           ast)
                                           (patch-ast-with depinned))
                              ;; not pinned but we had no rename
                              [false nil] (assert-compile false
                                                          (string.format
                                                            "unknown symbol %q, use in match list or ^pin for outer scope symbols"
                                                            (tostring ast))
                                                          ast)
                              ;; not pinned and we had a rename
                              [false rename] (patch-ast-with rename)
                              ;; pinned and we had a rename (this should never happen?)
                              [true rename] (assert-compile false "pinned cause sym but also had rename??" ast)
                              _ (assert-compile false "fn* bug, please report" ast)))))
                      clauses)
        _ (depth-walk (fn [[depth index] ast parent]
                        ;; Can't actually match against ... so don't include it in the match pattern
                        (if (varg? ast)
                          (tset parent index nil)
                          (when (sym? ast)
                            (tset ast 1 (tostring (. renamed-match-bindings (tostring ast)))))))
                      match-bindings)
        ;; Update fn arg list to drop pinned names as they're pulled from the
        ;; upval and are invalid argument names.
        fn-args-bindings (clone bindings)
        _ (depth-walk (fn [[depth index] ast parent]
                        (if (and (sym? ast) (sym-pinned? ast))
                          (tset ast 1 :_))
                        (if (or (= ast `nil) (not= :table (type ast)))
                          ;; non syms/tables should be ignored, only used for match pattern
                          (tset parent index (sym :_))))
                      fn-args-bindings)
        ;; Find arity check, which is either (= length of fn-args) or (<= len fn-args) when ... is present
        varg-index (accumulate [index nil i a (ipairs fn-args-bindings) &until index]
                     (if (varg? a) i))
        arity-check (match [(length fn-args-bindings) fn-args-bindings varg-index]
                      (where [_ _ _] just-_) `true
                      [0 _ nil] `(= 0 (select :# ...))
                      [n _ nil] `(= ,n (select :# ...))
                      [n _ not-nil] `(<= ,(- n 1) (select :# ...)))
        ;; Modify clauses if we have any, replacing all `...` with `(select pos-... ...)` so
        ;; they behave as they appear they should when looking at the [match arguments ...]
        ;; when really we're passed all the arguments via `...`.
        _ (depth-walk (fn [[depth index] ast parent]
                        (if (varg? ast)
                          (do
                            ;; can't use ... in clause if not in pattern,
                            ;; technically possible but out of line with lua
                            ;; regular behaviour which checks for ... in
                            ;; signature before you can use it.
                            (assert-compile varg-index "Cannot use ... in clause without using in argument list" ast)
                            (doto parent
                              (tset index `(select ,varg-index ...))))))
                      clauses)]
    ; (print (view `(fn [...]
    ;                 (if ,arity-check
    ;                   (match [...] (where ,match-bindings ,clauses) (fn ,fn-args-bindings ,...))))))
    `(do
       (table.insert (. ,dispatch-sym :help)
                     ,pattern-as-given)
       (table.insert (. ,dispatch-sym :bodies)
                     (fn [...]
                       (if ,arity-check
                         (match [...]
                           (where ,match-bindings ,clauses) (fn ,fn-args-bindings ,...)))))
       (values ,name))))

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

  See also `fn*'.

  Each call to `fn+` creates a local variable (used by fennel to assign the
  function to the dispatcher), which may impact large modules. Lua has a limit
  of 200 local variables, you can create new scopes with `(do)`."}
  (assert-compile name "fn+ requires fn* created name")
  (assert-compile pattern "fn+ requires argument list" name)
  (assert-compile (< 0 (select :# ...)) "fn+ requires at least one body expression")
  (assert-compile (in-scope? (gen-dispatch-sym name))
                  (string.format "Can't use fn+ without first defining (fn* %s)" (tostring name))
                  name)
  ;; If given just [x], wrap it into (where [x]) for consistentcy upstream
  (let [pattern (if (sequence? pattern) `(where ,pattern) pattern)]
        (fn+-impl name pattern ...)))

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

When called, `fn*' functions compare the arguments recieved against the
patterns defined and executes the first matching function body.

`fn*' functions are useful if you want a very strict API (by default they
will raise an error if no pattern matched the arguments recieved), or to
simplify dispatching against different argument types. The `enum` module
uses this macro heavily as an example.

Generally you probably should prefer regular `fn` functions with `match` unless
you know you want very strict argument checks or particular behaviour depending
on the arguments received.

Patterns are checked in the order they are defined and have strict arity
checks (unless `...` is in the argument list, then the arity is
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

Arguments matching follow `(match)` semantics *except `& rest` is unsupported
and `...` is* - this aligns closer to regular function arguments.
Arguments may be symbols or values. Destructuring is supported. Arguments may
not be nil unless defined as nil-able by prefixing with `?` or with the
explicit value (eg: `[a b nil]`).

As with `(match)`, values in patterns may match previously defined in-scope
symbols. This is explicity opt-in for `fn*', and symbols should be prefixed with
`^` to *\"pin\"* the value and indicate it should match the outer scope.

A default \"match all\" handler can be defined with `(where _)`, the handler
will receive `...` as an argument.

See also `fn+' to add additional patterns to an existing function.

Each call to `fn*` creates 4 local variables (3 if the function is assigned to
a field of an existing table). The function bodies specified with `fn*` do
not allocate additional variables. Lua has a limit of 200 local variables, you
can create new scopes with `(do)`.

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
  (where [a b c ...])
  (do
    (print a b c)
    (print :and-rest (select :# ...)))

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
        dispatch-lookup-sym (gen-dispatch-sym name)
        dispatch-fn `(fn [...]
                       ,(or ?docstring nil)
                       ;; automatic fail if we have no bodies registered
                       (if (= 0 (length (. ,dispatch-lookup-sym :bodies)))
                         (error (.. "multi-arity function " ,(tostring name) " has no bodies")))
                       ;; look for matching callable or die
                       (match (accumulate [f# nil _# match?# (ipairs (. ,dispatch-lookup-sym :bodies)) &until f#]
                                (match?# ...))
                         f# (f# ...)
                         nil (let [view# (match (pcall require :fennel)
                                           (true {:view view#}) view#
                                           (false _#) (or _G.vim.inspect print))
                                   msg# (string.format (.. "Multi-arity function %s had no matching head "
                                                           "or default defined.\nCalled with: [%s]\nHeads:\n%s")
                                                       ,(tostring name)
                                                       (-> (fcollect  [i# 1 (select :# ...)]
                                                             (view# (. [...] i#)))
                                                           (table.concat ", "))
                                                       (table.concat (. ,dispatch-lookup-sym :help) "\n"))]
                               (error msg#))))]
    ;; so we can only return one expression from a macro, but we want to
    ;; define a whole bunch then return the callable-function under name so
    ;; that gets passed around, put in arrays, etc.
    ;; So we stick it all in a seq, which gets broken out into statements
    ;; then the return values of the statements are put in the list, then we
    ;; make that seq callable and return the name fn when called, and
    ;; immediately call it. EASY.
    `((setmetatable [(local ,dispatch-lookup-sym {:bodies [] :help []})
                     (,(if (multi-sym? name) `set `local) ,name ,dispatch-fn)]
                    ;; this must be (fn []) - not #(do) otherwise fennel wont
                    ;; accept #(x $...) inside function bodies.
                    {:__call (fn []
                                ;; We end up with one local var at least per
                                ;; function body given to fn*. This can make us
                                ;; run up against luas 200 local var limit in
                                ;; larger modules.
                                ;; We'll create and insert-into-dispatch here,
                                ;; which is automatically called,

                                ;; must have an expression before fn-bodies
                                ;; otherwise nothing is output.
                                ;; https://todo.sr.ht/~technomancy/fennel/144
                                nil
                                ,fn+-bodies

                                ;; Return the given name, which should be bound to
                                ;; the dispatch-fn, so you can dosomething like
                                ;; (let [mf (fn* [...])] (mf ...))
                                (values ,name))}))))

{: fn+ : fn*}
