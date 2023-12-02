#!/usr/bin/env bb

;;;; # Day 2: Part two

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])

;;; user=> (make-game-info "Game 10: 2 red, 9 green, 8 blue; 16 green, 1 red, 7 blue; 3 blue, 5 red, 9 green; 5 blue, 2 red, 11 green")                                                                  ;;; {:number 10, :cubes {:red 5, :green 16, :blue 8}}
(defn- make-game-info
  "Return a map of game information which has game number and minimum required number of cubes by each color."
  [line]
  (let [[header game-data] (str/split line #": ")
        game-number (parse-long (nth (str/split header #" ") 1))
        cubes (->> (re-seq #"[^,;\s]+" game-data)
                   (partition 2)
                   (map (fn [[v k]] {(keyword k) (parse-long v)}))
                   (apply merge-with (fn [n1 n2] (max n1 n2))))]
    {:number game-number :cubes cubes}))

(defn- power-cubes
  [game]
  (* (get-in game [:cubes :red] 1)
     (get-in game [:cubes :blue] 1)
     (get-in game [:cubes :green] 1)))

(when (seq *command-line-args*)
  (->> (map make-game-info (line-seq (io/reader (first *command-line-args*))))
       (map power-cubes)
       (apply +)
       (println)))
