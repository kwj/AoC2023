#!/usr/bin/env bb

;;;; # Day 2: Part two

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])

(defn- make-game-info
  "Return a map of game information.

    {:game 10, :cubes {:red 5, :green 16, :blue 8}}

  It has the game number and minimum required numbers of cubes by each color."
  [line]
  (let [[header cube-data] (str/split line #": ")
        game-number (parse-long (nth (str/split header #" ") 1))
        cubes (->> (re-seq #"[^,;\s]+" cube-data)
                   (partition 2)
                   (map (fn [[v k]] {(keyword k) (parse-long v)}))
                   (apply merge-with (fn [n1 n2] (max n1 n2))))]
    {:game game-number :cubes cubes}))

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
