{ pkgs, ... }:
pkgs.mkShell {
  name = "ci";
  nativeBuildInputs = with pkgs; [
    oranc
    babashka
  ];
}
