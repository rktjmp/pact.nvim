(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use enum :pact.lib.ruin.enum
     scheduler :pact.workflow.scheduler
     {: subscribe : unsubscribe} :pact.pubsub
     result :pact.lib.ruin.result
     api vim.api
     {:format fmt} string
     status-wf :pact.workflow.git.status
     clone-wf :pact.workflow.git.clone)

(fn render-section [ui section-name previous-lines]
  (let [relevant-plugins (enum.filter #(= $2.state section-name) ui.plugins-meta)
        new-lines (enum.reduce (fn [lines i meta]
                                 (let [line [[meta.plugin.name "@symbol"]
                                             [(tostring  (+ 2 (length previous-lines) (length lines))) "@function"]
                                             [(enum.last meta.events) "@comment"]]]
                                   ;; todo ugly way to set offsets here
                                   (set meta.on-line (+ 2 (length previous-lines) (length lines)))
                                   (enum.append$ lines line)))
                               [] relevant-plugins)]
    (if (< 0 (length new-lines))
      (-> previous-lines
          (enum.append$ [[section-name "@function"]])
          (enum.concat$ new-lines)
          (enum.append$ [["" nil]]))
      (values previous-lines))))

(fn output [ui]
  (let [sections [:waiting :error :active :unstaged :staged :up-to-date :syncing :cloning]
        lines (enum.reduce (fn [lines _ section] (render-section ui section lines))
                           [] sections)
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
                               (api.nvim_buf_add_highlight ui.buf 0 hl (- i 1) start stop))
                          line-marks))
              extmarks)))

(fn exec-commit [ui]
  (fn make-clone-wf [plugin commit]
    (let [wf (clone-wf.new plugin.id
                           plugin.package-path
                           (. plugin.source 2)
                           commit.sha)
          handler (fn* handler
                    (where [[:ok]])
                    (let [meta (. ui :plugins-meta plugin.id)]
                      (tset meta :state :up-to-date)
                      (enum.append$ meta.events (fmt "cloned %s" plugin.constraint))
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
  (->> (enum.filter #(and (= :staged $2.state) (= :clone (. $2.action 1))) ui.plugins-meta)
       (enum.map (fn [_ meta]
                   (tset meta :state :active)
                   (scheduler.add-workflow ui.scheduler (make-clone-wf meta.plugin (. meta.action 2)))))))

(fn exec-keymap-cc [ui]
  ;; TODO warn if zero staged
  (exec-commit ui))

(fn exec-keymap-s [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (enum.find-value #(= line $2.on-line) ui.plugins-meta)]
    (when (= :unstaged meta.state)
      (tset meta :state :staged)
      (output ui))))

(fn exec-keymap-u [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (enum.find-value #(= line $2.on-line) ui.plugins-meta)]
    (when (= :staged meta.state)
      (tset meta :state :unstaged)
      (output ui))))

(fn open-win [ui]
  (let [api vim.api
        _ (vim.cmd.split)
        win (api.nvim_get_current_win)
        buf (api.nvim_create_buf false true)]

    (doto win
      (api.nvim_win_set_buf buf)
      (api.nvim_win_set_option :wrap false))

    (doto buf
      ;; TODO v mode
      (api.nvim_buf_set_keymap :n :cc "" {:callback #(exec-keymap-cc ui)})
      (api.nvim_buf_set_keymap :n :s "" {:callback #(exec-keymap-s ui)})
      (api.nvim_buf_set_keymap :n :u "" {:callback #(exec-keymap-u ui)}))

    (doto ui
      (tset :buf buf)
      (tset :win win))))


(fn exec-status [ui]
  (fn make-status-wf [plugin]
    (let [wf (status-wf.new plugin.id
                            (. plugin.source 2)
                            plugin.package-path
                            plugin.constraint)
          handler (fn* handler
                    (where [[:ok [action commit]]])
                    (let [meta (. ui :plugins-meta plugin.id)]
                      (tset meta :action [action commit])
                      (tset meta :state :unstaged)
                      (enum.append$ meta.events (fmt "%s %s" action commit))
                      (unsubscribe wf handler)
                      (output ui))

                    (where [[:ok nil]])
                    (let [meta (. ui :plugins-meta plugin.id)]
                      (tset meta :state :up-to-date)
                      (enum.append$ meta.events "up to date")
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

(fn new [plugins]
  (let [plugins-meta (-> (enum.map #[$2.id {:events ["waiting for scheduler"]
                                            :state :waiting
                                            :actions []
                                            :action nil
                                            :plugin $2}]
                                   plugins)
                         (enum.pairs->table))
        ui {: plugins
            : plugins-meta
            :scheduler (scheduler.new)}]
    (open-win ui)
    (values ui)))

;; Awaiting
;;
;; rktjmp/hotpot.nvim
;;
;; Stale
;;
;; rktjmp/lush.nvim
;;
;; Up to date
;;
;; faimu/feline.nvim


{: new
 : output
 : exec-status}
