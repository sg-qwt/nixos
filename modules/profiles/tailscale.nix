s@{ config, lib, self, ... }:
lib.mkProfile s "tailscale" (
  let
    interface = "tailscale0";
    port = config.myos.data.ports.tailscaled;
  in
  {
    vaultix.secrets.tailscale-tailnet-key = { };

    services.tailscale = {
      enable = true;
      interfaceName = interface;
      port = port;
      authKeyFile = config.vaultix.secrets.tailscale-tailnet-key.path;
      authKeyParameters = {
        ephemeral = false;
        preauthorized = true;
      };
      openFirewall = true;
      extraDaemonFlags = [ "--no-logs-no-support" ];
      extraUpFlags = [
        "--advertise-tags=tag:nixos"
      ];
    };

    systemd.services.tailscaled-autoconnect.serviceConfig.Type = lib.mkForce "exec";

    networking.firewall.trustedInterfaces = [ interface ];
  }
)
