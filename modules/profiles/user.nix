{ options, config, lib, self, ... }:

with lib;

let
  cfg = config.myos.user;
  state-version = config.system.stateVersion;
in
{
  imports = [
    (lib.mkAliasOptionModule [ "myhome" ] [ "home-manager" "users" cfg.mainUser ])
  ];

  options.myhomecfg = lib.mkOption {
    type = with lib.types; attrsOf anything;
    default = { };
  };

  options.myos.user = {
    mainUser = mkOption {
      type = types.str;
      default = "me";
      description = "Main user";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Host specific groups";
    };
  };

  config = {

    users.mutableUsers = false;

    users.users."${cfg.mainUser}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "systemd-journal" ] ++ cfg.extraGroups;
      hashedPasswordFile = config.sops.secrets.me-password.path;
      openssh.authorizedKeys.keyFiles = [
        (self + "/resources/keys/ssh-me.pub")
      ];
    };

    sops.secrets.me-password = {
      sopsFile = self + "/secrets/secrets.yaml";
      neededForUsers = true;
    };

    myhome = {
      home.stateVersion = state-version;
      systemd.user.startServices = "sd-switch";
    };
  };
}
