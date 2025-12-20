s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "tools"
{
  environment.systemPackages = with pkgs; [
    vim

    unrar

    wget

    vim

    bottom

    pciutils

    coreutils

    jq

    self.packages.${pkgs.stdenv.hostPlatform.system}.bbscripts

    my.rage
  ];

  programs.nix-index-database.comma.enable = true;
}
