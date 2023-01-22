(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'match-let} :pact.lib.ruin.let
     {:format fmt} string)

(fn* url-ok?
  (where [url] (string? url))
  (if (and (or (string.match url "^https?:") (string.match url "^ssh:"))
           (string.match url ".+://.+%..+"))
    (values true)
    (values nil (fmt "expected https or ssh url, got %s" url)))
  (where _)
  (values nil "expected https or ssh url string"))

(fn new [url]
  "Create a git source from arbitrary https or ssh url. Returns git source or nil, err"
  (match-let [true (url-ok? url)]
    (-> [:git url]
        (setmetatable {:__tostring #url}))))

(fn git->canonical-id [source]
  (match source
    [:git url] (let [clean (string.sub url "[^%w]+" "-")]
                 (.. :git- clean))))

{: new
 : git->canonical-id}
