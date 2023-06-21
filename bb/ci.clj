(ns ci
  (:require [babashka.process :as bp :refer [shell]]
            [cheshire.core :as json]))

(defn- build-target
  [target]
  (-> (shell {:out :string} "nix build --json" target)
      :out
      (json/parse-string true)
      ((comp :out :outputs first))))

(defn build
  [host]
  (let [os-flake (System/getenv "MYOS_FLAKE")
        flake (or os-flake ".")
        target (format "%s#nixosConfigurations.%s.config.system.build.toplevel"
                       flake
                       host)
        _ (println (format "Building %s %s" flake host))
        path (build-target target)]
    (println ">>> Building finised " path)
    path))

(defn configure-attic
  []
  (println ">>> attic server " (System/getenv "ATTIC_SERVER"))
  (println ">>> attic cache " (System/getenv "ATTIC_CACHE"))
  (shell (format "attic login --set-default ci %s %s"
                 (System/getenv "ATTIC_SERVER")
                 (System/getenv "ATTIC_TOKEN")))
  (shell (format "attic use %s" (System/getenv "ATTIC_CACHE"))))

(defn push-to-attic
  [path]
  (println ">>> start pushing " path)
  (shell (format "attic push ci:%s %s" (System/getenv "ATTIC_CACHE") path))
  (println ">>> finished pushing " path))

(defn build-and-push
  [host]
  (let [path (build host)]
    (shell "sleep 5")
    (configure-attic)
    (push-to-attic path)))
