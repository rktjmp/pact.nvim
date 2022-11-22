(fn assoc? [ast]
  (and (table? ast) (not (sequence? ast))))

(fn string? [s]
  (and (= :string (type s)) s))

(fn opt? [s]
  (and true (string.match (tostring s) "^&")))

(fn relative-root [...]
  "Returns relative root modpath. Relative requires are complicated, generally
  you must run this macro in a module root, though the returned value can be
  passed around.

  ```
  (relative-root &from :current.modname)
  ```

  The `&from` option value should be the mod-path of the current module, from
  the \"relative root\".

  Given `/my/module/a`, `/my` is considered our \"root\", 

  ```
  (local root (relative-root &from :my.module.a)) ;; => \"\"
  (require (.. root :. :my.module.b)) ;; my.module.b
  ```

  Which can be concated into `(.. (relative-root &from :my.module-a) :my.module.b)`
  to require correctly.

  Now if embedded in `/project/libs/my/module/a`, 

  ```
  (local root (relative-root &from :my.module.a)) ;; => \"libs\"
  (require (.. root :. :my.module.b)) ;; libs.my.module.b
  ```"
  (local opts (let [argv [...]
                    opts {}]
                (fcollect [i 1 (select :# ...) 2]
                  (let [key (string.gsub (tostring (. argv i)) "^&" "")
                        value (. argv (+ i 1))]
                    (tset opts key value)))
                (values opts)))
  (assert-compile opts.from "must provide &from <current-mod>")
  ;; If a file was run directly, not via require (which passes in modname and path),
  ;; then ... will be nil and string.find will error out.
  ;; This may make rel-require fail invisibly but its an unavoidable side
  ;; effect of how lua is built.
  `(or (let [full-mod-path# ...]
         (match full-mod-path#
           (where path# (= :string (type path#)))
           (if (string.find full-mod-path# ,opts.from)
             ;; we may actually be in the root, which means this wont match, but we just want to
             ;; set the root to ""
             (match (string.match full-mod-path# (.. "(.+%.)" ,opts.from))
               nil ""
               root# (values root#))
             ;; Here we *did* have a modpath, but we could not find the context
             ;; string inside it, which is just a configuration error where we
             ;; were given the wrong context mod path.
             (error (string.format "relative-root: no match in &from %q for %q" full-mod-path# ,opts.from)))
           nil ""))
      ""))

(fn relative-mod [mod-name ...]
  "Returns mod-path for `mod-name`, relative to `relative-root'. 

  See `relative-root' for details, usage and warnings.

  ```
  (require (relative-mod :enum &from :nested.module))
  ```"
  (local opts (let [argv [...]
                    opts {}]
                (fcollect [i 1 (select :# ...) 2]
                  (let [key (string.gsub (tostring (. argv i)) "^&" "")
                        value (. argv (+ i 1))]
                    (tset opts key value)))
                (values opts)))
  (assert-compile opts.from "must provide &from <current-mod>" mod-name)
  `(.. ,(relative-root `&from opts.from) ,mod-name))


(fn parse-use-args [...]
  ;; Arguments given are sort of free structured, so this is a bit messy.
  ;; Generally we should have a sym|assoc to define binds, then a
  ;; string|sym|list to define the source, then any number of options key-value
  ;; pairs (must have value!).
  ;; So we search through pretty iteratively for now.
  (local parsed [])
  (local args (doto [...] (tset :n (select :# ...))))
  (var (done? pos-in-args) (values false 1))
  (while (not done?)
    ;; grab args after what we've processed so far
    (local slice [(select pos-in-args ...)])
    ;; node we're building
    (local node {:n 0 :raw-binds nil :modules nil :macros nil :source nil :opts {}})
    ;; we need to manually flag that the node is done once the next value
    ;; seems invalid compared to the nodes current state.
    (var node-done? false)
    (each [i v (ipairs slice) &until node-done?]
      ;; We track node.n (number of things processed) to know what we're
      ;; looking for as well as knowing how far to jump ahead on the next
      ;; slice.
      (match node.n
        ;; first element, when valid
        (where 0 (or (sym? v) (assoc? v) (and (list? v) (= `quote (. v 1)))))
        (doto node
          (tset :n (+ node.n 1))
          (tset :raw-binds v))
        ;; first element, invalid
        0
        (assert-compile false "wanted sym or table" v)
        ;; second element, when valid
        (where 1 (or (sym? v) (string? v) (list? v)))
        (do
          ;; Want to do this, but it wont see `string`, because it's not a
          ;; local scope var so in-scope or get-scope wont show it.
          ;; We could look at _G but that's actually the compiler _G, which
          ;; may have `string` but not something like `_G.vim`.
          ;; (if (and (sym? v)) (assert-compile (in-scope? v) "Attempt to bind %s but %s not in scope" v))
          (doto node
            (tset :n (+ node.n 1))
            (tset :source v)))
        ;; second element, invalid
        1
        (assert-compile false "wanted sym got not sym" v)
        ;; grab option kv pairs as they can be found
        (where n (opt? v))
        (do
          (doto node.opts
            (tset (string.gsub (tostring v) "^&" "") (. slice (+ i 1))))
          (doto node
            (tset :n (+ node.n 1))
            (tset :n (+ node.n 1))))
        ;; otherwise assume we're onto the next node
        n
        (do
          (set node-done? true)
          (values node))))
    (table.insert parsed node)
    ;; setup for next slide or stopping
    (set pos-in-args (+ pos-in-args node.n))
    (if (<= args.n pos-in-args)
      (set done? true)))
  (values parsed))

