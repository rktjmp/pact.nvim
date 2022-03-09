(local {: git-host} (require :pact.provider.git_host))

(fn github [user-repo semver-or-opts]
  (git-host :github "https://github.com/" user-repo semver-or-opts))

{: github}
