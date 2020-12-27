(def args (dyn :args))
(def num (or (scan-number (get args 1)) 100000))
(def scale (or (scan-number (get args 2)) 1))

(math/seedrandom 42)


(def tbl @{}) 
(def nums @[])
(for _ 0 num
  (def n (* scale (math/random))) 
  (array/push nums n)
  (put tbl n true))

(each n nums (assert (true? (get tbl n))))
