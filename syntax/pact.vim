" Vim syntax file
" Language: Pact Plugin UI

if exists("b:current_syntax")
  finish
endif

syn sync fromstart

syn match pactComment "#.*$"
syn match pactCommandHold "^hold"
syn match pactCommandSync "^sync"
syn match pactCommandClone "^clone"
syn match pactCanSync "can-sync"
syn match pactWillSync "will-sync"
syn match pactInSync "in-sync"

let b:current_syntax = "pact"

hi def link pactComment Comment
hi def link pactCommand Function
hi def link pactCanSync DiffChange
hi def link pactWillSync DiffAdd
hi def link pactInSync Comment
hi def link pactCommandHold Comment
hi def link pactCommandSync Function
hi def link pactCommandClone Function
