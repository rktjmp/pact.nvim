(fn inspect [v ?one-line]
  "inspect with fennel.view or vim.inspect"
  (match (pcall require :fennel)
    (true {: view}) (view v {:one-line? ?one-line})
    (false _) (vim.inspect v {:newline (if ?one-line "" "\n")})))
