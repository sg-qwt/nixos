(ns myos.update
  (:require
   [babashka.process :as bp :refer [shell]]
   [babashka.fs :as fs]
   [cheshire.core :as json]))

(defn update
  []
  (let [flake-out (-> (shell {:err :string} "nix flake update")
                      :err)
        report (str "<pre># Update report\n" "# flake lock update\n" flake-out \newline "</pre>")]
    (when-let [output (System/getenv "GITHUB_OUTPUT")]
      (println ">>> setting summary")
      (spit output (str "report<<EOF\n" report "\nEOF") :append true))
    (println ">>> report")
    (println report)))

(update)
