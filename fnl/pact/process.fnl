;; Process
;;
;; Managers running a process, opening and closing any STDIO pipes
;; and notifying the caller via callbacks.
;;
;; Uses uv.spawn.

(import-macros {: raise : expect } :pact.error)
(local {: fmt : inspect} (require :pact.common))
(local {: spawn : fs_open : fs_close : new_pipe : pipe_open : close : read_start} vim.loop)

(fn open-io [log-path]
  (let [log (fs_open log-path :a+ 420)
        pipe (new_pipe)]
    (when (not log)
      (error "log fs open error"))
    (when (not pipe)
      (error "pipe new pipe error"))
    (pipe_open pipe log)
    (values log pipe)))

(fn into-table [t]
  (fn [err data]
    (when err
      (error err))
    (when data
      (table.insert t data))))

(fn stream->lines [bytes]
  (let [t (table.concat bytes)]
    (icollect [line (string.gmatch t "[^\r\n]+")]
      line)))

(fn close-io [log pipe]
  (fs_close log)
  (close pipe))

(fn run [cmd args cwd env on-exit]
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
                  (on-exit code (stream->lines out-bytes)
                           (stream->lines err-bytes)))))
    (match process-h
      ;; pid is actually an error string in some cases, if the command isn't
      ;; found for example.
      nil
      (let [{: view} (require :fennel)]
        (raise argument (fmt (.. "Could not spawn process, "
                                 "maybe the command wasn't found? %s (for %s)")
                             pid (view [cmd args cwd]))))
      ;; (on-exit -1 nil pid)
      ;; otherwise assume the process handle is fine and act as normal.
      _
      (do
        (read_start stdout (into-table out-bytes))
        (read_start stderr (into-table err-bytes))
        (values pid)))))

{: run}
