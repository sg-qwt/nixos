(ns build
  (:require
   [clojure.tools.build.api :as b]))

(def lib 'io.github.sg-qwt/infralab)
(def version "0.1.0-SNAPSHOT")

(def class-dir "target/classes")
(def basis (b/create-basis {:project "deps.edn"}))

(defn build
  [_]
  (b/delete {:path "target"})
  (b/copy-dir {:src-dirs ["src"] :target-dir class-dir})
  (b/compile-clj {:basis basis :src-dirs ["src"] :class-dir class-dir})
  (b/write-pom {:class-dir class-dir :lib lib :version version :basis basis :src-dirs ["src"]}))
