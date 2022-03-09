(import-macros {: describe} :fnl_spec.macro)

(describe "pact usage"
          (it "does something"
              (let [pact (require :pact)
                    default (pact.define :default
                                         (pact.github :rktjmp/pact.nvim
                                                      ">= 0.1.0"))]
                (assert.true (pact.has? :default))
                (pact.install :default))))
