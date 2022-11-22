(import-macros {: use : relative-mod}
               (.. (or (-?> ... (string.match "(.+%.)monad")) "") "use"))

(local math-path (relative-mod :math &from :monad))

(fn m-> [monad-t ival ...]
  (assert monad-t "m-> must receive monad-t as first argument")
  (assert (and (= :function (type monad-t.bind))
               (= :function (type monad-t.result)))
          "monad-t must have .bind and .result functions")
  (-> (accumulate [val ival _ f (ipairs [...])]
        (monad-t.bind val f))
      (monad-t.result)))

(local identity-m
  {:bind (fn [val fun] (fun val))
   :result (fn [val] val)})

(local maybe-m
  (let [zero-val nil]
    {:zero zero-val
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
     :result identity-m.result}))

(local state-m
  {:bind (fn bind [mv f]
           (fn [s]
             (let [(v ss) (mv s)]
               ((f v) ss))))
   :result (fn result [v]
             (fn [s] (values v s)))
   :set (fn [key val]
          (fn [s]
            (let [old-val (. s key)
                  new-s (doto s (tset key val))]
              (values old-val new-s))))
   :get (fn [key]
          (fn [s]
            (match key
              any (values (. s any) s)
              nil (values s s))))})

{: m->
 : maybe-m
 : identity-m
 : state-m}
