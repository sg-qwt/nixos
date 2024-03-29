s@{ config, pkgs, lib, ... }:
lib.mkProfile s "wayland"
{
  environment = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";

      QT_QPA_PLATFORM = "wayland";

      _JAVA_AWT_WM_NONREPARENTING = "1";

      NIXOS_OZONE_WL = "1";
    };

  };
}
