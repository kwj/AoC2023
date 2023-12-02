;;;; # Day 2: Part two

(ns d02-p2
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

(defn- power-cubes
  [game]
  (let [n-red (get-in game [:max-cubes "red"] 1)
        n-blue (get-in game [:max-cubes "blue"] 1)
        n-green (get-in game [:max-cubes "green"] 1)]
    (* n-red n-blue n-green)))

(defn d02-p2
  [fname]
  (let [games (map get-game-info (line-seq (io/reader fname)))]
    (->> (map power-cubes games)
         (apply +))))

;;; user=> (d02-p2 "input")

