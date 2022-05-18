" Pass all commands to pact.command
command! -complete=customlist,PactComplete -nargs=* Pact
      \ :Fnl (let [pact (require :pact)] (pact.command <q-args>))

fun PactComplete(A, L, P)
  return v:lua.require('pact')['command-completion'](a:A, a:L, a:P)
endfun
