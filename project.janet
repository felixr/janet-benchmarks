(declare-project
  :name "janet-benchmarks"
  :description "a collection of bnechmarks") 

(phony "bench" [] (os/shell "janet run.janet"))
