; (import-macros {: ruin!} :pact.lib.ruin)
; (ruin!)

(fn *dout* [x ?name]
  (local g-sym (sym :_G.__pact_debug))
  (local name (or ?name (if (sym x) (.. "sym: " (tostring x)))))
  `(do
    (if (not  ,g-sym)
      (set ,g-sym []))
    (let [log# []]
      (table.insert log# ,(.. (or x.filename "unknown-file") "#" (or x.line "unknown-line")))
      (table.insert log# ,name)
      (table.insert log# ,x)
      (table.insert ,g-sym log#))
    ,x))

{: *dout*}
