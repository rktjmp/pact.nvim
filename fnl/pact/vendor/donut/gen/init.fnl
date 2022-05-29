(local relrequire ((fn [ddd] #(require (.. (or (string.match ddd "(.+%.)donut%.") "") $1))) ...))
"Functions that generate functions that generate values when called."

(fn range [a b ?step]
  ;; TODO: optional b (infinity)
  ;; TODO: reverse ranges, -step
  (var last-value nil)
  (let [start a
        end b
        step (or ?step 1)]
    (fn gen []
      (let [v (if last-value
                (+ last-value step)
                start)]
        (set last-value v)
        (if (<= v end)
          (values v))))))

(fn fwd [seq ?step]
  "Returns an forward iterator over sequence.
  The iterator returns (value index)"
  (local step (or ?step 1))
  (var i (- 1 step))
  (fn iter []
    (let [next-i (+ i step)
          val (. seq next-i)]
      (when val
        (set i next-i)
        (values val i)))))

(fn bkwd [seq ?step]
  "Returns an backward iterator over sequence.
  The iterator returns (value index)"
  (local step (or ?step 1))
  (var i (+ (length seq) step))
  (fn iter []
    (let [next-i (- i step)
          val (. seq next-i)]
      (when val
        (set i next-i)
        (values val i)))))

(fn ->seq [gen]
 (icollect [v gen] v))

(fn donut [] (values :o))

{: range
 : fwd : bkwd
 : ->seq
 : donut}
