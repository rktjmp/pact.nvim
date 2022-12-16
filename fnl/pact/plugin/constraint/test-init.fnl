(import-macros {: describe : it : must : rerequire} :pact.lib.ruin.test)

(local v-sha "96de9a8bd862faab6c812148cd5fa95c2b793fb6")
(local constraint (rerequire :pact.plugin.constraint))
(local Commit (rerequire :pact.git.commit))

(local commit (Commit.new "96de9a8bd862faab6c812148cd5fa95c2b793fb6"
                          [[:branch :main] [:version :1.2.3]
                           [:HEAD true]
                           [:tag :v1.2.3]]))

(local commits [(Commit.new "96de9a8bd862faab6c812148cd5fa95c2b793fb6"
                          [[:branch :main] [:version :1.2.3] [:tag :v1.2.3]])
                (Commit.new "aaaaaaaaaaa2faab6c812148cd5fa95c2b793fb6"
                          [[:version :1.2.4] [:tag :v1.2.4]])
                (Commit.new "bbbbbbbbaaa2faab6c812148cd5fa95c2b793fb6"
                          [[:HEAD true] [:version :1.3.0] [:tag :v1.3.0]])])

(describe "git constraint"
  (it "constructs"
    (must match [:git :branch :main] (constraint.git :branch :main))
    (must match [:git :tag :main] (constraint.git :tag :main))
    (must match [:git :commit v-sha] (constraint.git :commit v-sha))
    (must match (nil _) (constraint.git :commit (string.sub v-sha 1 6)))
    (must match (nil _) (constraint.git :commit (.. v-sha 9)))
    (must match [:git :commit :96de9a8] (constraint.git :commit (string.sub v-sha 1 7)))
    (must match [:git :version "<= 1.2.3"] (constraint.git :version "<= 1.2.3"))
    (must match [:git :head true] (constraint.git :head)))

  (it "satisfies"
      (must match true
            (constraint.satisfies? (constraint.git :head) commit))
      (must match true
            (constraint.satisfies? (constraint.git :commit v-sha) commit))
      (must match true
            (constraint.satisfies? (constraint.git :commit (string.sub v-sha 1 7)) commit))
      (must match false
            (constraint.satisfies? (constraint.git :commit (.. 0 (string.sub v-sha 1 7))) commit))
      (must match true
            (constraint.satisfies? (constraint.git :branch :main) commit))
      (must match false
            (constraint.satisfies? (constraint.git :branch :dev) commit))
      (must match true
            (constraint.satisfies? (constraint.git :tag :v1.2.3) commit))
      (must match true
            (constraint.satisfies? (constraint.git :version :=1.2.3) commit))
      (must match true
            (constraint.satisfies? (constraint.git :version :>=1.2.3) commit))
      (must match true
            (constraint.satisfies? (constraint.git :version :>1.0.0) commit)))

  (it "solves"
      (must match {:sha "aaaaaaaaaaa2faab6c812148cd5fa95c2b793fb6"}
            (constraint.solve (constraint.git :version "~ 1.2.0") commits))
      (must match {:sha "bbbbbbbbaaa2faab6c812148cd5fa95c2b793fb6"}
            (constraint.solve (constraint.git :head) commits))))
