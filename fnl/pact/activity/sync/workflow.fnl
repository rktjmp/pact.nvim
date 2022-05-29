(import-macros {: raise : expect} :pact.error)

(local uv vim.loop)
(local {: fmt : inspect : pathify} (require :pact.common))
(local {:new new-workflow : halt : event} (require :pact.workflow))
(local {: fs : git} (require :pact.workflow.task))

(fn absolute-path? [path]
  ;; TODO use lua path sep
  (match (string.sub path 1 1)
    "/" true
    _ false))

(fn plugin-repo-path [pact-set-root plugin]
  (pathify pact-set-root plugin.id))

(fn create-local-repo [repo-path plugin]
  ;; only the sith deal in absolutes, so ... whoops.
  (event "validating target path")
  (match (absolute-path? repo-path)
    false (raise argument (fmt "path must be absolute %q" repo-path)))
  ;; "get" wants clean state, so make sure the clone target is missing
  (match (fs.what-is-at repo-path)
    :nothing true
    :directory (raise argument
                      "path already exists, remove path or use update instead of get"
                      {: repo-path})
    (nil msg) (raise internal msg {: repo-path})
    any (raise argument (fmt "repo-path %s was type %s" repo-path any)))
  ;; create the repo
  (event "creating repository")
  (match (git.init repo-path)
    (nil err) (raise internal err {: repo-path}))
  ;; now set origin for new repo
  (event "setting repository origin")
  (match (git.set-origin repo-path plugin.url)
    url url
    (nil err) (raise internal err {: repo-path}))
  ;; return *something* but really control flow is dictated by raising errors
  (values true))

(fn checkout2 [repo-path sha]
  (match-try (match (absolute-path? repo-path)
               true true
               false (values nil (error-result "must be absolute path")))
    true (match (what-is-at? repo-path)
           :directory true
           :nothing (values nil (error-result "path did not exist, unable to update")))))

(fn log [message]
  (fn [...]
    (event message)
    (values ...)))

; (fn checkout-mona [repo-path sha]
;   (let [state (new-state :path repo-path
;                          :dot-git-path (pathify repo-path :.git)
;                          :sha sha)]
;     (run (continue state)
;          (log "checking paths")
;          #(match (absolute-path? $1.repo-path)
;            true (continue $1)
;            false (failure ("must be absolute-path")))
;          #(match (what-is-at $1.repo-path)
;             :directory (continue $1)
;             other (failure "must be dir, got" other))
;          #(match (what-is-at $1.dot-git-path)
;             :directory (continue $1)
;             other (failure "must be git dir, got" other))
;          #(match (git.fetch-sha $1.repo-path $1.sha)
;             sha (continue $1)
;             nil err (failure (err))))))

(fn checkout [repo-path sha]
  ;; preflight
  (event "validating target path")
  (match (absolute-path? repo-path)
    false (raise argument (fmt "path must be absolute %q" repo-path)))
  ;; dir must exist to update ...
  (event "validating repository")
  (match (fs.what-is-at repo-path)
    :directory true
    :nothing (raise argument "path did not exist, unable to update"
                    {: repo-path})
    (nil msg) (raise internal msg {: repo-path})
    any (raise argument (fmt "repo-path %s was type %s" repo-path any)))
  ;; dir must also be a git repo
  (match (fs.what-is-at (pathify repo-path :.git))
    :directory true
    :nothing (raise argument "path is not a git repository, unable to upate"
                    {: repo-path})
    (nil msg) (raise internal msg {: repo-path})
    any (raise argument (fmt "repo-path %s was type %s" repo-path any)))
  (event (fmt "fetching %q" sha))
  ;; Fetch the desired sha first
  (match (git.fetch-sha repo-path sha)
    (nil err) (raise internal (fmt "could not fetch sha %q %q" sha repo-path)
                     {: sha : repo-path}))
  (event (fmt "checking out %q" sha))
  ;; Now checkout that sha specifically
  (match (git.checkout-sha repo-path sha)
    (nil err) (raise argument err {: repo-path : sha}))
  (values true))

(fn git-get [repo-path plugin sha]
  (create-local-repo repo-path plugin)
  (checkout repo-path sha))

(fn git-update [repo-path plugin sha]
  (checkout repo-path sha))

(fn git-sync [repo-path action]
  (expect (not (and (= nil repo-path) (= nil action))) argument
          "git-sync needs repo-path plugin command sha")
  (let [{: plugin : action :args [[hash ref]] : current-checkout} action]
    (match [action current-checkout]
      [:sync nil] (git-get repo-path plugin hash.hash)
      [:sync current-checkout] (git-update repo-path plugin hash.hash)
      other (raise internal (fmt "unsupported command given to sync: %q" other)))))

(fn path-get [repo-path plugin]
  ;; manually expand the path since we are running inside a loop callback and
  ;; cant use vim.fn. This is ... probably fine.

  (fn maybe-expand-tilde [path]
    (match [(string.sub path 1 1) (string.sub path 2)]
      ["~" rest] (pathify (uv.os_getenv :HOME) rest)
      _ path))

  (let [real-path (maybe-expand-tilde plugin.path)]
    (event (fmt "creating symlink to %q" real-path))
    (match (uv.fs_symlink real-path repo-path {:dir true :junction true})
      true repo-path
      (nil err)
      (raise internal (fmt "could not create symlink %q because %s" plugin.path
                           err)))))

(fn path-sync [repo-path action]
  (expect (not (and (= nil repo-path) (= nil action))) argument
          "path-sync needs repo-path action")
  (let [{: plugin : action} action]
    (match action
      :sync (path-get repo-path plugin)
      other (raise internal (fmt "unsupported command given to sync: %q" other)))))

(fn work [plugin-group-root action]
  (let [{: plugin : method} action
        repo-path (pathify plugin-group-root plugin.id)
        _ (event "ensuring plugin group directory exists")
        _ (fs.ensure-directory-exists plugin-group-root)
        result [(match method
                  :git (git-sync repo-path action)
                  :path (path-sync repo-path action))]]
    (halt result)))

(fn new [plugin-group-root action]
  (expect (not (and (= nil plugin-group-root) (= nil action))) argument
          "sync workflow needs plugin-repo-path action")
  (let [id (.. :sync- action.plugin.id)
        f #(work plugin-group-root action)]
    (new-workflow id f)))

{: new}
