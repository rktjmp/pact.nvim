(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {:format fmt} string
     enum :pact.lib.ruin.enum
     inspect :pact.inspect
     {: 'await} :pact.async-await
     {: 'result->> : 'result-> : 'result-let
      : ok : err : result} :pact.lib.ruin.result
     {:new new-workflow : yield} :pact.workflow)

(fn dump-err [code err]
  (fmt "run-error: [%d] %s" code (inspect err)))

(fn run-string [cmd cwd]
  (let [{: run} (require :pact.workflow.exec.process)
        parts (enum.map #$1 #(string.gmatch cmd "(%S+)"))]
    (result-let [_ (yield (fmt "%s" cmd))
                 _ (match (await (run (enum.hd parts) (enum.tl parts) cwd {}))
                     (0 _ _) (values true)
                     (code _ err) (values nil (dump-err code err))
                     (nil er) (values nil er))]
      (ok cmd))))

(fn run-function [func cwd]
  (let [{: run} (require :pact.workflow.exec.process)
        wrapped-run (fn [cmd args ?cwd]
                      (await (run cmd args (or ?cwd cwd) {})))]
    (result (func {:path cwd
                   :run wrapped-run
                   :yield yield}))))

(fn* new
  (where [id cmd cwd] (string? cmd))
  (new-workflow id #(run-string cmd cwd))
  (where [id func cwd] (function? func))
  (new-workflow id #(run-function func cwd)))

{: new}
