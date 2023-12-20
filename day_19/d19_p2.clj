#!/usr/bin/env bb

;;;; # Day 19: Part two

(require '[clojure.java.io :as io])
(require '[clojure.string :as str])

;;; Example
;;;   [in] "a<2006:qkq"
;;;   [out] [:a "<" 2006 :pkg]
(defn- make-workflow-aux
  "Make a condition vector from a string."
  [s]
  (let [category (subs s 0 1)
        op (subs s 1 2)
        [n next-tag] (str/split (subs s 2) #":")]
    [(keyword category) op (parse-long n) (keyword next-tag)]))

;;; Example
;;;   [in]
;;;     rfg{s<537:gd,x>2440:R,A}
;;;   [out]
;;;   {:rfg {:workflow ([:s "<" 537 :gd] [:x ">" 2440 :R]) :default :A}}
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

;;; user=> (next-range-aux "<" 2006 {:start 1, :end 4000})
;;; [{:start 1, :end 2005} {:start 2006, :end 4000}]
;;; user=> (next-range-aux "<" 2006 {:start 3000, :end 4000})
;;; [nil {:start 3000, :end 4000}]
;;; user=> (next-range-aux "<" 2006 {:start 1000, :end 2000})
;;; [{:start 1000, :end 2000} nil]
(defn- next-ranges-aux
  "Divide a range according to a condition and return a vector.

   The first element of the vector is the range which meets the conditin,
   The second element is the range which doesn't meet the condition.
   If there is not a range, the element must be `nil`."
  [op n r]
  (let [low (:start r)
        high (:end r)]
    (case op
      "<" (if (< low n)
            [{:start low, :end (min high (dec n))}
             (if (< high n) nil {:start n :end high})]
            [nil r])
      ">" (if (> high n)
            [{:start (max low (inc n)), :end high}
             (if (> low n) nil {:start low :end n})]
            [nil r])
      (assert false "unknown `op`"))))

;;; Example
;;;   [in]
;;;     m - {:workflow ([:a "<" 2006 :qkq] [:m ">" 2090 :A]), :default :rfg}
;;;     parts - {:x {:start 1 :end 4000}, :m {:start 1 :end 4000}, :a {:start 1 :end 4000}, :s {:start 1 :end 4000}}
;;;   [out]
;;;     [{:tag :qkq, :parts {:x {:start 1, :end 4000}, :m {:start 1, :end 4000}, :a {:start 1, :end 2005}, :s {:start 1, :end 4000}}}
;;;      {:tag :A, :parts {:x {:start 1, :end 4000}, :m {:start 2091, :end 4000}, :a {:start 2006, :end 4000}, :s {:start 1, :end 4000}}}
;;;      {:tag :rfg, :parts {:x {:start 1, :end 4000}, :m {:start 1, :end 2090}, :a {:start 2006, :end 4000}, :s {:start 1, :end 4000}}}]
(defn- next-ranges
  [m parts]
  (loop [vs (:workflow m)
         parts parts
         next-rs []]
    (if (seq vs)
      (let [[category op n tag] (first vs)
            [r1 r2] (next-ranges-aux op n (category parts))]
        (if (nil? r2)
          (conj next-rs {:tag tag, :parts (assoc parts category r1)})
          (recur (next vs)
                 (assoc parts category r2)
                 (if (nil? r1)
                   next-rs
                   (conj next-rs {:tag tag, :parts (assoc parts category r1)})))))
      (if (identity parts)
        (conj next-rs {:tag (:default m), :parts parts})
        next-rs))))

(defn- number-of-accepted
  [parts]
  (->> (vals parts)
       (mapv vals)
       (map #(inc (- (second %) (first %))))
       (apply *)))

(when (seq *command-line-args*)
  (let [tbl (make-workflow (first (str/split (slurp (first *command-line-args*)) #"\n\n")))]
    (loop [q (conj (clojure.lang.PersistentQueue/EMPTY)
                   {:tag :in,
                    :parts {:x {:start 1 :end 4000},
                            :m {:start 1 :end 4000},
                            :a {:start 1 :end 4000},
                            :s {:start 1 :end 4000}}})
           ans 0]
      (if (empty? q)
        (println ans)
        (let [state (peek q)]
          (case (:tag state)
            :R (recur (pop q) ans)
            :A (recur (pop q) (+ ans (number-of-accepted (:parts state))))
            (recur (apply conj
                          (pop q)
                          (next-ranges ((:tag state) tbl) (:parts state)))
                   ans)))))))
