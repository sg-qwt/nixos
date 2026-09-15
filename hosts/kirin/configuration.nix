{ config, pkgs, lib, ... }:
{
  services.fwupd.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  };

  myos = {
    sway.enable = true;
    tmux.enable = true;
    qqqemacs.enable = true;
    shell.enable = true;
    git.enable = true;
    ssh.enable = true;
    desktop-apps.enable = true;
    tools.enable = true;
    clash-meta.enable = true;
    tailscale.enable = true;
    android.enable = true;
    aitooling.enable = true;
    printing.enable = true;
  };
}
