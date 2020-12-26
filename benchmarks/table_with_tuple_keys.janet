(def args (dyn :args))
(def start (or (scan-number (args 1)) 0))
(def num (or (scan-number (args 2)) 100))

(def tbl @{}) 
(loop [x :in (range start (+ start num))
       y :in (range start (+ start num))] 
  (put tbl (tuple x 0 y) true))
