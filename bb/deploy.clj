(ns deploy
  (:require [babashka.process :as bp :refer [shell]]
            [cheshire.core :as json]))

(def host-ids [:ge :zheng :lei :dui])
(def fqdn-suffix ".h.edgerunners.eu.org")
(def user "deploy")

(defn- make-hosts
  [ids]
  (->> ids
       (mapv (fn [id] {:id id :host (str (name id) fqdn-suffix) :user user}))))

(def hosts (make-hosts host-ids))

(defn deploy-host
  [{:keys [id host user]}]
  (let [flake (or (System/getenv "MYOS_FLAKE") "github:sg-qwt/nixos")]
    (println "🔥 start deploying: " (name id))
    (println "💻 host: " host)
    (println "🤖 user: " user)
    (println "📦 flake: " flake)
    (shell "nixos-rebuild"
           "--target-host" (str user "@" host)
           "--flake" (str flake "#" (name id))
           "--use-remote-sudo" "switch")
    (println "✅ deploy successfully")))

(defn deploy
  [name]
  (if-some [host (->> hosts
                      (filter (fn [host] (= (:id host) (keyword name))))
                      first)]
    (deploy-host host)
    (do (println ">>> no host found: " name)
        (println "available hosts are: " host-ids))))
