;;;; # Day 2: Part one

(ns d02-p1
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

(defn- possible?
  [thr-map game]
  (and (<= (get-in game [:max-cubes :red] 0) (get thr-map :red))
       (<= (get-in game [:max-cubes :blue] 0) (get thr-map :blue))
       (<= (get-in game [:max-cubes :green] 0) (get thr-map :green))))

(defn d02-p1
  [fname]
  (->> (map make-game-info (line-seq (io/reader fname)))
       (filter #(possible? {:red 12 :green 13 :blue 14} %))
       (map #(get % :number))
       (apply +)))

;;; user=> (d02-p1 "input")

