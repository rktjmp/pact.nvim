(local uv vim.loop)

(fn has-all-keys? [map keys]
  "Does given map have every given key?"
  (accumulate [present? true _ key (ipairs keys) :until (not present?)]
    (and present? (not (= (. map key) nil)))))

(fn has-any-key? [map keys]
  "Does given map have at least one of the given keys?"
  (accumulate [present? false _ key (ipairs keys) :until present?]
    (not (= nil (. map key)))))

(fn inspect [...]
  "print fennel.view of arguments, then return arguments"
  (let [{: view} (require :fennel)]
    (print (view [...]))
    (values ...)))

(fn view [...]
  (let [{: view} (require :fennel)]
    (view ...)))

(fn pathify [start ...]
  (let [sep "/"
        path (accumulate [path start _ part (ipairs [...])]
               (.. path sep part))]
    path))

;; TODO: deprecate for typeof
(fn is-a [given]
  (match (type given)
    :table (match given.is-a
             nil :table
             val val)
    other other))

(fn set-mt [id ?prefix]
  (let [fmt string.format
        t {: id}
        tos #(fmt "%s#%d" (or ?prefix "monotonic-id") id)
        mt {:__tostring tos
            :__fennelview tos
            :__call #(values id)
            :__index #(match $2
                        :is-a :monotonic-id
                        :value id
                        _ (error "monotonic-id only has value attribute"))
            :__newindex #(error "cant set monotonic-id attributes")}]
    (setmetatable {} mt)))

(fn gen [fix]
  (var count 0)
  (var prefix fix)
  (while true
    (set count (+ count 1))
    (let [id (set-mt count prefix)]
      (set prefix (coroutine.yield id)))))

(local monotonic-id (coroutine.wrap gen))

{:fmt string.format
 : pathify
 : inspect
 : view
 : is-a
 : has-all-keys?
 : has-any-key?
 : monotonic-id}
