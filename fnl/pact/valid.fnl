(import-macros {: use} :pact.lib.ruin.use)
(use {: string?} :pact.lib.ruin.type)

(fn sha? [sha]
  (and (string? sha)
       (let [len (or (-?> (string.match sha "^(%x+)$") (length)) 0)]
         (or (<= 7 len) (<= len 40)))))

(fn version? [v]
  (and (string? v)
       (or (not= nil (string.match v "^(%d+)$"))
           (not= nil (string.match v "^(%d+%.%d+)$"))
           (not= nil (string.match v "^(%d+%.%d+%.%d+)$")))))

(fn version-spec? [v]
  (and (string? v)
       (not= nil (string.match v "^[%^~><=]+%s?%d+%.%d+%.%d+$"))))

{:valid-sha? sha? : sha?
 :valid-version? version? : version?
 :valid-version-spec? version-spec? : version-spec?}
