s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "tmux"
{
  environment = {
    systemPackages = with pkgs; [
      tmux
    ];
  };

  home-manager.users."${config.myos.users.mainUser}" = {
    xdg.configFile."tmux/tmux.conf".source = (self + "/config/tmux.conf");
  };

}
