;# MACRO

; Returns an easy-to-use timetable and departures table
; for use in the rest of the system.
; It's in a macro because this should be done compile-time +
; I don't want to include a whole dang CSV parser in the output
;
; Don't forget to pass --no-compiler-sandbox to fennel
; otherwise this thing can't read the input files
(fn gen-segment [segment]
  (local csv (require :csv))

  ; Open the timetable
  (local ttfile (csv.open (string.format "data/%s-ttb.csv" segment) {"header" true}))
  (local ttb {:_cycle "10;00"})
  (local trips (require (string.format "data.%s-depinfo" segment)))
  (local deps {})

  (each [line (ttfile:lines)]
    (each [train time (pairs line)]
      (local station line.Station)
      (local time (string.gsub time ":" ";"))
      (if
        ; Station name column is not data
        (= train "Station") nil
        ; No stop, no need to add
        (= time "") nil
        ; Actual time node - processing goes here
        (do
          ; Add to the time table...
          (if
            ; If we're inaugrating then do it
            (= (. ttb station) nil) (tset ttb station {train time})
            ; Otherwise just add it
            (tset (. ttb station) train time))
          ; And now the trip information table...
          (let [our-depinfo (or (?. trips train) {})]
            ; If this is the earliest station, it's the origin station
            (when (let [earliest-known-time (?. ttb our-depinfo.origin train)]
                    (or (= earliest-known-time nil) (> earliest-known-time time)))
              (set our-depinfo.origin station))
            ; If this is the latest station, it's the destination station
            (when (let [latest-known-time (?. ttb our-depinfo.destination train)]
                    (or (= latest-known-time nil) (< latest-known-time time)))
              (set our-depinfo.destination station))
            ; Save our changes
            (tset trips train our-depinfo))))))
  
  ; Generate the departures index from the trip info table
  (each [trip-id trip-info (pairs trips)]
    (tset deps trip-info.origin (or (. deps trip-info.origin) {}))
    (table.insert (. deps trip-info.origin) trip-id))
  
  ; And now parse the platform assignments table
  (local pfas {})
  (local pfa-file (csv.open (string.format "data/%s-pfa.csv" segment) {"header" true}))
  (each [line (pfa-file:lines)]
    (tset pfas line.Station {})
    (local station-record (. pfas line.Station))
    (each [tripcode platform (pairs line)]
      (if
        (= tripcode "Station") nil
        (= platform "")        nil
        (tset station-record tripcode platform))))
  
  `{:ttb ,ttb :trips ,trips :deps ,deps :pfas ,pfas})

(fn table-merge [a b] {})

(fn gen-tables []
  (gen-segment :A))

{: gen-tables}
