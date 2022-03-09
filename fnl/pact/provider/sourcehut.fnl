(local {: git-host} (require :pact.provider.git_host))

(fn sourcehut [user-repo semver-or-opts]
  (git-host :sourcehut "https://git.sr.ht.com/~" user-repo semver-or-opts))

{: sourcehut :srht sourcehut}
