s@{ config, pkgs, lib, self, ... }:
let
  myhomecfg = config.home-manager.users."${config.myos.user.mainUser}";
  cap = [
    "CAP_NET_RAW"
    "CAP_NET_ADMIN"
    "CAP_NET_BIND_SERVICE"
  ];
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

  vaultix.secrets.uuplugin = { };

  systemd.services.uuplugin = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      iproute2
      nettools
      iptables
    ];
    serviceConfig = {
      AmbientCapabilities = cap;
      CapabilityBoundingSet = cap;
      StateDirectory = "%N";
      WorkingDirectory = "%S/%N";
      LoadCredential = [
        "uuplugin-uuid:${config.vaultix.secrets.uuplugin.path}"
      ];
      ExecStartPre = [
        "${pkgs.coreutils}/bin/ln -nsf %d/uuplugin-uuid %S/%N/.uuplugin_uuid"
      ];
      ExecStart = "${lib.getExe pkgs.my.uuplugin} ${pkgs.my.uuplugin}/share/uuplugin/uu.conf";
      Restart = "on-failure";
    };
  };

  # for uuplugin
  networking.firewall = {
    allowedTCPPorts = [ 16363 ];
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

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
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

    xdg.dataFile."Steam/steam_dev.cfg".text = ''
      unShaderBackgroundProcessingThreads 8
    '';

  };

  # controller
  hardware.xone.enable = true;

  # Switch ASUS power profile based on Steam status
  systemd.user.services.steam-power-profile = {
    enable = true;
    description = "Switch ASUS power profile based on Steam status";
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };

    path = [ pkgs.procps pkgs.asusctl ];

    script = ''
      CURRENT_PROFILE=""

      while true; do
        if pgrep -x "steam" > /dev/null; then
          # Steam is running
          if [ "$CURRENT_PROFILE" != "Balanced" ]; then
            echo "Steam detected, switching to Balanced profile"
            asusctl profile set Balanced
            CURRENT_PROFILE="Balanced"
          fi
        else
          # Steam is not running
          if [ "$CURRENT_PROFILE" != "Quiet" ]; then
            echo "Steam not running, switching to Quiet profile"
            asusctl profile set Quiet
            CURRENT_PROFILE="Quiet"
          fi
        fi

        sleep 5
      done
    '';
  };
}
