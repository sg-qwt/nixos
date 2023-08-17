(ns infralab.infralab
  (:gen-class)
  (:import
   (com.pulumi Pulumi)
   (com.pulumi.azurenative.resources ResourceGroup ResourceGroupArgs)
   (java.util.function Consumer)))

(defn handler [ctx]
  (new ResourceGroup "pulumitest"
       (.build
        (doto (ResourceGroupArgs/builder)
          (.location  "eastus")
          (.resourceGroupName "new-pulumi-test")))))

(defn make-consumer
  []
  (reify Consumer
    (accept [_ ctx]
      (handler ctx))))

(defn -main
  [& args]
  (Pulumi/run (make-consumer)))
