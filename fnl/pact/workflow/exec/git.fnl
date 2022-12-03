(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use enum :pact.lib.ruin.enum
     inspect :pact.inspect
     {: run} :pact.workflow.exec.process
     {:loop uv} vim
     {:format fmt} string
     {: 'async : 'await} :pact.async-await)

(local const {:ENV [:GIT_TERMINAL_PROMPT=0]})

(fn dump-err [code err]
  ;; TODO drop fennel req
  (fmt "git-error: [%d] %s" code (inspect err)))

(fn HEAD-sha [repo-root]
  (assert repo-root "must provide repo root")
  ;; TODO handle case where git repo exists but has no commits and so
  ;; no HEAD 
  (match (await (run :git [:rev-parse :--sq :HEAD] repo-root const.ENV))
    (0 [line] _) (match (string.match line "([%x]+)")
                   nil (values "could not find SHA in command output")
                   sha (values sha))
    (code lines err) (values nil (dump-err code [lines err]))))

(fn ls-remote [repo-path-or-url]
  "Get refs for an existing clone or url and parse them into refs types"
  (fn url? [str]
    (let [str (string.lower str)
          http (string.match str :^http)
          ssh (string.match str :^ssh)]
      (not (= nil http ssh))))

  (let [(code lines err)
        (match (url? repo-path-or-url)
          true (await (run :git
                           [:ls-remote :--tags :--heads repo-path-or-url]
                           "." const.ENV))
          false (await (run :git
                            [:ls-remote :--tags :--heads]
                            repo-path-or-url const.ENV)))]
    (match [code lines err]
      [0 lines _] (values lines)
      [code _ err] (values nil (dump-err code err)))))

(fn set-origin [repo-path url]
  (match (await (run :git [:remote :add :origin url] repo-path const.ENV))
    (0 _ _) (values url)
    (code _ err) (values nil (dump-err code err))))

(fn get-origin [repo-path]
  ;; TODO check origins before committing in workflows
  (match (await (run :git [:remote :get-url :origin] repo-path const.ENV))
    (0 [url] _) (values (string.match url "([^\r\n]+)"))
    (code _ err) (values nil (dump-err code err))))

(fn fetch-sha [repo-path sha]
  ;; TODO: best :--recurse-submodules option here?, esp re: fetch vs pull
  (match (await (run :git [:fetch :--depth=1 :origin sha] repo-path const.ENV))
    (0 _ _) (values sha)
    (code _ err) (values nil (dump-err code err))))

(fn fetch [repo-path]
  (match (await (run :git [:fetch :origin] repo-path const.ENV))
    (0 _ _) (values true)
    (code _ err) (values nil (dump-err code err))))

(fn init [repo-path inited]
  ;; repo-path should be absolute, so local dir is fine for cwd
  (match (await (run :git [:init repo-path] "." const.ENV))
    (0 _ _) (values repo-path)
    (code _ err) (values nil (dump-err code err))))

(fn checkout-sha [repo-path sha]
  (match (await (run :git [:checkout sha] repo-path const.ENV))
    (0 _ _) (values sha)
    (code _ err) (values nil (dump-err code err))))

(fn shallow? [repo-path]
  (match (await (run :git [:rev-parse :--is-shallow-repository] repo-path const.ENV))
    (0 [:false] _) false
    (0 [:true] _) true
    (0 a b) (values nil (dump-err 0 [a b]))
    (code _ err) (values nil (dump-err code err))))

(fn unshallow [repo-path]
  (match (await (run :git [:fetch :--unshallow] repo-path const.ENV))
    (0 a b) (values true)
    (code _ err) (values nil (dump-err code err))))

(fn log-diff [repo-path old-sha new-sha]
  (match (await (run :git [:log :--oneline (fmt "%s..%s" old-sha new-sha)] repo-path const.ENV))
    (where (0 log _) (= 0 (length log))) (values nil "git log produced no output, are you moving backwards?")
    (0 log _) (values log)
    (code _ err) (values nil (dump-err code err))))

{: init
 : HEAD-sha
 : ls-remote
 : set-origin
 : get-origin
 : fetch-sha
 : fetch
 : checkout-sha
 : shallow?
 : unshallow
 : log-diff}
