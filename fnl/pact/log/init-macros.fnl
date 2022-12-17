
(fn log! [x ?name]
  (local name (or ?name (if (sym x) (.. "sym: " (tostring x)))))
  `(do
     (let [{: inspect#} (require :pact.inspect)
           {: log#} (require :pact.log)
           data# (inspect# ,x)]
       (
       (
    (if (not  ,g-sym)
      (set ,g-sym []))
    (let [log# []]
      (table.insert log# ,(.. (or x.filename "unknown-file") "#" (or x.line "unknown-line")))
      (table.insert log# ,name)
      (table.insert log# ,x)
      (table.insert ,g-sym log#))
    ,x))


(x 10)
