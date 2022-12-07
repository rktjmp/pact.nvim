(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use enum :pact.lib.ruin.enum
     inspect :pact.inspect
     {: run} :pact.workflow.exec.process
     {:loop uv} vim
     {:format fmt} string
     {: 'await} :pact.async-await)

(local const {:ENV [:GIT_TERMINAL_PROMPT=0]})

(fn dump-err [code err]
  (fmt "git-error: return-code: %s std-err: %s" code (inspect err)))

(macro match-run [[cmd opts] ...]
  (let [arg-v [...]
        arg-c (select :# ...)
        ok-bodies (fcollect [i 1 arg-c 2]
                    (if (= `where-ok? (. arg-v i 1))
                      [(. arg-v i 2) (. arg-v (+ 1 i))]))
        err-bodies (fcollect [i 1 arg-c 2]
                    (if (= `where-err? (. arg-v i 1))
                      [(. arg-v i 2) (. arg-v (+ 1 i))]))]
    `(do
       (match (await (run ,cmd ,opts))
         (0 stdout# stderr#) ,(doto (accumulate [body `(match [0 stdout# stderr#]) _ [pat bod] (ipairs ok-bodies)]
                                      (doto body
                                            (table.insert pat)
                                            (table.insert bod)))
                                    (table.insert `_#)
                                    (table.insert `(error (string.format "Unhandled success case for %s %s" ,cmd (inspect _#)))))
         (code# stdout# stderr#) ,(doto (accumulate [body `(match [code# stdout# stderr#]) _ [pat bod] (ipairs err-bodies)]
                                          (doto body
                                                (table.insert pat)
                                                (table.insert bod)))
                                        (table.insert `_#)
                                        (table.insert `(error (string.format "Unhandled success case for %s" ,cmd))))
       (nil err#) (values nil err#)))))

(fn HEAD-sha [repo-root]
  (assert repo-root "must provide repo root")
  ;; TODO handle case where git repo exists but has no commits and so no HEAD
  (match-run ["git rev-parse --sq HEAD" {:cwd repo-root :env const.ENV}]
    (where-ok? [0 [line] _]) (match (string.match line "([%x]+)")
                               nil (values nil "could not find SHA in command output")
                               sha (values sha))
    (where-err? [code out err]) (values nil (dump-err code [out err]))))

(fn ls-remote [repo-path-or-url]
  "Get refs for an existing clone or url and parse them into refs types"
  (fn url? [str]
    (let [str (string.lower str)
          http (string.match str :^http)
          ssh (string.match str :^ssh)]
      (not (= nil http ssh))))
  (let [(cmd cwd) (match (url? repo-path-or-url)
                    true (values "git ls-remote --tags --heads $repo-path-or-url" ".")
                    false (values "git ls-remote --tags --heads" repo-path-or-url))]
    (match (await (run cmd {: repo-path-or-url : cwd :env const.ENV}))
      (0 lines _) (values lines)
      (code _ err) (values nil (dump-err code err))
      (nil err) (values nil err))))

(fn set-origin [repo-path url]
  (match (await (run "git remote add origin $url" {: url :cwd repo-path :env const.ENV}))
    (0 _ _) (values url)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn get-origin [repo-path]
  ;; TODO check origins before committing in workflows
  (match (await (run "git remote get-url origin" {:cwd repo-path :env const.ENV}))
    (0 [url] _) (values (string.match url "([^\r\n]+)"))
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn fetch-sha [repo-path sha]
  ;; TODO: best :--recurse-submodules option here?, esp re: fetch vs pull
  (match (await (run "git fetch --depth=1 origin $sha" {: sha :cwd repo-path :env const.ENV}))
    (0 _ _) (values sha)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn fetch [repo-path]
  ;; git-fetch on its own wont get new/other tags so we must
  ;; explicitly force. it *does* seem to get new branches, though
  ;; there is also some documentation to the contrary...
  (match (await (run "git fetch origin --tags" {:cwd repo-path :env const.ENV}))
    (0 _ _) (values true)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn init [repo-path inited]
  ;; repo-path should be absolute, so local dir is fine for cwd
  (match (await (run "git init $repo-path" {: repo-path :cwd "." :env const.ENV}))
    (0 _ _) (values repo-path)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn checkout-sha [repo-path sha]
  (match (await (run "git checkout $sha" {: sha :cwd repo-path :env const.ENV}))
    (0 _ _) (values sha)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn update-submodules [repo-path]
  (match (await (run "git submodule update --init --recursive" {:cwd repo-path :env const.ENV}))
    (0 lines _) (values lines)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn shallow? [repo-path]
  (match (await (run "git rev-parse --is-shallow-repository" {:cwd repo-path :env const.ENV}))
    (0 [:false] _) false
    (0 [:true] _) true
    (0 a b) (values nil (dump-err 0 [a b]))
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn dirty? [repo-path]
  ;; we wont look at untracked files as some plugins might create things like
  ;; help tags in the checkout, or other files.
  (match (await (run "git status --porcelain --untracked-files=no" {:cwd repo-path :env const.ENV}))
    (where (0 out _) (= 0 (length out))) false
    (where (0 out _) (< 0 (length out))) true
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn unshallow [repo-path]
  (match (await (run "git fetch --unshallow" {:cwd repo-path :env const.ENV}))
    (0 a b) (values true)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn log-diff [repo-path old-sha new-sha]
  ;; sha abbrevations are not a consistent width between repos, so send back full and
  ;; manually trim
  (match (await (run "git log --oneline --no-abbrev-commit --decorate $range"
                     {:range (fmt "%s..%s" old-sha new-sha)
                      :cwd repo-path
                      :env const.ENV}))
    (where (0 log _) (= 0 (length log))) (values nil "git log produced no output, are you moving backwards?")
    (0 log _) (values log)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

{: init
 : HEAD-sha
 : ls-remote
 : set-origin
 : get-origin
 : fetch-sha
 : fetch
 : checkout-sha
 : update-submodules
 : shallow?
 : dirty?
 : unshallow
 : log-diff}
