s@{ config, pkgs, lib, helpers, rootPath, ... }:
helpers.mkProfile s "tailscale"
{
  services.tailscale.enable = true;

  systemd.services.tailscale-setup = {
    script = ''
      sleep 10

      if tailscale status; then
        echo "tailscale already up, skip"
      else
        echo "tailscale down, login using auth key"
        tailscale up --ssh=false --auth-key "file:${config.sops.secrets.tailscale_tailnet_key.path}"
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
    sopsFile = rootPath + "/secrets/tfout.json";
    restartUnits = [ "tailscale-setup.service" ];
  };
}
