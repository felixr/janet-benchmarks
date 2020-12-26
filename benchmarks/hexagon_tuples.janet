(def txt "sesenwnenenewseeswwswswwnenewsewsw\nneeenesenwnwwswnenewnwwsewnenwseswesw\nseswneswswsenwwnwse\nnwnwneseeswswnenewneswwnewseswneseene\nswweswneswnenwsewnwneneseenw\neesenwseswswnenwswnwnwsewwnwsene\nsewnenenenesenwsewnenwwwse\nwenwwweseeeweswwwnwwe\nwsweesenenewnwwnwsenewsenwwsesesenwne\nneeswseenwwswnwswswnw\nnenwswwsewswnenenewsenwsenwnesesenew\nenewnwewneswsewnwswenweswnenwsenwsw\nsweneswneswneneenwnewenewwneswswnese\nswwesenesewenwneswnwwneseswwne\nenesenwswwswneneswsenwnewswseenwsese\nwnwnesenesenenwwnenwsewesewsesesew\nnenewswnwewswnenesenwnesewesw\neneswnwswnwsenenwnwnwwseeswneewsenese\nneswnwewnwnwseenwseesewsenwsweewe\nwseweeenwnesenwwwswnew")

(defn parse-line [line]
  (peg/match '{:main (some :dir)
               :dir (<- (choice "ne" "nw" "se" "sw" "e" "w"))} line))
(def input 
  (->> (string/trim txt)
       (string/split "\n")
       (map parse-line)))


(var tiles @{})

(defn add [a b] 
 (tuple ;(map sum (partition 2 (interleave a b)))))


(defn move [curr dir]
  (match dir
          "nw" (add curr [0 1 -1])
          "ne" (add curr [1 0 -1])
          "se" (add curr [0 -1 1]) 
          "sw" (add curr [-1 0 1])
          "e"  (add curr [1 -1 0])
          "w"  (add curr [-1 1 0])))

(each arr input
  (var pos [0 0 0])
  (each dir arr
    (set pos (move pos dir)))
  (put tiles pos (not (get tiles pos))))

(defn count-black [pos]
  (var cnt 0)
  (each dir ["ne" "nw" "se" "sw" "e" "w"]
    (if (get tiles (move pos dir)) (+= cnt 1)))
  cnt)
  
(each pos (keys tiles)
  (each d ["ne" "nw" "se" "sw" "e" "w"]
    (def ppos (move pos d))
    (put tiles ppos (truthy? (get tiles ppos)))))
  
(def args (dyn :args))
(def iterations (or (scan-number (args 1)) 60))

(for i 0 iterations
  (def updates 
    (keep 
     (fn [[pos color]]
       (def cnt (count-black pos)) 
       (if color
         (if (or (= 0 cnt) (> cnt 2)) [pos false])
         (if (= 2 cnt) [pos true]))) 
     (pairs tiles)))
 (each [pos color] updates 
  (put tiles pos color)
  (each d ["ne" "nw" "se" "sw" "e" "w"]
    (def ppos (move pos d))
    (put tiles ppos (truthy? (get tiles ppos))))))


(def hashes (map hash (keys tiles)))
(def num (length hashes))
(def num-hash (length (distinct hashes)))

(pp {:num_tuples num :num_collisions (- num num-hash) :collision_percent (* 100 (/ (- num num-hash) num))})


