(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use inspect :pact.inspect
     {: run : cb->await : 'match-run} :pact.exec
     {:loop uv} vim
     {:format fmt} string)

(local const {:ENV [:GIT_TERMINAL_PROMPT=0]})
(local M {})

(fn dump-err [code err]
  (fmt "git-error: return-code: %s std-err: %s" code (inspect err)))

(fn M.create-stub-clone [repo-url repo-path]
  "Creates a blank clone of the remote repo. This contains enough data to see
  logs and interact with tags and branches, but contains no blobs or trees."
  (match-run ["git clone --no-checkout --filter=tree:0 $repo-url $repo-path"
              {: repo-url : repo-path :env const.ENV}]
    (where-ok? [_ lines _]) (values true)
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

(fn M.update-refs [repo-path]
  ;; TODO sense check filtering here. In tests we dont need it, and if
  ;; the shared repo is no-checkout then also probably not, but in some
  ;; cases it may end up pulling in data.
  (match-run ["git fetch --filter=tree:0" {:cwd repo-path :env const.ENV}]
    (where-ok? [_ lines _]) (values true)
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

(fn verify-ref [repo-path commit-ref]
  (match-run ["git show --format=%H -s $commit-ref"
              {: commit-ref :cwd repo-path :env const.ENV}]
    (where-ok? [_ [line] _]) (values line)
    (where-err? [code out err]) (values false)))

(fn M.verify-commit [repo-path sha]
  "Verify a given commit sha exists"
  (verify-ref repo-path sha))

(fn M.verify-branch [repo-path branch]
  "Verify a given branch exists remotely. Local branches are ignored."
  ;; We ignore local branches as we should always be treating the remote as a
  ;; single source of truth. We also always assume remote is 'origin'.
  (verify-ref repo-path (.. "refs/remotes/origin/" branch)))

(fn M.verify-tag [repo-path tag]
  "Verify a given tag exists."
  ;; Generally I have not seen a difference in representation between local and
  ;; remote tags but there may be one in odd circumstances.
  (verify-ref repo-path (.. "refs/tags/" tag)))

(fn M.ls-local [repo-path]
  (match-run ["git show-ref --dereference" {:cwd repo-path :env const.ENV}]
    (where-ok? [_ lines _]) (values lines)
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

(fn M.ls-remote [repo-path-or-url]
  "Get refs for an existing clone or url"
  (fn url? [str]
    (let [str (string.lower str)
          http (string.match str :^http)
          ssh (string.match str :^ssh)]
      (not (= nil http ssh))))
  (let [(cmd cwd) (match (url? repo-path-or-url)
                    true (values "git ls-remote $repo-path-or-url tags/* heads/* HEAD" ".")
                    false (values "git ls-remote origin tags/* heads/* HEAD" repo-path-or-url))]
    (match-run [cmd {: repo-path-or-url : cwd :env const.ENV}]
      (where-ok? [_ lines _]) (values lines)
      (where-err? [code out err]) (values nil (dump-err code [out err])))))

(λ M.sha-timestamp [repo-root sha]
  (match-run ["git show --format=%at -s $sha" {:cwd repo-root :sha sha :env const.ENV}]
    (where-ok? [0 [ts] _]) (values ts)
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

(fn M.HEAD-sha [repo-root]
  (assert repo-root "must provide repo root")
  ;; TODO handle case where git repo exists but has no commits and so no HEAD
  (match-run ["git rev-parse --sq HEAD" {:cwd repo-root :env const.ENV}]
    (where-ok? [0 [line] _]) (match (string.match line "([%x]+)")
                               nil (values nil "could not find SHA in command output")
                               sha (values sha))
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

(fn M.checkout-sha [repo-path sha]
  (match-run ["git checkout $sha" {: sha :cwd repo-path :env const.ENV}]
    (where-ok? [_ _ _]) (values true)
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

(fn M.update-submodules [repo-path]
  (match-run ["git submodule update --init --recursive" {:cwd repo-path :env const.ENV}]
    (where-ok? [_ lines _]) (values lines)
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

; (fn M.dirty? [repo-path]
;   ;; we wont look at untracked file as some plugins might create things like
;   ;; help tags in the checkout, or other files.
;   (match (await (run "git status --porcelain --untracked-files=no" {:cwd repo-path :env const.ENV}))
;     (where (0 out _) (= 0 (length out))) false
;     (where (0 out _) (< 0 (length out))) true
;     (code _ err) (values nil (dump-err code err))
;     (nil err) (values nil err)))

(fn M.log-diff [repo-path old-sha new-sha]
  ;; sha abbrevations are not a consistent width between repos, so send back full and
  ;; manually trim
  (match-run ["git log --oneline --no-abbrev-commit --decorate $range"
              {:range (fmt "%s..%s" old-sha new-sha)
               :cwd repo-path
               :env const.ENV}]
    (where-ok? [_ log _]) (values log)
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

(fn M.log-breaking [repo-path old-sha new-sha]
  (match-run ["git log --oneline --no-abbrev-commit --format=%H --grep=breaking --regexp-ignore-case $range"
              {:range (fmt "%s..%s" old-sha new-sha)
               :cwd repo-path
               :env const.ENV}]
    (where-ok? [_ log _]) (values log)
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

(fn M.clone [url repo-path]
  (match-run ["git clone --no-checkout --filter=tree:0 $url $repo-path"
              {: url : repo-path :env const.ENV}]
    (where-ok? [_ lines e]) (do
                              (values true))
    (where-err? [code o e]) (do
                              (values nil (dump-err code o e)))))

(fn M.add-worktree [repo-path worktree-path sha]
  ;; Note this is --no-checkout so we can sparse-check for packfile and read
  ;; without getting everything, in case that has knock on dependencies.
  (match-run ["git worktree add --no-checkout --detach $worktree-path $sha"
              {: worktree-path : sha :cwd repo-path :env const.ENV}]
    (where-ok? [_ lines e]) (do
                              (values true))
    (where-err? [code o e]) (do
                              (values nil (dump-err code [o e])))))

(values M)
