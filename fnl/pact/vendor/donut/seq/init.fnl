(local relrequire ((fn [ddd] #(require (.. (or (string.match ddd "(.+%.)donut%.") "") $1))) ...))

(fn chunk-every [seq n ?step]
  (let [{:range gen/range
         :->seq gen/->seq
         :fwd gen/fwd} (relrequire :donut.gen)
        i-sets (icollect [start (gen/range 1 (length seq) n)]
                 (let [r (gen/range start (+ start (- n 1)))]
                   (gen/->seq r)))]
    (icollect [indexes (gen/fwd i-sets)]
      (icollect [i (gen/fwd indexes)]
        (. seq i)))))

(fn join [ta tb]
  (let [tail (length ta)]
    (accumulate [t ta i v (ipairs tb)]
      (doto t (table.insert (+ tail i) v)))))

(fn hd [seq]
  (let [[h & _] seq]
    (values h)))

(fn tl [seq]
  (let [[_ & t] seq]
    (values t)))

(fn find [seq p]
 (match (accumulate [ok? false i v (ipairs seq) :until ok?]
          (if (p v)
            (values [v i])))
   [v i] (values v i)))

(fn any? [seq p]
  (match (find seq p)
    (v i) true
    _ false))

{
 : hd : tl
 : find : any?
 : chunk-every}
