(import-macros {: use} :pact.lib.ruin.use)
(use {: 'fn* : 'fn+} :pact.lib.ruin.fn
     {: string? : table?} :pact.lib.ruin.type
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

{: ensure-directory-exists : what-is-at}
