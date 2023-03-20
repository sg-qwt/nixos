s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "tools"
{
  documentation.man.generateCaches = true;
  # environment.variables.EDITOR = "${pkgs.vim}/bin/vim";
  environment.systemPackages = with pkgs; [
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
    
    # emacs 
    ripgrep

  ];
}
