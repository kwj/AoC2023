#!/usr/bin/env bb

;;;; # Day 6: Part two

(require '[clojure.java.io :as io])
(require '[clojure.math :as math])
(require '[clojure.string :as str])

(defn- number-of-win-ways
  [t d]
  (let [sq (math/sqrt (- (* t t) (* 4 d)))
        low (long (math/floor (inc (/ (- (double t) sq) 2.0))))
        high (long (math/ceil (dec (/ (+ (double t) sq) 2.0))))]
    (inc (- high low))))

(defn- make-race-info
  [line]
  (let [time-info (parse-long (str/replace (nth (str/split (first line) #":\s+") 1) #"\s+" ""))
        distance-info (parse-long (str/replace (nth (str/split (second line) #":\s+") 1) #"\s+" ""))]
    [time-info distance-info]))

(when (seq *command-line-args*)
  (->> (make-race-info (line-seq (io/reader (first *command-line-args*))))
       (apply number-of-win-ways)
       (println)))
