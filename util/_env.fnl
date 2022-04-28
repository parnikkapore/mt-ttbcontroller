(fn table.shallow_copy [t]
  (let [out {}]
    (each [k v (pairs t)]
      (tset out k v))
    out))

(fn table.copy [t]
  (table.shallow_copy t))

nil
