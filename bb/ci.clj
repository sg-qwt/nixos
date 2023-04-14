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

(defn push-to-oranc
  [path]
  (println ">>> oranc username " (System/getenv "ORANC_USERNAME"))
  (println ">>> start pushing " path)
  (let
    [pushing
     (bp/shell
      {:out :string, :err :string, :in path}
      "oranc push --registry ghcr.io --repository sg-qwt/nixos --allow-immutable-db")]
    (println (:err pushing)))
  (println ">>> pushing finised " path))

(defn build-and-push
  [host]
  (let [path (build host)]
    (shell "sleep 5")
    (push-to-oranc path)))
