#!/usr/bin/env bb

;;;; # Day 18: Part two

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])

(defn- parse-info-p2
  [line]
  (let [color (nth (str/split line #"\W+") 2)
        distance (Integer/parseInt (subs color 0 5) 16)
        dir (case (subs color 5 6)
              "0" "R"
              "1" "D"
              "2" "L"
              "U")]
    {:dir dir :distance distance :color color}))

(defn- make-point-info
  [ms]
  (loop [ms ms
         v [0 0]
         vs [v]
         acc 0]
    (if (seq ms)
      (let [m (first ms)
            d (:distance m)
            next-v (case (:dir m)
                     "R" (assoc v 0 (+ (nth v 0) d))
                     "L" (assoc v 0 (- (nth v 0) d))
                     "U" (assoc v 1 (+ (nth v 1) d))
                     (assoc v 1 (- (nth v 1) d)))]
        (recur (next ms) next-v (conj vs next-v) (+ acc d)))
      {:steps acc :points vs})))

;;; Shoelace formula
;;; https://en.wikipedia.org/wiki/Shoelace_formula
(defn- solve
  [m]
  (let [A2 (->> (partition 2 1 (:points m))
                (map #(- (* (nth (first %) 0) (nth (second %) 1))
                         (* (nth (first %) 1) (nth (second %) 0))))
                (apply +)
                (abs))]
    (inc (quot (+ A2 (:steps m)) 2))))

(when (seq *command-line-args*)
  (->> (line-seq (io/reader (first *command-line-args*)))
       (map parse-info-p2)
       (make-point-info)
       (solve)
       (println)))
