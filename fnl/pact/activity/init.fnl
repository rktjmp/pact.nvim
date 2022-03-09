(import-macros {: raise : expect} :pact.error)
(local {: inspect} (require :pact.common))

(fn new [initial-state event-handler]
  (fn loop []
    (var loop true)
    (var state initial-state)
    (while loop
      (let [given [(coroutine.yield)]]
        ;; TODO needs to catch true/false val
        (match [(event-handler state given)]
          [false err] (error err)
          [true :halt transition & val]
          (do
            (set loop false)
            ;; somehow transition state
            nil)))))

  (let [thread (coroutine.create loop)
        _ (coroutine.resume thread)]
    (values thread)))

{: new}
