(fn check-error-type [given]
  (let [k (tostring given)]
    (if (not (or (= k :internal)
                 (= k :argument)))
      (error (.. "raise-macro: invalid error type given: " k)))))

(fn raise [kind message ?context]
  (check-error-type kind)
  `(let [{,(tostring kind) make#} (require :pact.error_fn)
         context# (or ,?context {})
         trace# (debug.traceback)
         e# (make# ,message context# trace#)]
     ;; TODO hack for nvim table-errors issue, hard to convince it or lua not
     ;; to attach stack, so just don't include it for now,
     ;; (technically is attached as trace)
     (error e# 0)))

(fn expect [assertion kind message ?context]
  ;; TODO: context is never really used, so could instead automatically
  ;; fmt message with any extra arguments?
  (check-error-type kind)
  `(when (not ,assertion)
     (let [context# (or ,?context {})
           _# (tset context# :expect ,(view assertion))]
       (raise ,kind ,message context#))))

(fn error->string [err]
  `(let [{:error->string error->string#} (require :pact.error_fn)]
     (error->string# ,err)))

{: raise : expect : error->string}
