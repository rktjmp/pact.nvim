(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use inspect :pact.inspect
     {: run : cb->await : 'match-run} :pact.exec
     {:loop uv} vim
     {:format fmt} string)

(local M {})

(fn dump-err [code err]
  (fmt "luarocks-error: return-code: %s std-err: %s" code (inspect err)))

(λ M.install [name version prefix-path]
  (match-run ["luarocks install --tree $prefix-path $name $version"
              {: name : version : prefix-path}]
    (where-ok? [_ lines err]) (vim.pretty_print lines err)
    (where-err? [code out err]) (dump-err code [out err])))

(λ M.search-remote [name ?version]
  (match-run ["luarocks search --porcelain $name $version"
              {: name :version (or ?version "")}]
    (where-ok? [_ lines err]) (vim.pretty_print lines err)
    (where-err? [code out err]) (dump-err code [out err])))

M
