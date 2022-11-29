;; string match slightly different here as we're in the root mod
;; and it's simpler to just build most things manually.
(import-macros {: relative-root}
               (.. (or (-?> ... (string.match "(.+)")) "") :.use))


(local root (.. (relative-root &from "ruin") :ruin.))
(local use-path (.. root :use.kernel))
(local let-path (.. root :let.kernel))
(local fn-path (.. root :fn.kernel))
(local match-path (.. root :match.kernel))
(local type-path (.. root :type.kernel))

(fn ruin! [...]
  (let [mods [let-path fn-path match-path type-path use-path]]
    (accumulate [body [] _ path (ipairs mods)]
      (let [s (gensym)]
        (doto body
          (table.insert `(import-macros {:kernelise s#} ,path))
          (table.insert `(s#)))))))

{: ruin!}

