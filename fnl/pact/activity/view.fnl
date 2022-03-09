(import-macros {: raise : expect} :pact.error)
(import-macros {: struct} :pact.struct)

(local {: inspect : monotonic-id : fmt} (require :pact.common))
(local is-a-type :pact/view)
(local api vim.api)

(fn view-ready? [view]
  ;; Check view has been run in vim.schedule and is ready for use.
  ;; also check if id's are actually valid, which maybe makes this check
  ;; over-greedy and may swallow/misdirect some bugs? TODO
  (and (not (= -1 view.buf view.win))
       (not (= nil view.buf view.win))
       (api.nvim_win_is_valid view.win)
       (api.nvim_buf_is_valid view.buf)))

(fn set-content [view lines]
  "Set content of given view to given lines"
  (expect (= is-a-type view.is-a) argument "must be given view")
  (expect (= :table (type lines)) argument "must be given table")

  (fn unsafe []
    (when (view-ready? view)
      (doto view.buf
        (api.nvim_buf_set_option :modifiable true)
        (api.nvim_buf_set_lines 0 -1 false lines)
        (api.nvim_buf_set_option :modifiable false))))

  (vim.schedule unsafe))

(fn close [view]
  "Close given view"
  (expect (= is-a-type view.is-a) argument "must be given view")

  (fn unsafe []
    (when (view-ready? view)
      (api.nvim_win_close view.win true)))

  (vim.schedule unsafe))

(fn columnise-data [data fixed-widths]
  "Convert list of lists into list of strings where each sublist item is aligned.
  Assumes sublists are all of equal length."
  (fn find-widths [sub-data]
    (icollect [_ part (ipairs sub-data)]
      (length part)))

  (let [fixed-widths (or fixed-widths [])
        widths (accumulate [maxes [] _ line (ipairs data)]
                 (icollect [i width (ipairs (find-widths line))]
                   (let [max (or (. maxes i) 0)]
                     (match (. fixed-widths i)
                       nil (if (< max width) width max)
                       fixed fixed))))
        format (accumulate [s "" i width (ipairs widths)]
                 (if (= i (length widths))
                     (.. s "%s")
                     (.. s (fmt "%%-%ds " width))))]
    (icollect [_ line (ipairs data)]
      (fmt format (unpack line)))))

(fn new [opts]
  "Create a new window. Accepts
  {:on-close [send-target args...]
   :keymap {:normal {:ab [send-target args...]}}}"

  (local opts (or opts {}))
  (tset opts :keymap (or opts.keymap {}))
  (tset opts.keymap :normal (or opts.keymap.normal {}))
  (tset opts :on-close (or opts.on-close nil))
  ;; define context early so vim.schedule can see and update values
  (local context (struct pact/view
                         (attr buf -1 mutable show)
                         (attr win -1 mutable show)))

  (fn unsafe []
    (api.nvim_command "botright vnew")
    (let [{: view} (require :pact.common)
          win (api.nvim_get_current_win)
          buf (api.nvim_get_current_buf)
          normal-keymaps (collect [key [to & args] (pairs opts.keymap.normal)]
                           (values key
                                   #(let [{: send} (require :pact.pubsub)]
                                      (send to (unpack args)))))
          on-close (match opts.on-close
                     nil #(values nil)
                     [to & args] #(let [{: send} (require :pact.pubsub)]
                                    (send to (unpack args))))]
      (doto buf
        (api.nvim_buf_set_name (.. :pact-ui- buf))
        (api.nvim_buf_set_option :modifiable false)
        (api.nvim_buf_set_option :buftype :nofile)
        (api.nvim_buf_set_option :swapfile false)
        (api.nvim_buf_set_option :bufhidden :wipe)
        (api.nvim_buf_set_option :filetype :pact))
      ;; bind normal mode keys
      (each [key callback (pairs normal-keymaps)]
        (api.nvim_buf_set_keymap buf :n key ""
                                 {:nowait true
                                  :noremap true
                                  :silent true
                                  : callback}))
      ;; bind window close handler
      (api.nvim_create_autocmd :WinClosed
                               {:buffer buf :once true :callback on-close})
      (doto win
        (api.nvim_win_set_option :wrap false))
      (doto context
        (tset :buf buf)
        (tset :win win))))

  (vim.schedule unsafe)
  (values context))

{: new : close : set-content : columnise-data}
