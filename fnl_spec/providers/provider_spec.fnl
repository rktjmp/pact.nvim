(import-macros {:describe describe} :fnl_spec.macro)

(local {: new} (require :pact.provider))

(describe
  "provider base"
  (it "builds"
      (let [p (new
                {:id :my_id
                 :add (fn [] :in)
                 :remove (fn [] :out)
                 :update (fn [] :ok)
                 :via :base})]
        (assert.equal p.id :my_id)
        (assert.equal p.via :base)
        (assert.equal (p.add) :in)
        (assert.equal (p.remove) :out)
        (assert.equal (p.update) :ok))))
