(fn stn [name side reverse? stopping-rcs]
  (local side (or side "L"))
  (local reverse? (or reverse? false))
  
  (local handle-approach (require :stn.approach))
  (local handle-train (require :stn.train))
  (local handle-dep (require :stn.dep))
  
  (global __approach_callback_mode 1)
  (match event
    {:type "train"}                       (when (= atc_arrow true) (handle-train name side reverse? stopping-rcs))
    {:type "schedule" :msg "dep"}         (handle-dep)
    {:type "approach" :has_entered false} (handle-approach name)
  ))
