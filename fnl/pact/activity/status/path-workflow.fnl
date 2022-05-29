(import-macros {: use} :pact.vendor.donut)
(use {: defmonad :do-monad 'do-m :m-> '->
      : maybe-m : identity-m} :pact.vendor.donut.monad :as m
     {: fs} :pact.workflow.task
     {: 'raise : 'expect} :pact.error
     {: 'typeof : 'defstruct} :pact.struct
     {:loop uv} vim
     {: fmt : inspect : pathify} :pact.common
     {: workflow-m :new new-workflow : halt : event} :pact.workflow
     {: view} :fennel)

(local (new-exists-result {:type exists-result-type})
  ;; Plugin symlink is on disk and resolves
  (defstruct pact/path-status-workflow/result/exists
    [plugin]
    :describe-by [plugin]))

(local (new-missing-result {:type missing-result-type})
  ;; Plugin symlink does not exist
  (defstruct pact/path-status-workflow/result/missing
    [plugin]
    :describe-by [plugin]))

(local (new-broken-result {:type broken-result-type})
  ;; symlink exists but is invalid and needs repair
  (defstruct pact/path-status-workflow/result/broken
    [plugin reason]
    :describe-by [plugin reason]))

(local result-types ((defstruct pact/path-status-workflow/result-types
                       [EXISTS MISSING BROKEN]
                       :EXISTS exists-result-type
                       :BROKEN broken-result-type
                       :MISSING missing-results-type)))

(fn path-is-link? [path]
  (match (uv.fs_lstat path)
    {:type :link} true
    {:type t} (values nil (fmt "%s exists but was %s" path t))
    _ (values false)))

(fn links-to-dir? [path]
  (match (uv.fs_stat path)
    {:type :directory} true
    {:type t} (values false t)
    _ (values false :nothing)))

(fn work [plugin-group-root plugin]
  (let [_ (fs.ensure-directory-exists plugin-group-root)
        repo-path (pathify plugin-group-root plugin.id)
        finished workflow-m.finished
        result (m/-> workflow-m [:no-persistent-state]
                     (#(match (path-is-link? repo-path)
                         false (finished (new-missing-result :plugin plugin))
                         (nil err) (finished (new-broken-result :plugin plugin
                                                                :reason (fmt "was type %s" t)))))
                     (#(match (links-to-dir? repo-path)
                         true (finished (new-exists-result :plugin plugin))
                         (false t) (finished (new-broken-result :plugin plugin
                                                                :reason (fmt "link exists but resolves to %s" t)))
                         (nil err) (error "how did you get here?"))))]
    (halt result)))

(fn new [plugin-group-root plugin]
  (let [path-plugin (require :pact.provider.path)
        _ (expect (= path-plugin.type (typeof plugin))
                  internal "status path workflow must be given path plugin")
        id (.. :git-status- plugin.id)
        f #(work plugin-group-root plugin)]
    (new-workflow id f)))

{: new : result-types}
