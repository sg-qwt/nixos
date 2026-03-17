s@{ config, pkgs, lib, self, ... }:
let
  myhomecfg = config.home-manager.users."${config.myos.user.mainUser}";
  cap = [
    "CAP_NET_RAW"
    "CAP_NET_ADMIN"
    "CAP_NET_BIND_SERVICE"
  ];
  uu-interface = "veth-myos-uu";
  steam-gamescope-uunet = pkgs.writeShellScriptBin "steam-gamescope-uunet" ''
    exec ${config.security.wrapperDir}/netns-exec uunet steam-gamescope
  '';
in
lib.mkProfile s "gaming"
{
  environment.systemPackages = [ steam-gamescope-uunet ];

  environment.etc."netns/uunet/resolv.conf".text = ''
    nameserver 114.114.114.114
  '';

  networking.firewall.extraReversePathFilterRules = ''
    iifname "${uu-interface}" accept
  '';

  security.wrappers = {
    netns-exec = {
      source = lib.getExe pkgs.my.netns-exec;
      owner = "root";
      group = "root";
      setuid = true;
      setgid = true;
    };
  };

  # TODO move nvidia-offload to gamescope here once issue fixed
  # https://github.com/ValveSoftware/gamescope/issues/1590
  programs.gamescope = {
    enable = true;
    capSysNice = true;
    env = {
      MANGOHUD_CONFIGFILE = "${myhomecfg.xdg.configHome}/MangoHud/MangoHud.conf";
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking = {
    nat = {
      enable = true;
      internalInterfaces = [ uu-interface ];
    };
    firewall.trustedInterfaces = [ uu-interface ];
  };

  systemd.services.uunet-namespace = {
    description = "Setup UUnet Network Namespace";
    wantedBy = [ "network.target" ];
    before = [ "uuplugin.service" ];

    path = [ pkgs.iproute2 ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ip netns del uunet 2>/dev/null || true
      ip link del ${uu-interface} 2>/dev/null || true

      ip netns add uunet
      ip link add ${uu-interface} type veth peer name veth-uu-ns
      ip link set veth-uu-ns netns uunet

      # Host side
      ip addr add 10.99.99.1/24 dev ${uu-interface}
      ip link set ${uu-interface} up

      # Sandbox side
      ip -n uunet addr add 10.99.99.2/24 dev veth-uu-ns
      ip -n uunet link set veth-uu-ns up
      ip -n uunet link set lo up

      # Route sandbox traffic to the host
      ip -n uunet route add default via 10.99.99.1
    '';

    preStop = ''
      ip link del ${uu-interface} 2>/dev/null || true
      ip netns del uunet 2>/dev/null || true
    '';
  };

  vaultix.secrets.uuplugin = { };

  systemd.sockets.uuplugin-proxy = {
    description = "Listen on 16363 for UUplugin";
    listenStreams = [ "16363" ];
    wantedBy = [ "sockets.target" ];
  };

  systemd.services.uuplugin-proxy = {
    description = "Proxy UUplugin mobile app traffic to the namespace";
    requires = [ "uuplugin.service" ];
    after = [ "uuplugin.service" ];
    serviceConfig = {
      ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd 10.99.99.2:16363";
      DynamicUser = true;
    };
  };

  systemd.services.uuplugin = {
    requires = [ "uunet-namespace.service" ];
    after = [ "uunet-namespace.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      iproute2
      nettools
      iptables
    ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/uunet";
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

  # TODO remove hack after bug fix
  # https://github.com/MetaCubeX/mihomo/issues/2605
  systemd.services.mihomo = {
    postStart = ''
      until ${pkgs.nftables}/bin/nft list chain inet mihomo prerouting >/dev/null 2>&1; do
        sleep 0.5
      done

      ${pkgs.nftables}/bin/nft insert rule inet mihomo prerouting iifname "${uu-interface}" return
      ${pkgs.nftables}/bin/nft insert rule inet mihomo prerouting iifname "${config.services.tailscale.interfaceName}" return
    '';
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
