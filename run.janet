(import "./base64" :as base64)
(map print [ "   __                __                  __      "
             "  / /  ___ ___  ____/ /  __ _  ___ _____/ /__ ___"
             " / _ \\/ -_) _ \\/ __/ _ \\/  ' \\/ _ `/ __/  '_/(_-<"
             "/_.__/\\__/_//_/\\__/_//_/_/_/_/\\_,_/_/ /_/\\_\\/___/" ""])

(defn run [cmd]
  (->
    (file/popen cmd)
    (file/read :all)
    (string/trim)))

(def args (dyn :args))
(def janet-exe (or (get args 1) (run "which janet")))
(def janet-version (run (string janet-exe " -e '(print janet/version)'")))
(def janet-build (run (string janet-exe " -e '(print janet/build)'")))



(printf "ver:\t %s" janet-version)
(printf "build:\t %s" janet-build)

(def sha256sum (run "which sha256sum"))
(when (not (empty? sha256sum))
  (printf "sha256:\t %s" (first (string/split " " (run (string sha256sum " -b " janet-exe))))))

(print "")

(defn run-benchmark [b param]
  (def start (os/clock))
  (def result (run (string janet-exe " benchmarks/" b ".janet " param)))
  (def stop (os/clock))
  {:elapsed_time (- stop start)})

(def benchmarks @{"noop" [0]
                  "dict_words" [1000000]
                  "table_with_tuple_keys"  ["0 200" "1000 200" "10000 200" "100000 200" "1000000 200" "10000000 200" "100000000 200" "1000000000 200"]
                  "table_with_struct_keys" ["0 200" "1000 200" "10000 200" "100000 200" "1000000 200" "10000000 200" "100000000 200" "1000000000 200"]
                  "sort_hashes_of_tuples" ["0" "1000" "10000" "100000" "1000000" "10000000" "100000000" "1000000000"]
                  "sort_hashes_of_hashes_of_tuples" ["0" "1000" "10000" "100000" "1000000" "10000000" "100000000" "1000000000"]
                  "sort_random_numbers" ["300000 1" "300000 1000000" "300000 1000000000"]
                  "aoc_2020_d15_p1" [1000000]
                  "hexagon_tuples" [50]})

(def active-benchmarks
  (if
    (< (length args) 3)
    (pairs benchmarks)
    (let [selected (drop 2 args)]
      (filter (fn [[k v]] (find (partial = k) selected)) (pairs benchmarks)))))

(def number-of-runs 10)

(def all-results @{})
(each [b params] active-benchmarks
  (print b)
  (each param params
    (prinf "  param=%q " param)
    (def results (seq [i :in (range number-of-runs)]
                   (prin ".")(flush)
                   (run-benchmark b param)))
    (put all-results b results)
    (def times (map (fn [x] (x :elapsed_time)) results))
    (printf "\t\tmin=%.3f max=%.3f" (min ;times) (max ;times))))


(print "\nDATA:")
(print (base64/encode (marshal {:version janet-version :build janet-build :results all-results})))
