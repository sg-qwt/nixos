{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.fwupd.enable = true;
  services.power-profiles-daemon.enable = true;

  myos = {
    yubikey = "main";
    sway = {
      enable = true;
      primaryMonitor = {
        id = "Sharp Corporation 0x15DD Unknown";
        resolution = "2560x1600@120Hz";
        scale = 1.8;
      };
      showBattery = true;
    };
    tmux.enable = true;
    qqqemacs.enable = true;
    shell.enable = true;
    git.enable = true;
    ssh.enable = true;
    desktop-apps = {
      enable = true;
      mpvHwdec = "vaapi";
    };
    tools.enable = true;
    clash-meta.enable = true;
    tailscale.enable = true;
    android.enable = true;
    aitooling = {
      enable = true;
      ollama.enable = false;
    };
    printing.enable = true;
  };
}
