(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     Log :pact.log
     {:format fmt} string)

(local Action {})

(fn* Action.stage
  "Stage target version into next transaction.")

(fn+ Action.stage (where [package] (and package.git package.git.target.commit))
  (set package.action [:stage :git package.git.target.commit])
  (R.ok package))

(fn+ Action.stage (where [package] (and package.git (not package.git.target.commit)))
  (R.err "unable to apply action `stage` to package, no target git commit to checkout!"))

(λ Action.staged? [package]
  (= :stage (E.first package.action)))

(fn* Action.retain
  "Retain a package at current state through the next transaction. This is
  conceptually different to stage. Here we keep the existing checkout point
  where as stage expects to checkout a different point.

  Retain is the default behaviour for existing packages that are not staged, that is
  when performing a transaction with no user input, t == t+1.")

(fn+ Action.retain (where [package] (and package.git package.git.checkout.commit))
  (set package.action [:retain :git package.git.checkout.commit])
  (R.ok package))

(fn+ Action.retain (where [package] (and package.git (not package.git.checkout.commit)))
  (R.err "unable to apply action `retain` to package, no current checkout git commit to keep!"))

(λ Action.retained? [package]
  (= :retain (E.first package.action)))

(fn* Action.discard
  "Discard a package from the next transaction. This effectively disables it.")

(fn+ Action.discard (where [package])
  (set package.action [:discard])
  (R.ok package))

(λ Action.discarded? [package]
  (= :discarded (E.first package.action)))

Action
