(import-macros {: use}
               (.. (or (-?> ... (string.match "(.+%.)math")) "") :use))

(use {: number?} :type &from :math
     {: 'fn*} :fn &from :math)

(fn* add
  (where [a b] (and (number? a) (number? b)))
  (+ a b)
  (where [a b c ...] (and (number? a) (number? b) (number? c)))
  (add (add a b) c ...))

(fn* sub
  (where [a b] (and (number? a) (number? b)))
  (- a b)
  (where [a b c ...] (and (number? a) (number? b) (number? c)))
  (sub (sub a b) c ...))

(fn* mul
  (where [a b] (and (number? a) (number? b)))
  (* a b)
  (where [a b c ...] (and (number? a) (number? b) (number? c)))
  (mul (mul a b) c ...))

(fn* div
  (where [a b] (and (number? a) (number? b)))
  (/ a b)
  (where [a b c ...] (and (number? a) (number? b) (number? c)))
  (div (div a b) c ...))

(fn inc [x] (+ x 1))
(fn dec [x] (- x 1))

(fn* rem
  (where [x 0]) x
  (where [x n]) (% x n))

(fn even? [x] (= 0 (rem x 2)))
(fn odd? [x] (= 1 (rem x 2)))
(fn divides-into? [x n] (= 0 (% x n)))

{: inc
 : dec
 : add
 : sub
 : mul
 : div
 : rem
 : odd?
 : even?
 : divides-into?}
