(import-macros {: use} :pact.lib.ruin.use)
(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     {: string? : table? : not-nil?} :pact.lib.ruin.type
     enum :pact.lib.ruin.enum
     {:format fmt} string
     {:loop uv} vim)

(fn what-is-at [path]
  "file, directory, link, nothing or (nil err)"
  (match (uv.fs_stat path)
    ({: type}) (values type)
    (nil _ :ENOENT) (values :nothing)
    (nil err _) (values nil (fmt "uv.fs_stat error %s" err))
    (nil err) (values nil err)))

(fn ensure-directory-exists [path]
  (match (what-is-at path)
    :nothing (match (enum.reduce #(let [target (.. $1 :/ $2)]
                                    (match (what-is-at target)
                                      :nothing (and (uv.fs_mkdir target 493) target)
                                      :directory target
                                      other (enum.reduced [nil (fmt "could not create directory %q exists, already %q"
                                                                    target other)])
                                      (nil err) (enum.reduced [nil err])))
                                 "/" #(string.gmatch path "/([^/]+)"))
               [nil err] (values nil err))
    :directory (values path)
    (nil err) (values nil (fmt "could not ensure %q exists, %q" path err))
    any (values nil (fmt "could not ensure directory %q exists, already %q"
                         path any))))

(fn ls-path [path]
  (let [iter (fn [path]
               (let [fs (uv.fs_scandir path)]
                 (values #(uv.fs_scandir_next fs) path 0)))]
  (enum.map #{:kind $2 :name $1} #(iter path))))

(fn remove-path [path]
  (let [contents (ls-path path)]
    (enum.each #(let [full-path (.. path :/ $2.name)]
                  (match $2
                    {:kind :directory} (remove-path full-path)
                    _ (uv.fs_unlink full-path)))
               contents)
    (uv.fs_rmdir path)))

(fn absolute-path? [path]
  (not-nil? (string.match path "^/")))

(fn dir-exists? [path]
  (= :directory (what-is-at path)))

(fn symlink [target link-name]
  (uv.fs_symlink target link-name))

{: ensure-directory-exists
 : what-is-at
 : ls-path
 : symlink
 :make-path ensure-directory-exists 
 : remove-path
 : absolute-path?
 : dir-exists?}
