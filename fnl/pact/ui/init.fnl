(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use enum :pact.lib.ruin.enum
     inspect :pact.inspect
     scheduler :pact.workflow.scheduler
     {: subscribe : unsubscribe} :pact.pubsub
     {: ok? : err?} :pact.lib.ruin.result
     result :pact.lib.ruin.result
     api vim.api
     FS :pact.workflow.exec.fs
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
  (let [relevant-plugins (->> (enum.filter #(= $2.state section-name) ui.runtime.packages)
                              (enum.map #$2)
                              (enum.sort$ #(<= $1.order $2.order)))
        new-lines (enum.reduce (fn [lines i package]
                                 (let [name-length (length package.name)
                                       line [[package.name
                                              (highlight-for section-name :name)]
                                             [(string.rep " " (- (+ 1 ui.layout.max-name-length) name-length))
                                              nil]
                                             [(progress-symbol package.progress)
                                              (highlight-for section-name :name)]
                                             [(or package.text "did-not-set-text")
                                              (highlight-for section-name :text)]]]
                                   ;; TODO: kind of ugly way to set offsets here
                                   (tset ui.package->line package.id (+ 2
                                                                        (length previous-lines)
                                                                        (length lines)))
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

(fn output-classic [ui]
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
                                       (enum.append$ extmarks [(length str)
                                                               (+ (length str) (length txt))
                                                               ?extmarks])
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
    ; (enum.map #(if $2.log-open
    ;              (api.nvim_buf_set_extmark ui.buf ui.ns-id (- $2.on-line 1) 0
    ;                                        {:virt_lines (enum.map #(log-line->chunks $2)
    ;                                                               $2.log)}))
    ;           ui.plugins-meta)
    ))

(fn output [ui]
  (use R :pact.lib.ruin.result
       E :pact.lib.ruin.enum
       Runtime :pact.runtime)
  (let [data (Runtime.walk-packages ui.runtime
                                    (fn [acc node history]
                                      (if (R.err? node)
                                        (E.append$ acc {:name "Configuration Error"
                                                        :text (R.unwrap node)
                                                        :indent (length history)
                                                        :state :error})
                                        (E.append$ acc {:name node.name
                                                        :text node.text
                                                        :indent (length history)
                                                        :state node.state})))
                                    [])
        lines-with-extmarks  (E.reduce (fn [lines _ {: name : text : indent}]
                                         (E.append$ lines [[(string.rep " " indent) "@comment"]
                                                           [name (highlight-for :staged :name)]
                                                           [(string.rep " " (- (+ 1 ui.layout.max-name-length)
                                                                               (length name)
                                                                               indent))
                                                            :text]
                                                           [text (highlight-for :staged :text)]]))
                                       [] data)
        text-lines (E.map (fn [_ parts]
                            (-> (E.map (fn [_ [text _]] text) parts)
                                (table.concat "")))
                          lines-with-extmarks)]

    (api.nvim_buf_set_lines ui.buf 0 1 false
                            [(fmt "workflows: %s active %s waiting" (-> (Runtime.workflow-stats ui.runtime)
                                                                        (#(values $1.active $1.queued))))])
    (api.nvim_buf_set_lines ui.buf 1 -1 false text-lines)
    (->> (E.map (fn [i parts]
                  (-> (E.reduce (fn [[cursor exts] _ [text hl]]
                                  [(+ cursor (length text))
                                   (E.append$ exts {:line i
                                                    :start cursor
                                                    :stop (+ cursor (length text))
                                                    :hl hl})])
                                [0 []] parts)
                      ((fn [[_ marks]] marks))))
                lines-with-extmarks)
         (E.flatten)
         (E.each (fn [_ {: line : start : stop : hl}]
                   ;; line -0 for wf status, should be -1 normally
                   (api.nvim_buf_add_highlight ui.buf ui.ns-id hl (- line 0) start stop)
                   )))))

(fn schedule-redraw [ui]
  ;; asked to render, we only want to hit 60fps otherwise we can really pin
  ;; with lots of workflows pinging back to us.
  (local rate (/ 1000 30))
  (when (< (or ui.will-render 0) (vim.loop.now))
    (tset ui :will-render (+ rate (vim.loop.now)))
    (vim.defer_fn #(output ui) rate)))

(local exec {})

(fn exec.stage-transaction [ui]
  ;; Every plugin is always staged into a transaction. The checkouts are shared
  ;; between transactions so this is low cost for "not updated" plugins.
  ;; There *is* a difference between a staged and held plugin however, and if
  ;; a held plugin requires updating due to a dependency, then this can fail
  ;; the transaction and the user must re-run and stage the held plugin also.
  (fn make-wf [plugin]
    (let [stage (require :pact.workflow.transaction.stage)
          id (fmt "stage-%s" plugin.id)
          meta (. ui :plugins-meta plugin.id)
          ;; TODO this is really bad, magic getting sha non obvious
          wf (stage.new id ui.transaction plugin (. meta.action 2))
          handler (fn* handler
                       (where [event] (ok? event))
                       (do
                         (vim.pretty_print wf.id event)
                         (unsubscribe wf handler))
                       (where [event] (err? event))
                       (do
                         (unsubscribe wf handler)
                         (error (result.unwrap event)))
                       (where [msg] (string? msg))
                       (vim.pretty_print :close-trans msg)
                       (where _) nil)]
      (subscribe wf handler)
      (scheduler.add-workflow ui.scheduler wf)
      (values wf)))

  (->> (enum.filter #(and (= :unstaged $2.state)) ui.plugins-meta)
       (enum.map (fn [_ meta] (tset meta :state :held))))
  (->> (enum.filter #(and (= :staged $2.state)) ui.plugins-meta)
       (enum.map (fn [_ meta]
                   (let [wf (make-wf (. meta.action 1) meta.plugin (. meta.action 2))]
                     (set meta.workflow wf)
                     (scheduler.add-workflow ui.scheduler wf)
                     (tset meta :state :active)))))
  (schedule-redraw ui))

(fn exec-close-transaction [ui id how]
  (let [{: new} (require :pact.workflow.transaction.close)
        wf (new :close ui.transaction how)
        handler (fn* handler
                  (where [event] (ok? event))
                  (do
                    (vim.pretty_print event)
                    (unsubscribe wf handler))
                  (where [event] (err? event))
                  (do
                    (unsubscribe wf handler)
                    (error (result.unwrap event)))
                  (where [msg] (string? msg))
                  (vim.pretty_print :close-trans msg)
                  (where _) nil)]
    (subscribe wf handler)
    (scheduler.add-workflow ui.scheduler wf)))

(fn exec-open-transaction [ui]
  (let [{: new} (require :pact.workflow.transaction.open)
        root-path (FS.join-path (vim.fn.stdpath :data) :site/pack/pact/data)
        id (vim.loop.gettimeofday)
        wf (new id root-path)
        handler (fn* handler
                  (where [event] (ok? event))
                  (do
                    (unsubscribe wf handler)
                    (set ui.transaction (result.unwrap event))
                    (exec-close-transaction ui true))
                  (where [event] (err? event))
                  (do
                    (unsubscribe wf handler)
                    (error (result.unwrap event)))
                  (where [msg] (string? msg))
                  (vim.pretty_print :open-trans msg)
                  (where _) nil)]
    (subscribe wf handler)
    (scheduler.add-workflow ui.scheduler wf)))

(fn exec-commit [ui]
  (fn make-wf [how plugin action-data]
    (let [wf (match how
               :clone (clone-wf.new plugin.id plugin.path.package (. plugin.source 2) action-data.sha)
               :sync (sync-wf.new plugin.id plugin.path.package action-data.sha)
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

; (fn keymap-stage [ui]
;   (let [plugin (row->plugin-id ui (get-cursor-row))
;         action (Plugin.action plugin)]
;     (action.hold :some-sha)))

; (fn a-status [ui]
;   (E.reduce #(let [Plugin {}
;                    plugin $2
;                    wf (Workflow.Status.new plugin.id)
;                    handler (fn [event]
;                              (match event
;                                (where e (R.result? e))
;                                (do
;                                  ;; prefer Store.update-plugin vs Plugin.event
;                                  ;; because we can encapsulate other state
;                                  ;; changes inside it.
;                                  (Store.update-status ui.store $2.id e)
;                                  (PubSub.unsubscribe handler))
;                                (where msg (string? msg))
;                                (do
;                                  (plugin:log-event msg)
;                                  (Store.update-events ui.store $2.id msg))


                             
;                              )]
;                (pubsub:subscribe wf handler)
;                (ui.scheduler:queue-workflow wf))
;             (ui.store:plugins))

(fn exec-keymap-cc [ui]
  (if (enum.any? #(= :staged $2.state) ui.plugins-meta)
    (exec-open-transaction ui)
    (vim.notify "Nothing staged, refusing to commit")))

(fn exec-keymap-<cr> [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (enum.find-value #(= line $2.on-line) ui.plugins-meta)]
    (match [meta (?. meta :plugin :path :package)]
      [any path] (do
                   (print path)
                   (vim.cmd (fmt ":new %s" path)))
      [any nil] (vim.notify (fmt "%s has no path to open" any.plugin.name))
      _ nil)))

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

(fn prepare-interface [ui]
  (doto ui.win
        (api.nvim_win_set_option :wrap false))
  (doto ui.buf
        (api.nvim_buf_set_option :modifiable false)
        (api.nvim_buf_set_option :buftype :nofile)
        (api.nvim_buf_set_option :bufhidden :hide)
        (api.nvim_buf_set_option :buflisted false)
        (api.nvim_buf_set_option :swapfile false)
        (api.nvim_buf_set_option :ft :pact))
  (doto ui.buf
        (api.nvim_buf_set_keymap :n := "" {:callback #(exec-keymap-= ui)})
        (api.nvim_buf_set_keymap :n :<cr> "" {:callback #(exec-keymap-<cr> ui)})
        (api.nvim_buf_set_keymap :n :cc "" {:callback #(exec-keymap-cc ui)})
        (api.nvim_buf_set_keymap :n :s "" {:callback #(exec-keymap-s ui)})
        (api.nvim_buf_set_keymap :n :u "" {:callback #(exec-keymap-u ui)}))
  ui)

(fn dump [...]
  (let [{: view} (require :fennel)
        all (enum.reduce #(.. $1 (view $3 {:prefer-colon? true
                                           :detect-cylcles false

                                           }))
                         "" [...])]
    (enum.map #$1 #(string.gmatch all "[^\n]+"))))

(fn M.attach [win buf proxies opts]
  "Attach user-provided win+buf to pact view"
  (use R :pact.lib.ruin.result
       E :pact.lib.ruin.enum)
  (let [opts (or opts {})
        Runtime (require :pact.runtime)
        runtime (-> (Runtime.new {:concurrency-limit opts.concurrency-limit})
                    (Runtime.add-proxied-plugins proxies))
        ui (-> {: runtime
                : win
                : buf
                :layout {:max-name-length 1}
                :ns-id (api.nvim_create_namespace :pact-ui)
                :package->line {}
                :errors []}
               (prepare-interface))]
    ;; TODO: render failed plugins into the UI
    ;(->> (E.filter #(R.err? $2) packages)
    ;     (E.each #(table.insert ui.errors (R.unwrap $2))))

    (api.nvim_buf_set_option buf :modifiable true)
    (api.nvim_buf_set_lines buf 0 -1 false (dump runtime.packages))

    ;; TODO unsub all on win close
    ;; TODO: technically we're subbing to err's to here but little effect
    (runtime:walk-packages #(subscribe $1 #(schedule-redraw ui)))
    (set ui.layout.max-name-length
         (runtime:walk-packages (fn [max package]
                                  (if (not (R.err? package))
                                    (if (< max (length package.name))
                                      (length package.name)
                                      max)
                                    max)) 0))

    (Runtime.exec-current-status runtime)
    (schedule-redraw ui)
    ))

    ; (let [topic (Runtime.run-status runtime)]
    ;   (subscribe topic (fn [...] (print :x))))))
      ; (do
      ;   (let [lines [";; 🔪🩸🐐 Pact has no plugins defined!"
      ;                ";; "
      ;                ";; See `:h pact-usage`!"]]
      ;     (api.nvim_buf_set_option buf :ft :pact)
      ;     (api.nvim_buf_set_lines buf 0 -1 false lines))))))

(values M)
