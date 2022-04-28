(fn handleDep []
  "Functions to run when the train is scheduled to leave"
  ; Everything else is already scheduled as part of the ATC command sent in
  ; the train handler, so just clear the internal display
  (atc_set_text_inside ""))
