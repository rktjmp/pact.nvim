(macro c/fn [args ...]
  `(coroutine.wrap (fn ,args
                     ,...)))

(macro c/yield [...]
  `(coroutine.yield ,...))

(macro c/resume [thread ...]
  `(coroutine.resume ,thread ,...))

(fn >> [co ...]
  ;; bored of typing..
  (coroutine.resume co ...))

(fn << [...]
  (coroutine.yield ...))

(fn wrap [...]
  (coroutine.wrap ...))

(fn new [...]
  ;; inline with other pact term
  (coroutine.create ...))

(fn dead? [co]
  (= (coroutine.status co) :dead))

(fn alive? [co]
  (not (dead? co)))

(fn context []
  ;; running too much like "is running?"
  (coroutine.running))

{: >> : << : dead? : alive? : context : wrap : new}
