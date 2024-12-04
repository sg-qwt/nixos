s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "tools"
{
  environment.systemPackages = with pkgs; [
    vim

    unrar

    sops

    wget

    vim

    htop

    pciutils

    coreutils

    jq

    self.packages.${pkgs.system}.bbscripts
  ];
}
