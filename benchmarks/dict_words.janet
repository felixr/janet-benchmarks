(def input (->> (slurp "/usr/share/dict/words")
                (string/split "\n")))
(def words @{})

(each word input
  (put words word (length word)))

(def args (dyn :args))
(def iterations (or (scan-number (args 1)) (* 20 1000 1000)))

(for i 0 iterations 
  (def word (get input (mod (* i 349) (length input))))
  (assert (= 
            (get words word)
            (length word))))

