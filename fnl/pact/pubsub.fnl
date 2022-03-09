(import-macros {: raise : expect} :pact.error)
(local {: inspect : is-a : fmt : view} (require :pact.common))

(local registry {})

(fn send [to ...]
  (expect (not (= nil to)) argument
          "send to argument must not be nil")
  (expect (= (is-a to.id) :monotonic-id) argument
          "send to argument must have id")
  (expect (and (not (= nil to.thread)) (= :thread (type to.thread))) argument
          "send to must have thread attr")
  (expect (not (= :dead (coroutine.status to.thread))) argument
          "send to must have alive thread")
  ;; resume coroutine but propagate any errors up as if they occured naturally
  (match [(coroutine.resume to.thread ...)]
    [false err] (error err)
    [true & val] (values (unpack val))))

(fn channel-topic-subscribers [channel-id topic-id]
  (let [subs (-?> registry
                  (. channel-id)
                  (. topic-id))]
    (values (or subs []))))

(fn add-sub [channel-id topic-id new-sub]
  (when (= nil (. registry channel-id))
    (tset registry channel-id []))
  (when (= nil (. registry channel-id topic-id))
    (tset (. registry channel-id) topic-id []))
  (let [subs (. registry channel-id topic-id)
        exists? (accumulate [found nil _ sub (ipairs subs) :until found]
                  (when (= sub new-sub)
                    true))]
    (when (not exists?)
      (table.insert subs new-sub))))

(fn subscribe-channel-topic [subscriber channel topic]
  (expect (= (is-a channel.id) :monotonic-id) argument
          "subscribe channel argument must have id")
  (expect (= (is-a topic.id) :monotonic-id) argument
          "subscribe topic argument must have id")
  (add-sub channel.id topic.id subscriber))

(fn subscribe-channel [subscriber channel]
  (expect (= (is-a channel.id) :monotonic-id) argument
          "subscribe channel argument must have id")
  (add-sub channel.id true subscriber))

(fn subscribe [subscriber channel topic]
  ;; TODO maybe add extra type info to actor to check for?
  ;; aka (is-a sub) :actor, but still have (is-a sub) :pact/status...
  (expect (= :table (type subscriber)) argument
          (fmt "subscribe %s must be table" subscriber))
  (expect (= :monotonic-id (is-a subscriber.id)) argument
          "subscribe subscriber must have id")
  (expect (= :thread (type subscriber.thread)) argument
          (fmt "subscribe %s must be an actor" subscriber))
  (match [channel topic]
    [nil nil] (raise argument (fmt "must give at least channel %s"
                                   subscriber.id))
    [channel nil] (subscribe-channel subscriber channel)
    [channel topic] (subscribe-channel-topic subscriber channel topic)
    _ (raise internal "could not match subscribe request")))

(fn unsubscribe-channel-topic [subscriber channel-id topic-id]
  (let [subs (channel-topic-subscribers channel-id topic-id)
        index (accumulate [found nil i sub (ipairs subs) :until found]
                (when (= sub subscriber)
                  i))]
    (when index
      (table.remove subs index))
    ;; prune empty leafs.
    ;; topic subs is a list, so we can length check a topic and nil it out if
    ;; needed.
    (when (= 0 (length subs))
      (tset (. registry channel-id) topic-id nil))
    ;; channel->topic is a map, so we must actually check for any keys
    (when (accumulate [empty? true _ _ (pairs (or (. registry channel-id) {})) :until (not empty?)]
            false)
      (tset registry channel-id nil))))

(fn unsubscribe-channel [subscriber channel-id]
  (let [tree (. registry channel-id)]
    (each [topic-id subs (pairs tree)]
      (each [index sub (ipairs subs)]
        ;; technically unsafe to do this forward iter, but we should have no
        ;; dup subscribers so this should only effect once.
        (unsubscribe-channel-topic subscriber channel-id topic-id)))))

(fn unsubscribe-all [subscriber]
  (each [channel-id topics (pairs registry)]
    (each [topic-id subs (pairs topics)]
      (unsubscribe-channel-topic subscriber channel-id topic-id))))

(fn unsubscribe [subscriber channel topic]
  (expect (= :table (type subscriber)) argument
          (fmt "subscribe %s must be table" subscriber))
  (expect (= :monotonic-id (is-a subscriber.id)) argument
          "subscribe subscriber must have id")
  (expect (= :thread (type subscriber.thread)) argument
          (fmt "subscribe %s must be an actor" subscriber))
  ;; TODO: sub unsub is not symmetric as unsubscribe is greedy
  (match [channel topic]
    [nil nil] (unsubscribe-all subscriber)
    [channel nil] (do
                    (expect (= (is-a channel.id) :monotonic-id) argument
                            "unsubscribe channel argument must have id")
                    (unsubscribe-channel subscriber channel.id))
    [channel topic] (do
                      (expect (= (is-a channel.id) :monotonic-id) argument
                              "unsubscribe channel argument must have id")
                      (expect (= (is-a topic.id) :monotonic-id) argument
                              "unsubscribe topic argument must have id")
                      (unsubscribe-channel-topic subscriber channel.id topic.id))))

;; TODO: allow nil/true topic? Ok to just blast out a channel?
(fn broadcast [channel topic ...]
  (expect (= (is-a channel.id) :monotonic-id) argument
          "broadcast channel argument must have id")
  (expect (= (is-a topic.id) :monotonic-id) argument
          "broadcast topic argument must have id")
  (let [topic-subs (channel-topic-subscribers channel.id topic.id)
        channel-subs (channel-topic-subscribers channel.id true)]
    (each [_ sub (ipairs topic-subs)]
      (do
        (send sub channel topic ...)))
    (each [_ sub (ipairs channel-subs)]
      (do
        (send sub channel topic ...)))))

{: subscribe
 : unsubscribe
 : broadcast
 : send
 : registry}
