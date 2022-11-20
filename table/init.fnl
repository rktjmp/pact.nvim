(fn no-missing-access [t ?msg-fmt]
  "error on access to missing keys"
  (assert (= :table (type t)) "tried to protect non-table")
  (let [mt (or (getmetatable t) {})
        msg-fmt (or ?msg-fmt "unknown-key: %s")
        __index (or (. mt :__index) #nil)]
    (tset mt :__index #(match (__index $1 $2)
                         nil (error (string.format msg-fmt $2))
                         any (values any)))
    (setmetatable t mt)
    ;; descend
    (each [k v (pairs t)]
      (when (= :table (type v))
        (no-missing-access v)))
    (values t)))

;; TODO: enum.key? or table.key? its "simpler" to stick it in enum, and does
;; sort of fit, if you squint.
(fn has-key [t k]
  (not (= nil (. t k))))

{: no-missing-access}
