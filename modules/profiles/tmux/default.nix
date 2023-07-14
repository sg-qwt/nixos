s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "tmux"
{
  environment = {
    systemPackages = with pkgs; [
      tmux
      wl-clipboard
    ];

    etc."tmux.conf".source = ./tmux.conf;
  };
}
