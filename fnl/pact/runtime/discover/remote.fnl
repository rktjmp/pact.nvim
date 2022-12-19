(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use {: 'result->> : 'result-> : 'result-let
      : ok : err} :pact.lib.ruin.result
     Commit :pact.git.commit
     Git :pact.workflow.exec.git
     FS :pact.workflow.exec.fs
     R :pact.lib.ruin.result
     E :pact.lib.ruin.enum
     PubSub :pact.pubsub
     Package :pact.package
     {:format fmt} string
     {:new new-workflow : yield : log} :pact.workflow)

(local DiscoverRemote {})

(fn group-commits [commits]
  ;; Commits may share the multiple properties so filter each separately vs
  ;; using group-by.
  {:tags (E.filter #(match? {:tag t} $2) commits)
   :branches (E.filter #(match? {:branch t} $2) commits)
   :versions (E.filter #(match? {:version t} $2) commits)})

(fn status-remote [repo-url]
  "Fetch commits from remote and convert into commit datum."
  (result-let [_ (log "querying remote refs from %s" repo-url)
               commits (result->> (Git.ls-remote repo-url)
                                  (Commit.remote-refs->commits))]
    (log "retrieved facts")
    (ok commits)))

(fn status-local [repo-path]
  "Fetch commits from local repo, will update repo refs before hand."
  (result-let [_ (log "updating repository refs")
               _ (Git.update-refs repo-path)
               commits (result->> (Git.ls-local repo-path)
                                  (Commit.local-refs->commits))]
    (log "retrieved facts")
    (ok commits)))


(fn detect-kind [repo-url repo-path]
  (result-> (log "discovering viable commits")
            (or (FS.absolute-path? repo-path)
                (err (fmt "plugin path must be absolute, got %s" repo-path)))
            (#(if (FS.git-dir? repo-path)
                (status-local repo-path)
                (status-remote repo-url)))))

(fn* new
  "Discover git facts about a package. This includes all branches and tags as
  well as the current HEAD. A full list of commits is not returned for
  performance reasons. Packages depending on commit facts must access them
  individually.

  If a package does not exist locally, the remote endpoint is queried instead."
  (where [id repo-url repo-path])
  (new-workflow id #(detect-kind repo-url repo-path)))

(fn DiscoverRemote.workflow [canonical-set path-prefix]
  (let [;; we only need one packge to work on
        package (E.hd canonical-set)
        ;; but need to propagate results to all in the set
        update-siblings #(E.each (fn [_ p] ($1 p)) canonical-set)
        wf (new package.canonical-id
                (Package.source package)
                (FS.join-path path-prefix package.path.head))]
    (update-siblings (fn [package]
                       (Package.track-workflow package wf)))
    (wf:attach-handler
      (fn [commits]
        (update-siblings #(-> $
                              (Package.add-event wf commits)
                              (Package.untrack-workflow wf)
                              (Package.update-commits (R.unwrap commits))
                              (E.set$ :state :unstaged)
                              (PubSub.broadcast (R.ok :facts-updated)))))
      (fn [err]
        (update-siblings #(-> $
                              (Package.add-event wf err)
                              (Package.untrack-workflow wf)
                              (Package.update-commits [])
                              (E.set$ :text (tostring err))
                              ;; TODO
                              (Package.update-health
                                (Package.Health.failing (fmt "E-9999")))
                              ;; TODO wrapping not needed anymore
                              (PubSub.broadcast package (R.err :facts-updated)))))
      (fn [msg]
        (update-siblings #(-> $
                              (Package.add-event wf msg)
                              (E.set$ :text msg)
                              (PubSub.broadcast package :events-changed)))))
    wf))

DiscoverRemote
