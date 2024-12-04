{ pkgs, ... }:
pkgs.mkShell {
  name = "update";
  nativeBuildInputs = with pkgs; [
    babashka-unwrapped
  ];
}
