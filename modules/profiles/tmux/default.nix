s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "tmux"
{
  environment = {
    systemPackages = with pkgs; [
      tmux
      (if config.myos.wayland.enable then wl-clipboard else xclip)
    ];

    etc."tmux.conf".source =
      pkgs.substituteAll {
        src = ./tmux.conf;
        cmd = (if config.myos.wayland.enable then "wl-copy" else "xclip -in -selection clipboard");
      };
  };
}
