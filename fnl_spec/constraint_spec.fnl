(import-macros {:describe describe} :fnl_spec.macro)

(local req (require :pact.constraint.version))

(describe
  "semver constraint type"
  (it "new"
      (let [v (req.new "> 10.22.12")]
        (assert.not.nil v)
        (assert.equal ">" v.constraint)
        (assert.equal 10 v.major)
        (assert.equal 22 v.minor)
        (assert.equal 12 v.patch))))

(describe
  "satisfies? ="
  :setup {:behind (req.new "= 10.21.12")
          :same (req.new "= 10.22.12")
          :ahead (req.new "= 10.23.12")
          :base (req.new "= 10.22.12")}
  (it "same" (assert.true (req.satisfies? context.base context.same)))
  (it "behind" (assert.false (req.satisfies? context.base context.behind)))
  (it "ahead" (assert.false (req.satisfies? context.base context.ahead))))

(describe
  "satisfies? >"
  :setup {:behind (req.new "= 10.21.12")
          :same (req.new "= 10.22.12")
          :ahead (req.new "= 10.23.12")
          :base (req.new "> 10.22.12")}
  (it "same" (assert.false (req.satisfies? context.base context.same)))
  (it "behind" (assert.false (req.satisfies? context.base context.behind)))
  (it "ahead" (assert.true (req.satisfies? context.base context.ahead))))

(describe
  "satisfies? <"
  :setup {:behind (req.new "= 10.21.12")
          :same (req.new "= 10.22.12")
          :ahead (req.new "= 10.23.12")
          :base (req.new "< 10.22.12")}
  (it "same" (assert.false (req.satisfies? context.base context.same)))
  (it "behind" (assert.true (req.satisfies? context.base context.behind)))
  (it "ahead" (assert.false (req.satisfies? context.base context.ahead))))

(describe
  "satisfies? >="
  :setup {:behind (req.new "= 10.21.12")
          :same (req.new "= 10.22.12")
          :ahead (req.new "= 10.23.12")
          :base (req.new ">= 10.22.12")}
  (it "same" (assert.true (req.satisfies? context.base context.same)))
  (it "behind" (assert.false (req.satisfies? context.base context.behind)))
  (it "ahead" (assert.true (req.satisfies? context.base context.ahead))))

(describe
  "satisfies? <="
  :setup {:behind (req.new "= 10.21.12")
          :same (req.new "= 10.22.12")
          :ahead (req.new "= 10.23.12")
          :base (req.new "<= 10.22.12")}
  (it "same" (assert.true (req.satisfies? context.base context.same)))
  (it "behind" (assert.true (req.satisfies? context.base context.behind)))
  (it "ahead" (assert.false (req.satisfies? context.base context.ahead))))

(describe
  "satisfies? ~"
  :setup {:base         (req.new "~ 10.22.12")
          :patch-behind (req.new "= 10.22.11")
          :patch-same   (req.new "= 10.22.12")
          :patch-ahead  (req.new "= 10.22.13")
          :minor-behind (req.new "= 10.21.12")
          :minor-same   (req.new "= 10.22.99")
          :minor-ahead  (req.new "= 10.23.99")
          :major-behind (req.new "= 9.22.99")
          :major-same   (req.new "= 10.22.99")
          :major-ahead  (req.new "= 11.22.99")}
  (it "patch-same" (assert.true (req.satisfies? context.base context.patch-same)))
  (it "minor-same" (assert.true (req.satisfies? context.base context.minor-same)))
  (it "major-same" (assert.true (req.satisfies? context.base context.major-same)))
  (it "patch-behind" (assert.false (req.satisfies? context.base context.patch-behind)))
  (it "minor-behind" (assert.false (req.satisfies? context.base context.minor-behind)))
  (it "major-behind" (assert.false (req.satisfies? context.base context.major-behind)))
  (it "patch-ahead" (assert.true (req.satisfies? context.base context.patch-ahead)))
  (it "minor-ahead" (assert.false (req.satisfies? context.base context.minor-ahead)))
  (it "major-ahead" (assert.false (req.satisfies? context.base context.major-ahead))))

