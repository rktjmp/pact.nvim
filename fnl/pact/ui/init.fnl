(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use enum :pact.lib.ruin.enum
     scheduler :pact.workflow.scheduler
     {: subscribe : unsubscribe} :pact.pubsub
     result :pact.lib.ruin.result
     api vim.api
     {:format fmt} string
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
  [[[";; 🔪🐐🩸" :PactComment]]
   [["" :PactComment]]])

(fn usage []
  [[[";; usage:" :PactComment]]
   [[";;" :PactComment]]
   [[";;   s  - stage plugin for update" :PactComment]]
   [[";;   u  - unstage plugin" :PactComment]]
   [[";;   cc - commit staging and fetch updates" :PactComment]]
   [[";;   =  - view git log (staged/unstaged only)" :PactComment]]
   [["" nil]]])

(fn render-section [ui section-name previous-lines]
  (let [relevant-plugins (->> (enum.filter #(= $2.state section-name) ui.plugins-meta)
                              (enum.map #$2)
                              (enum.sort$ #(<= $1.order $2.order)))
        new-lines (enum.reduce (fn [lines i meta]
                                 (let [name-length (length meta.plugin.name)
                                       line [[meta.plugin.name (highlight-for section-name :name)]
                                             [(string.rep " " (- (+ 1 ui.layout.max-name-length) name-length)) nil]
                                             [(enum.last meta.events) (highlight-for section-name :text)]]]
                                   ;; todo ugly way to set offsets here
                                   (set meta.on-line (+ 2 (length previous-lines) (length lines)))
                                   (enum.append$ lines line)))
                               [] relevant-plugins)]
    (if (< 0 (length new-lines))
      (-> previous-lines
          (enum.append$ [[(section-title section-name)
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
     [sha :comment]
     [" " :comment]
     [log (if (log-line-breaking? log) :DiagnosticError :DiagnosticHint)]]))

(fn output [ui]
  (let [sections [:waiting :error :active :unstaged :staged :updated :held :up-to-date]
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
    (api.nvim_buf_set_lines ui.buf 0 -1 false text)
    (enum.map (fn [i line-marks]
                (enum.map (fn [_ [start stop hl]]
                               (api.nvim_buf_add_highlight ui.buf ui.ns-id hl (- i 1) start stop))
                          line-marks))
              extmarks)
    (enum.map #(if $2.log-open
                 (api.nvim_buf_set_extmark ui.buf ui.ns-id (- $2.on-line 1) 0
                                           {:virt_lines (enum.map #(log-line->chunks $2)
                                                                  $2.log)}))
              ui.plugins-meta)
    ))

(fn exec-commit [ui]
  (fn make-wf [how plugin commit]
    (let [wf (match how
               :clone (clone-wf.new plugin.id plugin.package-path (. plugin.source 2) commit.sha)
               :sync (sync-wf.new plugin.id plugin.package-path commit.sha)
               other (error (fmt "unknown staging action %s" other)))
          handler (fn* handler
                       (where [[:ok]])
                       (let [meta (. ui :plugins-meta plugin.id)]
                         (tset meta :state :updated)
                         (enum.append$ meta.events (fmt "(%s %s)"
                                                        (match how :clone :cloned :sync :synced)
                                                        commit))
                         (unsubscribe wf handler)
                         (output ui))

                       (where [[:err e]])
                       (let [meta (. ui :plugins-meta plugin.id)]
                         (set meta.state :error)
                         (enum.append$ meta.events e)
                         (unsubscribe wf handler)
                         (output ui))

                       (where [msg] (string? msg))
                       (let [meta (. ui :plugins-meta wf.id)]
                         (enum.append$ meta.events msg)
                         (output ui))
                       (where _)
                       nil)]
      (subscribe wf handler)
      (values wf)))

  (->> (enum.filter #(and (= :unstaged $2.state)) ui.plugins-meta)
       (enum.map (fn [_ meta] (tset meta :state :held))))
  (->> (enum.filter #(and (= :staged $2.state) ) ui.plugins-meta)
       (enum.map (fn [_ meta]
                   (let [wf (make-wf (. meta.action 1) meta.plugin (. meta.action 2))]
                     (scheduler.add-workflow ui.scheduler wf)
                     (tset meta :state :active)))))
  (output ui))

(fn exec-diff [ui meta]
  (fn make-wf [plugin commit]
    (let [wf (diff-wf.new plugin.id plugin.package-path commit.sha)
          handler (fn* handler
                       (where [[:ok log]])
                       (let [meta (. ui :plugins-meta plugin.id)]
                         (tset meta :log log)
                         (tset meta :log-open true)
                         (unsubscribe wf handler)
                         (output ui))

                       (where [[:err e]])
                       (let [meta (. ui :plugins-meta plugin.id)]
                         ; (set meta.state :error)
                         (enum.append$ meta.events e)
                         (unsubscribe wf handler)
                         (output ui))

                       (where [msg] (string? msg))
                       (let [meta (. ui :plugins-meta wf.id)]
                         (enum.append$ meta.events msg)
                         (output ui))
                       (where _)
                       nil)]
      (subscribe wf handler)
      (values wf)))
  (let [wf (make-wf meta.plugin (. meta.action 2))]
    (scheduler.add-workflow ui.scheduler wf))
  (output ui))

(fn exec-keymap-cc [ui]
  ;; TODO warn if zero staged
  (exec-commit ui))

(fn exec-keymap-s [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (enum.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta (= :unstaged meta.state))
      (do
        (tset meta :state :staged)
        (output ui))
      (vim.notify "May only stage unstaged plugins"))))

(fn exec-keymap-u [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (enum.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta (= :staged meta.state))
      (do
        (tset meta :state :unstaged)
        (output ui))
      (vim.notify "May only unstage staged plugins"))))


(fn exec-keymap-= [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (enum.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta
             (or (= :staged meta.state) (= :unstaged meta.state))
             (= :sync (. meta.action 1)))
      (if meta.log
        (do
          (tset meta :log-open (not meta.log-open))
          (output ui))
        (exec-diff ui meta))
      (vim.notify "May only view diff of staged or unstaged sync-able plugins"))))

(fn exec-status [ui]
  (fn make-status-wf [plugin]
    (let [wf (status-wf.new plugin.id
                            (. plugin.source 2)
                            plugin.package-path
                            plugin.constraint)
          handler (fn* handler
                    (where [[:ok [:hold commit]]])
                    (let [meta (. ui :plugins-meta plugin.id)]
                      (tset meta :state :up-to-date)
                      (enum.append$ meta.events (fmt "(at %s)" commit))
                      (unsubscribe wf handler)
                      (output ui))

                    (where [[:ok [action commit]]])
                    (let [meta (. ui :plugins-meta plugin.id)]
                      (tset meta :action [action commit])
                      (tset meta :state :unstaged)
                      (enum.append$ meta.events (fmt "(%s %s)" action commit))
                      (unsubscribe wf handler)
                      (output ui))

                    (where [[:err e]])
                    (let [meta (. ui :plugins-meta plugin.id)]
                      (set meta.state :error)
                      (enum.append$ meta.events e)
                      (unsubscribe wf handler)
                      (output ui))

                    (where [msg] (string? msg))
                    (let [meta (. ui :plugins-meta wf.id)]
                      (enum.append$ meta.events msg)
                      (output ui))
                    (where _)
                    nil)]
      (subscribe wf handler)
      (values wf)))
  (output ui)
  (enum.map (fn [_ plugin]
              (scheduler.add-workflow ui.scheduler (make-status-wf plugin)))
            ui.plugins))

(fn M.attach [win buf plugins]
  "Attach user-provided win+buf to pact view"
  (let [{true ok-plugins false err-plugins} (enum.group-by #(values (result.ok? $2) (result.unwrap $2))
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
      (let [plugins-meta (-> (enum.map #[$2.id {:events ["waiting for scheduler"]
                                                :order $1
                                                :state :waiting
                                                :actions []
                                                :action nil
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
                :scheduler (scheduler.new)}]
        (doto buf
          ;; TODO v mode
          (api.nvim_buf_set_option :ft :pact)
          (api.nvim_buf_set_keymap :n := "" {:callback #(exec-keymap-= ui)})
          (api.nvim_buf_set_keymap :n :cc "" {:callback #(exec-keymap-cc ui)})
          (api.nvim_buf_set_keymap :n :s "" {:callback #(exec-keymap-s ui)})
          (api.nvim_buf_set_keymap :n :u "" {:callback #(exec-keymap-u ui)}))


        ;; we always default to status ui
        (exec-status ui)
        (values ui)))))

(values M)
