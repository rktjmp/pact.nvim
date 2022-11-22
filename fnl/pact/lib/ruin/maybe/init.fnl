(import-macros {: use}
               (.. (or (-?> ... (string.match "(.+%.)maybe")) "") :use))

(use {: type-of} :type &from :maybe
     enum :enum &from :maybe
     {: 'def-either} :either &from :maybe)

(def-either {:name :maybe
             :docstring "A `none' holds a `nil` value and only matches when called with at most 1 `nil` or no arguments.

`some' may hold as many values as given.

Ex,

`(maybe nil) -> none`

`(maybe) -> none`

`(maybe 1) -> some`

`(maybe 1 2 3) -> some`

"
             :left {:id :ruin.maybe.NONE_TYPE
                    :name :none
                    :unit {
                           ;; strictly matches 1 value, nil or 0 nil
                           :match (where _ (or (= arguments.n 0)
                                               (and (= arguments.n 1) (= nil (. arguments 1)))))
                           :value nil}
                    }
             :right {:id :ruin.maybe.SOME_TYPE
                     :name :some
                     ;; matches any thing that is not none
                     :unit {:match (where _ (and (< 0 arguments.n)
                                                 (not= nil (. arguments 1))))
                            :value (unpack arguments)}}})
