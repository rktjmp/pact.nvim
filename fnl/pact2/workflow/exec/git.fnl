(import-macros {: use} :pact.lib.ruin.use)
(use enum :pact.lib.ruin.enum
     {: run} :pact2.workflow.exec.process
     {:loop uv} vim
     {:format fmt} string)

(import-macros {: raise : expect} :pact.error)
(import-macros {: async : await} :pact.async_await)

(local const {:ENV [:GIT_TERMINAL_PROMPT=0]})

(fn dump-err [code err]
  (let [{: view} (require :fennel)
        msg (view err {:one-line? true})]
    (fmt "git-error: [%d] %s" code msg)))

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

; (fn set-origin [repo-path url origin-set]
;   (match (await (run :git [:remote :add :origin url] repo-path const.ENV))
;     (0 _ _) (values url)
;     (code _ err) (values nil (dump-err code err))))

; (fn get-origin [repo-path]
;   (match (await (run :git [:remote :get-url :origin] repo-path const.ENV))
;     (0 [url] _) (values (string.match url "([^\r\n]+)"))
;     (code _ err) (values nil (dump-err code err))))

; (fn fetch-sha [repo-path sha]
;   ;; TODO: best :--recurse-submodules option here?, esp re: fetch vs pull
;   (match (await (run :git [:fetch :--depth=1 :origin sha] repo-path const.ENV))
;     (0 _ _) (values sha)
;     (code _ err) (values nil (dump-err code err))))

; (fn init [repo-path inited]
;   ;; repo-path should be absolute, so local dir is fine for cwd
;   (match (await (run :git [:init repo-path] "." const.ENV))
;     (0 _ _) (values repo-path)
;     (code _ err) (values nil (dump-err code err))))

; (fn checkout-sha [repo-path sha]
;   (match (await (run :git [:checkout sha] repo-path const.ENV))
;     (0 _ _) (values sha)
;     (code _ err) (values nil (dump-err code err))))

{
 ; : init
 : HEAD-sha
 : ls-remote
 ; : set-origin
 ; : get-origin
 ; : fetch-sha
 ; : checkout-sha
}
