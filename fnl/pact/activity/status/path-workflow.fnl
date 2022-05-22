(import-macros {: raise : expect} :pact.error)
(import-macros {: typeof : defstruct} :pact.struct)

(fn defmonad [name bind]
  "define a monadic type as name bind function should look like (fn [f a ma])
  where f will be a function, a is the current value and ma is the wrapped
  value."
  (fn tostring [t]
    (string.format "%s(%s)" name (tostring t)))
  (fn [a
        ;; var -> set to avoid strict compiler fail when evaling
        (var ma nil)
        (set ma {:bind #(bind $1 a ma)
                  :value (fn [] a)
                  :type name})
        (setmetatable ma {:__tostring tostring})]))

(fn run [x ...]
  (match (select :# ...)
    0 (x:value)
    _ (let [[head & rest] [...]]
        (run (x.bind head) (unpack rest)))))

(local continue (defmonad :continue (fn [f a] (f a))))
(local result (defmonad :result (fn [_ _ ma] ma)))
(local failure (defmonad :failure (fn [_ _ ma] ma)))

(local uv vim.loop)
(local {: fmt : inspect : pathify} (require :pact.common))
(local {:new new-workflow : halt : event} (require :pact.workflow))
(local {: git : fs} (require :pact.workflow.task))
(local git-commit (require :pact.git.commit))
(local git-provider (require :pact.provider.git))
(local path-provider (require :pact.provider.path))
(local constraint (require :pact.constraint))

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
  ;; Plugin symlink exists on disk, but doesn't resolve to a folder
  (defstruct pact/path-status-workflow/result/broken
    [plugin reason]
    :describe-by [plugin reason]))

(local result-types ((defstruct pact/path-status-workflow/result-types
                       [EXISTS MISSING]
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
    {:type t} (values false t)))

(fn work [plugin-group-root plugin]
  (let [_ (fs.ensure-directory-exists plugin-group-root)
        repo-path (pathify plugin-group-root plugin.id)
        result (run (continue :no-persistent-state)
                   #(match (path-is-link? repo-path)
                      true (continue $1)
                      false (result (new-missing-result :plugin plugin))
                      (nil err) (failure (new-broken-result :plugin plugin
                                                            :reason (fmt "was type %s" t))))
                   #(match (links-to-dir? repo-path)
                      true (result (new-exists-result :plugin plugin))
                      (false t) (failure (new-broken-result :plugin plugin
                                                            :reason (fmt "link exists but resolves to %s" t)))))]
    (halt result)))

(fn new [plugin-group-root plugin]
  (let [path-plugin (require :pact.provider.path)
        _ (expect (= path-plugin.type (typeof plugin))
                  internal "status path workflow must be given path plugin")
        id (.. :git-status- plugin.id)
        f #(work plugin-group-root plugin)]
    (new-workflow id f)))

{: new}
