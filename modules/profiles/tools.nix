s@{ config, pkgs, lib, helpers, ... }:
helpers.mkModule s "tools"
{
  environment.variables.EDITOR = "${pkgs.vim}/bin/vim";
  environment.systemPackages =
    [
      vim

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
}
