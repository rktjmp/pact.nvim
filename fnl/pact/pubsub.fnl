(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)
(use enum :pact.lib.ruin.enum)

;; holds list of topics -> callbacks
(local registry {})

;; we collate calls into one vim.schedule callback, so
;; track each bcast call in this until we drain it
(var bcast-queue [])

(fn drain-queue []
  ;; copy queue so any bcasts cant effect the current queue
  (let [current-queue bcast-queue
        _ (set bcast-queue [])]
    (enum.each #(let [{: topic : payload} $2
                      targets (or (. registry topic) [])]
                  (enum.each #($1 (enum.unpack payload))
                             targets))
               current-queue)))

;; public api

(fn* subscribe
  (where [topic-id callback] (function? callback))
  ;; topic subs list is a map to avoid dup subs simply
  (let [topic (or (. registry topic-id) {})]
    (tset topic callback true)
    (tset registry topic-id topic)
    (values true)))

(fn* unsubscribe
  (where [topic-id callback] (function? callback))
  (let [topic (. registry topic-id)]
    (when topic
      (tset topic callback nil)
      (if (enum.empty? topic)
        (tset registry topic-id nil))
      (values true))))

(fn broadcast [topic ...]
  (table.insert bcast-queue {: topic :payload (enum.pack ...)})
  ;; first insert schedules a drain in next event loop
  (if (= 1 (length bcast-queue))
    (vim.schedule drain-queue)))

{: subscribe
 : unsubscribe
 : broadcast}
