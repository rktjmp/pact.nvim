(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     R :pact.lib.ruin.result
     inspect :pact.inspect
     {: '*dout*} :pact.log
     api vim.api
     {:format fmt} string)

(local Render {})

; (fn section-title [section-name]
;   (or (. {:error "Error"
;           :waiting "Waiting"
;           :active "Active"
;           :held "Held"
;           :updated "Updated"
;           :up-to-date "Up to date"
;           :unstaged "Unstaged"
;           :staged "Staged"} section-name)
;       section-name))

(fn highlight-for [section-name field]
  ;; my-section,  -> PactMySectionTitle
  (let [joined (table.concat  [:pact section-name field] "-")]
    (E.reduce #(.. $1 (string.upper $2) $3)
                 "" #(string.gmatch joined "(%w)([%w]+)"))))

(var last-time 0)
(var spinner-frame 0)

(fn rate-limited-inc [value]
  ;; only increment n at a fixed fps
  ;; uv.now increments only at the event loop start, but this is ok for us.
  (let [every-n-ms (/ 1000 6)
        now (vim.loop.now)]
    (if (< every-n-ms (- now last-time))
      (do
        (set last-time now)
        (+ value 1))
      value)))

(fn progress-symbol [progress]
  (let [symbols [:◐ :◓ :◑ :◒]]
    (. symbols (+ 1 (% progress (length symbols))))))

(fn workflow-symbol []
  "⧖")

(fn package-tree->ui-data [packages]
  (use Package :pact.package
       Runtime :pact.runtime)
  (let [configuration-error #{:name "Configuration Error"
                              :text (R.unwrap $1)
                              :indent (length $2)
                              :state :error}
        package-data #{:name $1.name
                       :working? (E.any? #$1.timer $1.workflows)
                       :waiting? (E.any? #$1 $1.workflows)
                       :constraint $1.constraint
                       :text $1.text
                       :indent (length $2)
                       :state $1.state
                       :events $1.events
                       :error (and (R.err? (E.last $1.events))
                                   (E.last $1.events))}]
    (E.map (fn [node history]
             (if (R.err? node)
               (configuration-error node history)
               (do
                 (print node.uid (vim.inspect (E.any? #$ node.workflows)))
                 (package-data node history))))
           #(Package.iter packages {:include-err? true}))))

(fn ui-data->rows [ui-data]
  (fn indent-with [n]
    (match n
      0 ""
      1 " +"
      n (fmt " %s+" (string.rep " " (- n 0)))))

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
          wf-col [(match [package.working? package.waiting?]
                    [true _] {:text "work"
                              :highlight :DiagnosticInfo}
                   [_ true] {:text "wait"
                             :highlight :Comment}
                   _ {:text "____"
                      :highlight :None})]
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
      [wf-col name-col constraint-col action-col message-col]))

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

(local const {:lede (-> (E.map #[[{:text $2 :highlight :PactComment}]]
                               [";; 🔪🩸🐐" ""])
                        (rows->lines))
              :usage (-> (E.map #[[{:text $2 :highlight :PactComment}]]
                                [""
                                 ";; Usage:"
                                 ";; "
                                 ";;   s  - Stage plugin for update"
                                 ";;   u  - Unstage plugin"
                                 ";;   cc - Commit staging and fetch updates"
                                 ";;   =  - View git log (staged/unstaged only)"])
                         (rows->lines))})

(fn Render.output [ui]
  (use Runtime :pact.runtime)
  (let [rows (-> (package-tree->ui-data ui.runtime.packages)
                 (ui-data->rows)
                 (inject-padding-chunks)
                 (intersperse-column-breaks))]

    (var current-line 0)
    (macro write-lines [lines]
      `(do
         (let [len# (length ,lines)]
           (api.nvim_buf_set_lines ui.buf
                                   current-line
                                   (+ current-line len#)
                                   false
                                   ,lines)
           (set ,(sym :current-line) (+ ,(sym :current-line) len#)))))

    (api.nvim_buf_set_option ui.buf :modifiable true)

    (write-lines const.lede)

    (local package-line-offset current-line)
    ;; we want to store where we started drawing packages so we can link back
    ;; input events.
    (set ui.package-lines-offset package-line-offset)
    (write-lines (rows->lines rows))

    (write-lines const.usage)

    (E.each (fn [line marks]
              (E.each (fn [_ {: start : stop : highlight}]
                        (api.nvim_buf_add_highlight ui.buf
                                                    ui.ns-id
                                                    highlight
                                                    (- (+ package-line-offset line) 1)
                                                    start stop))
                      marks))
            (rows->extmarks rows))

    (if _G.__pact_debug
      (let [lines (E.map #$1
                         #(string.gmatch (inspect _G.__pact_debug) "([^\n]+)"))]
        (write-lines lines)))

    (api.nvim_buf_set_option ui.buf :modifiable false)))

Render
