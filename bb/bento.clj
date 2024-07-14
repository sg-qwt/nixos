(ns bento
  (:require
   [babashka.cli :as cli]
   [babashka.process :as bp :refer [shell]]
   [clojure.string :as str]))

(def flake (or (System/getenv "MYOS_FLAKE") "github:sg-qwt/nixos"))

(defn my-host
  []
  (-> (shell {:out :string} "hostname")
      :out
      str/trim
      keyword))

(def host-ids (str/split (or (System/getenv "MYOS_HOSTS") (name (my-host))) #":"))

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
  [{:keys [opts]}]
  (cond (:list-hosts opts) (println (str/join \newline host-ids))
        :else (if-some [host (->> hosts
                                  (filter (fn [h] (= (:id h) (name (:host opts)))))
                                  first)]
                (deploy-host host)
                (do (println ">>> no host found: " (:host opts))
                    (println "available hosts are: " host-ids)))))

(defn- get-brightness
  []
  (-> (shell {:out :string} "brightnessctl -m info")
      :out
      (str/split #",")
      (nth 3)
      (str/replace "%" "")))

(defn- send-brightness
  [brightness]
  (shell (str "notify-send --urgency low"
              " --hint int:value:" brightness
              " --expire-time 1000"
              " --hint string:x-canonical-private-synchronous:brightness-level"
              " 'Brightness: '" brightness)))

(defn change-brightness
  [up-down]
  (shell (str "brightnessctl set 5%" (if (= up-down :up) "+" "-")))
  (-> (get-brightness)
      (send-brightness)))

(defn grab-shi
  [shi-file-path]
  (->> (str/split (slurp shi-file-path) #"\n\n")
       (filter (fn [l] (and (str/starts-with? l "《") (> (count (str/split-lines l)) 1))))
       rand-nth
       str/split-lines
       (map (fn [l] (str ";; " l)))
       (str/join \newline)
       (println)))

(def power-menu
  {:suspend "systemctl suspend" :reboot "systemctl reboot" :poweroff "systemctl poweroff"})

(defn run-menu
  []
  (let [entries (->> power-menu
                     keys
                     (map name)
                     (str/join "\n"))
        result (-> (shell {:out :string} (format "echo '%s'" entries))
                   (shell {:out :string} "wofi --dmenu --cache-file /dev/null")
                   :out
                   str/trim
                   keyword)]
    (shell (power-menu result))))

(def spec
  [[:host {:desc "Host to deploy." :default (my-host) :coerce :keyword}]
   [:list-hosts {:desc "List all available hosts" :alias :l :coerce boolean}]
   [:help {:desc "Help" :coerce boolean :alias :h}]])

(def table
  [{:cmds ["deploy"] :fn deploy :args->opts [:host :list-hosts]}
   {:cmds ["brightness" "up"] :fn (fn [_] (change-brightness :up))}
   {:cmds ["brightness" "down"] :fn (fn [_] (change-brightness :down))}
   {:cmds ["grab-shi"] :fn (fn [_] (grab-shi (System/getenv "SHI_DATA")))}
   {:cmds ["power-menu"] :fn (fn [_] (run-menu))}])

(cli/dispatch table *command-line-args* {:spec spec})
