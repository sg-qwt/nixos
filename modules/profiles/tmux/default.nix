s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "tmux"
{
  environment = {
    systemPackages = with pkgs; [
      tmux
      wl-clipboard
    ];

    etc."tmux.conf".source = ./tmux.conf;
  };
}
