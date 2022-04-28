(fn handle-approach [name]
  (atc_set_ars_disable true)
  (atc_set_lzb_tsr 2)
  (atc_set_text_inside (.. "Next station:\n" name)))
  
handle-approach
