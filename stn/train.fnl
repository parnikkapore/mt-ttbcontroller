(fn get-trip [trip]
  (?. (require :data) :trips trip))

(fn train-destination [trip]
  (?. (get-trip trip) :destination))

; {:trip "L198" :origin "Pelipper Town" :destination "Meteor Cave" :flags "jPpT:A/1->K/1" :departs-in 20}
(fn next-trip [station train-rc]
  (local ttb (require :data.ttb))
  (local my-deps (. (require :data) :deps station))
  (local trips-and-times
         (icollect [_ tripcode (pairs my-deps)]
            {:trip tripcode :in (ttb.time-to-next station tripcode)}))
  (local best-trip
         (accumulate [best (. trips-and-times 1)
                      i cur (ipairs trips-and-times)]
            (if (< cur.in best.in) cur best)))
  (local best-trip-info (get-trip best-trip.trip))
  (tset best-trip-info :trip best-trip.trip)
  (tset best-trip-info :departs-in best-trip.in)
  best-trip-info)

(fn get-dwell-time [station trip]
  (local ttb (require :data.ttb))
  (local trip-info (get-trip trip))
  (if
    (not (ttb.does-stop? station trip))
      (do
        (print (string.format "[%s] Train %s isn't supposed to be here!" station trip))
        10) ; Fallback
    (< (ttb.time-to-next station trip) (ttb.time-from-last station trip)) ; early
      (let [time-to-next (ttb.time-to-next station trip)]
        (when (> time-to-next 15)
          (print (string.format "[%s] Train %s is early (%ss)!"
                                station trip time-to-next)))
        (ttb.time-to-next station trip))
    ; late
      (let [time-from-last (ttb.time-from-last station trip)]
        (when (> time-from-last 5)
          (print (string.format "[%s] Train %s is late (%ss)!"
                                station trip time-from-last)))
        0)))

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

(fn handle-train [name side reverse? stopping-rcs]
  (when S.DEBUG
    (print (string.format "%s: [%s] %s arrived w/ %s" (rwt.to_string (rwt.now) true) name (get_line)
                        ((. (require :data.ttb) :time-to-next) name (get_line)))))
  (local side (or side "L"))
  (local stopping-rcs (or stopping-rcs []))
  (local terminates-here? (= (train-destination (get_line)) name))
  (if terminates-here?
    (let [next-trip-info (next-trip name (get_rc))
          {: trip : origin : destination : flags : departs-in} next-trip-info
          (wait-time close-time) (get-door-times departs-in)]
      (when S.DEBUG
        (print (string.format "%s: [%s] %s -> %s" (rwt.to_string (rwt.now) true) name (get_line) trip)))
      (set_line trip)
      (set_rc flags)
      (atc_set_text_outside (string.format "%s\n%s -> %s" trip origin destination))
      (atc_set_text_inside name)
      (schedule_in wait-time :dep)
      (command-train side true wait-time close-time reverse?))
    ; (not (terminates-here?))
    (let [departs-in (get-dwell-time name (get_line))
          (wait-time close-time) (get-door-times departs-in)]
      (atc_set_text_inside name)
      (schedule_in wait-time :dep)
      (command-train side false wait-time close-time reverse?))))

handle-train
