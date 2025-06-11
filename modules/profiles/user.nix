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
      hashedPasswordFile = config.vaultix.secrets.me-password.path;
      openssh.authorizedKeys.keys = config.myos.data.openssh-keys;
    };

    vaultix.secrets.me-password = { };
    vaultix.beforeUserborn = [ "me-password" ];

    myhome = {
      home.stateVersion = state-version;
      systemd.user.startServices = "sd-switch";
    };
  };
}
