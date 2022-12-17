(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     uv vim.loop
     api vim.api
     {:format fmt} string)

(local Log {})

(fn Log.new-log-file [path]
  (match-let [fd (uv.fs_open path "w" 384)]
     (set Log.fd fd)
     (else
       (nil err) (print :no-log err))))

(fn Log.log [data ?tag ?location]
  (let [inspect (require :pact.inspect)
        data (inspect data)]
    (uv.fs_write Log.fd data)
    (uv.fs_write Log.fd "\n")
    (uv.fs_fsync Log.fd)))

Log
