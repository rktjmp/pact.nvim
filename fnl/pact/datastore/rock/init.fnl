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
     {: tap} :pact.lib.ruin.fn
     {: 'result-let} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     FS :pact.fs
     {: trace :new task/new :await task/await : task?} (require :pact.task)
     {:format fmt} string)

(λ register [ds canonical-id rock-name server]
  (local {: package-by-canonical-id} (require :pact.datastore))
  (match (package-by-canonical-id ds canonical-id)
    p (error (fmt "attempt to re-register known package %s" canonical-id))
    nil (let [f #(-> (result-let [store-path (FS.join-path ds.path.rock canonical-id)]
                       (R.ok {:kind :rock
                              :id canonical-id
                              :path store-path
                              :name rock-name
                              :server server}))
                     (tap #(tset ds :packages canonical-id $)))
              task (task/new (fmt :register-%s canonical-id) f)]
          (tset ds :packages canonical-id task)
          task)))

(λ version-at-path [ds path])

(λ fetch-versions [ds canonical-id]
  "Interrogate luarocks for versions related to previously registered package")

; (λ setup-version [rock-name rock-version rock-path]
;   "Install version of luarock into datastore and return path to it"
;   (trace "clone-if-missing %s" rock-path)
;   (result-let [_ (if (not (FS.absolute-path? rock-path))
;                    (R.err (fmt "rock path must be absolute, got %s" rock-path)))
;                _ (match [(FS.dir-exists? rock-path) (FS.git-dir? rock-path)]
;                    [true true] (R.ok)
;                    [true false] (R.err (fmt "%s exists already but is not a git dir" rock-path))
;                    _ (do
;                        (trace "git clone %s -> %s" repo-origin rock-path)
;                        (R.result (Git.create-stub-clone repo-origin rock-path))))]
;     (R.ok rock-path)))




{: register
 ; : setup-version
 }
