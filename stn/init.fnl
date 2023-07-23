(local rc (require :util.rc))
(local {: fallback} (require :util))

(fn stn [name side reverse? platform-code settings]
  (local side (or side "L"))
  (local reverse? (or reverse? false))

  (local handle-approach (require :stn.approach))
  (local handle-train (require :stn.train))
  (local handle-dep (require :stn.dep))

  (local normally-stop? (fallback (?. settings :normallyStop) true))
  (local stops-here?
    (if (= platform-code nil)
        normally-stop?
        (and
          (not (rc.matches-me (.. platform-code "-skip")))
          (or normally-stop? (rc.matches-me (.. platform-code "-stop"))))))

  (local reverse-this?
    (if (= platform-code nil)
        reverse?
        (and
          (not (rc.matches-me (.. platform-code "-no-reverse")))
          (or reverse? (rc.matches-me (.. platform-code "-reverse"))))))

  (global __approach_callback_mode 1)
  (if stops-here?
    (match event
      {:type "train"}
      (when (= atc_arrow true)
        (handle-train name side reverse-this? platform-code settings))
      {:type "schedule" :msg "dep"}         (handle-dep)
      {:type "approach" :has_entered false} (handle-approach name)
    )
    nil))

stn
