(import "./base64" :as base64)

(def args (dyn :args))
(def output-file (args 1))


(def previous-results
  (->>
    (slurp output-file)
    (string/trim)
    (base64/decode)
    (unmarshal)))
  

(pp previous-results)