(describe
  "satisfies? ^ for x.y.z"
  :setup {:base         (req.new "^ 10.22.12")
          :patch-behind (req.new "= 10.22.11")
          :patch-same   (req.new "= 10.22.12")
          :patch-ahead  (req.new "= 10.22.13")
          :minor-behind (req.new "= 10.21.12")
          :minor-same   (req.new "= 10.22.99")
          :minor-ahead  (req.new "= 10.23.99")
          :major-behind (req.new "= 9.22.99")
          :major-same   (req.new "= 10.22.99")
          :major-ahead  (req.new "= 11.22.99")}
  (it "patch-same" (assert.true (req.satisfies? context.base context.patch-same)))
  (it "minor-same" (assert.true (req.satisfies? context.base context.minor-same)))
  (it "major-same" (assert.true (req.satisfies? context.base context.major-same)))
  (it "patch-behind" (assert.false (req.satisfies? context.base context.patch-behind)))
  (it "minor-behind" (assert.false (req.satisfies? context.base context.minor-behind)))
  (it "major-behind" (assert.false (req.satisfies? context.base context.major-behind)))
  (it "patch-ahead" (assert.true (req.satisfies? context.base context.patch-ahead)))
  (it "minor-ahead" (assert.true (req.satisfies? context.base context.minor-ahead)))
  (it "major-ahead" (assert.false (req.satisfies? context.base context.major-ahead))))

(describe
  "satisfies? ^ for 0.y.z"
  :setup {:base         (req.new "^ 0.22.12")
          :patch-behind (req.new "= 0.22.11")
          :patch-same   (req.new "= 0.22.12")
          :patch-ahead  (req.new "= 0.22.13")
          :minor-behind (req.new "= 0.21.12")
          :minor-same   (req.new "= 0.22.99")
          :minor-ahead  (req.new "= 0.23.99")
          ; :major-behind (req.new "= 9.22.99") ; NA
          :major-same   (req.new "= 0.22.99")
          :major-ahead  (req.new "= 1.22.99")}
  (it "patch-same" (assert.true (req.satisfies? context.base context.patch-same)))
  (it "minor-same" (assert.true (req.satisfies? context.base context.minor-same)))
  (it "major-same" (assert.true (req.satisfies? context.base context.major-same)))
  (it "patch-behind" (assert.false (req.satisfies? context.base context.patch-behind)))
  (it "minor-behind" (assert.false (req.satisfies? context.base context.minor-behind)))
  ; (it "major-behind" (assert.false (req.satisfies? context.base context.major-behind)))
  (it "patch-ahead" (assert.true (req.satisfies? context.base context.patch-ahead)))
  (it "minor-ahead" (assert.false (req.satisfies? context.base context.minor-ahead)))
  (it "major-ahead" (assert.false (req.satisfies? context.base context.major-ahead))))

; (describe
;   "resolve!"
;   (fn []
;     (fn make [list]
;       (icollect [_ r (ipairs list)]
;                 (req.new r)))
;     (let [requirements (make [">= 2.0.0" ">= 2.1.2" "~ 2.1.0"])
;           versions (make ["= 2.0.0" "= 2.0.6" "= 2.2.8" "= 2.1.1" "= 2.1.2"])
;           version (req.resolve requirements versions)]
;       (assert.same "= 2.1.2" (tostring version)))

;     (let [requirements (make [">= 2.0.0" "= 2.1.8" "~ 2.1.0"])
;           versions (make ["= 2.0.0" "= 2.0.6" "= 2.2.8" "= 2.1.1" "= 2.1.8"])
;           version (req.resolve requirements versions)]
;       (assert.same "= 2.1.8" (tostring version)))

;     (let [requirements (make ["= 2.0.0" ">= 2.1.2" "~ 2.1.0"])
;           versions (make ["= 2.0.0" "= 2.0.6" "= 2.2.8" "= 2.1.1" "= 2.1.2"])
;           version (req.resolve requirements versions)]
;       (assert.nil version))
;     ))
