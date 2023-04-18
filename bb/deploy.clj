(ns deploy
  (:require [babashka.process :as bp :refer [shell]]
            [cheshire.core :as json]))

(def ts-host-ids [:ge :zheng :lei])
(def fqdn "edgerunners.eu.org")
(def user "deploy")

(defn- ts-hosts
  [ids]
  (->> ids
       (mapv (fn [id] {:id id :host (str (name id) ".ts." fqdn) :user user}))))

(def hosts
  (conj (ts-hosts ts-host-ids) {:id :dui :host (str "dui." fqdn) :user user}))

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
    (println ">>> no host found: " name)))
