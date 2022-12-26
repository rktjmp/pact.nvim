(var id 0)

(fn gen-id [?prefix]
  (set id (+ id 1))
  (if ?prefix
    (string.format "%s#%d" ?prefix id)
    (string.format "%s" id)))

gen-id
