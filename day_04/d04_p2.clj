#!/usr/bin/env bb

;;;; # Day 4: Part two

(require '[clojure.java.io :as io])
(require '[clojure.set])
(require '[clojure.string :as str])

(defn- make-card-info
  "Return a map of card information.

    {:card 1, :win #{86 48 41 17 83}, :own #{86 48 31 6 17 9 83 53} :cnt 4}

  It has the card number, winning numbers, own numbers and number of matching numbers."
  [line]
  (let [[header win mine] (str/split line #" *[:|] ")
        card-number (parse-long (nth (str/split header #" +") 1))
        win-numbers (set (map parse-long (str/split win #" +")))
        own-numbers (set (map parse-long (str/split mine #" +")))]
    {:card card-number
     :win win-numbers
     :own own-numbers
     :cnt (count (clojure.set/intersection win-numbers own-numbers))}))

(when (seq *command-line-args*)
  (let [cards (map make-card-info (line-seq (io/reader (first *command-line-args*))))
        n-cards (count cards)
        tbl (long-array (inc n-cards) 1)]
    (aset tbl 0 0)
    (doseq [{:keys [card cnt]} cards]
      (let [factor (aget tbl card)]
        (doseq [idx (range (inc card) (inc (+ card cnt)))]
          (when (<= idx n-cards)
            (aset tbl idx (+ (aget tbl idx) factor))))))
    (->> (seq tbl)
         (apply +)
         (println))))
