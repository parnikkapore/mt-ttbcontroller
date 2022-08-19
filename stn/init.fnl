(local rc (require :util.rc))
(local {: fallback} (require :util))

(fn stops-here? [platform-code normally-stop?]
  (if (= platform-code nil)
      normally-stop?
      (and
        (not (rc.matches (get_rc) (.. platform-code "-skip")))
        (or normally-stop? (rc.matches (get_rc) (.. platform-code "-stop"))))))

(fn stn [name side reverse? platform-code settings]
  (local side (or side "L"))
  (local reverse? (or reverse? false))
  (local normally-stop? (fallback (?. settings :normallyStop) true))
  
  (local handle-approach (require :stn.approach))
  (local handle-train (require :stn.train))
  (local handle-dep (require :stn.dep))
  
  (global __approach_callback_mode 1)
  (if (stops-here? platform-code normally-stop?)
    (match event
      {:type "train"}                       (when (= atc_arrow true) (handle-train name side reverse? platform-code settings))
      {:type "schedule" :msg "dep"}         (handle-dep)
      {:type "approach" :has_entered false} (handle-approach name)
    )
    nil))
  
stn
