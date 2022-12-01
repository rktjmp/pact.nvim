;; provides nicer interface to constraint and provider types
(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)
(use {: ok : err : map-err : 'result-let} :pact.lib.ruin.result
     enum :pact.lib.ruin.enum
     git-source :pact2.plugin.source.git
     constraints :pact2.plugin.constraint
     {: valid-sha? : valid-version-spec?} :pact2.valid
     {:format fmt} string)

(var id 0)
(fn generate-id [plugin]
  (set id (+ id 1))
  (fmt "plugin-%s" id))

(fn valid-args [user-repo constraint]
  (and (string? user-repo)
       (or (string? constraint)
           (table? constraint))))

(fn set-tostring [plugin]
  (setmetatable plugin {:__tostring #(fmt "%s@%s" plugin.source plugin.constraint)}))

(fn set-package-path [plugin]
  (let [dir (-> (.. (vim.fn.stdpath :data) :/site/pack/pact/start)
                (.. :/ (string.gsub plugin.name "/" "-")))]
    (enum.set$ plugin :package-path dir)))

(fn parse-opts [opts]
  (match-let [keys (enum.keys opts)
              ;; return err not nil msg due to or's behaviour with (values)
              true (or (= 1 (length keys))
                       (err "options table must contain at most one key"))
              true (or (enum.any? #(or (= :branch $2)
                                       (= :tag $2)
                                       (= :commit $2)
                                       (= :version $2))
                                  (enum.keys opts))
                       (err "options table must contain branch, tag, commit or version"))]
    (match opts
      (where {: version} (valid-version-spec? version)) [:version version]
      {: version} (values nil "invalid version spec")
      (where {: commit} (valid-sha? commit)) [:commit commit]
      {: commit} (values nil "invalid commit sha, must be full 40 characters")
      (where {: branch} (and (string? branch) (<= 1 (length branch)))) [:branch branch]
      {: branch} (values nil "invalid branch, must be non-empty string")
      (where {: tag} (and (string? tag) (<= 1 (length tag)))) [:tag tag]
      {: tag} (values nil "invalid tag, must be non-empty string")
      _ (values nil
                "expected semver constraint string or table with branch, tag, commit or version"))))

(fn* forge
  (where [forge-name user-repo constraint] (and (string? user-repo)
                                                (string? constraint)
                                                (valid-version-spec? constraint)))
  (forge forge-name user-repo {:version constraint})
  (where [forge-name user-repo constraint] (and (string? user-repo)
                                                (table? constraint)))
  (-> (result-let [source ((. git-source forge-name) user-repo)
                   ;; TODO this is kind of ugmo, exists because user gives {:branch :main}
                   ;; but constraint fn is stricter (:branch :main) to ensure user can't 
                   ;; give {:branch :main :tag :main} and we'd only use one value.
                   opts (parse-opts constraint)
                   constraint (constraints.git (enum.unpack opts))]
        (-> {:id (generate-id)
             :name user-repo
             : source
             : constraint}
            (set-package-path)
            (set-tostring)))
      (map-err (fn [e] (err (fmt "%s/%s %s" forge-name user-repo e)))))
  (where _)
  (err "requires user/repo and version-constraint string or constraint table"))

(fn github [user-repo constraint]
  (forge :github user-repo constraint))

(fn gitlab [user-repo constraint]
  (forge :gitlab user-repo constraint))

(fn sourcehut [user-repo constraint]
  (forge :sourcehut user-repo constraint))

(fn* git
  (where _)
  ;; TODO
  (error "currently unsupported, needs dir option support"))
  ; (where [url constraint] (valid-args url constraint))
  ; (result-let [source (git-source.git url)
  ;              ;; TODO this is kind of ugmo
  ;              opts (parse-opts constraint)
  ;              constraint (constraints.git (enum.unpack opts))]
  ;   (-> {:id (generate-id)
  ;        :name url
  ;        : source
  ;        : constraint}
  ;         (set-package-path)
  ;       (set-tostring)))
  ; (where _)
  ; (err "requires user/repo and constraint"))

{: git
 : github
 : gitlab
 : sourcehut :srht sourcehut}
