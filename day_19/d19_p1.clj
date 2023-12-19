#!/usr/bin/env bb

;;;; # Day 19: Part one

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])

(defn- make-workflow-aux
  [s]
  (let [category (subs s 0 1)
        op (subs s 1 2)
        [n next-tag] (str/split (subs s 2) #":")]
    [(keyword category) op (parse-long n) (keyword next-tag)]))

(defn- make-workflow
  [data]
  (loop [lines (str/split-lines data)
         tbl {}]
    (if (seq lines)
      (let [line (first lines)
            [tag body] (str/split line #"[{}]")
            flows (str/split body #",")
            default (peek flows)]

        (recur (next lines)
               (assoc tbl
                      (keyword tag)
                      {:workflow (map make-workflow-aux (drop-last flows)), :default (keyword default)})))
      tbl)))

(defn- make-parts
  [data]
  (loop [lines (str/split-lines data)
         v []]
    (if (seq lines)
      (let [line (first lines)]
        (recur (next lines) (conj v (load-string (str/replace line #"(.)=" ":$1 ")))))
      v)))

(defn- next-tag
  [m part]
  (loop [vs (:workflow m)]
    (if (seq vs)
      (let [[category op n tag] (first vs)]
        (case op
          "<" (if (< (category part) n)
                tag
                (recur (next vs)))
          ">" (if (> (category part) n)
                tag
                (recur (next vs)))
          (assert false "unknown `op`")))
      (:default m))))

(defn- accept?
  [tbl part]
  (loop [state :in]
    (case state
      :A true
      :R false
      (recur (next-tag (state tbl) part)))))

(when (seq *command-line-args*)
  (let [[s1 s2] (str/split (slurp (first *command-line-args*)) #"\n\n")
        tbl (make-workflow s1)
        parts (make-parts s2)]
    (->> (filter #(accept? tbl %) parts)
         (map vals)
         (map #(apply + %))
         (apply +)
         (println))))
