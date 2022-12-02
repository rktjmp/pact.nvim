(fn await [[func-name & args]]
  `(let [{:await-wrap await-wrap#} (require :pact.async-await)]
     (await-wrap# ,func-name ,args)))

(fn async [func]
  `(let [{:async-wrap async-wrap#} (require :pact.async-await)]
     (async-wrap# ,func)))

{: async : await}
