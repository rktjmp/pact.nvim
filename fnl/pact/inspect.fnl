(fn inspect [v ?one-line]
  "inspect with fennel.view or vim.inspect"
  (match (pcall require :fennel)
    (true {: view}) (view v {:one-line? (if (not ?one-line) false true)})
    (false _) (vim.inspect v {:newline (if (not ?one-line) "\n" "")})))
