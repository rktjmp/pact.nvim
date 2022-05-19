(import-macros {: raise : expect} :pact.error)
(local {: inspect : is-a : fmt : view} (require :pact.common))

(local registry {})

(fn assert-subscriber [subscriber]
  (expect (and (= :table (type subscriber))
               (not (= nil subscriber.__id))
               (= :thread (type subscriber.thread)))
          argument "invalid subscriber given, must be actor"))

(fn assert-topic [topic]
  (expect (or (and (= :table (type topic))
                   (not (= nil topic.__id)))
              (= :string (type topic)))
          argument (fmt "pubsub topic must have __id or be a string, got %s" topic)))

(fn topic->id [topic]
  (match (type topic)
    :table topic.__id
    :string topic))

(fn topic-subscribers [topic-id]
  (or (. registry topic-id) []))

(fn subscribe-topic [subscriber topic-id]
  (when (= nil (. registry topic-id))
    (tset registry topic-id []))
  (let [subs (topic-subscribers topic-id)
        exists? (accumulate [found nil _ sub (ipairs subs) :until found]
                            (= sub subscriber))]
    (when (not exists?)
      (table.insert subs subscriber))))

(fn unsubscribe-topic [subscriber topic-id]
  (let [subs (topic-subscribers topic-id)
        updated-subs (icollect [_ existing-sub (ipairs subs)]
                               (if (not (= existing-sub.__id subscriber.__id))
                                 (values existing-sub)))]
    (if (= 0 (length updated-subs))
      (tset registry topic-id nil)
      (tset registry topic-id updated-subs))))

;; Public API

(fn send [actor ...]
  (expect (not (= nil actor))
          argument "send to argument must not be nil")
  (expect (= (is-a actor.__id) :monotonic-id)
          argument "send to argument must have id")
  (expect (and (not (= nil actor.thread))
               (= :thread (type actor.thread)))
          argument "send to must have thread attr")
  (expect (not (= :dead (coroutine.status actor.thread)))
          argument "send to must have alive thread")
  ;; resume coroutine but propagate any errors up as if they occured naturally
  (match [(coroutine.resume actor.thread ...)]
    [false err] (error err)
    [true & val] (values (unpack val))))

(fn subscribe [subscriber topic]
  (assert-subscriber subscriber)
  (assert-topic topic)
  (subscribe-topic subscriber (topic->id topic)))

(fn unsubscribe [subscriber topic]
  (if (= true topic)
    (do
      (assert-subscriber subscriber)
      (each [topic-id _ (pairs registry)]
        (unsubscribe-topic subscriber topic-id)))
    (do
      (assert-subscriber subscriber)
      (assert-topic topic)
      (unsubscribe-topic subscriber (topic->id topic)))))

(fn broadcast [topic ...]
  (assert-topic topic)
  (let [topic-subs (topic-subscribers (topic->id topic))
        ;; clone out subs as messages may impact subscriber list and those
        ;; added while this broadcast is occuring should not receive the
        ;; message.
        targets (icollect [_ sub (ipairs topic-subs)]
                          (values sub))]
    (each [_ sub (ipairs targets)]
      (send sub topic ...))))

{: subscribe
 : unsubscribe
 : broadcast
 : send
 : registry}
