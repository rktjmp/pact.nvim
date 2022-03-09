(import-macros {: raise : expect} :pact.error)

(local uv vim.loop)
(local {: fmt : inspect : pathify} (require :pact.common))
(local {:new new-workflow : halt : event} (require :pact.workflow))
(local {: git : fs} (require :pact.workflow.task))
(local git-commit (require :pact.git.commit))
(local git-provider (require :pact.provider.git))
(local path-provider (require :pact.provider.path))
(local constraint (require :pact.constraint))

(fn git-result [plugin current-checkout action actions latest-version]
  [:git {: plugin : current-checkout : latest-version : action : actions}])

(fn path-result [plugin action actions]
  [:path {: plugin : action : actions}])

(fn find-best-commit-by-version [commits pin]
  "Search commits for version that satisfies given pin"
  ;; Some times ls-remote will give us multiple hashes for the same version tag
  ;; (peeled and unpeeled). We should return all commits that satisfy the pin
  ;; so we can accurately check whether the current sha is *any* of them.

  ;; first we will filter out all versions and map them version -> commit
  (let [versions->commits (collect [_ [hash btv] (ipairs commits)]
                            (if (= :version (constraint.type btv))
                                (values btv [hash btv])
                                (values nil nil)))
        ;; extract just the version numbers to solve for
        versions (icollect [version _ (pairs versions->commits)]
                   version)
        best (constraint.version.solve [pin] versions)
        ;; now find all commits that match the best version
        viable (icollect [version commit (pairs versions->commits)]
                       (when (= version best) commit))]
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
  (let [lines (match (git.ls-remote from)
                lines lines
                (nil err) (raise internal (fmt "ls-remote failed: %q %q" from err)))
        commits (icollect [_ line (ipairs lines)]
                  (git-commit.ref-line->commit line))]
    (match commits
      (where t (= 0 (length t)))
      (raise internal (fmt "ls-remote returned no commits %q" from))
      _ (values commits))))

(fn find-commit-for-constraint [commits pin]
  (match pin
    ;; version pins need to be "solved", they may have complex constraints
    {: major : minor : patch}
    (find-best-commit-by-version commits pin)
    ;; currently (?) we can't check the status of a commit in a remote to
    ;; verify it exists so when givin a commit as a pin, we just assume it's
    ;; ok, and return a commit-like shape. We are still able to compare local HEAD
    ;; against this pin to know if we should _try_ and sync.
    {: hash}
    [pin pin]
    ;; tags and branches are simple lookups
    {: tag}
    (find-commit-by-branch-or-tag commits pin)
    {: branch}
    (find-commit-by-branch-or-tag commits pin)))

(fn existing-git-status [repo-path plugin]
  ;; repo path must be a git rep
  (match (fs.what-is-at (pathify repo-path :.git))
    :directory true
    :nothing (raise internal
                    (fmt "path exists but no .git dir %s %s" repo-path))
    type (raise internal (fmt "path exists but .git is wrong type %s %s"
                              repo-path msg))
    (nil msg) (raise internal msg))
  ;; repo origin must match plugin origin
  (match (git.get-origin repo-path)
    origin (if (not (= origin plugin.url))
                      (raise internal
                             (fmt "plugin origin does not match repo origin %q %q %q %q"
                                  plugin.id plugin.url repo-path origin)))
    (nil err) (raise internal
                       (fmt "could not check origin for plugin %q %q: %q"
                            plugin.id repo-path err)))
  ;; proceed with status checking
  (let [_ (event "discovering local sha")
        current-hash (match (git.HEAD-sha repo-path)
                       val (constraint.hash.new val)
                       (nil err) (raise internal
                                        (fmt "could not get HEAD sha in %q %s"
                                             repo-path err)))
        _ (event "fetching remote commits")
        remote-commits (fetch-remote-refs plugin.url)
        _ (event "resolving pin to commit")
        commit (find-commit-for-constraint remote-commits plugin.pin)
        latest (maybe-latest-version remote-commits)
        via (constraint.type plugin.pin)
        _ (event "verifying pin against commit")]
    (match [via commit]
      [_ nil] (raise argument (fmt "could not resolve %s (%s)" via plugin.pin))
      ;; version may return multiple commits that match given version, so check
      ;; if we match any of them.
      [:version commit] (let [found (accumulate [found nil _ [hash btv] (ipairs commit) :until found]
                                              (when (= hash current-hash) [hash btv]))
                              first-option (. commit 1)]
                        (match found
                          nil (git-result plugin [current-hash current-hash] :hold
                                      {:hold [] :sync [first-option]} latest)
                          found (git-result plugin found :hold {:hold []} latest)))
      [_ [hash btv]] (match (= hash current-hash)
                   ;; current hash is equal to commit, so we can send that back
                   ;; as the current checkout
                   true
                   (git-result plugin commit :hold {:hold []} latest)
                   ;; commit cant stand in as current checkout, so construct a commit
                   false
                   (git-result plugin [current-hash current-hash] :hold
                               {:hold [] :sync [commit]} latest)))))

(fn new-git-status [plugin]
  ;; New plugins can't really be verified, but we can check that they're
  ;; requesting something reasonable, which is does the branch/tag exist? Is
  ;; the version valid? We can't check commits against remote hosts, so we just
  ;; assume this is OK and let it fail at the checkout stage later on.
  (let [_ (event "new: fetching remote commits")
        remote-commits (fetch-remote-refs plugin.url)
        _ (event "new: verifying pin target")
        commit (find-commit-for-constraint remote-commits plugin.pin)
        latest (maybe-latest-version remote-commits)
        via (constraint.type plugin.pin)]
    (match [via commit]
      [_ nil] (raise argument (fmt "could not resolve %s (%s) %s" via plugin.pin
                               latest))
      ;; version may return multiple commits that match given version, any will do.
      [:version commit] (let [first-option (. commit 1)]
                          (git-result plugin nil :sync {:hold [] :sync [first-option]} latest))
      [_ [hash btv]] (git-result plugin nil :sync {:hold [] :sync [commit]} latest))))

(fn git-status [repo-path plugin]
  (match (fs.what-is-at repo-path)
    (:nothing) (new-git-status plugin)
    (:directory) (existing-git-status repo-path plugin)
    (any) (raise internal (fmt "cant verify path %q because it is a %q"
                               repo-path any))
    (nil err) (raise internal err)))

(fn new-path-status [repo-path plugin]
  (path-result plugin :sync {:sync [repo-path] :hold []}))

(fn existing-path-status [repo-path plugin]
  (path-result plugin :hold {:hold []}))

(fn path-status [repo-path plugin]
  (match (fs.what-is-at repo-path)
    (:nothing) (new-path-status repo-path plugin)
    (:directory) (existing-path-status repo-path plugin)
    (any)
    (raise internal (fmt "cant verify path at %q because it is a %q" repo-path
                         any))
    (nil err) (raise internal err)))

(fn work [plugin-group-root plugin]
  (let [repo-path (pathify plugin-group-root plugin.id)
        _ (fs.ensure-directory-exists plugin-group-root)
        result (match plugin
                 (where (plugin) (git-provider.is-a? plugin)) (git-status repo-path
                                                                          plugin)
                 (where (plugin) (path-provider.is-a? plugin)) (path-status repo-path
                                                                            plugin))]
    (halt result)))

(fn new [plugin-group-root plugin]
  (let [id (.. :git-status- plugin.id)
        f #(work plugin-group-root plugin)]
    (new-workflow id f)))

(fn set-action [workflow action]
  (local mod (require :pact.workflow))
  (assert (= workflow.state mod.const.state.FINISHED) "must be finished")
  (match workflow.result
    [_ result] (match (. result :actions action)
                 nil (vim.notify (fmt "%s not valid action" action))
                 _ (tset result :action action))
    any (error any)))

{: new : set-action}
