s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "protonge"
{
  environment = {
    systemPackages = with pkgs; [ my.proton-ge-custom ];

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${pkgs.my.proton-ge-custom}";
    };
  };
}
