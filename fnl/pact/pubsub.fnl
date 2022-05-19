(import-macros {: raise : expect} :pact.error)
(local {: inspect : is-a : fmt : view} (require :pact.common))

(local registry {})

(fn send [to ...]
  (expect (not (= nil to)) argument
          "send to argument must not be nil")
  (expect (= (is-a to.__id) :monotonic-id) argument
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

(fn add-sub [topic-id new-sub]
  (when (= nil (. registry topic-id))
    (tset registry topic-id []))
  (let [subs (. registry topic-id)
        exists? (accumulate [found nil _ sub (ipairs subs) :until found]
                            ;; todo remove when
                  (when (= sub new-sub) true))]
    (when (not exists?)
      (table.insert subs new-sub))))

(fn subscribe-topic [subscriber topic]
  (match (type topic)
    :string  (add-sub topic subscriber)
    :table (add-sub topic.__id subscriber)))

(fn subscribe [subscriber topic]
  (expect (and (= :table (type subscriber))
               (not (= nil subscriber.__id))
               (= :thread (type subscriber.thread)))
          argument "invalid subscriber given, must be actor")
  (expect (or (and (= :table (type topic))
                   (not (= nil topic.__id)))
              (= :string (type topic)))
          argument "subscribe topic must have __id or be a string")
  (subscribe-topic subscriber topic))

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
  (expect (= :monotonic-id (is-a subscriber.__id)) argument
          "subscribe subscriber must have id")
  (expect (= :thread (type subscriber.thread)) argument
          (fmt "subscribe %s must be an actor" subscriber))
  ;; TODO: sub unsub is not symmetric as unsubscribe is greedy
  (match [channel topic]
    [nil nil] (unsubscribe-all subscriber)
    [channel nil] (do
                    (expect (= (is-a channel.__id) :monotonic-id) argument
                            "unsubscribe channel argument must have id")
                    (unsubscribe-channel subscriber channel.__id))
    [channel topic] (do
                      (expect (= (is-a channel.__id) :monotonic-id) argument
                              "unsubscribe channel argument must have id")
                      (expect (= (is-a topic.__id) :monotonic-id) argument
                              "unsubscribe topic argument must have id")
                      (unsubscribe-channel-topic subscriber channel.__id topic.__id))))

;; TODO: allow nil/true topic? Ok to just blast out a channel?
(fn broadcast [channel topic ...]
  (expect (= (is-a channel.__id) :monotonic-id) argument
          "broadcast channel argument must have id")
  (expect (= (is-a topic.__id) :monotonic-id) argument
          "broadcast topic argument must have id")
  (let [topic-subs (channel-topic-subscribers channel.__id topic.__id)
        channel-subs (channel-topic-subscribers channel.__id true)]
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
