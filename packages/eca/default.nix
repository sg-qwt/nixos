{ lib, buildGraalvmNativeImage, fetchurl, ...  }:

buildGraalvmNativeImage (finalAttrs: {
  pname = "eca";
  version = "0.70.6";

  src = fetchurl {
    url = "https://github.com/editor-code-assistant/eca/releases/download/${finalAttrs.version}/eca.jar";
    hash = "sha256-pZ/44ikMlaPl3Qo6jRLQNZXsk2BtF08CyugQKhB7AvE=";
  };

  extraNativeImageBuildArgs = [
    "-H:+ReportExceptionStackTraces"
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
