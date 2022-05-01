(local ttb (require :data.ttb))
(local triptb (. (require :data) :trips))
(local pfatb (?. (require :data) :pfas))

(fn get-trip [trip]
  (?. triptb trip))

(local patterns {
  ; pat  time-pat              header                      trip-pat                num-trips-shown
  :nlcd ["\n\n\n\n  Time:  %s" ": Next trains :\n"         "%-10s %4s\n%-15s\n"    4]
  :lcd  [" |  | Time: %s"      "Next trains | "            "%-8s %3s | %-12s | "   2]
  :txtl ["Time:  %s"           "From this station %8.8s\n" "%-5.5s %3.3s %-.16s\n" 3]
})

(fn print-record [trip time dest pattern]
  (local time-string
    (if (< time 60)        (.. time "s")
        (< time (* 60 60)) (.. (math.ceil (/ time 60)) "m")
        true               (.. (math.ceil (/ time (* 60 60))) "h")))
  (string.format pattern trip time-string dest))

(local next-deps-cache {})
; Get a sorted list of next trains to leave a station
(fn get-next-deps [station]
  (when (< (rwt.diff (rwt.now) (or (?. next-deps-cache station 1 :time) 0)) 0)
    ; First train on manifest has left: time to refresh!
    (local trips-and-times
         (icollect [_ tripcode (ipairs (ttb.trains-from station))]
            {:trip tripcode :time (ttb.time-of-next station tripcode)}))
    (table.sort trips-and-times #(> (rwt.diff $1.time $2.time) 0))
    (tset next-deps-cache station trips-and-times))
  (. next-deps-cache station))

(fn update-display [station pattern platform]
  (local [time-pat header trip-pat num-trips-shown]
         (or pattern (error "nexttrains: Invalid pattern name!")))
  (local time-string (rwt.to_string (rwt.now) true))
  (local trips-and-waits
    (icollect [_ entry (ipairs (get-next-deps station))]
      (if (or (= (?. pfatb station entry.trip) platform)
              (= platform nil))
          {:trip entry.trip :in (rwt.diff (rwt.now) entry.time)})))
  (digiline_send "lcd_clock"
    (string.format time-pat time-string))
  (digiline_send "lcd_nexttrains"
    (table.concat
      (icollect [i trip (ipairs trips-and-waits)
                 :into [(string.format header time-string)]
                 :until (> i num-trips-shown)]
        (print-record trip.trip
                      trip.in
                      (. (get-trip trip.trip) :destination)
                      trip-pat)))))

(fn nexttrains [station pattern blinky-pin platform]
  (when (and event.on (= event.pin.name blinky-pin))
    (update-display station (. patterns pattern) platform)))

nexttrains
