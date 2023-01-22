;;; pact.ui.render

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     R :pact.lib.ruin.result
     Log :pact.log
     Package :pact.package
     Constraint :pact.package.git.constraint
     Commit :pact.package.git.commit
     inspect :pact.inspect
     api vim.api
     {: mk-row : mk-col : mk-chunk : mk-content : mk-basic-row
      : rows->extmarks : rows->lines} :pact.ui.layout
     {:format fmt} string)

(local Render {})

;; TODO use a proper delta timer
(var last-time 0)
(var spinner-frame 0)

(fn package-configuration-error? [package]
  (or (R.err? package)
      (E.any? #(R.err? $)
              #(Package.iter [package] {:include-err? true}))))

(fn package-loading? [package]
  (E.any? #(not (Package.ready? $1))
          #(Package.iter [package])))

;; These are intended to be applied in order, where staged packages are
;; not checked for unstaged and those are not checked for up-to-date.
(fn package-staged? [package]
  ;; any package in the tree is set to align or discard
  (E.any? #(or (and (not (Package.installed? $))
                    (Package.aligning? $))
               (and (Package.installed? $)
                    (or (Package.aligning? $)
                        (Package.discarding? $))))
          #(Package.iter [package])))

(fn package-unstaged? [package]
  ;; any package in the tree is not aligned
  (and (not (package-staged? package))
       (E.any? #(not (Package.aligned? $1))
               #(Package.iter [package]))))

(fn package-up-to-date? [package]
  (and (not (package-unstaged? package))
       (E.all? #(Package.aligned? $1)
               #(Package.iter [package]))))

(fn rate-limited-inc [value]
  ;; only increment n at a fixed fps
  ;; uv.now increments only at the event loop start, but this is ok for us.
  (let [every-n-ms (/ 1000 30)
        now (vim.loop.now)]
    (if (< every-n-ms (- now last-time))
      (do
        (set last-time now)
        (+ value 1))
      value)))

(fn workflow-active-symbol [progress]
  (let [symbols [:◐ :◓ :◑ :◒]] ; symbols [:○ :◯ :◉] symbols [:⁐ :‿ :⁀] symbols [:⍐ :⍗] symbols [:∫ :∬ :∭]
    (. symbols (+ 1 (% progress (length symbols))))))

(fn workflow-waiting-symbol [] "⧖")

(fn package-tree->ui-data [packages section-id]
  "Extract and construct UI specific data from packages while also flattening the tree."
  (use Package :pact.package
       Runtime :pact.runtime)
  ;; TODO: wrap in result? otherwise keep duplicating some fields to error for
  ;; simpler view construction or otherwise flag
  (let [configuration-error #{:uid :error
                              :name (R.unwrap $1)
                              :health (Package.Health.failing "")
                              :indent (length $2)}
        package-data (fn [node history]
                       (-> {:working? (< 0 node.tasks.active)
                            :waiting? (< 0 node.tasks.waiting)
                            :error? false
                            :loading? false
                            :staged? false
                            :unstaged? false
                            :up-to-date? false
                            :last-event (do
                                          (-> (inspect (?. node :events 1 2) true)
                                              (string.gmatch "([^\n]+)")
                                              (E.map node)
                                              (table.concat " ")))
                            :indent (length history)
                            :error (match (E.last node.events)
                                     (where e (R.err? e)) (R.unwrap e)
                                     _ nil)}
                           (E.set$ (.. section-id :?) true)
                           (setmetatable {:__index node})))]
    (E.map (fn [node history]
             (if (R.err? node)
               (configuration-error node history)
               (package-data node history)))
           #(Package.iter packages {:include-err? true}))))

(fn ui-data->rows [ui-data section-id]
  (fn indent-with [n]
    (match n
      0 ""
      1 " └"
      n (fmt " %s└" (string.rep " " (- n 0)))))

  (fn indent-width [n]
    ;; (length) will show bytes not char width
    (match (indent-with n)
      "" 0
      s (-> (length s)
            (- 2))))

  (fn* package->columns)

  (fn+ package->columns (where [err] (= err.uid :error))
    (mk-row
      (mk-content
        (mk-col)
        (mk-col
          (mk-chunk (indent-with err.indent)
                    :PactComment
                    (indent-width err.indent))
          (mk-chunk err.name :PactPackageFailing)))
      {:error true}))

  (fn+ package->columns [package]
    ;; Each column may contain multiple "chunk" tables, which describe
    ;; text content, highlight group and optionally length. Length may be
    ;; specifically included as it must be utf8 aware, and the chunk generator
    ;; best knows how to do that curently.

    ;; The symbology needed for a package state is complex.
    ;;
    ;; At an individual package level, the action may be:
    ;;
    ;; align - the package will under go some kind of change to align with its constraint
    ;; discard - the package will be discarded
    ;; hold - the package will remain at its current state, whatever that is
    ;;
    ;; If a package *can* undergo alignment, we show the potential action in
    ;; some diminished way, and if a package *will* undergo alignment, we want
    ;; to call that out stronger.
    ;;
    ;; This is complicated when viewing a tree, as A -> B, when B will undergo alignment
    ;; A will appear in the "staged" section as its tree will incur a change, but A itself
    ;; may not be re-aligned -- but *may be able to undergo alignment*!
    (use {: installed? : aligned?} Package)
    (fn action-data [package]
      (match [section-id (if (installed? package) :existing :new) package.action]
        [:staged :existing :retain] [:will :hold]
        [:staged :existing :discard] [:will :discard]
        [:staged :existing :align] [:will :sync]

        [:unstaged :existing :retain] [:can :sync]
        ; [:unstaged :existing :discard] :discard
        [:unstaged :existing :align] [:can :sync]

        [:up-to-date :existing :retain] [:will :hold]
        ; [:up-to-date :existing :discard] :discard
        ; [:up-to-date :existing :align] :sync

        ; [:staged :new :retain] :hold
        [:staged :new :discard] [:can :install]
        [:staged :new :align] [:will :install]

        ; [:unstaged :new :retain] :install
        [:unstaged :new :discard] [:can :install]
        [:unstaged :new :align] [:can :install]
        [_ _ action] [:will (.. "_" action "_")]))
    (fn s->camel [s]
      (match [(string.match s "([%w])([%w]*)(.*)")]
        [a b nil] (.. (string.upper a) (or b ""))
        [a b rest] (.. (string.upper a) (or b "") (s->camel rest))
        _ s))
    (fn nice-action [package]
      (let [[verb name] (action-data package)
            hl (.. :Pact :Package (s->camel verb) (s->camel name))]
        (mk-chunk name hl)))
    (λ highlight-for-health [h]
      (match h
        ; [:healthy] :DiagnosticInfo
        [:degraded] :PactPackageDegraded
        [:failing] :PactPackageFailing))

    (let [commits-col (mk-col
                        (if package.git
                          (let [from (?. package.git.current.commit :short-sha)
                                to (?. package.git.target.commit :short-sha)
                                distance package.git.target.distance
                                direction (if (and distance (< 0 distance)) "ahead" "behind")
                                breaking? (?. package.git.target :breaking?)
                                constraint package.constraint
                                name (match (Constraint.type constraint)
                                       :version (-> (E.map #$
                                                           (or (?. package.git.target :commit :versions) []))
                                                    (table.concat ","))
                                       :head :HEAD
                                       :commit (Commit.abbrev-sha (Constraint.value constraint))
                                       _ (Constraint.value constraint))
                                hl #(if breaking? :PactPackageBreaking :PactPackageText)
                                warn #(if breaking? "⚠ " "")]
                            (match [from to distance]
                              [nil nil _] (mk-chunk (fmt "%s" :...) :PactComment)
                              [nil to _] (mk-chunk (fmt "%s" name) :PactPackageText)
                              [same same _] (mk-chunk (fmt "%s" name) :PactPackageText)
                              [from to count] (let [x (fmt "%s%s (%s %s)" (warn) name (math.abs count) direction)
                                                    ;; correct for /!\ sym
                                                    len (+ (length x) (match (warn) "" 0 _ -2))]
                                                    (mk-chunk x (hl) len))))
                          (mk-chunk "")))
          name-col (mk-col
                     (mk-chunk (indent-with package.indent)
                               :PactComment
                               (indent-width package.indent))
                     (mk-chunk package.name
                               (match (highlight-for-health package.health)
                                 hl hl
                                 nil :PactPackageName))
                     (match package.transaction
                       any (mk-chunk (fmt " (t %s)" any))
                       _ (mk-chunk "")))
          constraint-col (mk-col
                           (mk-chunk (match (Constraint.type package.constraint)
                                       :version (Constraint.value package.constraint)
                                       :head :HEAD
                                       :commit (.. "^" (Commit.abbrev-sha (Constraint.value package.constraint)))
                                       :tag (.. "#" (Constraint.value package.constraint))
                                       _ (Constraint.value package.constraint))))
          action-col (mk-col
                       (nice-action package))
          latest-col (mk-col
                       (match [(?. package :git :latest :commit)
                               (?. package :git :target :commit)]
                         [{: sha} {: sha}] (mk-chunk "")
                         [a _] (mk-chunk (fmt "(%s)" (table.concat a.versions ",")))
                         _ (mk-chunk "")))]
      {:content (mk-content
                  action-col
                  name-col
                  constraint-col
                  commits-col
                  latest-col)
       :meta {:uid package.uid
              :workflow (match [package.working? package.waiting?]
                          [true _] {:text (workflow-active-symbol spinner-frame)
                                    :highlight :PactSignWorking}
                          [_ true] {:text (workflow-waiting-symbol (vim.loop.gettimeofday))
                                    :highlight :PactSignWaiting})
              :logs (match (?. package :git :target :logs)
                      logs (E.map (fn [line]
                                    (match (string.match line "^(%x+)%s+(.+)$")
                                      (sha message) [[(Commit.abbrev-sha sha) :PactComment]
                                                     [" " :Normal]
                                                     [message :PactPackageText]]
                                      _ [[line :PactComment]]))
                                  logs))
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
                        _ nil
                        ; :align {:text "⍙"
                        ;        :highlight :DiagnosticOk}
                        ; :retain {:text "⍑"
                        ;        :highlight :PactComment}
                        )
              :health (match package.health
                         [:healthy] nil
                         [:degraded msg] {:text (tostring msg) :highlight :PactPackageDegraded}
                         [:failing msg] {:text (tostring msg) :highlight :PactPackageFailing})}}))

  ;; convert each package into a collection of columns, into a collection of lines
  (E.map #(package->columns $) ui-data))

(fn inject-padding-chunks [rows widths]
  ;; Each row has columns, but they are not intrinsically aligned in the data
  ;; we need to work out what the padding should be for each column on each
  ;; line and add that as a new chunk in the line.
  ;; It must be added as a new chunk so we can avoid over-highlight backgrounds
  ;; when we apply the extmarks.
  (let [sum-col-chunk-widths #(E.reduce
                                #(let [{: text :length len} $2]
                                   (match [text len]
                                     [nil nil] $1
                                     [any nil] (+ $1 (length text))
                                     [_ any] (+ $1 len)
                                     _ $1))
                                0 $1)]
    ;; now we can re-iterate the columns and inject a padding chunk
    (E.map (fn [row]
             {:meta row.meta
              :content (E.map (fn [column col-n]
                                (let [cur-width (sum-col-chunk-widths column)
                                      padding (- (or (. widths col-n) 0) cur-width)]
                                  ;; TODO performance if needed, drop copy for each
                                  (if (< 0 padding)
                                    (E.concat$ [] column [{:text (string.rep " " padding)
                                                           :highlight "None"}])
                                    (E.concat$ [] column))))
                              row.content)})
           rows)))

(λ intersperse-column-gutters [rows]
  "Add gaps between columns"
  (E.map #{:meta $.meta
           :content (E.intersperse $.content [{:text " " :highlight "PactComment"}])}
         rows))

(fn row->column-widths [row]
  (fn width-of-column [column]
    (E.reduce #(let [{: text :length len} $2]
                 (match [text len]
                   [nil nil] $1
                   [any nil] (+ $1 (length text))
                   [_ any] (+ $1 len)
                   _ $1))
              0 column))
  (E.map width-of-column row.content))

(fn widths->maximum-widths [widths]
  (E.reduce (fn [col-max col-widths]
              ;; note we use each as some cols may not contain all (or any)
              ;; values and we want to retain any seen.
              (E.each (fn [width col-n]
                        (E.set$ col-max col-n (math.max (or (. col-max col-n) 0)
                                                        width)))
                      col-widths)
              col-max) {} widths))

(fn find-maximum-column-widths [rows]
  (->> rows
       ;; get width of each column of each row
       (E.map row->column-widths)
       ;; find max width of each column
       (widths->maximum-widths)))

(local const {:lede [(mk-basic-row ";; 🔪🩸🐐")
                     (mk-basic-row ";; (some things are ugly right now, sorry)")
                     (mk-basic-row "")]
              :blank [(mk-basic-row "")]
              :no-plugins [(mk-basic-row ";;")
                           (mk-basic-row ";; Whoops!")
                           (mk-basic-row ";;")
                           (mk-basic-row ";; pact has no plugins defined! See `:h pact-usage`")
                           (mk-basic-row ";;")
                           (mk-basic-row ";; Since 0.0.10 you need to wrap your plugins inside `make-pact`/`make_pact`!")
                           (mk-basic-row ";; You may also have to reinstall your plugins.")
                           (mk-basic-row ";;")]
              :usage [(mk-basic-row "")
                      (mk-basic-row ";; Usage:")
                      (mk-basic-row ";;")
                      (mk-basic-row ";;   s  - Stage package tree in transaction")
                      (mk-basic-row ";;   u  - Unstage package tree in transaction")
                      (mk-basic-row ";;   d  - Discard package tree in transaction")
                      (mk-basic-row ";;   cc - Commit transaction")
                      (mk-basic-row ";;   =  - View git log (staged/unstaged only)")]})

(λ group-packages-by-section [packages]
  ;; we intentionally only iterate the "top" packages so sub-packages
  ;; are nested inside the correct parent && section.
  (E.reduce (fn [grouped [f key]]
              (let [{true g false r} (E.group-by f grouped.rest)]
                (doto grouped
                      (tset key (or g []))
                      (tset :rest (or r [])))))
            {:rest packages}
            ;; these intentionally cascade,
            ;; something that matches aligning 
            [[package-configuration-error? :error]
             [package-loading? :loading]
             [package-staged? :staged]
             [package-unstaged? :unstaged]
             [package-up-to-date? :up-to-date]]))

(fn Render.output [ui]
  ; (let [now (vim.loop.now)
  ;       last (or ui.last-run-at now)]
  ;   (set ui.last-run-at now)
  ;   (print :outp (- now last)))
  ;; We always operate on the top level packages, as we want to group
  ;; package-trees not separate packages.
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
  (set spinner-frame (rate-limited-inc spinner-frame))
  (let [sections (group-packages-by-section ui.runtime.packages)
        ;; We must create stub sections first which contains the text content
        ;; but none of it will be aligned.
        rows (E.reduce (fn [acc section id]
                         (E.set$ acc id (-> section
                                            (package-tree->ui-data id)
                                            (ui-data->rows id))))
                       {} sections)
        header-rows [(mk-row
                       (mk-content
                         (mk-col
                           (mk-chunk "action" :PactColumnTitle))
                         (mk-col
                           (mk-chunk "package" :PactColumnTitle))
                         (mk-col
                           (mk-chunk "target" :PactColumnTitle))
                         (mk-col
                           (mk-chunk "solved" :PactColumnTitle))
                         (mk-col
                           (mk-chunk "(latest)" :PactColumnTitle))))]
        ;; get the max widths of every section, then the max width between sections
        ;; which will then dictate the padding needed across all lines.
        column-widths (->> (E.map #(->> (E.map row->column-widths $)
                                        (widths->maximum-widths))
                                  (E.filter #(not (?. $ :meta :error)) rows))
                           (E.concat$ (E.map row->column-widths header-rows))
                           (widths->maximum-widths))
        ;; now that we know column widths we can insert padding chunks into every column
        ;; so they all align.
        rows (E.reduce (fn [acc section id]
                         (E.set$ acc id (-> section
                                            (inject-padding-chunks column-widths)
                                            (intersperse-column-gutters))))
                       {} rows)
        header-rows (-> header-rows
                        (inject-padding-chunks column-widths)
                        (intersperse-column-gutters))
        ;; Generate title lines. These dont follow the strict alignment and need us to know
        ;; the row counts before creation.
        titles (E.reduce (fn [acc section id]
                           (E.set$ acc id [(mk-row
                                             (mk-content
                                               (mk-col (mk-chunk (string.upper id) :PactSectionTitle)
                                                       (mk-chunk (fmt " (%s)" (length section)) :PactComment))))]))
                      {} rows)]
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
        (E.each (fn [marks line]
                  (E.each (fn [mark]
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
                              (if mark.logs
                                (api.nvim_buf_set_extmark ui.buf ui.ns-meta-id line 0
                                                          {:virt_lines mark.logs}))


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
        (write-rows header-rows)
        (write-rows section)
        (write-rows const.blank)))

    (api.nvim_buf_set_option ui.buf :modifiable true)

    (write-rows const.lede)

    (if (E.all? #(= 0 (length $)) rows)
      (write-rows const.no-plugins)
      (do
        (write-section titles.error rows.error)
        (write-section titles.rest rows.rest)
        (write-section titles.loading rows.loading)
        (write-section titles.unstaged rows.unstaged)
        (write-section titles.staged rows.staged)
        (write-section titles.up-to-date rows.up-to-date)))

    (write-rows const.usage)

    ;; clear tail
    (api.nvim_buf_set_lines ui.buf cursor-line -1 false [])
    (api.nvim_buf_set_option ui.buf :modifiable false)))

Render
