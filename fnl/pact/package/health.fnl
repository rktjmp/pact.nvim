(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     {:format fmt} string)

(local Health {})

(fn Health.healthy [] [:healthy])
(fn Health.healthy? [h] (match? [:healthy] h))

(fn Health.degraded [msg] [:degraded msg])
(fn Health.degraded? [h] (match? [:degraded] h))

(fn Health.failing [msg] [:failing msg])
(fn Health.failing? [h] (match? [:failing] h))

(fn Health.update [old new]
  (let [[old-kind & rest-old] old
        [new-kind & rest-new] new
        msgs #(E.concat$ [] rest-new rest-old)
        score #(. {:healthy 0 :degraded 1 :failing 2} $1)]
    (if (< (score old-kind) (score new-kind))
      [new-kind (E.unpack (msgs))]
      [old-kind (E.unpack (msgs))])))

Health
