;; provides nicer interface to constraint and provider types

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)
(use {: ok : err : map-err : 'result-let} :pact.lib.ruin.result
     enum :pact.lib.ruin.enum
     git-source :pact.plugin.source.git
     constraints :pact.plugin.constraint
     inspect (or vim.inspect print)
     {: valid-sha? : valid-version-spec?} :pact.valid
     {: join-path} :pact.workflow.exec.fs
     {:format fmt} string)

(fn set-tostring [plugin]
  (setmetatable plugin {:__tostring #(fmt "%s@%s" plugin.source plugin.constraint)}))

(fn opts->constraint [opts]
  (match-let [keys (enum.keys opts)
              ;; TODO this has better support in Constraint now
              true (-> (enum.filter #(or (= :head $1)
                                         (= :branch $1)
                                         (= :tag $1)
                                         (= :commit $1)
                                         (= :version $1)) opts)
                       (enum.table->pairs)
                       (length)
                       (#(match $1
                           1 true
                           0 true
                           n (err "options table must contain at most one constraint key"))))]
    (match opts
      (where {: head} (= true head)) (constraints.git :head)
      (where {: version} (valid-version-spec? version)) (constraints.git :version version)
      {: version} (values nil "invalid version spec")
      (where {: commit} (valid-sha? commit)) (constraints.git :commit commit)
      {: commit} (values nil "invalid commit sha, must be full 40 characters")
      (where {: branch} (and (string? branch) (<= 1 (length branch)))) (constraints.git :branch branch)
      {: branch} (values nil "invalid branch, must be non-empty string")
      (where {: tag} (and (string? tag) (<= 1 (length tag)))) (constraints.git :tag tag)
      {: tag} (values nil "invalid tag, must be non-empty string")
      _ (constraints.git :head))))

(fn make [basic opts]
  (assert basic.name "plugin.make requires basic.name")
  (assert basic.source "plugin.make requires basic.source")
  (assert basic.constraint "plugin.make requires basic.constraint")
  (let [canonical-id (-> (. basic.source 2)
                         (string.gsub "^.-://" "")
                         (->> (.. :plugin-))
                         (string.gsub "%W" "-")
                         (string.gsub "-+" "-"))
        plug (doto basic
                   (tset :dependencies (or opts.dependencies opts.deps []))
                   (tset :opt? (= true (or opts.opt? opts.opt)))
                   (tset :after opts.after)
                   (tset :canonical-id canonical-id))]
    (set-tostring plug)))

;; TODO: smell, can probably remove forge-name name as we no longer us it, and
;; is iffy when termed :git?
(fn* forge
  ;; default to tracking head when given no constraint
  (where [forge-name user-repo nil] (and (string? user-repo)
                                     (not (= :git forge-name))))
  (forge forge-name user-repo {:head true})

  ;; otherwise infer type from prefix/string
  (where [forge-name user-repo constraint] (and (string? user-repo) (string? constraint)))
  (match constraint
    (where _ (valid-version-spec? constraint))
    (forge forge-name user-repo {:version constraint})
    (where _ (string.match constraint "^#.+"))
    (forge forge-name user-repo {:tag (string.match constraint "^#(.+)")})
    (where _ (string.match constraint "^%^.+")) ;; ^ over @ for fennel :^sha support
    ;; TODO: should validate sha is 8 or 40 chars and also push short-sha support stream
    (forge forge-name user-repo {:commit (string.match constraint "^%^(.+)")})
    _
    (forge forge-name user-repo {:branch constraint}))

  ;; otherwise be explicit in your needs
  (where [forge-name user-repo opts] (and (string? user-repo)
                                          (table? opts)))
  (-> (result-let [source ((. git-source forge-name) user-repo)
                   constraint (opts->constraint opts)]
        (make {:name user-repo
               : forge-name
               : source
               : constraint} opts))
      (map-err (fn [e] (err (fmt "%s/%s %s" forge-name user-repo e)))))

  ;; or you really messed up
  (where _)
  (err (fmt "requires user/repo and version-constraint string or constraint table, got %s"
            (inspect [...]))))

(fn github [user-repo opts]
  (forge :github user-repo opts))

(fn gitlab [user-repo opts]
  (forge :gitlab user-repo opts))

(fn sourcehut [user-repo opts]
  (forge :sourcehut user-repo opts))

(fn* git
  (where [url constraint] (and (string? url)
                         (string? constraint)
                         (valid-version-spec? constraint)))
  (git url {:version constraint})
  (where [url opts] (and (string? url) (table? opts)))
  (-> (result-let [source (git-source.git url)
                   forge-name :git
                   name (if-let [name (. opts :name)]
                          (values name)
                          (values nil "requires name option"))
                   constraint (opts->constraint opts)]
        (make {: name
               : forge-name
               : source
               : constraint} opts))
      (map-err (fn [e] (err (fmt "%s/%s %s" :git url e)))))
  (where _)
  (err "requires url and constraint/options table"))

{: git
 : github
 : gitlab
 : sourcehut :srht sourcehut}
