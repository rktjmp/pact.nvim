(fn tap [x f]
  "Call (f x) then return (values x)"
  (f x) (values x))

(fn then [x f]
  "Return value of (f x)"
  (f x))

{: tap
 : then}
