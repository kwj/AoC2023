;;;; # Day 2: Part one

(ns d02-p1
  (:require
   [clojure.java.io :as io]
   [clojure.string :as str]))

(defn- cubes-map
  [cubes]
  (loop [cubes cubes
         ret {}]
    (if-let [cube (first cubes)]
      (let [[n color] (str/split cube #" ")]
        (recur (next cubes) (assoc ret color (parse-long n))))
      ret)))

(defn- get-game-info
  [line]
  (let [[header game-data] (str/split line #": ")
        game-number (parse-long (nth (str/split header #" ") 1))
        game-sets (->> (str/split game-data #"; ")
                       (map #(str/split % #", "))
                       (map cubes-map)
                       (apply merge-with (fn [n1 n2] (max n1 n2))))]
    {:number game-number :max-cubes game-sets}))

(defn- possible?
  [thr-red thr-blue thr-green game]
  (let [n-red (get-in game [:max-cubes "red"] 0)
        n-blue (get-in game [:max-cubes "blue"] 0)
        n-green (get-in game [:max-cubes "green"] 0)]
    (and (<= n-red thr-red)
         (<= n-blue thr-blue)
         (<= n-green thr-green))))

(defn d02-p1
  [fname]
  (let [games (map get-game-info (line-seq (io/reader fname)))]
    (->> (filter #(possible? 12 14 13 %) games)
         (map #(get % :number))
         (apply +))))

;;; user=> (d02-p1 "input")

