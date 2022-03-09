(import-macros {:describe describe} :fnl_spec.macro)

(local remotes (require :pact.git.remote_ref))

(local refs ["f7f8f1b67f594fd5c80b5e91cea024ad3ffcff64        refs/heads/3.10.1-post"
             "f299b52f39486275a9e6483b60a410e06520c538        refs/heads/4.17"
             "c84fe82760fb2d3e03a63379b297a1cc1a2fce12        refs/heads/4.17.15-post"
             "10681716750bfbd9ed862817e4dec70963adc492        refs/heads/amd"
             "11eb817cdfacf56c02d7005cbe520ffbeb0fe59a        refs/heads/es"
             "2da024c3b4f9947a48517639de7560457cd4ec6c        refs/heads/master"
             "c6e281b878b315c7a10d90f9c2af4cdb112d9625        refs/heads/npm"
             "aaa111912cb05e6f0f9f23d1eb8a41ccfcf9c2c2        refs/heads/npm-packages"
             "7293355e643c0a5633e25f5bca72b616c367c9f2        refs/pull/1/head"
             "3af557fa9b627633be1b6d3bef80ec93df599e70        refs/pull/1/merge"
             "7bf3df7419b02fc90f283d511f6eff89f31c6d30        refs/pull/1004/head"
             "cb2363b019dcac1cb1b2384e1c24ee9ef69c5639        refs/pull/1004/merge"
             "75f841cf4aad27d4da1e87c78b20e4b20e322811        refs/pull/1005/head"
             "784a7ec006720e5cc2ed5d38cee101793938309d        refs/pull/1006/head"
             "29a238b99b6224361c8a3ccd658006d8f4740f8f        refs/pull/1008/head"
             "ff092afa6f0a50254409264734b8f75d11001bae        refs/pull/1013/head"
             "761a6b026a42f128ecae05cb14861ae783350a0f        refs/tags/0.1.0"
             "e1a6b30a667d59dfc958d9ee99a9347bf9745510        refs/tags/0.10.0"
             "cc1e0308159c899b737345f61ca0cf40b5b50f7a        refs/tags/0.2.0"
             "7ac268039629e2ed5cca0c66f7d9ebcdb2bac265        refs/tags/0.2.1"
             "9bac46864b61fcf50c9f3b1707c71b0a95f601fd        refs/tags/0.2.2"
             "283b3d88742c4358fb0bb7a90458217179d9e726        refs/tags/0.3.0"])
(describe
  "extracting references"
  :setup {:refs refs}
  (it "parses remotes"
      (local parsed (icollect [_ remote (ipairs context.refs)]
                              (remotes.parse remote)))
      (assert.equal (length parsed) 14)
      (local tags (icollect [_ ref (ipairs parsed)]
                            (when (= ref.type :tag) ref)))
      (local branches (icollect [_ ref (ipairs parsed)]
                                (when (= ref.type :branch) ref)))
      (assert.equal (length tags) 6)
      (assert.equal (length branches) 8)))

(describe
  "branches"
  :setup (let [parsed (icollect [_ remote (ipairs refs)]
                                (remotes.parse remote))
               tags (icollect [_ ref (ipairs parsed)]
                              (when (= ref.type :tag) ref))
               branches (icollect [_ ref (ipairs parsed)]
                                  (when (= ref.type :branch) ref))]
           {:remotes parsed :tags tags :branches branches})
  (it "gets branch names"
      (each [_ b (pairs context.branches)]
        (assert.is.string b.name))))

(describe
  "tags"
  (it "gets tag names"
      (let [parsed (icollect [_ remote (ipairs refs)]
                             (remotes.parse remote))
            tags (icollect [_ ref (ipairs parsed)]
                           (when (= ref.type :tag) ref))
            branches (icollect [_ ref (ipairs parsed)]
                               (when (= ref.type :branch) ref))]
        (each [_ t (pairs tags)]
          (assert.is.string t.name))))
  (it "gets tag version"
      (let [parsed (icollect [_ remote (ipairs refs)]
                             (remotes.parse remote))
            tags (icollect [_ ref (ipairs parsed)]
                           (when (= ref.type :tag) ref))
            branches (icollect [_ ref (ipairs parsed)]
                               (when (= ref.type :branch) ref))]
        (each [_ t (pairs tags)]
          (assert.is.table t.version)))))
