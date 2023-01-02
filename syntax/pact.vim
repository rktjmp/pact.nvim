" Vim syntax file
" Language: Pact Plugin UI

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "pact"

syn match PactComment "\v^;;.*$"

" Title -> leading word before list of section
" Name -> the plugin name
" Text -> plain text message associated with plugin

hi def link PactTitle DiagnosticWarn
hi def link PactName Identifier
hi def link PactText DiagnosticInfo
hi def link PactComment @comment
hi def link PactError ErrorMsg

hi def PactColumnHeader ctermfg=8 gui=underline cterm=underline

" generic action groups
" these should look 'potential but not active'
hi def link PactActionCanOk @comment
hi def link PactActionCanDanger @comment
" these should look active
hi def PactActionWillOk  ctermfg=3 guibg=#6be581 guifg=#005E11
hi def link PactActionWillDanger DiagnosticError

hi def link PactActionCanInstall PactActionCanOk
hi def link PactActionCanSync PactActionCanOk
hi def link PactActionCanHold DiagnosticInfo

hi def link PactActionWillInstall PactActionWillOk
hi def link PactActionWillSync PactActionWillOk
hi def link PactActionWillDiscard PactActionWillDanger
hi def link PactActionWillHold DiagnosticInfo

hi def link PactStagedActionSync MoreMsg
hi def link PactStagedActionRetain Question
hi def link PactStagedActionDiscard WarningMsg

" these highlight groups should look inactive as they're only
" referencing a potential action.
hi def link PactUnstagedActionInstall @comment
hi def link PactUnstagedActionSync @comment
hi def link PactUnstagedActionRetain @comment
hi def link PactUnstagedActionDiscard @comment

hi def link PactErrorTitle DiagnosticError
hi def link PactErrorName PactName
hi def link PactErrorText DiagnosticWarn

hi def link PactUnstagedTitle PactTitle
hi def link PactUnstagedName PactName
hi def link PactUnstagedText PactText

hi def link PactStagedTitle PactTitle
hi def link PactStagedName PactName
hi def link PactStagedText PactText

hi def link PactHeldTitle PactTitle
hi def link PactHeldName PactName
hi def link PactHeldText PactText

hi def link PactUpToDateTitle PactTitle
hi def link PactUpToDateName PactName
hi def link PactUpToDateText PactText

hi def link PactActiveTitle PactTitle
hi def link PactActiveName PactName
hi def link PactActiveText PactText

hi def link PactWaitingTitle PactComment
hi def link PactWaitingName PactComment
hi def link PactWaitingText PactComment

hi def link PactUpdatedTitle PactTitle
hi def link PactUpdatedName PactName
hi def link PactUpdatedText PactText

