(fn workflow-> [...]
  (local (i-val chain)
    (match (select :# ...)
      1 (values nil [(select 1 ...)])
      2 (values [(select 1 ...)])
      _ (assert-compile false "workflow-> requires ival chain or chain" (select 1 ...))))
  `(do
     (import-macros {: m->} :pact.vendor.donut.monad)
     (let [{:workflow-m workflow-m# :halt halt#} (require :pact.workflow)]
       (m-> workflow-m# ,i-val
             ,(unpack chain)
             (#(halt# $1))))))

{: workflow->}
