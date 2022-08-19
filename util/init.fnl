; Miscellaneous helper functions

; Returns a memoized version of the given unary function
(fn memoize [function]
  (local memo-table {})
  (fn memoize-result [arg]
    (when (= (. memo-table arg) nil)
      (tset memo-table arg (function arg)))
    (. memo-table arg)))
    
; Returns the given value, or the fallback if it's nil
(fn fallback [value fallback-value]
  (if (not= value nil) value fallback-value))

{
 : memoize
 : fallback
}
