#!/usr/bin/env bb

;;;; # Day 19: Part two

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

(defn- next-ranges-aux
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
;;;   [in]narguments:
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
  (let [[s1 _] (str/split (slurp (first *command-line-args*)) #"\n\n")
        tbl (make-workflow s1)]
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
            (let [p-ranges (next-ranges ((:tag state) tbl) (:parts state))]
              (recur (apply conj (pop q) p-ranges) ans))))))))
