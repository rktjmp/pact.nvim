(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     R :pact.lib.ruin.result
     Log :pact.log
     Package :pact.package
     inspect :pact.inspect
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

;; TODO use a proper delta timer
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

(fn workflow-active-symbol [progress]
  (let [symbols [:◐ :◓ :◑ :◒]
        symbols ["`" "'" "\""]
        symbols ["\\" "|" "/" "-"]]
    (. symbols (+ 1 (% progress (length symbols))))))

(fn workflow-waiting-symbol []
  "⧖" ".")

(fn package-tree->ui-data [packages]
  "Extract and construct UI specific data from packages"
  (use Package :pact.package
       Runtime :pact.runtime)
  (let [configuration-error #{:uid :error
                              :name "Configuration Error"
                              :text (R.unwrap $1)
                              :indent (length $2)
                              :state :error}
        package-data #{:uid $1.uid
                       :name $1.name
                       :health $1.health
                       :head (?. $ :git :checkout :HEAD :short-sha)
                       :solves-to (?. $ :git :target :commit :short-sha)
                       :latest  (match (?. $ :git :latest :commit)
                                  c (table.concat c.versions ",")
                                  _ "")
                       :working? (E.any? #$1.timer $1.workflows)
                       :waiting? (E.any? #$1 $1.workflows)
                       :constraint $1.constraint
                       :text (do
                               (-> (inspect (?. $ :events 1 2) true)
                                   (string.gmatch "([^\n]+)")
                                   (E.map $1)
                                   (table.concat " "))

                               ; (E.reduce (fn [_ _ [_wf event]]
                               ;             (if (string? event)
                               ;               (E.reduced event)))
                               ;         "no text" $.events)
                               )
                       :distance (length (or (?. $ :git :target :logs) []))
                       :breaking? (?. $ :git :target :breaking?)
                       :logs (?. $ :git :target :logs)
                       :indent (length $2)
                       :action (?. $ :action 1)
                       :state $1.state
                       :events $1.events
                       :error (and (R.err? (E.last $1.events))
                                   (E.last $1.events))}]
    (E.map (fn [node history]
             (if (R.err? node)
               (configuration-error node history)
               (package-data node history)))
           #(Package.iter packages {:include-err? true}))))

(fn ui-data->rows [ui-data]
  (fn indent-with [n]
    (match n
      0 ""
      1 " \\"
      n (fmt " %s\\" (string.rep " " (- n 0)))))

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
                    [true _] {:text (workflow-active-symbol (vim.loop.now))
                              :highlight :DiagnosticInfo
                              :length 1}
                   [_ true] {:text (workflow-waiting-symbol (vim.loop.gettimeofday))
                             :highlight :Comment
                             :length 1}
                   _ {:text " "
                      :highlight :Comment})]
          health-col [(match package.health
                        [:healthy] {:text "healthy" :highlight :Comment}
                        [:degraded msg] {:text msg :highlight :DiagnosticWarn}
                        [:failing msg] {:text msg :highlight :DiagnosticError})]
          local-col [{:text (tostring package.head)
                       :highlight :Comment}]
          comp-col [{:text (if (= (?. package :head :sha) (?. package :solves-to :sha))
                             "="
                             "!=")
                       :highlight :Comment}]
          remote-col [{:text (fmt "%s %s" (tostring package.solves-to) package.distance)
                       :highlight :Comment}]
          latest-col [{:text package.latest
                       :highlight :Comment}]
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
          action-col [{:text (or package.action "none") :highlight "action"}]
          message-col [{:text text
                        :highlight (match state
                                     :warning :DiagnosticWarn
                                     :error :DiagnosticError
                                     _ (highlight-for :staged :text))}]]
      {:content [wf-col
                 name-col
                 constraint-col
                 local-col
                 comp-col
                 remote-col
                 latest-col
                 action-col
                 health-col
                 message-col]
       :meta {:uid package.uid}}))

  ;; convert each package into a collection of columns, into a collection of lines
  (E.map #(package->columns $2) ui-data))

(fn rows->lines [rows]
  (fn decomp-line [line-chunks]
    ;; combine columns with column separators
    (-> (E.map #(-> (E.map (fn [_ {: text}] text) $2)
                    (table.concat "")) line-chunks)
        (table.concat "")))
  ;; TODO or here as we use this for lede/usage as well as package lines
  ;; (which have meta data), could be refactored
  (E.map #(decomp-line (or $2.content $2)) rows))

(fn rows->extmarks [rows]
  (var cursor 0)
  (fn decomp-column [column]
    ;; combine column chunks into [{: hl : start : stop} ...]
    (-> (E.reduce (fn [data _ {: text : highlight :length len}]
                    (let [start cursor
                          stop (+ cursor (or len (length (or text ""))))]
                      (set cursor stop)
                      (E.append$ data {:start start
                                       :stop stop
                                       :highlight highlight})))
                  [] column)))
  (fn decomp-line [line]
    ;; combine columns with column separators
    (set cursor 0) ;; ugly...
    (-> (E.map #(decomp-column $2) line.content)
        (E.flatten)
        (#(if (?. line :meta :uid)
            (E.append$ $1 {:id line.meta.uid :start 0 :stop 0})
            $1))))
  (E.map #(decomp-line $2) rows))

(fn inject-padding-chunks [rows widths]
  ;; Each row has columns, but they are not intrinsically aligned in the data
  ;; we need to work out what the padding should be for each column on each
  ;; line and add that as a new chunk in the line.
  ;; It must be added as a new chunk so we can avoid over-highlight backgrounds
  ;; when we apply the extmarks.
  (let [sum-col-chunk-widths #(E.reduce
                                #(let [{: text :length len} $3]
                                   (match [text len]
                                     [nil nil] $1
                                     [any nil] (+ $1 (length text))
                                     [_ any] (+ $1 len)
                                     _ $1))
                                0 $1)]
    ;; now we can re-iterate the columns and inject a padding chunk
    (E.map (fn [_ row]
             {:meta row.meta
              :content (E.map (fn [col-n column]
                                (let [cur-width (sum-col-chunk-widths column)
                                      padding (- (or (. widths col-n) 0) cur-width)]
                                  ;; TODO performance if needed, drop copy for each
                                  (if (< 0 padding)
                                    (E.concat$ [] column [{:text (string.rep " " padding)
                                                           :highlight "None"}])
                                    (E.concat$ [] column))))
                              row.content)})
           rows)))

(λ intersperse-column-breaks [rows]
  "Add gaps between columns"
  (E.map #{:meta $2.meta
           :content (E.intersperse $2.content [{:text " " :highlight "@comment"}])}
         rows))

(fn row->column-widths [row]
  (fn width-of-column [column]
    (E.reduce #(let [{: text :length len} $3]
                 (match [text len]
                   [nil nil] $1
                   [any nil] (+ $1 (length text))
                   [_ any] (+ $1 len)
                   _ $1))
              0 column))
  (E.map #(width-of-column $2) row.content))

(fn rows->column-widths [rows]
  (E.map #(row->column-widths $2) rows))

(fn widths->maximum-widths [widths]
  (E.reduce (fn [col-max _ col-widths]
              ;; note we use each as some cols may not contain all (or any)
              ;; values and we want to retain any seen.
              (E.each (fn [col-n width]
                        (E.set$ col-max col-n (math.max (or (. col-max col-n) 0)
                                                        width)))
                      col-widths)
              col-max) {} widths))

(fn find-maximum-column-widths [rows]
  (->> rows
       ;; get width of each column of each row
       (E.map #(row->column-widths $2))
       ;; find max width of each column
       (widths->maximum-widths)))

(fn mk-chunk [text ?hl] {:text text :highlight (or ?hl :PactComment)})
(fn mk-col [...] [...])
(fn mk-content [...] [...])
(fn mk-row [content ?meta] {:content content :meta (or ?meta {})})
(fn mk-basic-row [content] (mk-row (mk-content (mk-col (mk-chunk content :PactComment)))))

(local const {:lede [(mk-basic-row ";; 🔪🩸🐐")
                     (mk-basic-row "")]
              :blank [(mk-basic-row "")]
              :no-plugins [(mk-basic-row "")
                           (mk-basic-row ";;")
                           (mk-basic-row ";; Whoops!")
                           (mk-basic-row ";;")
                           (mk-basic-row ";; pact has no plugins defined! See `:h pact-usage`")
                           (mk-basic-row ";;")
                           (mk-basic-row "")]
              :usage [(mk-basic-row "")
                      (mk-basic-row ";; Usage:")
                      (mk-basic-row ";;")
                      (mk-basic-row ";;   s  - Stage plugin for update")
                      (mk-basic-row ";;   u  - Unstage plugin")
                      (mk-basic-row ";;   cc - Commit staging and fetch updates")
                      (mk-basic-row ";;   =  - View git log (staged/unstaged only)")]})

(λ packages->sections [packages]
  ;; Given a list of packages, split then into groups for each UI section
  (let [waiting? (fn [package]
                   (E.any? #(Package.loading? $1)
                           #(Package.iter [package])))
        in-sync? (fn [package]
                   (E.any? #(Package.in-sync? $1)
                           #(Package.iter [package])))
        staged? (fn [package]
                   (E.any? #(Package.staged? $1)
                           #(Package.iter [package])))
        ;; we intentionally only iterate the "top" packages
        {true waiting false rest} (E.group-by #(waiting? $2) packages)
        {true in-sync false rest} (E.group-by #(in-sync? $2) (or rest []))
        {true staged false unstaged} (E.group-by #(staged? $2) (or rest []))]
    ;; TODO error? at least error if not staged/unstaged, so they don't get lost in waiting
    {:waiting (or waiting [])
     :in-sync (or in-sync [])
     :staged (or staged [])
     :unstaged (or unstaged [])}))

(fn Render.output [ui]
  ;; We always operate on the top level packages, as we want to group
  ;; package-trees not separate packages.
  ;;
  ;; We have these sections
  ;;
  ;; waiting: still collecting data for some package in the tree
  ;; in-sync: collected all data, no update available
  ;; unstaged: collected all data, one or more packages *can* be updated
  ;; staged: collected all data, one or more packages *will* be updated
  ;;
  ;; Line format:
  ;;
  ;; Each line is constructed of n-columns, and each column has n-chunks in it.
  ;; Chunks tables containing {:text ... :highlight ...} and optionally a :length n
  ;; key for unicode characters that span multiple bytes - needed so we can
  ;; accurately judge "render width" in the buffer. Note that extmarks are byte
  ;; indexed and should not use the length key (I think? TODO? Was this the case in shenzhenio?)
  ;;
  ;; These chunks are collated to determine column widths, and these columns
  ;; are collated to determine line content which is written out.
  ;; The chunks are used to apply extmarks.
  ;;
  ;; There is an additional {:id} key associated with the chunk which indicates
  ;; that an extmark should be placed to map between rows and packages in
  ;; keybindings.
  (use Runtime :pact.runtime)
  (let [;; split packages into sections
        {: waiting : in-sync : staged : unstaged} (packages->sections ui.runtime.packages)
        ;; We must create stub sections first which contains the text content
        ;; but none of it will be aligned.
        [staged-rows
         unstaged-rows
         in-sync-rows
         waiting-rows] (E.map #(-> $2
                                   (package-tree->ui-data)
                                   (ui-data->rows))
                              [staged unstaged in-sync waiting])
        ;; get the max widths of every section, then the max width between sections
        ;; which will then dictate the padding needed across all lines.
        column-widths (->> (E.map #(->> (E.map #(row->column-widths $2) $2)
                                        (widths->maximum-widths))
                                  [waiting-rows in-sync-rows unstaged-rows staged-rows])
                           (widths->maximum-widths))
        ;; now that we know column widths we can insert padding chunks into every column
        ;; so they all align.
        [staged-rows
         unstaged-rows
         in-sync-rows
         waiting-rows] (E.map #(-> $2
                                   (inject-padding-chunks column-widths)
                                   (intersperse-column-breaks))
                              [staged-rows unstaged-rows in-sync-rows waiting-rows])

        ;; Generate title lines. These dont follow the strict alignment and need us to know
        ;; the row counts before creation.
        title-map {:unstaged {:t "Unstaged" :hl "Unstaged"}
                   :staged {:t "Staged" :hl "Staged"}
                   :in-sync {:t "In Sync" :hl "InSync"}
                   :waiting {:t "Discovering Facts" :hl "Waiting"}}
        [staged-title
         unstaged-title
         in-sync-title
         waiting-title] (E.map (fn [_ [section count]]
                                 [(mk-row
                                    (mk-content
                                      (mk-col (mk-chunk (. title-map section :t)
                                                        (fmt "Pact%sTitle" (. title-map section :hl)))
                                              (mk-chunk (fmt " (%s)" count)
                                                        :PactComment))))])
                               [[:staged (length staged-rows)]
                                [:unstaged (length unstaged-rows)]
                                [:in-sync (length in-sync-rows)]
                                [:waiting (length waiting-rows)]])]

    ;; clear extmarks so we don't have them all pile up. We have to re-make
    ;; then each draw as the lines are re-drawn.
    (set ui.extmarks [])
    (var current-line 0)
    (fn write-lines [lines]
      (let [len (length lines)]
        (api.nvim_buf_set_lines ui.buf current-line (+ current-line len) false lines)
        (set current-line (+ current-line len))))
    (fn draw-extmarks [lines offset]
      (E.each (fn [line marks]
                (E.each (fn [_ mark]
                          (let [{: id : start : stop : highlight} mark
                                line (- (+ offset line) 1)]
                            (if id
                              (-> (api.nvim_buf_set_extmark ui.buf ui.ns-meta-id line 0 {})
                                  (#(tset ui.extmarks $1 id)))
                              (api.nvim_buf_add_highlight ui.buf ui.ns-id highlight line start stop))))
                        marks))
              lines))
    (fn write-rows [rows]
      (-> (rows->lines rows)
          (write-lines))
      (-> (rows->extmarks rows)
          (draw-extmarks (- current-line (length rows)))))

    (fn write-section [title section]
      (when (not (E.empty? section))
        (write-rows title)
        (write-rows section)
        (write-rows const.blank)))

    (api.nvim_buf_set_option ui.buf :modifiable true)

    (write-rows const.lede)
    ; (if (E.all? #(length $2) [staged-rows unstaged-rows])
    ;   (write-lines const.no-plugins))
    (write-section unstaged-title unstaged-rows)
    (write-section staged-title staged-rows)
    (write-section in-sync-title in-sync-rows)
    (write-section waiting-title waiting-rows)
    (write-rows const.usage)

    (if _G.__pact_debug
      (let [lines (E.map #$1
                         #(string.gmatch (inspect _G.__pact_debug) "([^\n]+)"))]
        (write-lines lines)))

    (api.nvim_buf_set_option ui.buf :modifiable false)))

Render
