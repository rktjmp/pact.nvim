(import-macros {: describe : it : must : rerequire} :pact.lib.ruin.test)

(local _ (rerequire :pact.valid))
(local {: satisfies? : solve} (rerequire :pact.package.spec.constraint.version))

(describe "version constraint"
  (it "works with strings with space between operator"
    (must match true (satisfies? "= 1.0.0" "1.0.0"))
    (must match false (satisfies? "> 1.0.0" "1.0.0"))
    (must match true (satisfies? "~ 1.1.0" "1.1.1")))
  (it "works with strings without space between operator"
    (must match true (satisfies? "=1.0.0" "1.0.0"))
    (must match false (satisfies? ">1.0.0" "1.0.0"))
    (must match true (satisfies? "~1.1.0" "1.1.1"))))

(local versions [:1.1.0 :0.9.1 :1.2.99 :1.2.9 :1.4.0 :1.2.0])
(describe "solve constraint"
  (it "works with one spec"
    (must match [:1.4.0 :1.2.99 :1.2.9 :1.2.0]
          (solve ">= 1.2.0" versions)))
  (it "works with many specs"
    (must match [:1.2.99 :1.2.9 :1.2.0]
          (solve [">= 1.2.0" "<= 1.3.0"] versions))))

(describe "satisfies? = equal"
  [behind "10.21.12"
   same "10.22.12"
   ahead "10.23.12"
   spec "= 10.22.12"]
  (it "behind" (must match false (satisfies? spec behind)))
  (it "same" (must match true (satisfies? spec same)))
  (it "ahead" (must match false (satisfies? spec ahead))))

(describe "satisfies? > greater than"
  [behind "10.21.12"
   same "10.22.12"
   ahead "10.23.12"
   spec "> 10.22.12"]
  (it "behind" (must match false (satisfies? spec behind)))
  (it "same" (must match false (satisfies? spec same)))
  (it "ahead" (must match true (satisfies? spec ahead))))

(describe "satisfies? < less than"
  [behind "10.21.12"
   same "10.22.12"
   ahead "10.23.12"
   spec "< 10.22.12"]
  (it "behind" (must match true (satisfies? spec behind)))
  (it "same" (must match false (satisfies? spec same)))
  (it "ahead" (must match false (satisfies? spec ahead))))

(describe "satisfies? >= greater than or equal"
  [behind "10.21.12"
   same "10.22.12"
   ahead "10.23.12"
   spec ">= 10.22.12"]
  (it "behind" (must match false (satisfies? spec behind)))
  (it "same" (must match true (satisfies? spec same)))
  (it "ahead" (must match true (satisfies? spec ahead))))

(describe "satisfies? <= less than or equal"
  [behind "10.21.12"
   same "10.22.12"
   ahead "10.23.12"
   spec "<= 10.22.12"]
  (it "behind" (must match true (satisfies? spec behind)))
  (it "same" (must match true (satisfies? spec same)))
  (it "ahead" (must match false (satisfies? spec ahead))))

(describe "satisfies? ~ patch ahead"
  [spec         "~ 10.22.12"
   patch-behind "10.22.11"
   patch-same   "10.22.12"
   patch-ahead  "10.22.13"
   minor-behind "10.21.12"
   minor-same   "10.22.99"
   minor-ahead  "10.23.99"
   major-behind "9.22.99"
   major-same   "10.22.99"
   major-ahead  "11.22.99"]
  (it "patch-same" (must match true (satisfies? spec patch-same)))
  (it "minor-same" (must match true (satisfies? spec minor-same)))
  (it "major-same" (must match true (satisfies? spec major-same)))
  (it "patch-behind" (must match false (satisfies? spec patch-behind)))
  (it "minor-behind" (must match false (satisfies? spec minor-behind)))
  (it "major-behind" (must match false (satisfies? spec major-behind)))
  (it "patch-ahead" (must match true (satisfies? spec patch-ahead)))
  (it "minor-ahead" (must match false (satisfies? spec minor-ahead)))
  (it "major-ahead" (must match false (satisfies? spec major-ahead))))

(describe "satisfies? ^ for x.y.z"
  [spec         "^ 10.22.12"
   patch-behind "10.22.11"
   patch-same   "10.22.12"
   patch-ahead  "10.22.13"
   minor-behind "10.21.12"
   minor-same   "10.22.99"
   minor-ahead  "10.23.99"
   major-behind "9.22.99"
   major-same   "10.22.99"
   major-ahead  "11.22.99"]
  (it "patch-same" (must match true (satisfies? spec patch-same)))
  (it "minor-same" (must match true (satisfies? spec minor-same)))
  (it "major-same" (must match true (satisfies? spec major-same)))
  (it "patch-behind" (must match false (satisfies? spec patch-behind)))
  (it "minor-behind" (must match false (satisfies? spec minor-behind)))
  (it "major-behind" (must match false (satisfies? spec major-behind)))
  (it "patch-ahead" (must match true (satisfies? spec patch-ahead)))
  (it "minor-ahead" (must match true (satisfies? spec minor-ahead)))
  (it "major-ahead" (must match false (satisfies? spec major-ahead))))

(describe "satisfies? ^ for 0.y.z"
  [spec         "^ 0.22.12"
   patch-behind "0.22.11"
   patch-same   "0.22.12"
   patch-ahead  "0.22.13"
   minor-behind "0.21.12"
   minor-same   "0.22.99"
   minor-ahead  "0.23.99"
   ; major-behind "9.22.99" NA
   major-same   "0.22.99"
   major-ahead  "1.22.99"]
  (it "patch-same" (must match true (satisfies? spec patch-same)))
  (it "minor-same" (must match true (satisfies? spec minor-same)))
  (it "major-same" (must match true (satisfies? spec major-same)))
  (it "patch-behind" (must match false (satisfies? spec patch-behind)))
  (it "minor-behind" (must match false (satisfies? spec minor-behind)))
  ; (it "major-behind" (must match false (satisfies? spec major-behind)))
  (it "patch-ahead" (must match true (satisfies? spec patch-ahead)))
  (it "minor-ahead" (must match false (satisfies? spec minor-ahead)))
  (it "major-ahead" (must match false (satisfies? spec major-ahead))))
