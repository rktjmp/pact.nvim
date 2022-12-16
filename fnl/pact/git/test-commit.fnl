(import-macros {: describe : it : must : rerequire} :pact.lib.ruin.test)

(local v-sha "96de9a8bd862faab6c812148cd5fa95c2b793fb6")
(local _ (rerequire :pact.valid))
(local commit (rerequire :pact.git.commit))

 (describe "commit"
  (it "raw constructs"
    (must match {:sha v-sha} (commit.new v-sha))
    (must match {:sha v-sha :branches [:main]} (commit.new v-sha [[:branch :main]]))
    (must match {:sha v-sha :HEAD? true} (commit.new v-sha [[:HEAD true]]))
    (must match {:sha v-sha :tags [:v0.1.1]} (commit.new v-sha [[:tag :v0.1.1]]))
    (must match {:sha v-sha :versions [:1.2.3]} (commit.new v-sha [[:version :1.2.3]]))
    (must match {:sha v-sha :versions [:1.2.0]} (commit.new v-sha [[:version :1.2]]))
    (must match {:sha v-sha :versions [:1.0.0]} (commit.new v-sha [[:version :1]]))
    (must match {:sha v-sha :versions [:1.0.0] :branches [:main]}
          (commit.new v-sha [[:branch :main] [:version :1.0]])))

  (it "constructs from ref line"
    (must match [{:sha :9ce80731a489097879f1d02738e3271bbc8ffad3
                 :branches [:nightly]}]
          (commit.remote-refs->commits
            ["9ce80731a489097879f1d02738e3271bbc8ffad3 refs/heads/nightly"]))
    (must match [{:sha :368e451bfb4d4c61251c69f14f312bced795b972
                 :tags [:v0.4.0]
                 :versions [:0.4.0]}]
          (commit.remote-refs->commits
            ["368e451bfb4d4c61251c69f14f312bced795b972	refs/tags/v0.4.0"]))
    (must match [{:sha "008ac2d2953d1b92669e02af5df3ab2a7d651a77"
                  :HEAD? true}
                 {:sha "e509f4aea1ed09b012556fbd6a2a7c20b083ee59"
                  :tags ["v0.19.1"]
                  :versions ["0.19.1"]} ]
          (commit.remote-refs->commits
            ["008ac2d2953d1b92669e02af5df3ab2a7d651a77 HEAD"
             "008ac2d2953d1b92669e02af5df3ab2a7d651a77 refs/tags/v0.19.1"
             "e509f4aea1ed09b012556fbd6a2a7c20b083ee59 refs/tags/v0.19.1^{}"]))))
