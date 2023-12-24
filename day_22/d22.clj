#!/usr/bin/env bb

;;;; # Day 22

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])
(require 'clojure.set)

(defn- parse-data
  [data]
  (loop [lines (map-indexed vector (str/split data #"\n"))
         result (transient [])]
    (if (seq lines)
      (let [[id line] (first lines)
            v (mapv parse-long (str/split line #"\W+"))]
        (recur (next lines)
               (conj! result {:id (keyword (str id))
                             :xy (for [x (range (nth v 0) (inc (nth v 3)))
                                       y (range (nth v 1) (inc (nth v 4)))]
                                   [x y])
                             :z1 (nth v 2)
                             :z2 (nth v 5)})))
      (sort-by :z1 (persistent! result)))))

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
           lower-bricks {}
           upper-bricks {}]
      (if (seq bricks)
        (let [[id floor-bricks] (drop-brick (first bricks) height-map)]
          (recur (next bricks)
                 (assoc lower-bricks id floor-bricks)
                 (reduce (fn [m k] (assoc m k (conj (get m k #{}) id)))
                         (assoc upper-bricks id #{})
                         floor-bricks)))
        [lower-bricks upper-bricks]))))

(defn- p1
  [lower-bricks upper-bricks]
  (loop [vs (vals upper-bricks)
         cnt 0]
    (if (seq vs)
      (if (some #(= (count (% lower-bricks)) 1) (first vs))
        (recur (next vs) cnt)
        (recur (next vs) (inc cnt)))
      cnt)))

(defn- p2
  [lower-bricks upper-bricks]
  (let [cnt (atom 0)]
    (loop [ks (keys upper-bricks)]
      (if (seq ks)
        (let [id (first ks)]
          (loop [q (apply conj (clojure.lang.PersistentQueue/EMPTY) (id upper-bricks))
                 removed-bricks #{id}]
            (if (empty? q)
              ;; Since what we are looking for is the number of *other* bricks that would fall
              ;; due to the removal of one, the first removed brick is not the target for count up.
              ;; So we subtract 1 from the numbers of removed bricks, the result is the number of
              ;; fallen bricks.
              (swap! cnt + (dec (count removed-bricks)))
              (let [brick (peek q)]
                (if (clojure.set/subset? (brick lower-bricks) removed-bricks)
                  (recur (apply conj (pop q) (brick upper-bricks)) (conj removed-bricks brick))
                  (recur (pop q) removed-bricks)))))
          (recur (next ks)))
        @cnt))))

(when (seq *command-line-args*)
  (let [[lower-bricks upper-bricks] (drop-all-bricks (parse-data (slurp (first *command-line-args*))))]
    (println "Part one:" (p1 lower-bricks upper-bricks))
    (println "Part two:" (p2 lower-bricks upper-bricks))))
