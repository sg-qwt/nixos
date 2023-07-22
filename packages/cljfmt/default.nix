{ lib, buildGraalvmNativeImage, fetchurl, ...  }:

buildGraalvmNativeImage rec {
  pname = "cljfmt";
  version = "0.10.6";

  src = ./cljfmt-0.10.6-standalone.jar;

  extraNativeImageBuildArgs = [
    "--no-server"
    "-H:EnableURLProtocols=https,http"
    "-H:+ReportExceptionStackTraces"
    "--report-unsupported-elements-at-runtime"
    "--initialize-at-build-time"
    "--no-fallback"
  ];

  meta = with lib; {
    description = "A tool for formatting Clojure code";
    homepage = "https://github.com/weavejester/cljfmt";
    license = licenses.epl10;
  };
}
