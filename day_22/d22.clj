#!/usr/bin/env bb

;;;; # Day 22

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])

(defn- parse-data
  [data]
  (loop [lines (str/split data #"\n")
         result []]
    (if (seq lines)
      (let [v (mapv parse-long (str/split (first lines) #"\W+"))]
        (recur (next lines)
               (conj result {:x1 (nth v 0), :y1 (nth v 1), :z1 (nth v 2) :x2 (nth v 3) :y2 (nth v 4) :z2 (nth v 5)})))
      (sort-by :z1 result))))

(defn- drop-brick
  [brick ^java.util.HashMap m]
  (let [max-height (apply max (for [x (range (:x1 brick) (inc (:x2 brick)))
                                    y (range (:y1 brick) (inc (:y2 brick)))]
                                (.getOrDefault m [x y] 0)))
        delta (max (- (:z1 brick) max-height 1) 0)]
    (assoc brick :z1 (- (:z1 brick) delta) :z2 (- (:z2 brick) delta))))

(defn- drop-all-bricks
  [bricks ^java.util.HashMap floor]
  (loop [bricks bricks
         v []
         n-falls 0]
    (if (seq bricks)
      (let [b (first bricks)
            new-b (drop-brick b floor)]
          (doseq [x (range (:x1 new-b) (inc (:x2 new-b)))
                  y (range (:y1 new-b) (inc (:y2 new-b)))]
            (.put floor [x y] (:z2 new-b)))
          (cond
            (= (:z1 b) (:z1 new-b)) (recur (next bricks) (conj v new-b) n-falls)
            :else (recur (next bricks) (conj v new-b) (inc n-falls))))
      [v n-falls])))

(defn- jenga
  [tower]
  (let [floor (java.util.HashMap.)]
    (loop [bricks tower
           n-safe-bricks 0
           total-falls 0]
      (if (seq bricks)
        (let [brick (first bricks)
              bs (rest bricks)
              [_ n-falls] (drop-all-bricks bs (java.util.HashMap. floor))]
          (doseq [x (range (:x1 brick) (inc (:x2 brick)))
                  y (range (:y1 brick) (inc (:y2 brick)))]
            (.put floor [x y] (:z2 brick)))
          (cond
            (zero? n-falls) (recur (next bricks) (inc n-safe-bricks) total-falls)
            :else (recur (next bricks) n-safe-bricks (+ total-falls n-falls))))
        [n-safe-bricks total-falls]))))

(when (seq *command-line-args*)
  (let [[tower _] (drop-all-bricks (parse-data (slurp (first *command-line-args*))) (java.util.HashMap.))
        [ans1 ans2] (jenga tower)]
    (println "Part one:" ans1)
    (println "Part two:" ans2)))
