" Execute file
command! -nargs=* Pact
      \ :Fnl (let [pact (require :pact)] (pact.command <q-args>))
