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
  steam-is-running = pkgs.writeShellScript "steam-is-running" ''
    exec ${pkgs.procps}/bin/pgrep -u ${lib.escapeShellArg config.myos.user.mainUser} -x steam > /dev/null
  '';
in
lib.mkProfile s "gaming"
{
  systemd.tmpfiles.rules = [
    "Z /sys/class/powercap/intel-rapl:0/energy_uj 0444 root root - -"
    "Z /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/intel-rapl:0:0/energy_uj 0444 root root - -"
  ];

  security.pam.loginLimits = [
    {
      item = "nice";
      type = "hard";
      domain = "*";
      value = "-8";
    }
  ];

  environment.variables = {
    MESA_SHADER_CACHE_MAX_SIZE = "16G";
  };

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

    bwrap = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.bubblewrapSetuid}/bin/bwrap";
    };
  };

  programs.gamescope = {
    enable = true;
    enableWsi = true;
    capSysNice = true;
    env = {
      MANGOHUD_CONFIGFILE = "${myhomecfg.xdg.configHome}/MangoHud/MangoHud.conf";
      STEAM_MULTIPLE_XWAYLANDS = "1";
      STEAM_LAUNCH_WRAPPER_SCOPE = "1";
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = 1;

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

  systemd.services.uuplugin-proxy = {
    description = "Proxy UUplugin mobile app traffic to the namespace";
    requires = [ "uunet-namespace.service" ];
    after = [ "uunet-namespace.service" ];
    partOf = [ "uuplugin.service" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.socat} TCP4-LISTEN:16363,reuseaddr,fork TCP4:10.99.99.2:16363";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = "1s";
      SuccessExitStatus = [ 143 ];
    };
  };

  systemd.services.steam-state-monitor = {
    description = "Manage gaming services based on Steam status";
    wantedBy = [ "multi-user.target" ];
    script = ''
      LAST_STEAM_STATE=""

      while true; do
        if ${steam-is-running}; then
          STEAM_STATE="running"
          DESIRED_PROFILE="performance"

          if ! ${config.systemd.package}/bin/systemctl is-active --quiet uuplugin.service; then
            ${config.systemd.package}/bin/systemctl start uuplugin.service
          fi
        else
          STEAM_STATE="stopped"
          DESIRED_PROFILE="balanced"

          if ${config.systemd.package}/bin/systemctl is-active --quiet uuplugin.service; then
            ${config.systemd.package}/bin/systemctl stop uuplugin.service
          fi
        fi

        if [ "$STEAM_STATE" != "$LAST_STEAM_STATE" ]; then
          echo "Steam $STEAM_STATE; switching to $DESIRED_PROFILE power profile"
          ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set "$DESIRED_PROFILE"
          LAST_STEAM_STATE="$STEAM_STATE"
        fi

        ${pkgs.coreutils}/bin/sleep 1
      done
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  systemd.services.uuplugin = {
    requires = [
      "uunet-namespace.service"
      "uuplugin-proxy.service"
    ];
    after = [
      "uunet-namespace.service"
      "uuplugin-proxy.service"
    ];
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
      KillSignal = "SIGKILL";
      SuccessExitStatus = [ "SIGKILL" ];
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
    package = pkgs.steam.override { platformArgs = ""; };
    gamescopeSession = {
      enable = true;
      args = [
        "--fullscreen"
        "--mangoapp"
        "--nested-refresh"
        "60"
        "--output-width"
        "3840"
        "--output-height"
        "2160"
        "--hide-cursor-delay"
        "3000"
        "--xwayland-count"
        "2"
      ];
      steamArgs = [
        "-pipewire"
        "-steampal"
        "-steamdeck"
        "-gamepadui"
        "-steamos3"
      ];
    };
  };

  myhome = { config, lib, osConfig, ... }: {
    programs.mangohud = {
      enable = true;
      settings = {
        preset = "2,3,4,0,1";
        horizontal_stretch = false;
        toggle_preset = "F10";
        toggle_hud = "F11";
        toggle_hud_position = "F12";
      };
    };
  };

  # controller
  hardware.xone.enable = true;
}
