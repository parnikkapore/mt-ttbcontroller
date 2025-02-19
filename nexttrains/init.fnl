(local ttb (require :data.ttb))
(local triptb (. (require :data) :trips))
(local pfatb (?. (require :data) :pfas))

(fn get-trip [trip]
  (?. triptb trip))

; Train  Plat In
; L123a  12   34m
; Omenutleikque
(fn nlcd-pattern [time trips]
  (local msgs (string.format "\n\n\n\n  Time:  %s" time))
  (local main
    (table.concat
      (icollect [i trip (ipairs trips)
                :into ["Train  Plat In \n"]
                :until (> i 4)]
        (string.format "%-6s %4s %3s\n%-15s\n"
                       trip.tripcode
                       (or trip.platform "-")
                       trip.in
                       trip.destination))))
  (values msgs main))

; Nr   Pl In
; L123a 1 34m
; Omenutleikq
(fn lcd-pattern [time trips]
  (local msgs (string.format " |  | Time: %s" time))
  (local main
    (table.concat
      (icollect [i trip (ipairs trips)
                :into ["Nr   Pl In  | "]
                :until (> i 2)]
        (string.format "%-5s %1s %3s | %-12s | "
                       trip.tripcode
                       (or trip.platform "-")
                       trip.in
                       trip.destination))))
  (values msgs main))

; Train Destination   Pl In
; R103  Omenutleikque 12 34m
; L888a *Does not stop*
(fn txtl-pattern [time trips platform]
  (local msgs (string.format "Time: %s" time))
  (local main
  (if platform
    (table.concat
      (icollect [i trip (ipairs trips)
                :into ["Train Destination      In \n"]
                :until (> i 3)]
        (string.format "%-5s %-16s %3s\n"
                       trip.tripcode
                       trip.destination
                       trip.in)))
    (table.concat
      (icollect [i trip (ipairs trips)
                :into ["Train Destination   Pl In \n"]
                :until (> i 3)]
        (string.format "%-5s %-13s %2s %3s\n"
                       trip.tripcode
                       trip.destination
                       (or trip.platform "-")
                       trip.in)))))
  (values msgs main))

(local patterns {
  :nlcd nlcd-pattern
  :lcd  lcd-pattern
  :txtl txtl-pattern
})

(fn format-time [time]
  (if (< time 60)        (.. time "s")
      (< time (* 60 60)) (.. (math.floor (/ time 60)) "m")
      true               (.. (math.floor (/ time (* 60 60))) "h")))

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

(fn update-display [station pattern-name platform]
  (local pattern (or (. patterns pattern-name) (error "nexttrains: Invalid pattern name!")))
  (local time-tbl (rwt.now))
  (local time-string (string.format "%2d:%02d" time-tbl.m time-tbl.s))
  (local trips-and-waits
    (icollect [_ entry (ipairs (get-next-deps station))]
      (if (or (= platform nil)
              (= (?. pfatb station entry.trip) platform))
          { :tripcode entry.trip 
            :in (format-time (rwt.diff (rwt.now) entry.time))
            :platform (?. pfatb station entry.trip)
            :destination (. (get-trip entry.trip) :destination)})))
  (local (msgs-text main-text) (pattern time-string trips-and-waits platform))
  (digiline_send "lcd_clock" msgs-text)
  (digiline_send "lcd_nexttrains" main-text))

(fn nexttrains [station pattern blinky-pin platform]
  (when (and (or event.on event.off) (= event.pin.name blinky-pin))
    (update-display station pattern platform)))

nexttrains
