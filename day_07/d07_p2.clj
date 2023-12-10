#!/usr/bin/env bb

;;;; # Day 7: Part two

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])

(defn- ch->num
  [ch]
  (case ch
    \2 2, \3 3, \4 4, \5 5, \6 6, \7 7, \8 8, \9 9, \T 10, \J 1, \Q 12, \K 13, \A 14))

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

  example: 32T3K -> [1 [3 2 10 3 13]]"
  [card]
  (let [nums (->> (seq card) (map ch->num))
        pattern (->> (sort nums)
                     (partition-by identity)
                     (map count)
                     (sort #(compare %2 %1)))]
    [(index-of hand-patterns pattern) (vec nums)]))

(defn- get-rank-with-wildcard
  "Return a hand information (wild card [Joker] enabled version).

  example:
    [without Joker] 32T3K -> [1 [3 2 10 3 13]]
    [with Joker]    KTJJT -> [5 [13 10 1 1 10]]
      max_rank(KTJJT, KTKKT, KTTTT) = max(2, 4, 5) = 5"
  [card]
  (let [card-set (set (str/split card #""))]
    (if (contains? card-set "J")
      (let [max-rank (->> (map #(str/replace card "J" %) card-set)
                          (map get-rank)
                          (apply max-key first)
                          (first))]
        [max-rank (vec (map ch->num (seq card)))])
      (get-rank card))))

(defn- parse-line
  [line]
  (let [[card bid] (str/split line #" ")]
    {:hand (get-rank-with-wildcard card) :bid (parse-long bid) :card card}))

(when (seq *command-line-args*)
  (->> (map parse-line (line-seq (io/reader (first *command-line-args*))))
       (sort-by :hand compare)
       (map-indexed #(* (inc %1) (:bid %2)))
       (apply +)
       (println)))
