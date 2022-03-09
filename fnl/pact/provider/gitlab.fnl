(local git-host (require :pact.provider.git_host))

(fn gitlab [user-repo semver-or-opts]
  (git-host :gitlab "https://gitlab.com/" user-repo semver-or-opts))

{:  gitlab}
