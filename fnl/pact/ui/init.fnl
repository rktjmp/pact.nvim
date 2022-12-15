(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     {: '*dout*} :pact.log
     inspect :pact.inspect
     scheduler :pact.workflow.scheduler
     {: subscribe : unsubscribe} :pact.pubsub
     {: ok? : err?} :pact.lib.ruin.result
     R :pact.lib.ruin.result
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
    (E.reduce #(.. $1 (string.upper $2) $3)
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
  (let [relevant-plugins (->> (E.filter #(= $2.state section-name) ui.runtime.packages)
                              (E.map #$2)
                              (E.sort$ #(<= $1.order $2.order)))
        new-lines (E.reduce (fn [lines i package]
                                 (let [name-length (length package.name)
                                       line [[package.name
                                              (highlight-for section-name :name)]
                                             [(string.rep " " (- (+ 1 ui.layout.col-1-width) name-length))
                                              nil]
                                             [(progress-symbol package.progress)
                                              (highlight-for section-name :name)]
                                             [(or package.text "did-not-set-text")
                                              (highlight-for section-name :text)]]]
                                   ;; TODO: kind of ugly way to set offsets here
                                   (tset ui.package->line package.id (+ 2
                                                                        (length previous-lines)
                                                                        (length lines)))
                                   (E.append$ lines line)))
                               [] relevant-plugins)]
    (if (< 0 (length new-lines))
      (-> previous-lines
          (E.append$ [[(.. "" (section-title section-name))
                          (highlight-for section-name :title)]
                         [" " nil]
                         [(fmt "(%s)" (length new-lines)) :PactComment]])
          (E.concat$ new-lines)
          (E.append$ [["" nil]]))
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
        lines (-> (E.reduce (fn [lines _ section] (render-section ui section lines))
                           (lede) sections)
                  (E.concat$ (usage)))
        ;; pretty gnarly, we want to split the line data out into just flat text
        ;; to be inserted into the buffer, and a list of [start stop highlight]
        ;; groups for extmark highlighting.
        lines->text-and-extmarks (E.reduce
                                  (fn [[str extmarks] _ [txt ?extmarks]]
                                    [(.. str txt)
                                     (if ?extmarks
                                       (E.append$ extmarks [(length str)
                                                               (+ (length str) (length txt))
                                                               ?extmarks])
                                       extmarks)]))
        [text extmarks] (E.reduce (fn [[lines extmarks] _ line]
                                      (let [[new-lines new-extmarks] (lines->text-and-extmarks ["" []] line)]
                                        [(E.append$ lines new-lines)
                                         (E.append$ extmarks new-extmarks)]))
                                    [[] []] lines)]
    (when (E.any? #(string.match $2 "\n") text)
      (print "pact.ui text had unexpected new lines")
      (print (vim.inspect text)))
    (api.nvim_buf_set_option ui.buf :modifiable true)
    (api.nvim_buf_set_lines ui.buf 0 -1 false text)
    (api.nvim_buf_set_option ui.buf :modifiable false)
    (E.map (fn [i line-marks]
                (E.map (fn [_ [start stop hl]]
                            (api.nvim_buf_add_highlight ui.buf ui.ns-id hl (- i 1) start stop))
                          line-marks))
              extmarks)
    ; (E.map #(if $2.log-open
    ;              (api.nvim_buf_set_extmark ui.buf ui.ns-id (- $2.on-line 1) 0
    ;                                        {:virt_lines (E.map #(log-line->chunks $2)
    ;                                                               $2.log)}))
    ;           ui.plugins-meta)
    ))

(fn package-tree->ui-data [packages]
  (use Package :pact.package
       Runtime :pact.runtime)
  (let [configuration-error #{:name "Configuration Error"
                              :text (R.unwrap $1)
                              :indent (length $2)
                              :state :error}
        package-data #{:name $1.name
                       :constraint $1.constraint
                       :text $1.text
                       :indent (length $2)
                       :state $1.state
                       :events $1.events
                       :error (and (R.err? (E.last $1.events))
                                   (E.last $1.events))}]
    (Package.Tree.map (fn [node history]
                        (if (R.err? node)
                          (configuration-error node history)
                          (package-data node history)))
                      packages)))

(fn ui-data->rows [ui-data]
  (fn indent-with [n]
    (match n
      0 "  "
      1 "   +"
      n (fmt "   %s+" (string.rep " " (- n 0)))))

  (fn indent-width [n]
    ;; (length) will show bytes not char width
    (match (indent-with n)
      ; "  " 0
      s (-> (length s)
            ; (- 2)
            )))

  (fn package->columns [package]
    ;; Columns should be roughly:
    ;;
    ;; name | constraint | action/newer? | message
    ;;
    ;; Each column may contain multiple "chunk" tables, which describe
    ;; text content, highlight group and optionally length. Length may be
    ;; specifically included as it must be utf8 aware, and the chunk generator
    ;; best knows how to do that curently.
    (let [{: name : text : state : constraint : indent} package
          name-col [{:text (indent-with indent)
                     :highlight "@comment"
                     :length (indent-width indent)}
                    {:text name
                     :highlight (match state
                                  :warning :DiagnosticWarn
                                  :error :DiagnosticError
                                  _ (highlight-for :staged :name))}]
          constraint-col [{:text (tostring constraint)
                           :highlight (highlight-for :staged :text)}]
          action-col [{:text "no-action" :highlight "action"}]
          message-col [{:text text
                        :highlight (match state
                                     :warning :DiagnosticWarn
                                     :error :DiagnosticError
                                     _ (highlight-for :staged :text))}]]
      [name-col constraint-col action-col message-col]))

  ;; convert each package into a collection of columns, into a collection of lines
  (E.map #(package->columns $2) ui-data))

(fn rows->lines [rows]
  (fn decomp-line [line-chunks]
    ;; combine columns with column separators
    (-> (E.map #(-> (E.map (fn [_ {: text}] text) $2)
                (table.concat "")) line-chunks)
        (table.concat "")))
  (E.map #(decomp-line $2) rows))

(fn rows->extmarks [rows]
  (var cursor 0)
  (fn decomp-column [column]
    ;; combine column chunks into [{: hl : start : stop} ...]
    (-> (E.reduce (fn [data _ {: text : highlight :length len}]
                    (let [start cursor
                          stop (+ cursor (or len (length text)))]
                      (set cursor stop)
                      (E.append$ data {:start start
                                       :stop stop
                                       :highlight highlight})))
                  [] column)))
  (fn decomp-line [line]
    ;; combine columns with column separators
    (set cursor 0) ;; ugly...
    (-> (E.map #(decomp-column $2) line)
        (E.flatten)))
  (E.map #(decomp-line $2) rows))

(fn inject-padding-chunks [rows]
  ;; Each row has columns, but they are not intrinsically aligned in the data
  ;; we need to work out what the padding should be for each column on each
  ;; line and add that as a new chunk in the line.
  ;; It must be added as a new chunk so we can avoid over-highlight or
  ;; mis-highligting text when we apply the extmarks.
  (let [sum-col-chunk-widths #(E.reduce
                                #(let [{: text :length len} $3]
                                   (match [text len]
                                     [nil nil] $1
                                     [any nil] (+ $1 (length text))
                                     [_ any] (+ $1 len)
                                     _ $1))
                                0 $1)
        get-col-widths (E.map (fn [i col] [i (sum-col-chunk-widths col)]))
        ;; woof
        widths (->> rows
                    ;; get widths of each column in each row as [col-n width]
                    (E.map #(get-col-widths $2))
                    (E.flatten)
                    ;; group all widths by column
                    (E.group-by (fn [_ [col-n w]] (values col-n w)))
                    ;; find max width for each column
                    (E.reduce (fn [maxes i widths] (E.set$ maxes i (math.max (unpack widths))))
                              []))]
    ;; now we can re-iterate the columns and inject a padding chunk
    (E.map (fn [_ row]
             (E.map (fn [col-n column]
                      (let [cur-width (sum-col-chunk-widths column)
                            padding (- (. widths col-n) cur-width)]
                        ;; TODO performance if needed, drop copy for each
                        (if (< 0 padding)
                          (E.concat$ [] column [{:text (string.rep " " padding)
                                                 :highlight "None"}])
                          (E.concat$ [] column))))
                    row))
           rows)))

(fn intersperse-column-breaks [rows]
  (E.map #(E.intersperse $2 [{:text "  " :highlight "None"}])
         rows))

  (fn output [ui]
    (use Packages :pact.package
         Runtime :pact.runtime)
    (let [rows (-> (package-tree->ui-data ui.runtime.packages)
                   (ui-data->rows)
                   (inject-padding-chunks)
                   (intersperse-column-breaks))]

      (api.nvim_buf_set_option ui.buf :modifiable true)

      ;; debug data
      (api.nvim_buf_set_lines ui.buf 0 1 false
                              [(fmt "workflows: %s active %s waiting"
                                    (-> (Runtime.workflow-stats ui.runtime)
                                        (#(values $1.active $1.queued))))])

      (api.nvim_buf_set_lines ui.buf 1 -1 false (rows->lines rows))
      (E.each (fn [line marks]
              (E.each (fn [_ {: start : stop : highlight}]
                        ;; line -0 for wf status, should be -1 normally
                        (api.nvim_buf_add_highlight ui.buf ui.ns-id highlight (- line 0) start stop))
                      marks))
            (rows->extmarks rows))

    (if _G.__pact_debug
      (let [lines (E.map #$1
                         #(string.gmatch (inspect _G.__pact_debug) "([^\n]+)"))]
        (api.nvim_buf_set_lines ui.buf -1 -1 false lines)))

    (api.nvim_buf_set_option ui.buf :modifiable false)))

(fn schedule-redraw [ui]
  ;; asked to render, we only want to hit 60fps otherwise we can really pin
  ;; with lots of workflows pinging back to us.
  (local rate (/ 1000 30))
  (when (< (or ui.will-render 0) (vim.loop.now))
    (tset ui :will-render (+ rate (vim.loop.now)))
    (vim.defer_fn #(output ui) rate)))

(fn exec-keymap-cc [ui]
  (if (E.any? #(= :staged $2.state) ui.plugins-meta)
    #nil ;(exec-open-transaction ui)
    (vim.notify "Nothing staged, refusing to commit")))

(fn exec-keymap-<cr> [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (E.find-value #(= line $2.on-line) ui.plugins-meta)]
    (match [meta (?. meta :plugin :path :package)]
      [any path] (do
                   (print path)
                   (vim.cmd (fmt ":new %s" path)))
      [any nil] (vim.notify (fmt "%s has no path to open" any.plugin.name))
      _ nil)))

(fn exec-keymap-s [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (E.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta (= :unstaged meta.state))
      (do
        (tset meta :state :staged)
        (schedule-redraw ui))
      (vim.notify "May only stage unstaged plugins"))))

(fn exec-keymap-u [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (E.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta (= :staged meta.state))
      (do
        (tset meta :state :unstaged)
        (schedule-redraw ui))
      (vim.notify "May only unstage staged plugins"))))


(fn exec-keymap-= [ui]
  (let [[line _] (api.nvim_win_get_cursor ui.win)
        meta (E.find-value #(= line $2.on-line) ui.plugins-meta)]
    (if (and meta
             (or (= :staged meta.state) (= :unstaged meta.state))
             (= :sync (. meta.action 1)))
      (if meta.log
        (do
          (set meta.log-open (not meta.log-open))
          (schedule-redraw ui))
        (do
          #nil));(exec-diff ui meta)))
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

(fn M.attach [win buf proxies opts]
  "Attach user-provided win+buf to pact view"
  (let [opts (or opts {})
        Runtime (require :pact.runtime)
        runtime (-> (Runtime.new {:concurrency-limit opts.concurrency-limit})
                    (Runtime.add-proxied-plugins proxies))
        ui (-> {: runtime
                : win
                : buf
                :layout {:col-1-width 1}
                :ns-id (api.nvim_create_namespace :pact-ui)
                :package->line {}
                :errors []}
               (prepare-interface))]

    ;; TODO unsub all on win close
    (runtime:walk-packages #(if (not (R.err? $1))
                              (subscribe $1 #(schedule-redraw ui))))
    (set ui.layout.col-1-width
         (runtime:walk-packages (fn [max package]
                                  (if (not (R.err? package))
                                    (if (< max (length package.name))
                                      (length package.name)
                                      max)
                                    max)) 0))
    (->> (Runtime.Command.discover-status)
         (Runtime.dispatch runtime))

    ; (Runtime.discover-current-status runtime)
    (schedule-redraw ui)))

    ; (let [topic (Runtime.run-status runtime)]
    ;   (subscribe topic (fn [...] (print :x))))))
      ; (do
      ;   (let [lines [";; 🔪🩸🐐 Pact has no plugins defined!"
      ;                ";; "
      ;                ";; See `:h pact-usage`!"]]
      ;     (api.nvim_buf_set_option buf :ft :pact)
      ;     (api.nvim_buf_set_lines buf 0 -1 false lines))))))

(values M)
