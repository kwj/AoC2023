#!/usr/bin/env bb

;;;; # Day 2: Part one

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

(defn- possible?
  [thr-map game]
  (and (<= (get-in game [:cubes :red] 0) (:red thr-map))
       (<= (get-in game [:cubes :blue] 0) (:blue thr-map))
       (<= (get-in game [:cubes :green] 0) (:green thr-map))))

(when (seq *command-line-args*)
  (->> (line-seq (io/reader (first *command-line-args*)))
       (map make-game-info)
       (filter #(possible? {:red 12 :green 13 :blue 14} %))
       (map #(:game %))
       (apply +)
       (println)))
