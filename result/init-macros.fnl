(import-macros {: use : relative-mod} (.. (or (-?> ... (string.match "(.+%.)result")) "") :use))
(local monad-path (relative-mod :monad &from :result))
(local result-path (relative-mod :result &from :result))

(fn result-let [...]
  `(do
     (import-macros {: monad-let} ,monad-path)
     (let [{:bind bind# :unit unit#} (require ,result-path)]
       (monad-let {:bind bind# :unit unit# :unwrap unwrap#} ,...))))

(fn result-let* [...]
  ;; unwrapping an error only gives the error value, but in this
  ;; case we actually want to unwrap into `nil err`.
  `(let [{:unwrap unwrap# :ok? ok?#} (require ,result-path)
         result# ,(result-let ...)]
     (if (ok?# result#)
       (unwrap# result#)
       (values nil (unwrap# result#)))))

(fn result->impl [{: unwrap? : tail?} ...]
  (let [mac (if tail? `monad->> `monad->)]
    `(do
       (import-macros {: monad-> : monad->> } ,monad-path)
       (let [{:map-ok map-ok# :result result# :unwrap unwrap#} (require ,result-path)]
         ,(if unwrap?
            `(unwrap# (,mac {:map-right map-ok# :unit result#} ,...))
            `(,mac {:map-right map-ok# :unit result#} ,...))))))

(fn result-> [...]
  (result->impl {:unwrap? false :tail? false} ...))

(fn result->> [...]
  (result->impl {:unwrap? false :tail? true} ...))

(fn result->* [...]
  (result->impl {:unwrap? true :tail? false} ...))

(fn result->>* [...]
  (result->impl {:unwrap? true :tail? true} ...))

{: result-let
 : result-let*
 : result->
 : result->>
 : result->*
 : result->>*}
