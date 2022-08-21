(fn env []
  (fn table.shallow_copy [t]
    (let [out {}]
      (each [k v (pairs t)]
        (tset out k v))
      out))
  
  (fn table.merge_smart_deep [a b]
    (local c {})
    (local a-maxI (accumulate [maxi 0
                               i v (ipairs a)]
                    (do (table.insert c v)
                        i)))
    (local b-maxI (accumulate [maxi 0
                               i v (ipairs b)]
                    (do (table.insert c v)
                        i)))
    (each [k v (pairs a)]
      (if (not (and (= (type k) "number")
                    (> k 0)
                    (<= k a-maxI)))
          (tset c k v)))
    (each [k v (pairs b)]
      (if (and (= (type k) "number")
               (> k 0)
               (<= k b-maxI))
          nil
          (and (= (type v) :table) (= (type (. c k)) :table))
          (tset c k (table.merge_smart_deep (. c k) v))
          ; either b.k or c.k is not a table
          (tset c k v)))
    c)

  (fn table.copy [t]
    (table.shallow_copy t)))

; (table.merge_smart_deep [1 2 3] [4 5 6])
; (table.merge_smart_deep {:a 1 :b 2 :d 4} {:c 3 :e 5})
; (table.merge_smart_deep {:a 1 :b 2 :c 3} [4 5 6])
