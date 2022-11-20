(fn rerequire [mod]
  `(do
     (tset package.loaded ,mod nil)
     (require ,mod)))

(fn describe [name ...]
  (let [(fixtures exprs) (match [...]
                           (where [fixtures & exprs] (sequence? fixtures))
                           (values fixtures exprs)
                           exprs (values `[] (or exprs `(values nil))))
        suite-code (icollect [_ c (ipairs exprs) :into `(do)]
                      `(let ,fixtures ,c))
        col (icollect [_ c (ipairs exprs)]
               `(let ,fixtures ,c))]
    `(do
       (local suite-tests# ,col)
       (local x# [,name (icollect [_# [name# test#] (ipairs suite-tests#)]
                          (match (pcall test#)
                            (true true) (do
                                          (print (string.format "✓ %s it %s"
                                                                ,name
                                                                name#))
                                          [name# :pass])
                            (true nil) (do
                                         (print (string.format "  \27[33m%s it %s\27[0m"
                                                               ,name
                                                               name#))
                                         [name# :pending])
                            (false err#) (do
                                           (print (string.format "\27[31m✕ %s it %s\27[0m "
                                                                                    ,name
                                                                                    name#))
                                           (print (string.format "  -->%s"
                                                                 err#))
                                           [name# :fail err#])))]))))

;; TODO: probably replace this with (test) and maybe (suite) as the classic language
;; tends to enforce a language inside the tests which isn't always useful. Its
;; not 2009 anymore.
(fn it [name ...]
  ;; It acccepts a test name and optionally a list of bindings, then any number
  ;; of expressions:
  (let [(fixtures exprs) (match [...]
                           (where [fixtures & exprs] (sequence? fixtures))
                           (values fixtures exprs)
                           exprs (values `[] (or exprs `(values nil))))
        code (icollect [_ c (ipairs exprs) :into `(do)]
               (values c))]
    `(do
       [,name (fn [] (let ,fixtures ,code))])))

(fn expect [check text]
  `(match (pcall #(assert ,check))
     true (values true)
     (false err#)
     (error (string.format "expected %s (%s)"
                           ,(or text (tostring check))
                           (tostring err#)))
     (false nil)
     (error (string.format "expected %s [no-message]"
                           ,(or text (tostring check))))))

(fn throws-error? [code]
  `(match (pcall #(do ,code))
     true (values false "did not throw error")
     false (values true)))

(fn ok? [code]
  `(match (pcall #(do ,code))
     true true
     (false err#) (values false err#)))

(fn function? [x]
  `(= :function (type ,x)))

(fn match? [shape val]
  `(match ,val
     ,shape true
     other# (let [{:view view#} (require :fennel)]
              (values false (.. (view# ,shape) "<<>>" (view# other#))))))

(fn must [...]
  "equal -> x = y
  be -> (type x) = (type y)
  match -> match shape"
  (var args [...])
  (local cons {:not false
               :check false})
  (match (tostring (. args 1))
    :not (let [[_ & rest] args]
           (tset cons :not true)
           (set args rest)))
  (match (tostring (. args 1))
    :throw (match args
             [_ msg expr] (let [code `(match (pcall #(do ,expr))
                                        true (values false "did not throw error")
                                        (false ,msg) true
                                        (false err#) (values false (.. "did not match error" err#)))]
                            (tset cons :action code))
             [_ expr] (doto cons
                        (tset :action `(match (pcall #(do ,expr))
                                         true (values false "did not throw error")
                                         (false err#) true))))
    :not-compile (let [[_ expr] args]
                   (doto cons
                     (tset :action
                           `(let [{:eval eval#} (require :fennel)]
                              (match (pcall eval# ,(tostring expr))
                                true (values false "compiled without error")
                                false true)))))
    :equal (let [[_ a b] args]
             (doto cons
               (tset :action `(= ,a ,b))))
    :be (let [[_ t v] args]
          (doto cons
            (tset :action `(= ,(tostring t) (type ,v)))))
    :match (let [[_ shape expr] args]
             (doto cons
               (tset :action `(match ,expr ,shape true other# (let [{:view v#} (require :fennel)]
                                                                (values false (.. "mismatch: \n" ,(view shape) "\n\n" (v# other#))))))))
    _ (assert-compile false "unknown action" (. args 1)))
  (local action (if cons.not
                  `(not ,cons.action)
                  cons.action))
  `(let [(ok# msg#) ,action]
     (assert ok# (or msg# ,(tostring action)))))

(fn inspect! [...]
  `(do
      (let [{:view view#} (require :fennel)]
        (for [i# 1 (select :# ,...)]
          (print (view# (do (. [,...] i#)))))
        (values ,...))))

{: describe
 : it
 :test it
 :suite describe
 : ok?
 : function?
 : match?
 : throws-error?
 : expect
 : must
 : rerequire
 : inspect!
 :view inspect!}
