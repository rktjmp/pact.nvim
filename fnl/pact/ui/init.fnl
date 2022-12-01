(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use enum :pact.lib.ruin.enum
     scheduler :pact.workflow.scheduler
     {: subscribe} :pact.pubsub
     result :pact.lib.ruin.result
     api vim.api
     {:format fmt} string
     status-wf :pact.workflow.git.status)

(fn open-win [ui]
  (let [api vim.api
        buf (api.nvim_create_buf false true)
        win (api.nvim_open_win buf true {:relative :editor
                                         :row 4
                                         :col 4
                                         :width 80
                                         :height 20
                                         :style :minimal})]
    (doto win
      (api.nvim_win_set_option :wrap false))

    (doto buf)

    (tset ui :buf buf)))

(fn output [ui]
  (fn p [section-name]
    (enum.map #(let [s (. ui :sections section-name $2.id)]
                     (if s (.. $2.name " " s)))
                  ui.plugins))

  (let [lines (enum.reduce (fn [lines _ name]
                             (-> lines
                                 (enum.append$ (.. "--- " name " ---"))
                                 (enum.concat$ (p name))))
                           [] [:awaiting :stale :uptodate])]
    (api.nvim_buf_set_lines ui.buf 0 -1 false lines)))

(fn exec-status [ui]
  (output ui)
  (subscribe ui.scheduler
            (fn*
              (where [wf [:ok {:actions a}]])
              (let [plugin (enum.find-value #(= wf.id $2.id) ui.plugins)
                    [t msg] (match a
                              [:sync commit] [:stale (fmt "sync %s" commit)]
                              [:clone commit] [:stale (fmt "clone %s" commit)]
                              [] [:uptodate "no update required"])
                    plugin-id wf.id]
                (print :ok wf)
                (tset ui :sections :awaiting wf.id nil)
                (tset ui :sections t wf.id msg)
                (output ui))
              (where [wf [:err e]])
              (do
                (print :err wf)
                (tset ui :sections :awaiting wf.id (string.gsub e "\n" ""))
                (output ui))
              ;; string events are just status messages
              ;; TODO this wont work when running an update in "stale" section
              (where [wf msg] (string? msg))
              ;; update awaiting
              (let [plugin-id wf.id]
                (print :msg wf)
                (tset ui :sections :awaiting wf.id msg)
                (output ui))
              (where _)
              (print :??? (vim.inspect (. [...] 1)))))
  (fn queue-plugin [_ plugin]
    (scheduler.add-workflow ui.scheduler (status-wf.new
                                           plugin.id
                                           plugin.source
                                           plugin.package-path
                                           plugin.constraint)))
  (enum.map queue-plugin ui.plugins))

(fn new [plugins]
  (let [awaiting (enum.reduce #(enum.set$ $1 $3.id "waiting for scheduler") {} plugins)
        ui {: plugins
            :scheduler (scheduler.new)
            :sections {:awaiting awaiting
                       :stale []
                       :uptodate []}}]
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
