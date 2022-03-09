;; SemVer Constraint Type (also moonlights as version type)
;;
;; When using this to represent a version, set the constraint to "=" for
;; clarity
;;
;; Allows you to compare two versions or see if a version satisfies a
;; constraint.

(import-macros {: raise : expect} :pact.error)
(local {: fmt} (require :pact.common))

(fn compare [a b]
  "compare a to b and return a 3 element table describing
  major, minor and patch level comparisons"
  (fn to-sym [x y]
    (match [x y]
      (where [x y] (= x y)) :=
      (where [x y] (> x y)) :>
      (where [x y] (< x y)) :<))
  [(to-sym a.major b.major)
   (to-sym a.minor b.minor)
   (to-sym a.patch b.patch)])

(fn eq? [a b]
  (match (compare a b)
    [:= := :=] true
    _ false))

(fn lt? [a b]
  (match (compare a b)
    (where (or [:< _ _] [:= :< _] [:= := :<])) true
    _ false))

(fn gt? [a b]
  (match (compare a b)
    (where (or [:> _ _] [:= :> _] [:= := :>])) true
    _ false))

(fn lte? [a b]
  (or (eq? a b)
      (lt? a b)))

(fn gte? [a b]
  (or (eq? a b)
      (gt? a b)))

(fn at-most-patch-ahead? [a b]
  (match (compare a b)
    (where (or [:= := :=]
               [:= := :>])) true
    _ false))

(fn at-most-minor-ahead? [a b]
  (match (compare a b)
    (where (or [:= := :=]
               [:= := :>]
               [:= :> _])) true
    _ false))

(fn tilde? [a b]
  (at-most-patch-ahead? a b))

(fn caret? [a b]
  (match b.major
    ; 0.y.z should only increment z
    0 (at-most-patch-ahead? a b)
    ; x.y.z should increment on y and z
    _ (at-most-minor-ahead? a b)))

(fn build [operator ver]
  (match operator
    "=" true
    ">" true
    "<" true
    ">=" true
    "<=" true
    "^" true
    "~" true
    other (raise argument (fmt "invalid operator: %q" other)))

  (let [semver (require :pact.vendor.semver)
        sv (semver ver)
        t {: operator
           :major sv.major
           :minor sv.minor
           :patch sv.patch}]

    (setmetatable t {:__tostring #(let [{: fmt} (require :pact.common)]
                                     (fmt "%s %d.%d.%d" $1.operator $1.major $1.minor $1.patch))
                     :__eq eq?
                     :__lt lt?
                     :__le lte?})))

(fn new [str]
  ; TODO this match could be a bit sharper, esp build tag etc
  ;; This can match ~> as >, so for now be relaxed here, but strict inbuild
  ;; (match (string.match str "([%^~><=][=]?) ([%d]+%.[%d]+%.[%d]+)")
  (match (string.match str "([%^~><=]+) ([%d]+%.[%d]+%.[%d]+)")
    (operator ver) (build operator ver)
    _ (raise argument (fmt "could not parse semver operator %q" str))))

(fn satisfies? [base ask]
  ; given a base version with a operator, does the given 'ask' version
  ; satisfy that constraint?
  (match base.operator
    "=" (eq? ask base)
    ">" (gt? ask base)
    "<" (lt? ask base)
    ">=" (gte? ask base)
    "<=" (lte? ask base)
    "^" (caret? ask base)
    "~" (tilde? ask base)))

(fn solve [constraints versions]
  ; given a list of constraints and versions, find the newest version that
  ; satisfies all constaints.

  (fn find-satisfying [constraint versions]
    ; given a list of versions, find all that satisfy the constraint
    (icollect [_ version (ipairs versions)]
              (when (satisfies? constraint version) version)))

  (fn collect-satisfied [constraints versions]
    ; given list of constraints and versions,
    ; find versions to satisfy each constraint
    (collect [_ c (ipairs constraints)]
             (values c (find-satisfying c versions))))

  (fn check-all-constraints-have-an-option [usables]
    ; given a list of [constraint [versions] ] check versions list is not emtpy
    ; returns nil for error
    (let [ok (accumulate [ok true
                          _ options (ipairs usables)]
                         (and ok (> (length options) 0)))]
      (when ok usables)))

  (fn only-present-in-all-options [usables]
    ; flatten all per-constraint viable versions,
    ; then reject any that are not present in *all* constraints
    (fn contains? [list val]
      (accumulate [ok false
                   _ v (pairs list) :until ok]
                  (= val v)))
    (fn satisfies-all-constraints [usables version]
      (let [ok (accumulate [ok true
                   _constraint versions (pairs usables)]
                  (and ok (contains? versions version)))]
        (if ok usables)))
    (let [all-possibly-viable (accumulate [all []
                                           _constraint versions (pairs usables)]
                                          (icollect [_ v (ipairs versions) :into all] v))
          strictly-viable (icollect [_ v (ipairs all-possibly-viable)]
                                    (when (satisfies-all-constraints usables v) v))]
      strictly-viable))

  (fn highest-version [list]
    (accumulate [highest nil
                 _ v (ipairs list)]
                (match [highest v]
                  [nil v] v
                  (where [highest v] (gt? v highest)) v
                  _ highest)))

  (-?> (collect-satisfied constraints versions)
       (check-all-constraints-have-an-option)
       (only-present-in-all-options)
       (highest-version)))

{: new
 : satisfies?
 : solve}
