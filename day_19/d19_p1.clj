#!/usr/bin/env bb

;;;; # Day 19: Part one

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])

;;; Example
;;;   [in] "a<2006:qkq"
;;;   [out] {:a "<" 2006 :pkg}
(defn- make-workflow-aux
  "Make a condition map from a string."
  [s]
  (let [category (subs s 0 1)
        op (subs s 1 2)
        [n next-tag] (str/split (subs s 2) #":")]
    [(keyword category) op (parse-long n) (keyword next-tag)]))

;;; Example
;;;   [in]
;;;     rfg{s<537:gd,x>2440:R,A}
;;;   [out]
;;;     {:rfg {:workflow ({:s "<" 537 :gd} {:x ">" 2440 :R}) :default :A}}
(defn- make-workflow
  "Make a workflow table."
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

;;; Example
;;;   [in] "{x=787,m=2655,a=1222,s=2876}"
;;;   [out] {:x 787, :m 2655, :a 1222, :s 2876}
(defn- make-parts
  "Make a part map."
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
         (flatten)
         (apply +)
         (println))))
