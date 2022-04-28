; Stuff for dealing with routing codes

; Checks if rc is one of the routing codes in rcs
(fn matches [rcs rc]
  (if (or (= rc nil) (= rc ""))
      true
      (string.find (.. " " (or rcs "") " ")
                   (.. " " rc " ")
                   nil
                   true)))

{: matches}
