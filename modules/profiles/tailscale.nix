s@{ config, lib, self, ... }:
lib.mkProfile s "tailscale" (
  let
    interface = "tailscale0";
    port = config.myos.data.ports.tailscaled;
  in
  {
    services.tailscale = {
      enable = true;
      interfaceName = interface;
      port = port;
      authKeyFile = config.sops.secrets.tailscale_tailnet_key.path;
      openFirewall = true;
    };
    systemd.services.tailscaled.environment = {
      TS_NO_LOGS_NO_SUPPORT = "true";
    };

    networking.firewall.trustedInterfaces = [ interface ];

    sops.secrets.tailscale_tailnet_key = {
      sopsFile = self + "/secrets/tfout.json";
      restartUnits = [ "tailscaled-autoconnect.service" ];
    };
  }
)
