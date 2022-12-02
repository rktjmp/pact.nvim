(import-macros {: use} :pact.lib.ruin.use)
(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     {: string? : table?} :pact.lib.ruin.type
     {: 'match-let} :pact.lib.ruin.let
     enum :pact.lib.ruin.enum
     {:format fmt} string
     {: valid-sha? : valid-version-spec?} :pact.valid
     {:git git-constraint} :pact.plugin.constraint)



(fn make-provider [url]
  [:git url])

(fn decorate-tostring [t name short]
  (setmetatable t {:__tostring #(fmt "%s/%s" name short)}))

(fn* url-ok?
  (where [url] (string? url))
  (if (and (or (string.match url "^https?:") (string.match url "^ssh:"))
           (string.match url ".+://.+%..+"))
    (values true)
    (values nil (fmt "expected https or ssh url, got %s" url)))
  (where _)
  (values nil "expected https or ssh url string"))

(fn* user-repo-ok?
  (where [user-repo] (and (string? user-repo)
                          (string.match user-repo "^[^/]+/[^/]+$")))
  (values true)
  (where _)
  (values nil "expected user-name/repo-name"))

(fn git [url]
  "Create a git source from arbitrary https or ssh url. Returns git source or nil, err"
  (match-let [true (url-ok? url)]
    (-> (make-provider url)
        (decorate-tostring :git url))))

(fn github [user-repo]
  "Create github source with user/repo. Returns source or nil, err"
  (match-let [true (user-repo-ok? user-repo)]
    (-> (git (.. "https://github.com/" user-repo))
        (decorate-tostring :github user-repo))))

(fn gitlab [user-repo]
  "Create gitlab source with user/repo. Returns source or nil, err"
  (match-let [true (user-repo-ok? user-repo)]
    (-> (git (.. "https://gitlab.com/" user-repo))
        (decorate-tostring :gitlab user-repo))))

(fn sourcehut [user-repo]
  "Create sourcehut source with user/repo. Returns source or nil, err"
  (match-let [true (user-repo-ok? user-repo)]
    (-> (git (.. "https://git.sr.ht.com/~" user-repo))
        (decorate-tostring :sourcehut user-repo))))

{: github
 : gitlab
 : sourcehut :srht sourcehut
 : git}
