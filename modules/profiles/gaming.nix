s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "gaming"
{
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
      ];
      steamArgs = [
        "-tenfoot"
        "-pipewire-dmabuf"
      ];
    };
  };

  # controller
  # hardware.xone.enable = true;
}
