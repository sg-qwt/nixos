s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "wayland"
{
  environment = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";

      QT_QPA_PLATFORM = "wayland";

      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

  };
}
