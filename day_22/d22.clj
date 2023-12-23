#!/usr/bin/env bb

;;;; # Day 22

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])
(require 'clojure.set)

(defn- parse-data
  [data]
  (loop [lines (map-indexed vector (str/split data #"\n"))
         result []]
    (if (seq lines)
      (let [[id line] (first lines)
            v (mapv parse-long (str/split line #"\W+"))]
        (recur (next lines)
               (conj result {:id (keyword (str id))
                             :xy (for [x (range (nth v 0) (inc (nth v 3)))
                                       y (range (nth v 1) (inc (nth v 4)))]
                                   [x y])
                             :z1 (nth v 2)
                             :z2 (nth v 5)})))
      (sort-by :z1 result))))

(defn- drop-brick
  [brick ^java.util.HashMap m]
  (loop [low (:z1 brick)]
    (let [floors (remove nil? (map #(.get m (conj % (dec low))) (:xy brick)))]
      (if (and (> low 1) (zero? (count floors)))
        (recur (dec low))
        (do (doall (map #(.put m (conj % (- (:z2 brick) (- (:z1 brick) low))) (:id brick)) (:xy brick)))
            [(:id brick) (set floors)])))))

(defn- drop-all-bricks
  [bricks]
  (let [height-map (java.util.HashMap.)]
    (loop [bricks bricks
           floors {}
           ceils {}]
      (if (seq bricks)
        (let [[id floor-bricks] (drop-brick (first bricks) height-map)]
          (recur (next bricks)
                 (assoc floors id floor-bricks)
                 (reduce (fn [m k] (assoc m k (conj (get m k #{}) id)))
                         (assoc ceils id #{})
                         floor-bricks)))
        [floors ceils]))))

(defn- p1
  [floors ceils]
  (loop [ks (keys ceils)
         cnt 0]
    (if (seq ks)
      (if (some #(= (count (% floors)) 1) ((first ks) ceils))
        (recur (next ks) cnt)
        (recur (next ks) (inc cnt)))
      cnt)))

(defn- p2
  [floors ceils]
  (let [cnt (atom 0)]
    (loop [ks (keys ceils)]
      (if (seq ks)
        (let [brick (first ks)]
          (loop [q (apply conj (clojure.lang.PersistentQueue/EMPTY) (brick ceils))
                 fallen-bricks #{brick}]
            (if (empty? q)
              (swap! cnt + (dec (count fallen-bricks)))
              (let [target (peek q)]
                (if (clojure.set/subset? (target floors) fallen-bricks)
                  (recur (apply conj (pop q) (target ceils)) (conj fallen-bricks target))
                  (recur (pop q) fallen-bricks)))))
          (recur (next ks)))
        @cnt))))

(when (seq *command-line-args*)
  (let [[floors ceils] (drop-all-bricks (parse-data (slurp (first *command-line-args*))))]
    (println "Part one:" (p1 floors ceils))
    (println "Part two:" (p2 floors ceils))))
