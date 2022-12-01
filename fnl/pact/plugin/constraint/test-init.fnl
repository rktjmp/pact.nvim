(import-macros {: describe : it : must : rerequire} :pact.lib.ruin.test)

(local v-sha "96de9a8bd862faab6c812148cd5fa95c2b793fb6")
(local constraint (rerequire :pact.plugin.constraint))

(describe "git constraint"
  (it "constructs"
    (must match [:git :branch :main] (constraint.git :branch :main))
    (must match [:git :tag :main] (constraint.git :tag :main))
    (must match [:git :commit v-sha] (constraint.git :commit v-sha)
    (must match [:git :version "<= 1.2.3"] (constraint.git :version "<= 1.2.3")))))
