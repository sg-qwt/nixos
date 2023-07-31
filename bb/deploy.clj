(ns deploy
  (:require
   [babashka.cli :as cli]
   [babashka.process :as bp :refer [shell]]
   [cheshire.core :as json]
   [clojure.string :as str]))

(def flake (or (System/getenv "MYOS_FLAKE") "github:sg-qwt/nixos"))

(defn my-host
  []
  (-> (shell {:out :string} "hostname")
      :out
      str/trim
      keyword))

(defn get-hosts
  [flake]
  (-> (shell {:out :string}
             (format "nix eval %s#nixosConfigurations --apply builtins.attrNames --json" flake))
      :out
      json/parse-string
      vec))

(defmacro def-host-ids [] (let [flake-hosts (get-hosts flake)] `(def ~'host-ids ~flake-hosts)))

(declare host-ids)
(def-host-ids)

(def fqdn-suffix ".h.edgerunners.eu.org")
(def user "deploy")

(defn- make-hosts
  [ids]
  (->> ids
       (mapv (fn [id] {:id id :host (str (name id) fqdn-suffix) :user user}))))

(def hosts (make-hosts host-ids))

(defn deploy-host
  [{:keys [id host user]}]
  (println "🔥 start deploying: " (name id))
  (println "💻 host: " host)
  (println "🤖 user: " user)
  (println "📦 flake: " flake)
  (shell "nixos-rebuild"
         "--target-host" (str user "@" host)
         "--flake" (str flake "#" (name id))
         "--use-remote-sudo" "switch")
  (println "✅ deploy successfully"))

(defn deploy
  [hostname]
  (if-some [host (->> hosts
                      (filter (fn [h] (= (:id h) (name hostname))))
                      first)]
    (deploy-host host)
    (do (println ">>> no host found: " name) (println "available hosts are: " host-ids))))

(def spec
  [[:host {:desc "Host to deploy." :alias :h :default (my-host) :coerce :keyword}]
   [:list-hosts {:desc "List all available hosts" :alias :l :coerce boolean}]
   [:help {:desc "Help" :coerce boolean}]])

(let [opts (cli/parse-opts *command-line-args* {:spec spec})]
  (cond (:help opts) (println (cli/format-opts {:spec spec}))
        (:list-hosts opts) (println (str/join \newline host-ids))
        :else (deploy (:host opts))))
