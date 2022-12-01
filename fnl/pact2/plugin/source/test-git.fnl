(import-macros {: describe : it : must : rerequire} :pact.lib.ruin.test)

(local v-sha "96de9a8bd862faab6c812148cd5fa95c2b793fb6")
(local git (rerequire :pact2.provider.git))

(describe "git provider"
  (it "constructs raw git"
    (must match {:id :https://raw.git/user/repo
                 :constraint ["git" "commit" "96de9a8bd862faab6c812148cd5fa95c2b793fb6"]
                 :source ["git" "https://raw.git/user/repo"]}
                 (git.git "https://raw.git/user/repo" {:commit v-sha}))

    (must match {:id :http://raw.git/user/repo
                 :constraint ["git" "tag" "v1"]
                 :source ["git" "http://raw.git/user/repo"]}
                 (git.git "http://raw.git/user/repo" {:tag :v1}))

    (must match {:id :ssh://raw.git/user/repo
                 :constraint ["git" "branch" "main"]
                 :source ["git" "ssh://raw.git/user/repo"]}
                 (git.git "ssh://raw.git/user/repo" {:branch :main}))

    (must match {:id :ssh://raw.git/user/repo
                 :constraint ["git" "version" "= 1.0.0"]
                 :source ["git" "ssh://raw.git/user/repo"]}
                 (git.git "ssh://raw.git/user/repo" {:version "= 1.0.0"}))

    (must match {:id :ssh://raw.git/user/repo
                 :constraint ["git" "version" "= 1.0.0"]
                 :source ["git" "ssh://raw.git/user/repo"]}
                 (git.git "ssh://raw.git/user/repo" "= 1.0.0")))

  (it "constructs github"
    (must match {:id :https://github.com/user/repo
                 :constraint ["git" "commit" "96de9a8bd862faab6c812148cd5fa95c2b793fb6"]
                 :source ["git" "https://github.com/user/repo"]}
                 (git.github "user/repo" {:commit v-sha})))

  (it "constructs gitlab"
    (must match {:id :https://gitlab.com/user/repo
                 :constraint ["git" "commit" "96de9a8bd862faab6c812148cd5fa95c2b793fb6"]
                 :source ["git" "https://gitlab.com/user/repo"]}
                 (git.gitlab "user/repo" {:commit v-sha})))

  (it "constructs sourcehut"
    (must match {:id "https://git.sr.ht.com/~user/repo"
                 :constraint ["git" "commit" "96de9a8bd862faab6c812148cd5fa95c2b793fb6"]
                 :source ["git" "https://git.sr.ht.com/~user/repo"]}
                 (git.sourcehut "user/repo" {:commit v-sha})))

  (it "returns errors"
      (must match (nil "expected https or ssh url, got fake://raw.git/user/repo") (git.git "fake://raw.git/user/repo" "arstarst"))
      (must match (nil err) (git.git "https://raw.git/user/repo" "arstarst"))))
