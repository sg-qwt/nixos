{ lib
, pkgs
, self
, ...
}:
let
  trivialBuild = pkgs.emacsPackages.trivialBuild;
  shell-maker = trivialBuild {
    pname = "shell-maker";
    version = "unstable";
    src = self.inputs.shell-maker;
    packageRequires = [ ];
  };
  acp = trivialBuild {
    pname = "acp";
    version = "unstable";
    src = self.inputs.acp;
    packageRequires = [ ];
  };
in
trivialBuild {
  pname = "agent-shell";
  version = "unstable";

  src = self.inputs.agent-shell;

  packageRequires = [ acp shell-maker ];

  meta = with lib; {
    description = "A native Emacs buffer to interact with LLM agents powered by ACP";
    homepage = "https://github.com/xenodium/agent-shell";
    license = licenses.gpl3;
  };
}
