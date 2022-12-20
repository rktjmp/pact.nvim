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
        symbols [:○
                 :◯
                 :◉]
        symbols [:⍐ :⍗]
        symbols [:∫
                 :∬
                 :∭]
        ]
    (. symbols (+ 1 (% progress (length symbols))))))

(fn workflow-waiting-symbol [] "⧖")

(λ highlight-for-health [h]
  (match h
    [:healthy] :DiagnosticInfo
    [:degraded] :DiagnosticWarn
    [:failing] :DiagnosticError))

(fn mk-chunk [text ?hl ?len] {:text text
                              :highlight (or ?hl :PactComment)
                              :length (or ?len (length text))})
(fn mk-col [...] [...])
(fn mk-content [...] [...])
(fn mk-row [content ?meta] {:content content :meta (or ?meta {})})
(fn mk-basic-row [content] (mk-row (mk-content (mk-col (mk-chunk content :PactComment)))))


(fn package-tree->ui-data [packages]
  "Extract and construct UI specific data from packages"
  (use Package :pact.package
       Runtime :pact.runtime)
  ;; TODO: wrap in result? otherwise keep duplicating some fields to error for
  ;; simpler view construction or otherwise flag
  (let [configuration-error #{:uid :error
                              :name (R.unwrap $1)
                              :constraint ""
                              :health (Package.Health.failing "")
                              :indent (length $2)}
        package-data #{:uid $1.uid
                       :name $1.name
                       :health $1.health
                       :git {:checkout {:commit (?. $ :git :checkout :HEAD)}
                             :target {:commit (?. $ :git :target :commit)
                                      :logs (?. $ :git :target :logs)}
                             :latest {:commit (?. $ :git :latest :commit)}}
                       :working? (E.any? #$1.timer $1.workflows)
                       :waiting? (E.any? #$1 $1.workflows)
                       :constraint $1.constraint
                       :last-event (do
                               (-> (inspect (?. $ :events 1 2) true)
                                   (string.gmatch "([^\n]+)")
                                   (E.map $1)
                                   (table.concat " ")))
                       :distance (length (or (?. $ :git :target :logs) []))
                       :breaking? (?. $ :git :target :breaking?)
                       :logs (?. $ :git :target :logs)
                       :indent (length $2)
                       :action (?. $ :action 1)
                       :events $1.events
                       :error (match (E.last $1.events)
                                (where e (R.err? e)) (R.unwrap e)
                                _ nil)}]
    (E.map (fn [node history]
             (if (R.err? node)
               (configuration-error node history)
               (package-data node history)))
           #(Package.iter packages {:include-err? true}))))

(fn ui-data->rows [ui-data]
  (fn indent-with [n]
    (match n
      0 ""
      1 " └" ; ⁐‿⁀
      n (fmt " %s└" (string.rep " " (- n 0)))))

  (fn indent-width [n]
    ;; (length) will show bytes not char width
    (match (indent-with n)
      "" 0
      s (-> (length s)
            (- 2))))

  (fn package->columns [package]
    ;; Columns should be roughly:
    ;;
    ;; name | constraint | action/newer? | message
    ;;
    ;; Each column may contain multiple "chunk" tables, which describe
    ;; text content, highlight group and optionally length. Length may be
    ;; specifically included as it must be utf8 aware, and the chunk generator
    ;; best knows how to do that curently.
    (let [{: name : last-event : state : constraint : indent} package
          commits-col (mk-col
                        (if package.git
                          (let [from (?. package.git.checkout.commit :short-sha)
                                to (?. package.git.target.commit :short-sha)
                                count (match (?. package.git.target.logs)
                                        nil ""
                                        l (length l))]
                            (match [from to count]
                              [nil nil _] (mk-chunk :unknown :PactComment)
                              [nil to _] (mk-chunk :clone :DiagnosticInfo)
                              [same same _] (mk-chunk :in-sync :DiagnosticInfo)
                              [from to _] (mk-chunk (fmt "%s ahead" count) :DiagnosticInfo)))
                          (mk-chunk "")))
          name-col (mk-col
                     (mk-chunk (indent-with indent)
                               :PactComment
                               (indent-width indent))
                     (mk-chunk name
                               (highlight-for-health package.health)))
          constraint-col (mk-col
                           (mk-chunk (tostring constraint)
                                     (highlight-for :staged :text)))
          latest-col (mk-col
                       (match (?. package :git :latest :commit)
                         c (mk-chunk (fmt " (%s)" (table.concat c.versions ",")))
                         _ (mk-chunk "")))]
      {:content (mk-content
                  name-col
                  constraint-col
                  latest-col
                  commits-col)
       :meta {:uid package.uid
              :workflow (match [package.working? package.waiting?]
                          [true _] {:text (workflow-active-symbol (vim.loop.now))
                                    :highlight :DiagnosticInfo}
                          [_ true] {:text (workflow-waiting-symbol (vim.loop.gettimeofday))
                                    :highlight :Comment})
              :last-event package.last-event
              :error package.error
              :action (match package.action
                        ;☑
                        ;☒ <- parent staged? cant stage?
                        ;☐
                        ;; Feels superfluous until you have a sub-package
                        ;; staged but parent unstaged and need to show the
                        ;; differences. Could be only shown (or shown as
                        ;; virt-lines?) in that case but for its as is.
                        :stage {:text "⍙"
                                :highlight :DiagnosticOk}
                        :hold {:text "⍑"
                               :highlight :PactComment})
              :health (match package.health
                         [:healthy] nil
                         [:degraded msg] {:text (.. "" msg) :highlight :DiagnosticWarn}
                         [:failing msg] {:text (.. "" msg) :highlight :DiagnosticError})}}))

  ;; convert each package into a collection of columns, into a collection of lines
  (E.map #(package->columns $2) ui-data))

(fn rows->lines [rows]
  (fn decomp-line [line-chunks]
    ;; combine column chunks into columns into lines
    (-> (E.map #(-> (E.map (fn [_ {: text}] text) $2)
                    (table.concat ""))
               line-chunks)
        (table.concat "")))
  (E.map #(decomp-line $2.content) rows))

(fn rows->extmarks [rows]
  (var cursor 0)
  (fn decomp-column [column]
    ;; combine column chunks into [{: hl : start : stop} ...]
    (-> (E.reduce (fn [data _ {: text : highlight}]
                    (let [start cursor
                          ;; note: extmarks are byte-offsets, so no need to use length prop
                          stop (+ cursor (length (or text "")))]
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
        (E.append$ (E.merge$ line.meta
                            {:meta true}))))
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

(local const {:lede [(mk-basic-row ";; 🔪🩸🐐")
                     (mk-basic-row "")]
              :blank [(mk-basic-row "")]
              :no-plugins [(mk-basic-row ";;")
                           (mk-basic-row ";; Whoops!")
                           (mk-basic-row ";;")
                           (mk-basic-row ";; pact has no plugins defined! See `:h pact-usage`")
                           (mk-basic-row ";;")
                           (mk-basic-row ";; Since 0.0.10 you need to wrap your plugins inside `make-pact`/`make_pact`!")
                           (mk-basic-row ";;")]
              :usage [(mk-basic-row "")
                      (mk-basic-row ";; Usage:")
                      (mk-basic-row ";;")
                      (mk-basic-row ";;   s  - Stage plugin for update")
                      (mk-basic-row ";;   u  - Unstage plugin")
                      (mk-basic-row ";;   cc - Commit staging and fetch updates")
                      (mk-basic-row ";;   =  - View git log (staged/unstaged only)")]})

(λ packages->sections [packages]
  ;; Given a list of packages, split then into groups for each UI section
  (let [error? (fn [package]
                 (= package.uid :error))
        waiting? (fn [package]
                   (E.any? #(Package.loading? $1)
                           #(Package.iter [package])))
        in-sync? (fn [package]
                   (E.all? #(Package.in-sync? $1)
                           #(Package.iter [package])))
        staged? (fn [package]
                   (E.any? #(Package.staged? $1)
                           #(Package.iter [package])))
        ;; we intentionally only iterate the "top" packages so sub-packages
        ;; are nested inside the correct parent && section.
        {true error false rest} (E.group-by #(error? $2) packages)
        {true waiting false rest} (E.group-by #(waiting? $2) packages)
        {true in-sync false rest} (E.group-by #(in-sync? $2) (or rest []))
        {true staged false unstaged} (E.group-by #(staged? $2) (or rest []))]
    {:error (or error [])
     :waiting (or waiting [])
     :in-sync (or in-sync [])
     :staged (or staged [])
     :unstaged (or unstaged [])}))

(λ ui-data->log-virt-text [])

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
  ;; indexed and should not use the length key.
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
        {: waiting
         : in-sync
         : staged
         : unstaged
         : error} (packages->sections ui.runtime.packages)
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
    ;; Clear extmarks so we don't have them all pile up. We have to re-make
    ;; then each draw as the lines are re-drawn.
    (set ui.extmarks [])
    ;; It's simplest to just track the current "last line" so we can backtrack
    ;; for extmark drawing
    (var cursor-line 0)
    (fn write-rows [rows]
      (fn write-lines [lines]
        (let [len (length lines)]
          (api.nvim_buf_set_lines ui.buf cursor-line (+ cursor-line len) false lines)
          (set cursor-line (+ cursor-line len))))
      (fn draw-extmarks [lines offset]
        (E.each (fn [line marks]
                  (E.each (fn [_ mark]
                            (let [line (- (+ offset line) 1)]
                              ;; extmark -> package lookup for keymaps
                              (if mark.uid
                                (-> (api.nvim_buf_set_extmark ui.buf ui.ns-meta-id line 0 {})
                                    (#(tset ui.extmarks $1 mark.uid))))

                              ;; health warnings
                              (if mark.health
                                (api.nvim_buf_set_extmark ui.buf ui.ns-meta-id line 0
                                                          {:sign_text "⚠"
                                                           :sign_hl_group mark.health.highlight
                                                           :priority 200
                                                           :virt_text [[mark.health.text mark.health.highlight]]}))

                              (if mark.workflow
                                (api.nvim_buf_set_extmark ui.buf ui.ns-meta-id line 0
                                                          {:sign_text mark.workflow.text
                                                           :priority 110
                                                           :sign_hl_group mark.workflow.highlight}))

                              (if mark.action
                                (api.nvim_buf_set_extmark ui.buf ui.ns-meta-id line 0
                                                          {:sign_text mark.action.text
                                                           :priority 100
                                                           :sign_hl_group mark.action.highlight}))

                              (if mark.last-event
                                (api.nvim_buf_set_extmark ui.buf ui.ns-meta-id line 0
                                                          {:virt_text [[mark.last-event :PactComment]]}))

                              ;; regular highlights
                              (match mark
                                {: start : stop : highlight}
                                (api.nvim_buf_add_highlight ui.buf ui.ns-id highlight line start stop))))

                          marks))
                lines))
      (-> (rows->lines rows)
          (write-lines))
      (-> (rows->extmarks rows)
          (draw-extmarks (- cursor-line (length rows)))))

    (fn write-section [title section]
      (when (not (E.empty? section))
        (write-rows title)
        (write-rows section)
        (write-rows const.blank)))

    (api.nvim_buf_set_option ui.buf :modifiable true)

    (write-rows const.lede)

    (if (E.all? #(= 0 (length $2))
                [staged-rows unstaged-rows waiting-rows in-sync-rows])
      (write-rows const.no-plugins))
    ;; TODO: put waiting at head to any that fail while discovering facts remain in view
    (write-section waiting-title waiting-rows)
    (write-section unstaged-title unstaged-rows)
    (write-section staged-title staged-rows)
    (write-section in-sync-title in-sync-rows)

    (write-rows const.usage)

    (api.nvim_buf_set_option ui.buf :modifiable false)))

Render
