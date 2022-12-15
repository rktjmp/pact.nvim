(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     R :pact.lib.ruin.result
     Constraint :pact.plugin.constraint
     E :pact.lib.ruin.enum
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)


(fn solve-latest [commits]
  (result-let [_ (log "discovering latest commit")
               ;; just aim high
               constraint (Constraint.git :version "> 0.0.0")
               latest (Constraint.solve constraint commits)]
    (if (not latest)
      (log "no latest commit found"))
    ;; latest might be nil, but that's ok, there may be no versions
    (ok latest)))

(fn* new
  (where [id commits])
  (new-workflow id #(solve-latest commits)))

{: new}
