(ns myos.update
  (:require [babashka.process :as bp :refer [shell]]
            [babashka.fs :as fs]
            [cheshire.core :as json]))

(defn update
  []
  (let [flake-out (-> (shell {:err :string} "nix flake update")
                      :err)
        nv-out (-> (shell {:out :string} "nvfetcher")
                   :out)
        report (str "<pre># Update report\n"
                    "# flake lock update\n"
                    flake-out
                    \newline
                    "# nvfetcher update\n"
                    nv-out
                    \newline
                    "</pre>")]
    (when-let [output (getenv "GITHUB_OUTPUT")]
      (println ">>> setting summary")
      (spit step-summary (str "report=" report) :append true))
    (println ">>> report")
    (println report)))

(update)
