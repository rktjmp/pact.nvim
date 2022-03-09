" Pass all commands to pact.command
command! -nargs=* Pact
      \ :Fnl (let [pact (require :pact)] (pact.command <q-args>))
