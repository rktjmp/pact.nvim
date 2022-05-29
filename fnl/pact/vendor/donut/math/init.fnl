(fn inc [x] (+ x 1))
(fn dec [x] (- x 1))
(fn rem [x n] (% x n))

(fn even? [x] (= 0 (rem x 2)))
(fn odd? [x] (= 1 (rem x 2)))

(fn divides-by? [x n] (= 0 (% x n)))

{: inc
 : dec
 : rem
 : odd?
 : even?
 : divides-by?}
