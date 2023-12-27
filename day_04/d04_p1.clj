#!/usr/bin/env bb

;;;; # Day 4: Part one

(require '[clojure.java.io :as io])
(require '[clojure.math :as math])
(require '[clojure.set])
(require '[clojure.string :as str])

(defn- make-card-info
  "Return a map of card information.

    {:card 1, :win #{86 48 41 17 83}, :own #{86 48 31 6 17 9 83 53} :cnt 4}

  It has the card number, winning numbers, own numbers and number of matched numbers."
  [line]
  (let [[header win mine] (str/split line #" *[:|] ")
        card-number (parse-long (nth (str/split header #" +") 1))
        win-numbers (set (map parse-long (str/split win #" +")))
        own-numbers (set (map parse-long (str/split mine #" +")))]
    {:card card-number
     :win win-numbers
     :own own-numbers
     :cnt (count (clojure.set/intersection win-numbers own-numbers))}))

(defn- calc-point
  [n]
  (if (zero? n)
    0
    (long (math/pow 2 (dec n)))))

(when (seq *command-line-args*)
  (->> (line-seq (io/reader (first *command-line-args*)))
       (map make-card-info)
       (map #(calc-point (:cnt %)))
       (apply +)
       (println)))
