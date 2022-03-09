;; Error type so we can use more than strings as error descriptors.
;;
;; Use macros when interacting with the error type

(local error-type :error)

(fn __tostring [e]
  (let [{: view} (require :fennel)
        str (.. e.message " [" (view e.context) "]")
        str (string.gsub str "\n" "  ")]
    str))

(fn new [type message context ?trace]
  (let [fennel (require :fennel)
        e {: type : message : context : ?trace :is-a error-type}]
    (setmetatable e {: __tostring})
    ;; Seems that neovim wont use __tostring'd tables when displaying errors
    ;; and instead we get [NULL]
    ;; Also seems that tables cause a segfault, only in the context of pact, maybe because of idle loop?
    ; e.message))
    (tostring e)))
    ; e))

(fn internal [message context]
  (new :internal message context))

(fn argument [message context]
  (new :argument message context))

(fn external [message context]
  (new :external message context))

(fn is-a [e]
  (match e
    {:is-a error-type} true
    _ false))

(fn error->string [err]
  (let [{: fmt} (require :pact.common)]
    (match (is-a err)
      false (match (type err)
              :string err
              _ (tostring err))
      true (fmt "%s" err.message))))

{: internal : argument : external : is-a : error->string}
