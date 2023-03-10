s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "tools"
{
  home-manager.users."${config.myos.users.mainUser}" = {
    home.packages = with pkgs; [
      nixfmt

      unrar

      cloudflare-warp

      sops

      wget

      vim

      htop

      pciutils

      coreutils

      jq
    ];
  };
}
