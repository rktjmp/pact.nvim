
(fn x []
  (result->> (yield "starting workflow")
             (absolute-path? repo-path)
             (git-dir? repo-path)
             (tap #(yield "fetching sha"))
             (fetch-sha repo-path commit-target)
             (tap #(yield "checking out sha"))
             (checkout-sha repo-path commit-target)
             (map-ok #"Checked out x")))
 
