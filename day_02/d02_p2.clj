;;;; # Day 2: Part two

(ns d02-p2
  (:require
   [clojure.java.io :as io]
   [clojure.string :as str]))

(defn- make-game-info
  [line]
  (let [[header game-data] (str/split line #": ")
        game-number (parse-long (nth (str/split header #" ") 1))
        max-cubes (->> (re-seq #"[^,;\s]+" game-data)
                       (partition 2)
		       (map (fn [[v k]] {(keyword k) (parse-long v)}))
                       (apply merge-with (fn [n1 n2] (max n1 n2))))]
    {:number game-number :max-cubes max-cubes}))

(defn- power-cubes
  [game]
  (* (get-in game [:max-cubes :red] 1)
     (get-in game [:max-cubes :blue] 1)
     (get-in game [:max-cubes :green] 1)))

(defn d02-p2
  [fname]
  (->> (map make-game-info (line-seq (io/reader fname)))
       (map power-cubes)
       (apply +)))

;;; user=> (d02-p2 "input")

