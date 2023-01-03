;;; pact.ui.render.layout
;;;
;;; Handles creation of "render rows", nested tree data structures describing
;;; the text and metadata for rows, columns and column chunks

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     {:format fmt} string)

(local Layout {})

(fn Layout.mk-chunk [text ?hl ?len] {:text text
                              :highlight (or ?hl :PactComment)
                              :length (or ?len (length (or text "")))})

(fn Layout.mk-col [...] [...])

(fn Layout.mk-content [...] [...]) ;; TODO content seems ne-needed? or at least rebrand as "mk-colums"?

(fn Layout.mk-row [content ?meta] {:content content :meta (or ?meta {})})

(fn Layout.mk-basic-row [text]
  "Helper function to create a one-column row containing some text"
  (Layout.mk-row
    (Layout.mk-content
      (Layout.mk-col
        (Layout.mk-chunk text :PactComment)))))

(fn Layout.rows->lines [rows]
  "Convert render-rows into text-lines to be inserted into the buffer."
  (fn decomp-line [line-chunks]
    ;; combine column chunks into columns into lines
    (-> (E.map #(-> (E.map (fn [{: text}] text) $)
                    (table.concat ""))
               line-chunks)
        (table.concat "")))
  (E.map #(decomp-line $.content) rows))

(fn Layout.rows->extmarks [rows]
  "Convert render-rows into processable extmark ranges."
  (var cursor 0)
  (fn decomp-column [column]
    ;; combine column chunks into [{: hl : start : stop} ...]
    (-> (E.reduce (fn [data {: text : highlight}]
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
    (-> (E.map decomp-column line.content)
        (E.flatten)
        (E.append$ (E.merge$ line.meta
                            {:meta true}))))
  (E.map decomp-line rows))

Layout
