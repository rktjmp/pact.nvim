(import-macros {: raise : expect} :pact.error)

(local uv vim.loop)
(local {: inspect : fmt : pathify} (require :pact.common))

(fn what-is-at [path]
  (match (uv.fs_stat path)
    ({: type}) (values type)
    (nil _ :ENOENT) (values :nothing)
    (nil err _) (values nil (fmt "uv.fs_stat error %s" err))))

(fn ensure-directory-exists [path]
  (fn make-recursively [full-path]
    (accumulate [partial-path "/" part (string.gmatch full-path "/([^/]+)")]
      (let [next-dir (pathify partial-path part)]
        (match (what-is-at next-dir)
          :nothing (match (uv.fs_mkdir next-dir 493)
                     (nil err) (error err))
          :directory true
          (nil err) (error err)
          any (raise argument
                     (fmt "could not create directory %q exists, already %q"
                          next-dir any)))
        (values next-dir))))

  (match (what-is-at path)
    :nothing (make-recursively path)
    :directory (values path)
    (nil err) (raise internal (fmt "could not ensure %q exists, %q" path err))
    any (raise argument (fmt "could not ensure directory %q exists, already %q"
                             path any))))

{: ensure-directory-exists : what-is-at}
