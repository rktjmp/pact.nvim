(import-macros {: use} :pact.lib.ruin.use)
(use {: string?} :pact.lib.ruin.type)

(fn sha? [sha]
  (and (string? sha)
       (= 40 (-> (string.match sha "^(%x+)$") (length)))))

(fn version? [v]
  (and (string? v)
       (or (not= nil (string.match v "^(%d+)$"))
           (not= nil (string.match v "^(%d+%.%d+)$"))
           (not= nil (string.match v "^(%d+%.%d+%.%d+)$")))))

(fn version-spec? [v]
  (and (string? v)
       (not= nil (string.match v "^[%^~><=]+ %d+%.%d+%.%d+$"))))

{:valid-sha? sha? : sha?
 :valid-version? version? : version?
 :valid-version-spec? version-spec? : version-spec?}
