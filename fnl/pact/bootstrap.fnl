;; Go from "install instructions" to "usable pact"
;;
;; Should be run via :Pact bootstrap <source-dir>

;; require pact to create preloaded config module
(local pact (require :pact))

(local fmt string.format)

(λ mkdir [path]
  (let [p (vim.fs.normalize path)]
    (vim.notify (fmt "mkdir %s" p)
                vim.log.levels.INFO)
    (assert (= 1 (vim.fn.mkdir p :p)) (fmt "Could not create dir %s" p))))

(λ symlink [target name]
  (vim.notify (fmt "link %s -> %s" name target)
              vim.log.levels.INFO)
  (assert (vim.loop.fs_symlink target name)))

(λ bootstrap [pactstrap-path]
  (let [config (require :pact.config)
        pactstrap-path (vim.fs.normalize pactstrap-path)
        t-1-path (.. config.path.data :/1)
        start-path (.. t-1-path :/start)
        opt-path (.. t-1-path :/opt)
        source-path (match (vim.fs.find "pact.nvim" {:path pactstrap-path
                                                         :type :directory})
                      [path] path
                      _ (error (fmt (.. "Could not find pact.nvim dir "
                                        "inside %s to bootstrap with")
                                    pactstrap-path)))]
    ;; this is all done manually because the core modules expect to be under
    ;; task supervision. ideally they would one day support running in and out
    ;; of a coroutine context and just force synchronisity when needed.
    (assert (vim.loop.fs_stat source-path)
            (fmt "Source path did not exist: %s. Unable to bootstrap." source-path))
    (each [_ p (ipairs [config.path.data config.path.runtime start-path])]
      (mkdir p))

    ;; link transaction-1 to HEAD
    (symlink t-1-path config.path.head)

    ;; link rtp/start|opt -> HEAD/start|opt
    (each [_ fix (ipairs [:/start :/opt])]
      (symlink (.. config.path.head fix)
               (.. config.path.runtime fix)))

    ;; copy pact into real pact
    (let [src source-path
          dest (fmt "%s/start/pact.nvim" t-1-path)]
      (vim.notify (fmt "copy %s -> %s" src dest)
                  vim.log.levels.INFO)
      (vim.fn.system [:cp :-r src dest]))

    ;; rm pactstrap
    (let [src pactstrap-path]
      (vim.notify (fmt "remove %s" src)
                  vim.log.levels.INFO)
      (vim.fn.system [:rm :-rf src]))

    (vim.cmd "packloadall!")

    (vim.notify (.. "pact.nvim was bootstrapped!\n"
                    "You will be prompted to install pact the first time you run :Pact to finalise the installation\n")
                 vim.log.levels.INFO)))
