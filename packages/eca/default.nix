{ lib, buildGraalvmNativeImage, fetchurl, ... }:

buildGraalvmNativeImage (finalAttrs: {
  pname = "eca";
  version = "0.75.0";

  src = fetchurl {
    url = "https://github.com/editor-code-assistant/eca/releases/download/${finalAttrs.version}/eca.jar";
    hash = "sha256-FO1WDY1XlQIhPjZbcrTgnqrRXOnikOMpYU2QBcOMlHE=";
  };

  extraNativeImageBuildArgs = [
    "--no-fallback"
    "--native-image-info"
    "--features=clj_easy.graal_build_time.InitClojureClasses"
  ];

  meta = {
    mainProgram = "eca";
    description = "Editor Code Assistant (ECA) - AI pair programming capabilities agnostic of editor";
    homepage = "https://github.com/editor-code-assistant/eca";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.asl20;
  };
})
