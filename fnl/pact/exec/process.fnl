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
      : close : read_start} vim.loop
     {:format fmt} string)

(fn into-table [t]
  (fn [err data]
    (when err
      (error err))
    (when data
      (table.insert t data))))

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
                  (close stdout)
                  (close stderr)
                  (on-exit code
                           (stream->lines out-bytes)
                           (stream->lines err-bytes)))))
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
        (read_start stdout (into-table out-bytes))
        (read_start stderr (into-table err-bytes))
        (values pid)))))

(fn string->spawn-args [cmd-str opts]
  (let [parts (->> (E.map #$1 #(string.gmatch cmd-str "(%S+)"))
                   (E.map #(match (string.match $2 "^(%$+)([%w-]+)$")
                             (prefix name) (match [prefix (. opts name)]
                                             [:$ val] val
                                             [:$ nil] (error (fmt "Could not construct command `%s`, `%s` not in substitution table" cmd-str name))
                                             _ (.. (string.sub prefix 1 -2) name))
                             _ $2)))]
    [(E.hd parts) (E.tl parts) (or opts.cwd ".") (or opts.env {})]))

(fn run [cmd opts on-exit]
  (assert (string? cmd) "must provide command string")
  (assert (table? opts) "must provide opts table")
  (assert (function? on-exit) "must provide on-exit function")
  (let [args (-> (string->spawn-args cmd opts)
                 (E.append$ on-exit))]
    (exec (E.unpack args))))

(fn cb->await [func argv]
  ;; TODO, should be func ... so we can accurately parse nil? upstream into ruin
  ;; Must be called inside a coroutine.
  ;;
  ;; Must be passed a function that accepts an async callback.
  ;;
  ;; Creates a co-routine that suspends itself after calling the given
  ;; function, and then un-suspends itself after the async callback occurs.
  ;; When it suspends, it returns its own coroutine, which can be treated as a
  ;; spin on a future/promise.
  ;;
  ;; Since the async callback resumes the suspended coroutine, we can check the
  ;; status of that coroutine to get the status of the "promise". When its
  ;; suspended or running, the value isn't resolved, when it's "dead", that
  ;; means the async callback has completed.
  ;;
  ;; This comes together with the second step, that (await ...) *also* suspends
  ;; the main coroutine, when it returns the "promise" to the scheduler. When
  ;; the scheduler sees the promise is resolved, it can resume the main
  ;; workflow coroutine.
  ;;
  ;; Once resumed, the final value can be returned to the main coroutine as if
  ;; it had been a syncronous call.
  ;;
  ;; This could also (probably simplerly) done with an actual {:promise} table
  ;; being passed around but this is a bit of an experiment.
  ; (expect (= :function (type func)) "must be a function")
  (assert (coroutine.running) "must call await inside (async ...)")
  (local co coroutine)
  (var awaited-value nil)

  (fn create-thread [func argv]
    (let [await-co (co.running)
          resolve-future (fn [...]
                           ;; store the return value
                           (set awaited-value (E.pack ...))
                           ;; kill our future
                           (co.resume await-co))
          _ (table.insert argv resolve-future)
          ;; this *can* throw, which we will rethrow
          ;; nil, x is caught and returned as nil, ex
          ;; any other value is returned as thread, x
          first-return (E.pack (func (E.unpack argv)))]
      (match first-return
        ;; assume nil + x is an error internally and we should not proceed
        [nil & rest] (E.unpack first-return)
        ;; otherwise assume we're ok to "thread"
        ;; now suspend this coroutine, as a future, when the future resumes
        ;; itself, we will terminate and the future will be "dead" at which
        ;; point we know we can resume the main coroutine.
        _ (co.yield await-co (E.unpack first-return)))))
  (let [await-co (co.create create-thread)
        vals (E.pack (co.resume await-co func argv))]
    (match vals
      ;; internal error when running function, so behave the same
      [false err] (error err)
      ;; "error like" return, so assume thread failed. Repack values
      ;; and continune on to return them.
      [true nil & rest] (set awaited-value (E.pack (E.unpack vals 2)))
      ;; got thread, so we can suspend ourselves
      (where [true thread & rest] (thread? thread)) (co.yield (E.unpack vals 2)))
    ;; once we're resumed, when the "future" becomes "dead" and the scheduler
    ;; has picked up again, we can return the sticky value set in the thread.
    (values (E.unpack awaited-value))))

{: run
 : cb->await}
