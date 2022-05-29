;; note relrequire check path is slightly different here than other modules, as
;; donut is not postfixed with a dot. It should really check for .init also
(local relrequire ((fn [ddd] #(require (.. (or (string.match ddd "(.+%.)donut") "") $1))) ...))

{:gen (relrequire :donut.gen)
 :seq (relrequire :donut.seq)}
 ;:monad (relrequire :donut.monad)}
