(import-macros {: describe : it : must : rerequire} :pact.lib.ruin.test)

(local v-sha "96de9a8bd862faab6c812148cd5fa95c2b793fb6")
(local git (rerequire :pact.plugin.source.git))

(describe "git provider"
  (it "constructs raw git"
    (must match [:git :https://raw.git/user/repo]
          (git.git "https://raw.git/user/repo")))

  (it "constructs github"
    (must match  ["git" "https://github.com/user/repo"]
          (git.github "user/repo")))

  (it "constructs gitlab"
    (must match  ["git" "https://gitlab.com/user/repo"]
          (git.gitlab "user/repo")))

  (it "constructs sourcehut"
    (must match  ["git" "https://git.sr.ht.com/~user/repo"]
          (git.sourcehut "user/repo")))

  (it "returns errors"
    (must match
          (nil "expected https or ssh url, got fake://raw.git/user/repo")
          (git.git "fake://raw.git/user/repo"))
    (must match (nil err)
          (git.github "https://raw.git/user/repo"))))
