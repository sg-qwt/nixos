{ config, pkgs, lib, helpers, ... }:
helpers.mkModule config lib
  "tmux"
  "tmux"
{
  environment = {
    systemPackages = with pkgs; [
      tmux
    ];
  };

  home-manager.users."${config.myos.users.mainUser}" = {
    xdg.configFile."tmux/tmux.conf".source = ../config/tmux.conf;
  };

}
