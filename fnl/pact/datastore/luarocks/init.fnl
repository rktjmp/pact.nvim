;;; pact.datastore.luarocks
;;;
;;; knows how to
;;;
;;; - detect associated version if given a path
;;; - get a list of currently "solveable" refs
;;; - create a local copy of a package at a specific version
;;;

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)


(use R :pact.lib.ruin.result
     {: 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     datastore :pact.datastore
     {:new task/new : task?} :pact.task)

; (λ register [ds canonical-id rock-name]
;   "Add luarocks package to datastore registry, checks if luarock exists."
;   (local {: package-by-canonical-id} (require :pact.datastore))
;   (match (package-by-canonical-id ds canonical-id)
;     p (error (fmt "attempt to re-register known package %s" canonical-id))
;     nil (let [f #(let [dsp {:kind :luarock
;                             :id canonical-id
;                             :path (FS.join-path ds.path.luarocks canonical-id)}]
;                    (tset ds :packages canonical-id dsp)
;                    (R.ok dsp))

;               (task/new (fmt :register-%s canonical-id)
;                   #)
;                      dsp)))

(λ version-at-path [ds path])

(λ fetch-versions [ds canonical-id]
  "Interrogate luarocks for versions related to previously registered package")

(λ setup-version [ds canonical-id version]
  "Install version of luarock into datastore and return path to it")
