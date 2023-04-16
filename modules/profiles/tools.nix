s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "tools"
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
  ];
}
