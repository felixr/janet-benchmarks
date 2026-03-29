(import "./base64" :as base64)
(map print ["   __                __                  __      "
            "  / /  ___ ___  ____/ /  __ _  ___ _____/ /__ ___"
            " / _ \\/ -_) _ \\/ __/ _ \\/  ' \\/ _ `/ __/  '_/(_-<"
            "/_.__/\\__/_//_/\\__/_//_/_/_/_/\\_,_/_/ /_/\\_\\/___/" ""])

(defn run [cmd]
  (def p (os/spawn cmd :p {:in :pipe :out :pipe}))
  (def output (:read (p :out) :all))
  (string/trim (or output "")))

(def args (dyn :args))
(def system-janet (run ["which" "janet"]))
(def janet-exe (or (get args 1) system-janet))
(def janet-version (run [janet-exe "-e" "(print janet/version)"]))
(def janet-build (run [janet-exe "-e" "(print janet/build)"]))
(def output-file (string "results/" janet-version "-" janet-build))

(printf "ver:\t %s" janet-version)
(printf "build:\t %s" janet-build)

(def sha256sum (run ["which" "sha256sum"]))
(when (not (empty? sha256sum))
  (printf "sha256:\t %s" (first (string/split " " (run [sha256sum "-b" janet-exe])))))

(print "")

(def benchmark-timeout 30)

(defn run-benchmark [b param]
  (def cmd [janet-exe (string "benchmarks/" b ".janet") ;(string/split " " param)])
  (def start (os/clock))
  (def p (os/spawn cmd :p {:in :pipe :out :pipe}))
  (var timed-out false)
  (try
    (ev/with-deadline benchmark-timeout
      (:read (p :out) :all)
      (os/proc-wait p))
    ([err]
      (os/proc-kill p true)
      (try (os/proc-wait p) ([_]))
      (if (= err "deadline expired")
        (set timed-out true)
        (do
          (os/proc-close p)
          (error err)))))
  (os/proc-close p)
  (if timed-out
    {:elapsed_time benchmark-timeout :timed_out true}
    {:elapsed_time (- (os/clock) start)}))

# (def benchmarks @{"noop" ["0"]
#                   "dict_words" ["3000000"]
#                   "table_with_tuple_keys" ["0 600" "1000 600" "10000 600" "100000 600" "1000000 600" "10000000 600"]
#                   "table_with_struct_keys" ["0 600" "1000 600" "10000 600" "100000 600" "1000000 600" "10000000 600"]
#                   "table_with_float_keys" ["1000000 1" "1000000 1.79769e+308"]
#                   "sort_random_numbers" ["300000 1" "300000 1000000"]
#                   "hash_numbers" ["100000"]
#                   "aoc_2020_d15_p1" ["1000000"]
#                   "hexagon_tuples" ["50"])})

(def benchmarks @{"noop" ["0"]
                  "dict_words" ["4000000"]
                  "table_with_tuple_keys" ["0 1300" "1000 1300" "10000000 1300"]
                  "table_with_struct_keys" ["0 720" "1000 720" "10000000 720"]
                  "table_with_float_keys" ["2500000 1" "2500000 1.79769e+308"]
                  "sort_random_numbers" ["1250000 1" "1250000 1000000"]
                  "hash_numbers" ["5000000"]
                  "aoc_2020_d15_p1" ["1600000"]
                  "hexagon_tuples" ["59"]})


(def active-benchmarks
  (if
    (< (length args) 4)
    (pairs benchmarks)
    (let [selected (drop 3 args)]
      (filter (fn [[k v]] (find (partial = k) selected)) (pairs benchmarks)))))


(def previous-results
  (if (os/stat output-file)
    (->>
      (slurp output-file)
      (string/split "DATA:\n")
      (last)
      (string/trim)
      (base64/decode)
      (unmarshal))
    {:version janet-version
     :build janet-build
     :results @{}}))

(assert (= janet-version (previous-results :version)) "version does not match")
(assert (= janet-build (previous-results :build)) "build does not match")

(def number-of-runs 3)

(def all-results (previous-results :results))
(each [b params] active-benchmarks
  (print b)
  (def b-results @[])
  (var timed-out false)
  (each param params
    (when timed-out (break))
    (prinf "  param=%q " param)
    (def results @[])
    (for i 0 number-of-runs
      (def r (run-benchmark b param))
      (prin (if (r :timed_out) "T" ".")) (flush)
      (array/push results r)
      (when (r :timed_out)
        (set timed-out true)
        (break)))
    (array/push b-results {:param param :results results})
    (def times (map (fn [x] (x :elapsed_time)) results))
    (printf "\t\tmin=%.3f max=%.3f" (min ;times) (max ;times))
    (put all-results b b-results)))

(pp all-results)

(print "\nDATA:")
(def output (base64/encode (marshal {:version janet-version :build janet-build :results all-results})))
(print output)
(spit output-file output)
