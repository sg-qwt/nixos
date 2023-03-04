{ config, pkgs, lib, helpers, ... }:
helpers.mkModule config lib
  "ibus"
  "ibus"
{
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ rime ];
  };

  environment.sessionVariables = {
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    SDL_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
  };
}
