(defn sort-hashes [start]
  (def hashes @[]) 
  (loop [x :in (range start (+ 100 start)) 
         y :in (range start (+ 100 start))]
    (array/push hashes (hash (tuple x 0 y))))
  (sort hashes))

(def args (dyn :args))
(sort-hashes (scan-number (args 1)))
