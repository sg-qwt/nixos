s@{ config, pkgs, lib, self, ... }:
let
  myhomecfg = config.home-manager.users."${config.myos.user.mainUser}";
in
lib.mkProfile s "gaming"
{
  # TODO move nvidia-offload to gamescope here once issue fixed
  # https://github.com/ValveSoftware/gamescope/issues/1590
  programs.gamescope = {
    enable = true;
    capSysNice = true;
    env = {
      MANGOHUD_CONFIGFILE = "${myhomecfg.xdg.configHome}/MangoHud/MangoHud.conf";
    };
  };

  programs.steam = {
    enable = true;
    fontPackages = with pkgs; [ noto-fonts-cjk-sans ];
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    remotePlay.openFirewall = true;
    package = pkgs.steam.override {
      extraEnv = {
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };
    };
    gamescopeSession = {
      enable = true;
      args = [
        "--fullscreen"
        "--nested-refresh"
        "60"
        "--output-width"
        "3840"
        "--output-height"
        "2160"
        "--mangoapp"
      ];
      steamArgs = [
        "-tenfoot"
        "-pipewire-dmabuf"
      ];
    };
  };

  myhome = { config, lib, osConfig, ... }: {
    programs.mangohud = {
      enable = true;
      settings = {
        pci_dev = "0000:01:00.0";
        horizontal = true;
        horizontal_stretch = false;
        hud_no_margin = true;
        fps = true;
        cpu_stats = true;
        cpu_temp = true;
        gpu_stats = true;
        gpu_temp = true;
        ram = true;
        vram = true;
        hud_compact = true;
        toggle_hud = "F12";
        toggle_hud_position = "F11";
      };
    };
  };

  # controller
  # hardware.xone.enable = true;
}
