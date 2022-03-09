(fn await [[func-name & args]]
  `(let [{:await-wrap await-wrap#} (require :pact.async_await_fn)]
     (await-wrap# ,func-name ,args)))

(fn async [func]
  `(let [{:async-wrap async-wrap#} (require :pact.async_await_fn)]
     (async-wrap# ,func)))

{: async : await}
