(def input [1 20 11 6 12 0])

(def num-turns @{})

(defn put-last [n idx]
  (def cur (get num-turns n))
  (when (tuple? cur)
    (put num-turns n [(last cur) idx]))
  (when (nil? cur)
    (put num-turns n idx))
  (when (number? cur)
    (put num-turns n [cur idx])))
  
(defn get-num [n]
  (def res (get num-turns n))
  (if (tuple? res)
      (- (last res) (first res))
      0))

(def limit 1000000)

(defn part1[]
  (var i 1)
  (var lst 0)
  (each n input 
    (set lst n)
    (put-last n i)
    (+= i 1))
  (while (< i (+ limit 1)) 
    (do
     (def n (get-num lst))
     (put-last n i)
     (set lst n)
     (+= i 1)))
  lst)

(part1)
