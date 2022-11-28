(import-macros {: use : relative-mod}
               (.. (or (-?> ... (string.match "(.+%.)ruin")) "") :use))

(local use-path (relative-mod :use.kernel &from "ruin"))
(local let-path (relative-mod :let.kernel &from "ruin"))
(local fn-path (relative-mod :fn.kernel &from "ruin"))
(local match-path (relative-mod :match.kernel &from "ruin"))
(local type-path (relative-mod :type.kernel &from "ruin"))

(fn ruin! [...]
  (let [mods [let-path fn-path match-path type-path use-path]]
    (accumulate [body [] _ path (ipairs mods)]
      (let [s (gensym)]
        (doto body
          (table.insert `(import-macros {:kernelise s#} ,path))
          (table.insert `(s#)))))))

{: ruin!}
