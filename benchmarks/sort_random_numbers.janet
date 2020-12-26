
(def args (dyn :args))
(def num (scan-number (args 1)))
(def scale (scan-number (args 2)))

(math/seedrandom 42)

(def numbers @[])
(for _ 0 num 
  (array/push numbers (* scale (math/random))))

(sort numbers)


