(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use enum :pact.lib.ruin.enum
     inspect :pact.inspect
     scheduler :pact.workflow.scheduler
     {: subscribe : unsubscribe} :pact.pubsub
     {: ok? : err?} :pact.lib.ruin.result
     result :pact.lib.ruin.result
     api vim.api
     {:format fmt} string
     {: abbrev-sha} :pact.git.commit
     orphan-find-wf :pact.workflow.orphan.find
     orphan-remove-fw :pact.workflow.orphan.remove
     status-wf :pact.workflow.git.status
     clone-wf :pact.workflow.git.clone
     sync-wf :pact.workflow.git.sync
     diff-wf :pact.workflow.git.diff)

(local M {})

(fn section-title [section-name]
  (or (. {:error "Error"
          :waiting "Waiting"
          :active "Active"
          :held "Held"
          :updated "Updated"
          :up-to-date "Up to date"
          :unstaged "Unstaged"
          :staged "Staged"} section-name)
      section-name))

(fn highlight-for [section-name field]
  ;; my-section,  -> PactMySectionTitle
  (let [joined (table.concat  [:pact section-name field] "-")]
    (enum.reduce #(.. $1 (string.upper $2) $3)
                 "" #(string.gmatch joined "(%w)([%w]+)"))))

(fn lede []
  [[[";; 🔪🩸🐐" :PactComment]]
   [["" :PactComment]]])

(fn usage []
  [[[";; Usage:" :PactComment]]
   [[";;" :PactComment]]
   [[";;   s  - Stage plugin for update" :PactComment]]
   [[";;   u  - Unstage plugin" :PactComment]]
   [[";;   cc - Commit staging and fetch updates" :PactComment]]
   [[";;   =  - View git log (staged/unstaged only)" :PactComment]]
   [["" nil]]])

(fn rate-limited-inc [[t n]]
  ;; only increment n at a fixed fps
  ;; uv.now increments only at the event loop start, but this is ok for us.
  (let [every-n-ms (/ 1000 6)
        now (vim.loop.now)]
    (if (< every-n-ms (- now t))
      [now (+ n 1)]
      [t n])))

(fn progress-symbol [progress]
  (match progress
    nil " "
    [_ n] (let [symbols [:◐ :◓ :◑ :◒]]
            (.. (. symbols (+ 1 (% n (length symbols)))) " "))))

(fn workflow-symbol []
  "⧖")

(fn render-section [ui section-name previous-lines]
  (let [relevant-plugins (->> (enum.filter #(= $2.state section-name) ui.plugins-meta)
                              (enum.map #$2)
                              (enum.sort$ #(<= $1.order $2.order)))
        new-lines (enum.reduce (fn [lines i meta]
                                 (let [name-length (length meta.plugin.name)
                                       line [[meta.plugin.name
                                              (highlight-for section-name :name)]
                                             [(string.rep " " (- (+ 1 ui.layout.max-name-length) name-length))
                                              nil]
                                             [(progress-symbol meta.progress)
                                              (highlight-for section-name :name)]
                                             [(or meta.text "did-not-set-text")
                                              (highlight-for section-name :text)]]]
                                   ;; todo ugly way to set offsets here
                                   (set meta.on-line (+ 2 (length previous-lines) (length lines)))
                                   (enum.append$ lines line)))
                               [] relevant-plugins)]
    (if (< 0 (length new-lines))
      (-> previous-lines
          (enum.append$ [[(.. "" (section-title section-name))
                          (highlight-for section-name :title)]
                         [" " nil]
                         [(fmt "(%s)" (length new-lines)) :PactComment]])
          (enum.concat$ new-lines)
          (enum.append$ [["" nil]]))
      (values previous-lines))))

(fn log-line-breaking? [log-line]
  ;; matches break breaking, might be over-eager
  (not-nil? (string.match (string.lower log-line) :break)))

(fn log-line->chunks [log-line]
  (let [(sha log) (string.match log-line "(%x+)%s(.+)")]
    [["  " :comment]
     [(abbrev-sha sha) :comment]
     [" " :comment]
     [log (if (log-line-breaking? log) :DiagnosticError :DiagnosticHint)]]))

(fn output [ui]
  (let [sections [:error :active :unstaged :staged :waiting :updated :held :up-to-date]
        lines (-> (enum.reduce (fn [lines _ section] (render-section ui section lines))
                           (lede) sections)
                  (enum.concat$ (usage)))
        ;; pretty gnarly, we want to split the line data out into just flat text
        ;; to be inserted into the buffer, and a list of [start stop highlight] 
        ;; groups for extmark highlighting.
        lines->text-and-extmarks (enum.reduce
                                  (fn [[str extmarks] _ [txt ?extmarks]]
                                    [(.. str txt)
                                     (if ?extmarks
                                       (enum.append$ extmarks [(length str) (+ (length str) (length txt)) ?extmarks])
                                       extmarks)]))
        [text extmarks] (enum.reduce (fn [[lines extmarks] _ line]
                                      (let [[new-lines new-extmarks] (lines->text-and-extmarks ["" []] line)]
                                        [(enum.append$ lines new-lines)
                                         (enum.append$ extmarks new-extmarks)]))
                                    [[] []] lines)]
    (when (enum.any? #(string.match $2 "\n") text)
      (print "pact.ui text had unexpected new lines")
      (print (vim.inspect text)))
    (api.nvim_buf_set_option ui.buf :modifiable true)
    (api.nvim_buf_set_lines ui.buf 0 -1 false text)
    (api.nvim_buf_set_option ui.buf :modifiable false)
    (enum.map (fn [i line-marks]
                (enum.map (fn [_ [start stop hl]]
                            (api.nvim_buf_add_highlight ui.buf ui.ns-id hl (- i 1) start stop))
                          line-marks))
              extmarks)
    (enum.map #(if $2.log-open
                 (api.nvim_buf_set_extmark ui.buf ui.ns-id (- $2.on-line 1) 0
                                           {:virt_lines (enum.map #(log-line->chunks $2)
                                                                  $2.log)}))
              ui.plugins-meta)))

(fn schedule-redraw [ui]
  ;; asked to render, we only want to hit 60fps otherwise we can really pin
  ;; with lots of workflows pinging back to us.
  (local rate (/ 1000 30))
  (when (< (or ui.will-render 0) (vim.loop.now))
    (tset ui :will-render (+ rate (vim.loop.now)))
    (vim.defer_fn #(output ui) rate)))

(fn exec-commit [ui]
  (fn make-wf [how plugin action-data]
    (let [wf (match how
               :clone (clone-wf.new plugin.id plugin.package-path (. plugin.source 2) action-data.sha)
               :sync (sync-wf.new plugin.id plugin.package-path action-data.sha)
               :clean (orphan-remove-fw.new plugin.id action-data)
               other (error (fmt "unknown staging action %s" other)))
          meta (. ui :plugins-meta plugin.id)
          _ (set meta.workflow wf)
          handler (fn* handler
                       (where [event] (ok? event))
                       (do
                         (enum.append$ meta.events event)
                         (set meta.state :updated)
                         (set meta.text (fmt "(%s %s)"
                                             (match how
                                               :clone :cloned
                                               :sync :synced
                                               :clean :cleaned
                                               _ how)
                                             action-data))
                         (set meta.workflow nil)
                         (set meta.progress nil)
                         (vim.schedule
                           (fn after-handler []
                             (vim.cmd "packloadall!")
                             (vim.cmd "silent! helptags ALL")
                             (when plugin.after
                               (let [{: new} (require :pact.workflow.after)
                                     old-text meta.text
                                     after-wf (new wf.id plugin.after plugin.package-path)]
                                 (set meta.text "running...")
                                 (set meta.workflow after-wf)
                                 (subscribe after-wf
                                            (fn [event]
                                              (match event
                                                ;; handle ok and err events specially as we don't want
                                                ;; to swap sections etc.
                                                (where _ (ok? event))
                                                (do
                                                  (set meta.text (fmt "%s after: %s"
                                                                      old-text
                                                                      (or (result.unwrap event)
                                                                          "finished with no value")))
                                                  (set meta.progress nil)
                                                  (set meta.workflow nil)
                                                  (unsubscribe after-wf after-handler)
                                                  (schedule-redraw ui))
                                                (where _ (err? event))
                                                (do
                                                  (set meta.text (.. old-text (fmt " error: %s" (inspect (result.unwrap event)))))
                                                  (set meta.progress nil)
                                                  (set meta.workflow nil)
                                                  (unsubscribe after-wf after-handler)
                                                  (schedule-redraw ui))
                                                ;; we can pass these up to
                                                ;; the normal handler for
                                                ;; sting logging and
                                                ;; progress meter
                                                (where _ (string? event))
                                                (handler (fmt "after: %s" event))
                                                (where _ (thread? event))
                                                (handler event))))
                                 (scheduler.add-workflow ui.scheduler after-wf)))))
                         (unsubscribe wf handler)
                         (schedule-redraw ui))

                       (where [event] (err? event))
                       (let [[_ e] event]
                         (enum.append$ meta.events event)
                         (set meta.state :error)
                         (set meta.text e)
                         (set meta.progress nil)
                         (unsubscribe wf handler)
                         (schedule-redraw ui))

                       (where [msg] (string? msg))
                       (do
                         (enum.append$ meta.events msg)
                         (set meta.text msg)
                         (set meta.progress nil)
                         (schedule-redraw ui))

                       (where [future] (thread? future))
                       (do
                         (set meta.progress (rate-limited-inc (or meta.progress [0 0])))
                         (schedule-redraw ui))

                       (where _)
                       nil)]
      (subscribe wf handler)
      (values wf)))

  (->> (enum.filter #(and (= :unstaged $2.state)) ui.plugins-meta)
       (enum.map (fn [_ meta] (tset meta :state :held))))
  (->> (enum.filter #(and (= :staged $2.state) ) ui.plugins-meta)
       (enum.map (fn [_ meta]
                   (let [wf (make-wf (. meta.action 1) meta.plugin (. meta.action 2))]
                     (set meta.workflow wf)
                     (scheduler.add-workflow ui.scheduler wf)
                     (tset meta :state :active)))))
  (schedule-redraw ui))

(fn exec-diff [ui meta]
  (fn make-wf [plugin commit]
    (let [wf (diff-wf.new plugin.id plugin.package-path commit.sha)
          previous-text meta.text
          meta (. ui :plugins-meta plugin.id)
          handler (fn* handler
                       (where [event] (ok? event))
                       (let [[_ log] event]
                         (enum.append$ meta.events event)
                         (set meta.text previous-text)
                         (set meta.progress nil)
                         (set meta.log log)
                         (set meta.log-open true)
                         (set meta.workflow nil)
                         (unsubscribe wf handler)
                         (schedule-redraw ui))

                       (where [event] (err? event))
                       (let [[_ e] event]
                         (enum.append$ meta.events event)
                         (set meta.text e)
                         (set meta.progress nil)
                         (set meta.workflow nil)
                         (unsubscribe wf handler)
                         (schedule-redraw ui))

                       (where [msg] (string? msg))
                       (let [meta (. ui :plugins-meta wf.id)]
                         (enum.append$ meta.events msg)
                         (tset meta :text msg)
                         (schedule-redraw ui))

                       (where [future] (thread? future))
                       (do
                         (set meta.progress (rate-limited-inc (or meta.progress [0 0])))
                         (schedule-redraw ui))

                       (where _)
                       nil)]
      (subscribe wf handler)
      (values wf)))
  (let [wf (make-wf meta.plugin (. meta.action 2))]
    (set meta.workflow wf)
    (scheduler.add-workflow ui.scheduler wf))
  (schedule-redraw ui))

(fn exec-orphans [ui meta]
  (let [start-root (.. (vim.fn.stdpath :data) :/site/pack/pact/start)
        opt-root (.. (vim.fn.stdpath :data) :/site/pack/pact/opt)
        known-paths (enum.map #$2.package-path ui.plugins)]
    (fn make-wf [id root]
      (let [wf (orphan-find-wf.new id root known-paths)
            handler (fn* handler
                         (where [event] (ok? event))
                         (do
                           (match (result.unwrap event)
                             (where list (not (enum.empty? list)))
                             (enum.each #(let [plugin-id (fmt "orphan-%s" $1)
                                               name (fmt "%s/%s" id $2.name)
                                               len (length name)]
                                             (tset ui.plugins-meta
                                                 plugin-id
                                                 {:plugin {:id plugin-id
                                                           :name name}
                                                  :order (* -1 $1)
                                                  :events []
                                                  :text "(orphan) exists on disk but unknown to pact!"
                                                  :action [:clean $2.path]
                                                  :state :unstaged})
                                             (if (< ui.layout.max-name-length len)
                                               (set ui.layout.max-name-length len)))
                                        list))
                           (unsubscribe wf handler)
                           (schedule-redraw ui))

                         (where [event] (err? event))
                         (do
                           (vim.notify (fmt "error checking for orphans, please report: %s" (result.unwrap event)))
                           (unsubscribe wf handler))

                         (where _)
                         nil)]
        (subscribe wf handler)
        (values wf)))
    (enum.map #(scheduler.add-workflow ui.scheduler (make-wf $1 $2))
              {:start start-root :opt opt-root})))


(fn exec-status [ui]
  (fn make-status-wf [plugin]
    (let [wf (status-wf.new plugin.id
                            (. plugin.source 2)
                            plugin.package-path
                            plugin.constraint)
          meta (. ui :plugins-meta plugin.id)
          handler (fn* handler
                    (where [event] (ok? event))
                    (let [(command ?maybe-latest ?maybe-current) (result.unwrap event)
                          text (-> (match command
                                     [:hold commit] (fmt "(at %s" commit)
                                     [action commit] (fmt "(%s %s" action commit))
                                   (#(match ?maybe-latest
                                       commit (fmt "%s, latest: %s" $1 commit)
                                       nil (fmt "%s" $1)))
                                   (#(match ?maybe-current
                                       commit (fmt "%s, current: %s)" $1 commit)
                                       nil (fmt "%s)" $1))))]
                      (enum.append$ meta.events event)
                      (set meta.text text)
                      (set meta.progress nil)
                      (set meta.workflow nil)
                      (match command
                        [:hold commit] (do
                                         (set meta.state :up-to-date))
                        [action commit] (do
                                          (set meta.state :unstaged)
                                          (set meta.action [action commit])))
                      (unsubscribe wf handler)
                      (schedule-redraw ui))

                    (where [event] (err? event))
                    (do
                      (set meta.state :error)
                      (enum.append$ meta.events event)
                      (set meta.progress nil)
                      (set meta.workflow nil)
                      (set meta.text (result.unwrap event))
                      (unsubscribe wf handler)
                      (schedule-redraw ui))

                    (where [msg] (string? msg))
                    (do
                      (enum.append$ meta.events msg)
                      (set meta.progress nil)
                      (set meta.text msg)
                      (schedule-redraw ui))

                    (where [future] (thread? future))
                    (do
                      (set meta.progress (rate-limited-inc (or meta.progress [0 0])))
                      (schedule-redraw ui))

                    (where _)
                    nil)]
      (subscribe wf handler)
      (values wf)))
  ;; plugins-meta is kv, but we want to run the workflows in order
  (->> (enum.map #$2 ui.plugins-meta)
       (enum.sort$ #(<= $1.order $2.order))
       (enum.map #(let [wf (make-status-wf $2.plugin)]
                    (set $2.workflow wf)
                    (scheduler.add-workflow ui.scheduler wf))))
  (schedule-redraw ui))

(fn exec-keymap-cc [ui]
  (if (enum.any? #(= :staged $2.state) ui.plugins-meta)
    (exec-commit ui)
    (vim.notify "Nothing staged, refusing to commit")))

(fn exec-keymap-s [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (enum.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta (= :unstaged meta.state))
      (do
        (tset meta :state :staged)
        (schedule-redraw ui))
      (vim.notify "May only stage unstaged plugins"))))

(fn exec-keymap-u [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (enum.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta (= :staged meta.state))
      (do
        (tset meta :state :unstaged)
        (schedule-redraw ui))
      (vim.notify "May only unstage staged plugins"))))


(fn exec-keymap-= [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (enum.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta
             (or (= :staged meta.state) (= :unstaged meta.state))
             (= :sync (. meta.action 1)))
      (if meta.log
        (do
          (set meta.log-open (not meta.log-open))
          (schedule-redraw ui))
        (do
          (exec-diff ui meta)))
      (vim.notify "May only view diff of staged or unstaged sync-able plugins"))))

(fn M.attach [win buf plugins opts]
  "Attach user-provided win+buf to pact view"
  (let [opts (or opts {})
        {true ok-plugins false err-plugins} (enum.group-by #(values (result.ok? $2) (result.unwrap $2))
                                                           plugins)]
    ;; warn user which plugins failed
    (if err-plugins
      (-> (enum.reduce (fn [lines _ $2]
                         (enum.append$ lines (fmt "  - %s" $2)))
                       ["Some Pact plugins had configuration errors and wont be processed!"]
                       err-plugins)
          (table.concat "\n")
          (.. "\n")
          (api.nvim_err_writeln)))

    ;; try to run...
    (if ok-plugins
      (let [plugins-meta (-> (enum.map #[$2.id {:events []
                                                :text "waiting for scheduler"
                                                :order $1
                                                :state :waiting
                                                :plugin $2}]
                                       ok-plugins)
                             (enum.pairs->table))
            max-name-length (enum.reduce #(math.max $1 (length $3.name)) 0 ok-plugins)
            ui {:plugins ok-plugins
                : plugins-meta
                : win
                : buf
                :ns-id (api.nvim_create_namespace :pact-ui)
                :layout {: max-name-length}
                :scheduler (scheduler.new {:concurrency-limit opts.concurrency-limit})
                :opts opts}]
        (doto buf
          ;; TODO v mode
          (api.nvim_buf_set_option :modifiable false)
          (api.nvim_buf_set_option :buftype :nofile)
          (api.nvim_buf_set_option :bufhidden :hide)
          (api.nvim_buf_set_option :buflisted false)
          (api.nvim_buf_set_option :swapfile false)
          (api.nvim_buf_set_option :ft :pact)
          (api.nvim_buf_set_keymap :n := "" {:callback #(exec-keymap-= ui)})
          (api.nvim_buf_set_keymap :n :cc "" {:callback #(exec-keymap-cc ui)})
          (api.nvim_buf_set_keymap :n :s "" {:callback #(exec-keymap-s ui)})
          (api.nvim_buf_set_keymap :n :u "" {:callback #(exec-keymap-u ui)}))

        ;; we always default to status ui
        (exec-orphans ui)
        (exec-status ui)
        (values ui))
      (do
        (let [lines [";; 🔪🩸🐐 Pact has no plugins defined!"
                     ";; "
                     ";; See `:h pact-usage`!"]]
          (api.nvim_buf_set_option buf :ft :pact)
          (api.nvim_buf_set_lines buf 0 -1 false lines))))))

(values M)
