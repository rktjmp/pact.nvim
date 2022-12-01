(import-macros {: describe : it : must : rerequire} :pact.lib.ruin.test)

(local v-sha "96de9a8bd862faab6c812148cd5fa95c2b793fb6")
(local _ (rerequire :pact.valid))
(local commit (rerequire :pact.git.commit))

(describe "commit"
  (it "raw constructs"
    (must match {:sha v-sha} (commit.commit v-sha))
    (must match {:sha v-sha :branch :main} (commit.commit v-sha {:branch :main}))
    (must match {:sha v-sha :tag :v0.1.1} (commit.commit v-sha {:tag :v0.1.1}))
    (must match {:sha v-sha :version :1.2.3} (commit.commit v-sha {:version :1.2.3}))
    (must match {:sha v-sha :version :1.2.0} (commit.commit v-sha {:version :1.2}))
    (must match {:sha v-sha :version :1.0.0} (commit.commit v-sha {:version :1}))
    (must match {:sha v-sha :version :1.0.0 :branch :main}
          (commit.commit v-sha {:branch :main :version :1.0})))

  (it "constructs from ref line"
    (must match {:sha :9ce80731a489097879f1d02738e3271bbc8ffad3
                 :branch :nightly} (commit.ref-line->commit
                                     "9ce80731a489097879f1d02738e3271bbc8ffad3 refs/heads/nightly"))
    (must match {:sha :368e451bfb4d4c61251c69f14f312bced795b972
                 :tag :v0.4.0
                 :version :0.4.0} (commit.ref-line->commit
                                    "368e451bfb4d4c61251c69f14f312bced795b972	refs/tags/v0.4.0"))))
