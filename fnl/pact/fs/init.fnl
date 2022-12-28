(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     {:format fmt} string
     {:loop uv} vim)

(fn join-path [...]
  (pick-values 1 (-> (E.reduce #(.. $1 "/" $2) [...])
                     (string.gsub ://+ :/))))

(fn what-is-at [path]
  "file, directory, link, nothing or (nil err)"
  (match (uv.fs_stat path)
    ({: type}) (values type)
    (nil _ :ENOENT) (values :nothing)
    (nil err _) (values nil (fmt "uv.fs_stat error %s" err))
    (nil err) (values nil err)))

(fn lstat [path]
  (match (uv.fs_lstat path)
    ({: type}) (values type)
    (nil _ :ENOENT) (values :nothing)
    (nil err _) (values nil (fmt "uv.fs_stat error %s" err))
    (nil err) (values nil err)))

(fn make-path [path]
  (match (what-is-at path)
    :nothing (match (E.reduce #(let [target (.. $1 :/ $2)]
                                 (match (what-is-at target)
                                   :nothing (and (uv.fs_mkdir target 493) target)
                                   :directory target
                                   other (E.reduced [nil
                                                     (fmt "could not create directory %q exists, already %q"
                                                          target
                                                          other)])
                                   (nil err) (E.reduced [nil err])))
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
    (E.map #{:kind $2 :name $1} #(iter path))))

(fn remove-path [path]
  (let [contents (ls-path path)]
    (E.each #(let [full-path (join-path path $.name)]
               (print :rm full-path)
               (match $
                 {:kind :directory} (remove-path full-path)
                 _ (uv.fs_unlink full-path)))
            contents)
    (uv.fs_rmdir path)))

(fn absolute-path? [path]
  (not-nil? (string.match path "^/")))

(fn git-dir? [path]
  (match (what-is-at (.. path "/.git"))
    :directory true ;; git repo
    :file true ;; git worktree
    _ false))

(fn dir-exists? [path]
  (= :directory (what-is-at path)))

(fn symlink [target link-name]
  (uv.fs_symlink target link-name))

{: what-is-at
 : ls-path
 : lstat
 : symlink
 : make-path
 : remove-path
 : absolute-path?
 : git-dir?
 : dir-exists?
 : join-path}
