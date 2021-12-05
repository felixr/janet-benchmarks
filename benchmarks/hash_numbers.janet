(def args (dyn :args))
(def num (scan-number (args 1)))

(do
  (def squares @{})
  (for i 0 num
    (set (squares (* i i)) true)))
