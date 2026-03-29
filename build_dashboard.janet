#!/usr/bin/env janet
# Inject Janet benchmark data from report.dat into dashboard.html.

(defn json-escape [s]
  (->> s
       (string/replace-all "\\" "\\\\")
       (string/replace-all "\"" "\\\"")
       (string/replace-all "\n" "\\n")
       (string/replace-all "\r" "\\r")
       (string/replace-all "\t" "\\t")))

(defn row->json [row]
  (string/format
    "{\"version\": \"%s\", \"index\": %d, \"benchmark\": \"%s\", \"min\": %.17g, \"max\": %.17g, \"mean\": %.17g}"
    (json-escape (row :version))
    (row :index)
    (json-escape (row :benchmark))
    (row :min)
    (row :max)
    (row :mean)))

(defn rows->json [rows]
  (string "[" (string/join (map row->json rows) ", ") "]"))

(defn parse-report-dat [text]
  (def rows @[])
  (each raw-line (string/split "\n" text)
    (def line (string/trim raw-line))
    (when (and (> (length line) 0) (not (string/has-prefix? "#" line)))
      (def parts (string/split "\t" line))
      (when (>= (length parts) 6)
        (def [version idx-str benchmark min-str max-str mean-str] parts)
        (def idx (scan-number idx-str))
        (def mi (scan-number min-str))
        (def mx (scan-number max-str))
        (def avg (scan-number mean-str))
        (when (and idx mi mx avg)
          (array/push rows
                      {:version version
                       :index (math/trunc idx)
                       :benchmark benchmark
                       :min mi
                       :max mx
                       :mean avg})))))
  rows)

(defn replace-benchmark-data [html-text json-str]
  (def marker "const BENCHMARK_DATA = ")
  (when-let [start (string/find marker html-text)]
    (def line-end (or (string/find "\n" html-text start) (length html-text)))
    (def line (string/slice html-text start line-end))
    (def semis (string/find-all ";" line))
    (when (not (empty? semis))
      (def end (+ start (last semis) 1))
      (string (string/slice html-text 0 start)
              marker json-str ";"
              (string/slice html-text end)))))

(defn print-usage []
  (print "Usage: janet build_dashboard.janet [-i INPUT] [-o OUTPUT]")
  (print "  -i, --input   Input .dat file (or '-' for stdin). Default: report.dat")
  (print "  -o, --output  Target HTML dashboard file to update. Default: dashboard.html")
  (print "  -h, --help    Show this help message"))

(defn main [_ & args]
  (var input-path "report.dat")
  (var output-path "dashboard.html")
  (var i 0)
  (while (< i (length args))
    (def arg (get args i))
    (cond
      (or (= arg "-h") (= arg "--help"))
      (do (print-usage) (os/exit 0))

      (or (= arg "-i") (= arg "--input"))
      (do
        (++ i)
        (when (>= i (length args))
          (eprint "Error: missing value for " arg)
          (os/exit 1))
        (set input-path (get args i)))

      (or (= arg "-o") (= arg "--output"))
      (do
        (++ i)
        (when (>= i (length args))
          (eprint "Error: missing value for " arg)
          (os/exit 1))
        (set output-path (get args i)))

      (do
        (eprint "Error: unknown argument " arg)
        (print-usage)
        (os/exit 1)))
    (++ i))

  (def dat-text
    (if (= input-path "-")
      (or (file/read stdin :all) "")
      (slurp input-path)))

  (def rows (parse-report-dat dat-text))
  (def html-text (slurp output-path))
  (def new-html (replace-benchmark-data html-text (rows->json rows)))

  (when (nil? new-html)
    (eprintf "Error: could not find BENCHMARK_DATA placeholder in %s" output-path)
    (os/exit 1))

  (spit output-path new-html)
  (printf "Updated %s with %d benchmark entries." output-path (length rows)))
