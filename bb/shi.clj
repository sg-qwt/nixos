(ns shi
  (:require [clojure.string :as str]))

(def shi-file-path (first *command-line-args*))

(println
 (->> (str/split (slurp shi-file-path) #"\n\n")
      (filter (fn [l]
                (and (str/starts-with? l "《")
                     (> (count (str/split-lines l)) 1))))
      rand-nth
      str/split-lines
      (map (fn [l] (str ";; " l)))
      (str/join \newline)))

