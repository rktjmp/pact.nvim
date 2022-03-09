(import-macros {:describe describe} :fnl_spec.macro)

(local {: git} (require :pact.provider.git))

(describe
  "git provider"
  (it "requires a url and version or options table"
      (assert.has_error (fn [] (git)))
      (assert.has_error (fn [] (git "http://my-host/my-repo.nvim")))
      (assert.has_error (fn [] (git "http-bad-url-my-host-my-repo.nvim" "= 1.0")))
      (assert.not.has_error (fn [] (git "http://my-host/my-repo.nvim" "= 1.0.0")))
      (assert.not.has_error (fn [] (git "http://my-host/my-remo.nvim" {:branch :master}))))

  (it "extracts an id or accepts one"
      (let [g (git "https://my-host.com/my/path/to/my-plugin.nvim" "= 1.0")]
        (assert.equal g.id "my-plugin.nvim"))
      (let [g (git "https://my-host.com/my/path/to/my-plugin.nvim" {:version "= 1.0" :id :my-custom})]
        (assert.equal g.id "my-custom"))))
