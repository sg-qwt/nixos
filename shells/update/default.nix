{ pkgs, ... }:
pkgs.mkShell {
  name = "update";
  nativeBuildInputs = with pkgs; [
    my.babashka-bin
    nvfetcher
  ];
}
