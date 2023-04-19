s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "wireguard" {
  # get gateway
  # $(${pkgs.iproute2}/bin/ip -o -4 route show to default | ${pkgs.gawk}/bin/awk '{print $3}' | ${pkgs.coreutils}/bin/head -n 1)
  networking.wg-quick.interfaces = {
    wg0 =
      let
        server-ip = "20.247.117.236";
        gateway = "192.168.1.1";
      in
      {
        autostart = false;
        address = [ "10.13.13.2/32" ];
        dns = [ "10.13.13.1" ];
        listenPort = 51820;
        privateKeyFile = config.sops.secrets.wg0.path;

        postUp = ''
          ${pkgs.iproute2}/bin/ip route add ${server-ip} via ${gateway}
        '';

        postDown = ''
          ip route del ${server-ip} via ${gateway}
        '';

        peers = [{
          publicKey = "SjnIo+ov7N4wvRetkSj8kuiQYL6DhQG1DI5Upa8wjAA=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "${server-ip}:35500";
          persistentKeepalive = 25;
        }];
      };
  };

  sops.secrets.wg0 = {
    sopsFile = self + "/secrets/secrets.yaml";
    restartUnits = [ "wg-quick-wg0.service" ];
  };
}
