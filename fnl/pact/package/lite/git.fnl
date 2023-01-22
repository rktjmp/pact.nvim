(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: ok : err} :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     constraints :pact.package.constraint
     inspect :pact.inspect
     package :pact.package
     {:format fmt} string)

(fn validate-url [url]
  (local protocols [#(string.match url "^http://.+")
                    #(string.match url "^https://.+")
                    #(string.match url "^ssh://.+")])
  (match (E.any? #(not= nil ($1)) protocols)
    true :ok
    false [:error "must be protocol must be http/https/ssh"]))

(fn validate-name [opts]
  (local pat "^[%a%d_%-%./]+$")
  (match-try
    opts.name name
    (not= nil (string.match name pat)) true
    (do :ok)
    (catch
      nil [:error "must provide name"]
      false [:error (.. "name must match " pat)])))

(fn url->name [url]
  ;; When no name is given, we try to get the last section of the url
  (string.match url ".+/(.-)$"))

(fn url->canonical-id [url]
  (let [clean (string.gsub url "[^%w]+" "-")]
    (.. :git- clean)))

(fn translate-constraint [str]
  ;; Constraints come in a semi-structured notation, which we should convert
  ;; into an actual constraint so package doesn't have to deal with it.
  (local git-pat "[%a%d_%-%./]+")
  (local checks (->> [[:head "^%*$" constraints.git.head]
                      ;; TODO: should validate sha is 8 or 40 chars and also
                      ;; push short-sha support stream
                      ;; ^ over @ for fennel :^sha support
                      [:commit "^%^(%x+)$" constraints.git.commit]
                      [:tag (.. "^#([^%^]" git-pat ")$") constraints.git.tag]
                      [:branch (.. "^([^%^]" git-pat ")$") constraints.git.branch]]
                     (E.map (fn [[kind pat make]] [kind #(string.match str pat) make]))))
  (table.insert checks 1 [:version
                          #(constraints.version.str-is-notation? str)
                          constraints.git.version])
  (match (E.reduce (fn [_ [kind is? make]]
                     (match (is?)
                       any (match (make any)
                             val (E.reduced [:ok val])
                             (nil err) [:error err])))
                   :ignored checks)
    nil [:error "could not translate constraint spec"]
     any any))

(fn validate-constraint [opts]
  (match-try
    (or opts.constraint
        opts.version
        opts.branch
        (and opts.tag (.. "#" opts.tag))
        (and opts.commit (.. "^" opts.commit))
        :*) constraint
    (match constraint
      (where str (string? str)) (translate-constraint str)
      _ [:error "invalid constraint"])
    (catch
      [:error e] [:error e]
      nil [:error "must provide constraint"]
      _ [:error "constraint invalid"])))

(fn* git
  "Define a git source. Must be passed a source url and options table which
  must contain at least a :constraint value."
  (where [url opts] (and (string? url) (table? opts)))
  ;; some things we can guess if not set
  (match-try
    (validate-url url) :ok
    (set opts.name (or opts.name (url->name url))) _
    (validate-name opts) :ok
    (validate-constraint opts) [:ok constraint]
    (do
      (set opts.source url)
      (set opts.constraint constraint)
      (set opts.canonical-id (url->canonical-id url))
      (ok opts))
    (catch
      [:error e] (err (fmt "%s %s"
                           (or opts.name
                               opts.url
                               "unknown-package")
                           e))
      _ (err (fmt "%s %s"
                  (or opts.name
                      opts.url
                      "unknown-name")
                  "invalid git plugin spec"))))
  (where _)
  (err "requires url and constraint/options table"))

{: git}
