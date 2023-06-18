{ pkgs, ... }:
pkgs.mkShell {
  name = "ci";
  nativeBuildInputs = with pkgs; [
    attic-client
    babashka
  ];
}
