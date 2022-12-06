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

(fn HEAD-sha [repo-root]
  (assert repo-root "must provide repo root")
  ;; TODO handle case where git repo exists but has no commits and so
  ;; no HEAD 
  (match (await (run :git [:rev-parse :--sq :HEAD] repo-root const.ENV))
    (0 [line] _) (match (string.match line "([%x]+)")
                   nil (values nil "could not find SHA in command output")
                   sha (values sha))
    (code lines err) (values nil (dump-err code [lines err]))
    (nil err) (values nil err)))

(fn ls-remote [repo-path-or-url]
  "Get refs for an existing clone or url and parse them into refs types"
  (fn url? [str]
    (let [str (string.lower str)
          http (string.match str :^http)
          ssh (string.match str :^ssh)]
      (not (= nil http ssh))))
  (let [(args cwd) (match (url? repo-path-or-url)
                     true (values [:ls-remote :--tags :--heads repo-path-or-url] ".")
                     false (values [:ls-remote :--tags :--heads] repo-path-or-url))]
    (match (await (run :git args cwd const.ENV))
      (0 lines _) (values lines)
      (code _ err) (values nil (dump-err code err))
      (nil err) (values nil err))))

(fn set-origin [repo-path url]
  (match (await (run :git [:remote :add :origin url] repo-path const.ENV))
    (0 _ _) (values url)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn get-origin [repo-path]
  ;; TODO check origins before committing in workflows
  (match (await (run :git [:remote :get-url :origin] repo-path const.ENV))
    (0 [url] _) (values (string.match url "([^\r\n]+)"))
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn fetch-sha [repo-path sha]
  ;; TODO: best :--recurse-submodules option here?, esp re: fetch vs pull
  (match (await (run :git [:fetch :--depth=1 :origin sha] repo-path const.ENV))
    (0 _ _) (values sha)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn fetch [repo-path]
  ;; git-fetch on its own wont get new/other tags so we must
  ;; explicitly force. it *does* seem to get new branches, though
  ;; there is also some documentation to the contrary...
  (match (await (run :git [:fetch :origin :--tags] repo-path const.ENV))
    (0 _ _) (values true)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn init [repo-path inited]
  ;; repo-path should be absolute, so local dir is fine for cwd
  (match (await (run :git [:init repo-path] "." const.ENV))
    (0 _ _) (values repo-path)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn checkout-sha [repo-path sha]
  (match (await (run :git [:checkout sha] repo-path const.ENV))
    (0 _ _) (values sha)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn update-submodules [repo-path]
  (match (await (run :git [:submodule :update :--init :--recursive] repo-path const.ENV))
    (0 lines _) (values lines)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn shallow? [repo-path]
  (match (await (run :git [:rev-parse :--is-shallow-repository] repo-path const.ENV))
    (0 [:false] _) false
    (0 [:true] _) true
    (0 a b) (values nil (dump-err 0 [a b]))
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn dirty? [repo-path]
  ;; we wont look at untracked files as some plugins might create things like
  ;; help tags in the checkout, or other files.
  (match (await (run :git [:status :--porcelain :--untracked-files=no] repo-path const.ENV))
    (where (0 out _) (= 0 (length out))) false
    (where (0 out _) (< 0 (length out))) true
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn unshallow [repo-path]
  (match (await (run :git [:fetch :--unshallow] repo-path const.ENV))
    (0 a b) (values true)
    (code _ err) (values nil (dump-err code err))
    (nil err) (values nil err)))

(fn log-diff [repo-path old-sha new-sha]
  ;; sha abbrevations are not a consistent width between repos, so send back full and
  ;; manually trim
  (let [args [:log :--oneline :--no-abbrev-commit :--decorate (fmt "%s..%s" old-sha new-sha)]]
    (match (await (run :git args repo-path const.ENV))
      (where (0 log _) (= 0 (length log))) (values nil "git log produced no output, are you moving backwards?")
      (0 log _) (values log)
      (code _ err) (values nil (dump-err code err))
      (nil err) (values nil err))))

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
