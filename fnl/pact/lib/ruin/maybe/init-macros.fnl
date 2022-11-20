(import-macros {: use : relative-mod} (.. (or (-?> ... (string.match "(.+%.)maybe")) "") :use))
(local monad-path (relative-mod :monad &from :maybe))
(local maybe-path (relative-mod :maybe &from :maybe))

(fn maybe-let [...]
  `(do
     (import-macros {: monad-let} ,monad-path)
     (let [{:bind bind# :unit unit#} (require ,maybe-path)]
       (monad-let {:bind bind# :unit unit#} ,...))))

(fn maybe-let* [...]
  `(do
     (let [{:unwrap unwrap#} (require ,maybe-path)]
       (unwrap# ,(maybe-let ...)))))

(fn maybe->impl [{: unwrap? : tail?} ...]
  (let [mac (if tail? `monad->> `monad->)]
    `(do
       (import-macros {: monad-> : monad->> } ,monad-path)
       (let [{:map-some map-some# :maybe maybe# :unwrap unwrap#} (require ,maybe-path)]
         ,(if unwrap?
            `(unwrap# (,mac {:map-right map-some# :unit maybe#} ,...))
            `(,mac {:map-right map-some# :unit maybe#} ,...))))))

(fn maybe-> [...]
  (maybe->impl {:unwrap? false :tail? false} ...))

(fn maybe->> [...]
  (maybe->impl {:unwrap? false :tail? true} ...))

(fn maybe->* [...]
  (maybe->impl {:unwrap? true :tail? false} ...))

(fn maybe->>* [...]
  (maybe->impl {:unwrap? true :tail? true} ...))

{: maybe-let
 : maybe-let*
 : maybe->
 : maybe->>
 : maybe->*
 : maybe->>*}
