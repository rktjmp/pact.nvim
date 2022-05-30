(import-macros {: use} :pact.vendor.donut)
(use {: 'do-monad} :pact.vendor.donut.monad
     {: git : fs} :pact.workflow.task
     {: 'raise : 'expect} :pact.error
     {: 'typeof : 'defstruct} :pact.struct
     {:loop uv} vim
     {: fmt : inspect : pathify} :pact.common
     {: workflow-m :new new-workflow : halt : event : new-error-result} :pact.workflow
     {: view} :fennel)

(local git-commit (require :pact.git.commit))
(local constraint (require :pact.constraint))

(local (needs-sync-result {:type needs-sync-type})
  (defstruct pact/git-status-workflow/result/satisfied
    [plugin current latest]
    :describe-by [plugin current latest]))

(local (in-sync-result {:type in-sync-type})
  (defstruct pact/git-status-workflow/result/unsatisfied
    [plugin latest]))

(local (can-sync-result {:type can-sync-type})
  (defstruct pact/git-status-workflow/result/unsatisfied
    [plugin satisfied-by latest]))

(local (needs-clone-result {:type needs-clone-type})
  ;; plugin has no current checkout
  (defstruct pact/git-status-workflow/result/clone
    [plugin satisfied-by latest]
    :describe-by [plugin satisfied-by latest]))

(local result-types ((defstruct pact/git-status-workflow/result-types
                       [NEEDS-CLONE NEEDS-SYNC IN-SYNC CAN-SYNC])
                     :NEEDS-CLONE needs-clone-type
                     :NEEDS-SYNC needs-sync-type
                     :IN-SYNC in-sync-type
                     :CAN-SYNC can-sync-type))

(fn find-best-commit-by-version [commits pin]
  "Search commits for version that satisfies given pin"
  ;; Sometimes ls-remote will give us multiple hashes for the same version tag
  ;; (peeled and unpeeled). We should return all commits that satisfy the pin
  ;; so we can accurately check whether the current sha is *any* of them.

  ;; first we will filter out all versions and map them version -> commit
  (let [versions->commits (collect [_ [hash btv] (ipairs commits)]
                            (if (= :version (constraint.type btv))
                                (values btv [hash btv])))
        ;; extract just the version numbers to solve for
        versions (icollect [version _ (pairs versions->commits)] version)
        best (constraint.version.solve [pin] versions)
        ;; now find all commits that match the best version
        viable (icollect [version commit (pairs versions->commits)]
                       (when (= version best) commit))]
    (inspect viable)
    (values viable)))

(fn find-commit-by-branch-or-tag [commits branch-or-tag]
  "Search commits for any branch or tag that satisfies given pin"
  (accumulate [found nil _ [hash btv] (ipairs commits) :until found]
    (when (constraint.satisfies? btv branch-or-tag)
      [hash btv])))

(fn maybe-latest-version [commits]
  (-?> commits
    (find-best-commit-by-version (constraint.version.new "> 0.0.0"))
    ;; just get first value if any, we only really want the version number
    (. 1)))

(fn fetch-remote-refs [from]
  (match-try (git.ls-remote from)
    lines (icollect [_ line (ipairs lines)]
            (git-commit.ref-line->commit line))
    commits (if (< 0 (length commits))
              (values commits)
              (values nil "ls-remote returned no commits"))
    (catch (nil err) (values nil (fmt "(ls-remote) %s" err)))))

(fn find-commit-for-constraint [commits pin]
  (match pin
    ;; version pins need to be "solved", they may have complex constraints
    {: major : minor : patch}
    (find-best-commit-by-version commits pin)
    ;; currently (?) we can't check the status of a commit in a remote to
    ;; verify it exists so when given a commit as a pin, we just assume it's
    ;; ok, and return a commit-like shape. We are still able to compare local HEAD
    ;; against this pin to know if we should _try_ and sync.
    {: hash}
    [pin pin]
    ;; tags and branches are simple lookups
    {: tag}
    (find-commit-by-branch-or-tag commits pin)
    {: branch}
    (find-commit-by-branch-or-tag commits pin)))

(fn existing-checkout-ready? [repo-path plugin]
  ;; check that the existing clone is actually usable
  (do-monad workflow-m
    [_ (event "checking existing repo ok on disk")
     ;; repo path must be a git rep
     dir-ok (match (fs.what-is-at (pathify repo-path :.git))
              :directory true
              :nothing (workflow-m.finished
                         (new-error-result :plugin plugin
                                           :reason (fmt "%s exists but missing .git dir" repo-path)))
              t (workflow-m.finished
                  (new-error-result :plugin plugin
                                    :reason (fmt "%s/.git exists but is wrong type" repo-path t)))
              (nil msg) (raise internal msg))
     ;; repo origin must match plugin origin
     _ (event "checking repo remote ok")
     origin-ok (match (git.get-origin repo-path)
                 origin (if (not (= origin plugin.url))
                          (workflow-m.finished
                            (new-error-result :plugin plugin
                                              :reason (fmt "plugin origin does not match repo origin %q %q %q %q"
                                                           plugin.id plugin.url repo-path origin))))
                 (nil err) (workflow-m.finished
                             (new-error-result :plugin plugin
                                               :reason (fmt "could not check origin for plugin %q %q: %q"
                                                             plugin.id repo-path err))))]
    (values true)))

(fn existing-git-status [repo-path plugin]
  (do-monad workflow-m
    [existing-clone-ok? (match (existing-checkout-ready? repo-path plugin)
                          true true
                          other (workflow-m.finished other))
     _ (event "discovering local sha")
     current-hash (match (git.HEAD-sha repo-path)
                    val (constraint.hash.new val)
                    (nil err) (workflow-m.finished
                                (new-error-result :plugin plugin
                                                  :reason (fmt "could not get current sha %s %s %s"
                                                               plugin.id repo-path err))))
     _ (event "fetching remote commits")
     refs (match (fetch-remote-refs plugin.url)
            refs refs
            (nil err) (workflow-m.finished (new-error-result :plugin plugin
                                                             :reason err)))
     _ (event "resolving latest commit")
     latest (maybe-latest-version refs)
     _ (event "verifying pin target")
     commit (match (find-commit-for-constraint refs plugin.pin)
              commits commits
              nil (workflow.finished (new-error-result :plugin plugin
                                                       :reason (fmt "could not satisfy %s"
                                                                    plugin.pin))))
     _ (event "resolving pin to commit")
     via (constraint.type plugin.pin)
     _ (event "verifying pin against commit")]
    (print (vim.inspect [current-hash refs latest commit via]))
    (match [via commit]
      [_ nil] (raise argument (fmt "could not resolve %s (%s)" via plugin.pin))
      ;; version may return multiple commits that match given version, so check
      ;; if we match any of them.
      [:version commit] (let [found (accumulate [found nil _
                                                 [hash btv] (ipairs commit)
                                                 :until found]
                                     (when (= hash current-hash) [hash btv]))
                               first-option (. commit 1)]
                         (match found
                           nil (can-sync-type :plugin plugin
                                              :satisfied-by first-option
                                              :latest latest)
                           found (in-sync-type :plugin plugin
                                               :satisfied-by found
                                               :lates latest)))
      [_ [hash btv]] (match (= hash current-hash)
                      ;; current hash is equal to commit, so we can send that back
                      ;; as the current checkout
                      true
                      (git-result plugin commit :hold {:hold []} latest)
                      ;; commit cant stand in as current checkout, so construct a commit
                      false
                      (git-result plugin [current-hash current-hash] :hold {:hold [] :sync [commit]} latest)))))

(fn new-git-status [repo-path plugin]
  ;; New plugins can't really be verified, but we can check that they're
  ;; requesting something reasonable, which is does the branch/tag exist? Is
  ;; the version valid? We can't check commits against remote hosts, so we just
  ;; assume this is OK and let it fail at the checkout stage later on.
  (do-monad
    workflow-m
    [_ (event "fetching remote commits")
     refs (match (fetch-remote-refs plugin.url)
            refs refs
            (nil err) (workflow-m.finished (new-error-result :plugin plugin
                                                             :reason err)))
     latest (match (maybe-latest-version refs)
              ;; will get back hash - version, but we only care
              ;; to use version to *show* latest
              [_ version] version)
     _ (event "verifying pin target")
     _ (inspect :latest latest)
     commit (match (find-commit-for-constraint refs plugin.pin)
              ;; version may return multiple commits that match given version but
              ;; for new status-checks any version will do, so just grab the first.
              [[commit & _]] commit
              nil (workflow.finished (new-error-result :plugin plugin
                                                       :reason (fmt "could not satisfy %s"
                                                                    plugin.pin))))]
    (workflow-m.finished (needs-clone-result :plugin plugin
                                             :satisfied-by commit
                                             :latest latest))))

(fn work [plugin-group-root plugin]
  (fn workflow-for-dir-type [repo-path plugin]
    (match (fs.what-is-at repo-path)
      :nothing new-git-status
      :directory existing-git-status
      any (raise internal (fmt "cant verify path %q because it is a %q" repo-path any))
      (nil err) (raise internal err)))

  (let [repo-path (pathify plugin-group-root plugin.id)
        _ (fs.ensure-directory-exists plugin-group-root)
        result (match (workflow-for-dir-type repo-path plugin)
                 (where f (= :function (type f))) (f repo-path plugin)
                 any (raise internal
                            (fmt "cant verify path %q because it is a %q" repo-path any))
                 (nil err) (raise internal err))]
    (halt result)))

(fn new [plugin-group-root plugin]
  (let [ git-plugin (require :pact.provider.git)
        _ (expect (= git-plugin.type (typeof plugin))
                  internal "status git workflow must be given git plugin")
        id (.. :git-status- plugin.id)
        f #(work plugin-group-root plugin)]
    (new-workflow id f)))

{: new : result-types}
