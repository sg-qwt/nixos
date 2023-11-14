{ lib, buildGraalvmNativeImage, fetchurl, ... }:

buildGraalvmNativeImage rec {
  pname = "cljfmt";
  version = "0.11.2";

  src = fetchurl {
    url = "https://github.com/weavejester/cljfmt/releases/download/${version}/cljfmt-${version}-standalone.jar";
    sha256 = "sha256-vEldQ7qV375mHMn3OUdn0FaPd+f/v9g+C+PuzbSTWtk=";
  };

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
