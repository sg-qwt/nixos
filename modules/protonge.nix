{ config, pkgs, lib, helpers, ... }:
helpers.mkModule config lib
  "protonge"
  "proton-ge"
{
  environment = {
    systemPackages = with pkgs; [my.proton-ge];

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${pkgs.my.proton-ge}";
    };
  };
}
