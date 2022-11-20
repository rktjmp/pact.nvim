(import-macros {: use : relative-mod} (.. (or (-?> ... (string.match "(.+%.)debug")) "") :use))

(local enum-path (relative-mod :enum &from :debug))

(local M {})

(fn M.inspect [...]
  "Lazy-load fennel and fennel.view any number of arguments"
  (use {: pack : unpack} (require enum-path))
  (let [{: view} (require :fennel)
        args (pack ...)
        viewed []]
    (for [n 1 args.n] (table.insert viewed (view (. args n))))
    (unpack viewed)))

(fn M.inspect! [...]
  "Lazy-load fennel and print the fennel.view any number of arguments"
  (print (M.inspect ...))
  (values ...))

(values M)
