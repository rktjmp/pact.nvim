(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'match-let} :pact.lib.ruin.let
     {: git} :pact.package.spec.git
     {:format fmt} string)

(fn* user-repo-ok?
  (where [user-repo] (and (string? user-repo)
                          (string.match user-repo "^[^/]+/[^/]+$")))
  (values true)
  (where _)
  (values nil "expected user-name/repo-name"))

(fn github [user-repo]
  "Create github source with user/repo. Returns source or nil, err"
  (match-let [true (user-repo-ok? user-repo)]
    (git (.. "https://github.com/" user-repo))))

(fn gitlab [user-repo]
  "Create gitlab source with user/repo. Returns source or nil, err"
  (match-let [true (user-repo-ok? user-repo)]
    (git (.. "https://gitlab.com/" user-repo))))

(fn sourcehut [user-repo]
  "Create sourcehut source with user/repo. Returns source or nil, err"
  (match-let [true (user-repo-ok? user-repo)]
    (git (.. "https://git.sr.ht/~" user-repo))))

{: github
 : gitlab
 : sourcehut :srht sourcehut}
