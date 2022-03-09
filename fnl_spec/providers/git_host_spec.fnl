(import-macros {: describe} :fnl_spec.macro)

(local {: git-host} (require :pact.provider.git_host))

(describe "git-host provider"
          (it "acts a lot like git"
              (assert.has_error (fn []
                                  (git-host)))
              ; check its internal vs argument
              (assert.has_error (fn []
                                  (git-host :github "https://github.com")))
              (assert.has_error (fn []
                                  (git-host :github "https://github.com"
                                            :my-user_my-repo "= 1.0.0")))
              (assert.not.has_error (fn []
                                      (git-host :github "https://github.com"
                                                :my-user/my-repo "= 1.0.0")))))
