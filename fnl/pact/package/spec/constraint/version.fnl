;; Semver solver
;;
;; Currently reduced to just accepting strings, which is perhaps simpler
;; from the outside but it does mean when solving a bunch of
;; version-commits against a spec, you need to manually repair the
;; version number back to commit shas.

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     {:format fmt} string
     {: valid-version? : valid-version-spec?} :pact.valid)

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

(fn str->ver [str]
  (let [(v-maj v-min v-patch) (string.match str "^([%d]+)%.([%d]+)%.([%d]+)$")]
    (E.reduce #(E.set$ $1 $3 (tonumber $2))
              {} {:major v-maj :minor v-min :patch v-patch})))

(fn str->spec [str]
  (let [pat "([%^~><=]+)%s?([%d]+)%.([%d]+)%.([%d]+)"
        (s-op s-maj s-min s-patch) (string.match str pat)]
    (-> (E.reduce #(E.set$ $1 $3 (tonumber $2))
                  {} {:major s-maj :minor s-min :patch s-patch})
        (E.set$ :operator s-op))))

(fn* satisfies?
  (where [spec ver] (and (valid-version-spec? spec) (valid-version? ver)))
  (let [ver (str->ver ver)
        spec (str->spec spec)]
    ;; NOTE these are ver spec, not spec ver!
    ;; As in, the version given, is greater than the spec version
    (match spec.operator
      "=" (eq? ver spec)
      ">" (gt? ver spec)
      "<" (lt? ver spec)
      ">=" (gte? ver spec)
      "<=" (lte? ver spec)
      "^" (caret? ver spec)
      "~" (tilde? ver spec)
      _ (error (fmt "unsupported version spec operator %s" spec.operator)))))

(fn* solve
  "Given `spec` (or list of specs), and list of `versions`, return list of
  versions which satisfy all given specs, in descending order from most newest
  to oldest."
  ;; 1-spec n-versions
  (where [spec versions] (and (valid-version-spec? spec)
                              (table? versions)))
  (->> (E.filter #(satisfies? spec $) versions)
       (E.sort #(let [a (str->ver $1)
                      b (str->ver $2)]
                  (gt? a b))))
  ;; n-specs n-versions
  (where [specs versions] (and (table? specs)
                               (table? versions)))
  (->> (E.map #(solve $ versions) specs)
       (E.flatten)
       ;; count number of times a version passed a spec
       (E.reduce #(E.set$ $1 $2 (+ 1 (or (. $1 $2) 0))) {})
       ;; drop any versions that didn't pass all specs
       (E.filter #(= (length specs) $))
       ;; resort the versions
       (E.keys)
       (E.sort #(let [a (str->ver $1)
                      b (str->ver $2)]
                  (gt? a b)))))

{: satisfies? : solve}
