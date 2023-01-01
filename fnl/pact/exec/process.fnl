;; Process
;;
;; Managers running a process, opening and closing any STDIO pipes
;; and notifying the caller via callbacks.
;;
;; Uses uv.spawn.

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     inspect :pact.inspect
     {: spawn
      : fs_open : fs_close
      : new_pipe : pipe_open
      : close : read_start
      :is_closing closing?} vim.loop
     {: cb->await} :pact.task
     {:format fmt} string)

(fn into-table [pipe t]
  (fn [err data]
    (match [err data]
      [any _] (error err)
      [_ nil] (close pipe)
      [_ data] (table.insert t data))))

(fn stream->lines [bytes]
  (E.map #$1 #(string.gmatch (table.concat bytes) "[^\r\n]+")))

(fn exec [cmd args cwd env on-exit]
  "spawns a new process"
  (let [stdout (new_pipe)
        stderr (new_pipe)
        [out-bytes err-bytes] [[] []]
        stdio [nil stdout stderr]]
    ;; fiddly trick to get access to process handle in the callback
    (var [process-h pid] [nil nil])
    (set (process-h pid)
         (spawn cmd {: args : cwd : env : stdio}
                (fn [code sig]
                  (close process-h)
                  ;; It's possible to close the read handlers before all data
                  ;; is read. So we do a little check to collect everything.
                  ;; This is cycle-wasteful but generally there should not be
                  ;; much time between the process ending and the read closing.
                  (fn read-until-closed []
                    (if (and (closing? stdout) (closing? stderr))
                      (do
                        (on-exit code
                                 (stream->lines out-bytes)
                                 (stream->lines err-bytes)))
                      (do
                        (vim.defer_fn read-until-closed 10))))
                  (vim.defer_fn read-until-closed 10))))
    (match process-h
      ;; pid is actually an error string in some cases, if the command isn't
      ;; found for example.
      nil
      (values nil (fmt "Could not spawn process, maybe the command wasn't found? %s (for %s)"
                       pid (inspect [cmd args cwd])))
      ;; (on-exit -1 nil pid)
      ;; otherwise assume the process handle is fine and act as normal.
      _
      (do
        (read_start stdout (into-table stdout out-bytes))
        (read_start stderr (into-table stderr err-bytes))
        (values pid)))))

(fn string->spawn-args [cmd-str opts]
  (let [parts (->> (E.map #$ #(string.gmatch cmd-str "(%S+)"))
                   (E.map #(match (string.match $ "^(%$+)([%w-]+)$")
                             (prefix name) (match [prefix (. opts name)]
                                             [:$ val] val
                                             [:$ nil] (error (fmt "Could not construct command `%s`, `%s` not in substitution table" cmd-str name))
                                             _ (.. (string.sub prefix 1 -2) name))
                             _ $)))]
    [(E.hd parts) (E.tl parts) (or opts.cwd ".") (or opts.env {})]))

(fn run [cmd opts on-exit]
  (assert (string? cmd) "must provide command string")
  (assert (table? opts) "must provide opts table")
  (assert (function? on-exit) "must provide on-exit function")
  (let [args (-> (string->spawn-args cmd opts)
                 (E.append$ on-exit))]
    (exec (E.unpack args))))

(fn cb-await-wrap [f argv]
  ;; legacy wrapper for old arg format TODO
  (cb->await f (E.unpack argv)))

{: run
 :cb->await cb-await-wrap}
