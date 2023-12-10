#!/usr/bin/env bb

;;;; # Day 7: Part one

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])

(defn- ch->num
  [ch]
  (case ch
    \2 2, \3 3, \4 4, \5 5, \6 6, \7 7, \8 8, \9 9, \T 10, \J 11, \Q 12, \K 13, \A 14))

(defn- find-all
  [f lst]
  (keep-indexed #(if (f %2) %1 nil) lst))

(defn- index-of
  ^long [colls elm]
  (let [lst (find-all #(= elm %) colls)]
    (if (seq lst)
      (first lst)
      -1)))

(def ^:private hand-patterns
  ;; 0: High Card - [1 1 1 1 1]
  ;; 1: One Pair [2 1 1 1]
  ;; 2: Two Pairs [2 2 1]
  ;; 3: Three of a Kind [3 1 1]
  ;; 4: Full House [3 2]
  ;; 5: Four of a Kind [4 1]
  ;; 6: Five of a Kind [5]
  '([1 1 1 1 1] [2 1 1 1] [2 2 1] [3 1 1] [3 2] [4 1] [5]))

(defn- get-rank
  "Return a hand information.

  example: KTJJT -> [2 [13 10 11 11 10]]"
  [card]
  (let [nums (->> (seq card) (map ch->num))
        pattern (->> (sort nums)
                     (partition-by identity)
                     (map count)
                     (sort #(compare %2 %1)))]
    [(index-of hand-patterns pattern) (vec nums)]))

(defn- parse-line
  [line]
  (let [[card bid] (str/split line #" ")]
    {:rank (get-rank card) :bid (parse-long bid) :hand card}))

(when (seq *command-line-args*)
  (->> (line-seq (io/reader (first *command-line-args*)))
       (map parse-line)
       (sort-by :rank compare)
       (map-indexed #(* (inc %1) (:bid %2)))
       (apply +)
       (println)))
