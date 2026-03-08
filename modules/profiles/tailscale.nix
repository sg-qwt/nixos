s@{ config, lib, self, ... }:
lib.mkProfile s "tailscale" (
  let
    interface = "veth-myos-ts";
    port = self.shared-data.ports.tailscaled;
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

    networking.firewall.trustedInterfaces = [ interface ];
  }
)
