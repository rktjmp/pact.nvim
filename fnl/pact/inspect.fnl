(fn inspect [v]
  "inspect with fennel.view or vim.inspect"
  (match (pcall require :fennel)
    (true {: view}) (view v {:one-line? true})
    (false _) (vim.inspect v {:newline ""})))
