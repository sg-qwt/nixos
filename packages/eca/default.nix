{ lib, buildGraalvmNativeImage, self, ... }:

buildGraalvmNativeImage (finalAttrs: {
  pname = "eca";
  version = "unstable";

  # a necessary hack to rename flake input to jar file
  src = builtins.path {
    path = self.inputs.eca;
    name = "eca.jar";
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
