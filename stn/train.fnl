(local ttb (require :data.ttb))
(local triptb (. (require :data) :trips))
(local deptb (. (require :data) :deps))
(local rc (require :util.rc))
(local { : ipairs-single } (require :util))

(fn get-trip [trip]
  (?. (require :data) :trips trip))

(fn train-destination [trip]
  (?. (get-trip trip) :destination))

; {:trip "L198" :origin "Pelipper Town" :destination "Meteor Cave" :flags "jPpT:A/1->K/1" :departs-in 20}
; returns next trip to leave the station that train-rc can serve
(fn next-trip [station train-rc platform-code]
  (local my-deps (. deptb station))
  (local all-trips-and-times
    (icollect [_ tripcode (pairs my-deps)]
      {:trip tripcode :in (ttb.time-to-next station tripcode)}))
  (local valid-trips-and-times
    (icollect [_ entry (pairs all-trips-and-times)]
      (let [combined-rc (.. (or train-rc "") " " (or platform-code ""))]
        (if (accumulate [matches true
                         i cur-rc (ipairs-single (?. (get-trip entry.trip) :traintag))]
                        (and matches (rc.matches combined-rc cur-rc)))
            entry))))
  (local trips-and-times
    (if (= (length valid-trips-and-times) 0)
        (do
          (print (string.format "[%s] Train ineligible for every trip!" station)
                 train-rc)
          all-trips-and-times)
        valid-trips-and-times))
  (local best-trip
         (accumulate [best (. trips-and-times 1)
                      i cur (ipairs trips-and-times)]
            (if (< cur.in best.in) cur best)))
  (local best-trip-info (get-trip best-trip.trip))
  (tset best-trip-info :trip best-trip.trip)
  (tset best-trip-info :departs-in best-trip.in)
  best-trip-info)

(fn offset-from-timetable [station trip]
  (local time-to-next (ttb.time-to-next station trip))
  (local time-from-last (ttb.time-from-last station trip))
  (if (or (= time-to-next nil) (= time-from-last nil))
      nil
      (< time-to-next time-from-last) ; early
      (- time-to-next)
      time-from-last))

(fn check-on-time [station trip]
  (local PLANNED-DWELL 13)
  (local raw-offset (offset-from-timetable station trip))
  (when (~= raw-offset nil)
    (local offset (+ raw-offset PLANNED-DWELL))
    (local margin (if S.PEDANTIC 1 10))
    (when (< offset (- margin))
      (print (string.format "[%s] Train %s is early (%ss)!" station trip offset)))
    (when (< margin offset)
      (print (string.format "[%s] Train %s is late (%ss)!" station trip offset)))))

(fn get-dwell-time [station trip]
  (if
    (not (ttb.does-stop? station trip))
    (do
      (print (string.format "[%s] Train %s isn't supposed to be here!" station trip))
      10) ; Fallback
    (let [delay-needed (- (offset-from-timetable station trip))]
      (math.max delay-needed 0))))

; (wait-time close-time)
(fn get-door-times [dwell-time]
  ; How long should the door be open for, at minimum
  (local MIN-STOP-TIME 5)
  ; Doors that are open for longer than this can be
  ; closed earlier to make things nicer
  (local GOOD-STOP-TIME 10)

  (if (< dwell-time (+ GOOD-STOP-TIME 1))
      (values (math.max MIN-STOP-TIME (- dwell-time 1)) 1)
      (> dwell-time (+ GOOD-STOP-TIME 3))
      (values (- dwell-time 3) 3)
      ; GOOD-STOP-TIME+1 < dwell-time < GOOD-STOP-TIME+3
      (values GOOD-STOP-TIME (- dwell-time GOOD-STOP-TIME))))

(fn command-train [side kick? wait-time close-time reverse?]
  (atc_send (string.format "B0WO%s%s D%s OCD%s%sA1SM"
                           side
                           (if kick? "K" "")
                           wait-time
                           close-time
                           (if reverse? "R" ""))))

(fn handle-train [name side reverse? platform-code settings]
  (local side (or side "L"))
  (local trip-id (get_line))
  (local terminates-here? (= (train-destination trip-id) name))
  (when S.DEBUG
    (print (string.format "%s: [%s] %s arrived w/ %s"
                          (rwt.to_string (rwt.now) true)
                          name
                          trip-id
                          (ttb.time-to-next name trip-id))))
  (check-on-time name trip-id)
  (if terminates-here?
    (let [next-trip-info (next-trip name (get_rc) platform-code)
          {: trip : origin : destination : flags : departs-in} next-trip-info
          (wait-time close-time) (get-door-times departs-in)]
      (when S.DEBUG
        (print (string.format "%s: [%s] %s -> %s"
                              (rwt.to_string (rwt.now) true)
                              name
                              trip-id
                              trip)))
      (set_line trip)
      (set_rc flags)
      (atc_set_text_outside (string.format "%s\n%s ➜ %s" trip origin destination))
      (atc_set_text_inside name)
      (schedule_in wait-time :dep)
      (command-train side true wait-time close-time reverse?))
    ; (not (terminates-here?))
    (let [departs-in (get-dwell-time name trip-id)
          (wait-time close-time) (get-door-times departs-in)]
      (atc_set_text_inside name)
      (schedule_in wait-time :dep)
      (command-train side false wait-time close-time reverse?))))

handle-train
