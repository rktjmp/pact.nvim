(import-macros {: use} (.. (or (string.match ... "(.+%.)donut%.") "") "donut"))
(local relrequire ((fn [ddd] #(require (.. (or (string.match ddd "(.+%.)donut%.") "") $1))) ...))

(fn m-> [monad-t ival ...]
  (assert monad-t "m-> must receive monad-t as first argument")
  (assert (and (= :function (type monad-t.bind))
               (= :function (type monad-t.result)))
          "monad-t must have .bind and .result functions")
  (-> (accumulate [val ival _ f (ipairs [...])]
        (monad-t.bind val f))
      (monad-t.result)))

(fn defmonad [...]
  (use {: even?} (relrequire :donut.math)
       {: range} (relrequire :donut.gen) :as gen)
  (fn function? [x] (= :function (type x)))
  (local argc (select :# ...))
  (assert (even? argc) "defmonad must be given even number of arguments")
  (let [mon (collect [i (gen/range 1 argc 2)]
                (values (select i ...)
                        (select (+ 1 i) ...)))]
    (tset mon :-> (fn [ival ...] (m-> mon ival ...)))
    (assert (function? mon.bind) "defmonad requires :bind function")
    (assert (function? mon.result) "defmonad requires :result function")
    (values mon)))

(local identity-m
  (defmonad :bind (fn [val fun] (fun val))
            :result (fn [val] val)))

(local maybe-m
  (let [zero-val nil]
    (defmonad :zero zero-val
              :plus (fn [...]
                      (var (f break) (values zero-val false))
                      (for [i 1 (select :# ...) :until break]
                        (when (not (= zero-val (select i ...)))
                          (set f (select i ...))
                          (set break true)))
                      (values f))
              :bind (fn [val fun]
                      (if (= zero-val val)
                        (values zero-val)
                        (fun val)))
              :result identity-m.result)))

(local state-m
  (defmonad
    :bind (fn bind [mv f]
           (fn [s]
             (let [[v ss] (mv s)]
               ((f v) ss))))
    :result (fn result [v]
             (fn [s] [v s]))
    :set (fn [key val]
             (fn [s]
               (let [old-val (. s key)
                     new-s (doto s (tset key val))]
                 [old-val new-s])))
    :get (fn [key]
           (fn [s]
             (match key
               any [(. s any) s]
               nil [s s])))))

{: defmonad
 : m->
 : maybe-m
 : identity-m
 : state-m}
