;;; pact.luarocks.rock
;;;
;;; Represents a luarocks rock.
;;;

(import-macros {: ruin!} :pact.lib.ruin)
(ruin!)

(use E :pact.lib.ruin.enum
     {:format fmt} string)

(local Rock {})

(λ Rock.new [name version revision]
  ;; luarocks can have a rockspec or src ... source but i dont think that
  ;; matters for us.
  {: name
   : version
   : revision})

(fn Rock.search-results->rocks [results]
  ;; Convert a luarocks search <name> into a rock with list of versions
  )

Rock
