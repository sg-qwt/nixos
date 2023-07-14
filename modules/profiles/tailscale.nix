s@{ config, pkgs, lib, self, ... }:
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
    };

    networking.firewall.allowedUDPPorts = [ port ];
    networking.firewall.trustedInterfaces = [ interface ];

    systemd.services.tailscale-setup = {
      script = ''
        sleep 10

        if tailscale status; then
          echo "tailscale already up, skip"
        else
          echo "tailscale down, login using auth key"
          tailscale up --auth-key "file:${config.sops.secrets.tailscale_tailnet_key.path}"
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [ config.services.tailscale.package ];
      after = [ "tailscaled.service" ];
      requiredBy = [ "tailscaled.service" ];
    };

    sops.secrets.tailscale_tailnet_key = {
      sopsFile = self + "/secrets/tfout.json";
      restartUnits = [ "tailscale-setup.service" ];
    };
  }
)
