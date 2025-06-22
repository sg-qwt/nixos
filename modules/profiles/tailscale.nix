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
      openFirewall = true;
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };

    networking.firewall.trustedInterfaces = [ interface ];
  }
)
