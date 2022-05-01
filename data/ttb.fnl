; Timetable interface

(local ttb (?. (require :data) :ttb))
(local cycle ttb._cycle)
(local triptb (?. (require :data) :trips))
(local util (require :util))

(fn does-stop? [station train]
  (not (= (?. ttb station train) nil)))

(fn time-to-next [station train delay]
    (local offset (?. ttb station train))
    (local delay (or delay 0))
    ;(print offset "/" delay)
    
    (if (= offset nil)
      nil
      (rwt.time_to_next_rpt (rwt.add (rwt.now) delay) cycle offset)))

(fn time-of-next [station train delay]
    (local offset (?. ttb station train))
    (local delay (or delay 0))
    ;(print offset "/" delay)
    
    (if (= offset nil)
      nil
      (rwt.next_rpt (rwt.add (rwt.now) delay) cycle offset)))

(fn time-from-last [station train delay]
    (local offset (?. ttb station train))
    (local delay (or delay 0))
    ;(print offset "-" delay)
    
    (if (= offset nil)
      nil
      (rwt.time_from_last_rpt (rwt.add (rwt.now) delay) cycle offset)))

(fn time-of-last [station train delay]
    (local offset (?. ttb station train))
    (local delay (or delay 0))
    ;(print offset "-" delay)
    
    (if (= offset nil)
      nil
      (rwt.last_rpt (rwt.add (rwt.now) delay) cycle offset)))

; Returns the tripcodes of trains stopping and leaving the given station.
(local trains-from
  (util.memoize (fn do-trains-from [station]
      (icollect [train time (pairs (or (. ttb station) []))]
        (when (and (~= time nil)
                   (~= (. triptb train :destination) station))
          train)))))

{
 : does-stop?
 : time-to-next
 : time-of-next
 : time-from-last
 : time-of-last
 : trains-from
}