(fn check-rebind [commands]
  (local seen {})
  (fn seen? [ast]
    (let [name (tostring ast)]
      (assert-compile (= nil (. seen name)) "Duplicate use binding" ast)
      (tset seen name true)))
  (each [_ command (ipairs commands)]
    (if (sym? command.modules)
      (seen? command.modules))
    (if (table? command.modules)
      (each [_ bind (ipairs command.modules)]
        (seen? bind)))
    (if (sym? command.macros)
      (seen? command.macros))
    (if (table? command.macros)
      (each [_ bind (ipairs command.macros)]
        (seen? bind)))))

(fn use [...]
  "Multi `require`/`import-macros` macro.

  ```
  (use {:head hd : tail : 'over} :lib.list
       enum :lib.enum
       {: 'pipe} :some.pipe.macro
       {:format fmt} string)
  ```

  Accepts a table of module keys to user symbol names, a module name as a
  string or expression, and a collection of options.

  Bind names prefixed by `'` are treated as macro imports.

  Options:

  `&from :mod.path` -> use relative requires, see `relative-root' `relative-mod'"
  ;; (use {: map : reduce} :enum &from :uuse.nested
  ;;      enum :enum
  ;;      {:format str/fmt} string
  ;;      {: seq? : assoc? : nil?} :type &from :uuse.nested)
  ;;
  ;; sym|table sym|string ?opt-name ?opt-val ...
  (local parsed-args (parse-use-args ...))
  (each [i command (ipairs parsed-args)]
    ;; assoc table for raw binds, split modules and macros
    (match command.raw-binds
      (where binds (assoc? binds))
      (each [key-name bind-name (pairs command.raw-binds)]
        (match bind-name
          ;; bind name is plain symbol, so module import, no need
          ;; to process key-name as fennel has already done this
          (where n (sym? n))
          (tset command :modules (doto (or command.modules {})
                                   (tset key-name bind-name)))
          ;; bind name matches (quote x), which is from 'macro-name,
          ;; we need to unquote it and rebuild the key name and bind-name
          (where n (and (list? n) (= (. n 1) `quote)))
          (do
            (match key-name
              ;; was `: 'x`, and fennel cant create key name for us, so we do it
              (where name (= `: name))
              (tset command :macros (doto (or command.macros {})
                                      (tset (tostring (. bind-name 2)) (. bind-name 2))))
              ;; was :x 'my-x, so key name is fine and but un-quote the bind
              _
              (tset command :macros (doto (or command.macros {})
                                      (tset key-name (. bind-name 2))))))
          _ (assert-compile false "Could not handle bind" bind-name)))
      ;; raw sym, just use as is for module, note we clobber the existing table
      ;; for direct sym
      (where binds (sym? binds))
      (tset command :modules binds)
      (where binds (and (list? binds) (= (. binds 1) `quote)))
      ;; again, 'sym == macro module
      (tset command :macros (. binds 2))
      (where _)
      (assert-compile false "Could not handle bind type" command.raw-binds)))
  (check-rebind parsed-args)
  ;; We've parsed everything out into a reasonable structure, now
  ;; we want to end up with something like
  ;; (local [a b] (do (...) (values a-mod b-mod)))
  ;; If we have macros we actually need to return sequence which will
  ;; end up compiling out into separate lua parts in the correct scope.
  ;; [(import-macros ...)(local ...)]
  (fn command->require [command]
    (let [source-sym (gensym)
          source-expr (match command.source
                        (where source (and (= :string (type source)) command.opts.from))
                        `(require ,(relative-mod source `&from command.opts.from))
                        (where source (= :string (type source)))
                        `(require ,source)
                        (where source (sym? source))
                        `(values ,source)
                        (where source (list? source))
                        `,(macroexpand source)
                        _source
                        (assert-compile false "Unrecognised module bind source type" _source))]
      (values [command.modules source-sym source-expr])))
  (fn command->import-macros [command]
    (let [source-expr (match command.source
                        (where source (and (= :string (type source)) command.opts.from))
                        (relative-mod source `&from command.opts.from)
                        (where source (= :string (type source)))
                        source
                        (where source (list? source))
                        `,(macroexpand source)
                        _source
                        (assert-compile false "Unrecognised macro bind source type" _source))]
      (values [command.macros source-expr])))
  (local module-generation
    (accumulate [code nil  _ command (ipairs parsed-args)]
      (if command.modules
        (let [[binds source expr] (command->require command)
              code (or code `(local () (do (values))))]
          (table.insert (. code 2) binds)
          (table.insert (. code 3) 2 `(local ,source ,expr))
          (table.insert (. code 3 (length (. code 3))) source)
          (values code))
        (values code))))
  (local macro-generation
    (accumulate [code nil _ command (ipairs parsed-args)]
      (if command.macros
        (let [[binds expr] (command->import-macros command)
              code (or code [])]
          (table.insert code `(import-macros ,binds ,expr))
          (values code))
        (values code))))
  (match [module-generation macro-generation]
    [nil nil] nil
    [mods nil] mods
    [nil macs] macs
    [mods macs] (doto macro-generation
                  (table.insert module-generation))))

{: use
 : relative-root
 : relative-mod}
