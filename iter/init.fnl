(import-macros {: use} (.. (or (-?> ... (string.match "(.+%.)iter")) "") :use))

(use {: 'fn*} :fn &from :iter
     {: seq? : number?} :type &from :iter)

(local M {})

(fn* M.range
  "Returns an iterator to generate numbers from start to stop, by step. Step is
  always positive, but start and stop may be inverted."
  (where [start stop] (and (number? start) (number? stop)))
  (M.range start stop 1)
  (where [start stop step] (and (number? start) (number? stop) (number? step) (<= 1 step)))
  (do
    (local [op inv-op check] (if (<= start stop)
                               [#(+ $1 $2) #(- $1 $2) #(<= $1 $2)]
                               [#(- $1 $2) #(+ $1 $2) #(<= $2 $1)]))
    (fn gen [[start stop step] last]
      (let [maybe (op last step)]
        (if (check maybe stop)
          (values maybe)
          (values nil))))
    (values gen [start stop step] (inv-op start step))))

(fn ward-impl [seq step step-flip initial-state]
  ;; step-flip lets us check that step is positive but still use it negatively
  ;; when going in reverse.
  (let [step (* step-flip step)]
    (fn gen [seq last]
      (local next-i (+ last step))
      (match (. seq next-i)
        val (values next-i val)))
    (values gen seq initial-state)))

(fn* M.fward
  "Identical to ipairs but accepts an optional step argument."
  (where [seq] (seq? seq))
  (M.fward seq 1)
  (where [seq step] (and (seq? seq) (number? step) (<= 1 step)))
  (ward-impl seq step 1 (- 1 step)))

(fn* M.bward
  "Identical to ipairs but runs in reverse and accepts an optional step argument."
  (where [seq] (seq? seq))
  (M.bward seq 1)
  (where [seq step] (and (seq? seq) (number? step) (<= 1 step)))
  (ward-impl seq step -1 (+ (length seq) step)))

(values M)
