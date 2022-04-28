; /usr/bin/env fennel --no-compiler-sandbox

; Literally just here to contain all the timetable data so it won't get pasted all over the place

(import-macros {: gen-tables} :data.gen-tables)
(gen-tables)
