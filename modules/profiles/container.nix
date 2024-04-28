s@{ config, pkgs, lib, inputs, self, ... }:
lib.mkProfile s "container" {
  virtualisation.containers.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers =
      let
        username = "${config.myos.user.mainUser}";
        homepath = config.users.users."${username}".home;
      in
      {
        netdisk115 = {
          autoStart = false;
          image = "funcman/115pc";
          volumes = [
            "${homepath}/.config/115pc:/config"
            "${homepath}/Downloads/115download:/Downloads/115download"
          ];
          ports = [ "5800:5800" ];
        };

        baidunetdisk = {
          autoStart = false;
          image = "tzuhsiao/baidunetdisk";
          volumes = [
            "${homepath}/.config/baidunetdisk:/root/baidunetdisk"
            "${homepath}/Downloads/baidunetdisk:/root/baidunetdiskdownload"
          ];
          ports = [ "5801:6080" ];
          environment = { VNC_SERVER_PASSWD = "passwd"; };
        };

        jellyfin = {
          autoStart = false;
          image = "ghcr.io/linuxserver/jellyfin";
          volumes = [
            "${homepath}/.config/jellyfin:/config"
            "/rpool/data/media:/media"
          ];
          ports = [ "8096:8096" "7359:7359/udp" "1900:1900/udp" ];
          environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "Asia/Shanghai";
          };
          extraOptions = [ "--device=/dev/dri:/dev/dri" ];
        };
      };
  };

}
