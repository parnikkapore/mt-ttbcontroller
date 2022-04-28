; /usr/bin/env fennel --no-compiler-sandbox

(local fennel (require :fennel)) (global pp (fn [x] (print (fennel.view x))))

(import-macros {: gen-tables} :data.gen-tables)

(let [{: ttb : trips : deps} (gen-tables)]
  (pp ttb)
  (print)
  (pp trips)
  (print)
  (pp deps))
