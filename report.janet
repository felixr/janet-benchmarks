(import "./base64" :as base64)
(def results @[])
(->>
  (os/dir "results")
  (map (partial string "results/"))
  (map slurp)
  (map (fn [s] (string/trim (last (string/split "DATA:\n" s)))))
  (map (comp unmarshal base64/decode string/trim))
  (map (partial array/push results)))

(var idx 0)
(def seen-benchmarks @{})

(print "# version\tbenchmark\tmin\tmax\tmean")
(each ver results
  (def ver-name (string (ver :version) "_" (ver :build)))
  (each [name res] (pairs (ver :results))
    (when (nil? (get seen-benchmarks name)) (put seen-benchmarks name (++ idx)))
    (def bidx (get seen-benchmarks name))
    (def times (->> (mapcat (fn [{:results r}] r) res)
                (map (fn [x] (x :elapsed_time))))) 
    (def [mi mx avg] [(min ;times) (max ;times) (mean times)])
    (print ;(interpose "\t" [ver-name bidx name mi mx avg])))
  (print "\n"))
