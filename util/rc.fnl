; Stuff for dealing with routing codes

(fn matches [rcs rc]
  "Checks if rc is one of the routing codes in rcs."
  (if (or (= rc nil) (= rc ""))
      true
      (string.find (.. " " (or rcs "") " ")
                   (.. " " rc " ")
                   nil
                   true)))

(fn matches-me [rc]
  "Checks if the current train matches rc."
  (matches (get_rc) rc))

{: matches : matches-me}
