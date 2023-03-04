{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myos.users;
in
{
  options.myos.users = {
    enable = mkEnableOption "Users config";

    mainUser = mkOption {
      type = types.str;
      default = "me";
      description = "Main user";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Host specific groups";
    };
  };

  config = mkIf cfg.enable {

    users.mutableUsers = false;

    users.groups.deployment = {};
    users.users.deployment = {
      isSystemUser = true;
      openssh.authorizedKeys.keys = [
        "no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRy54Bxz2eul3zNZLq+Vw9DZPs7DCLTh9HsQdl8FFEw7co92C2a0+Ih5WxF2rh7Z89Em9yyHvMLu6iz8Zv78AY6CJVHgxeDzEcf3XtNanIbDMyD2omLn6MpnLCJWQCK0uYQtj4W/aCPLlSAJEyTUPhmy/syg/9An4xgx33YcWOyXNks24b4WttSM+tQ2qpem1yVnnV9imziYsdCEU34dacmyVY4ayWPxSWEEcxFIKcp/s10bbdYoIL/Zc88vRbBwZwk1hVOgJ+D8DFpIxHy+Uyr/KgRQCKp4Bju6AJUDYq6jKS3Bv/4zS+4ZF3ArV/AUxP5KxEPXsjhNic34uorPOcxTyJcXe7lylSYjD3h/I8hthmleiYCcOOHCKFjPSI2BpuXpG4T49tJ0jHMA45cP2I13jDoWbSYu8mKglarutykSbj6PjTfTmIXUSUwXkXW4052bWiaxReDySYjUw+anJZLXX/EqFyN/Eiw2CG/l3o8uKuASeqbmn+z/bq30FghAczHbDR3W/AOoDybqxSCle2dRzESmabHkhQep85BZJ8D1bNy6TVvIgAzsLPzEWWi/f2i6XAcmDHSaaqeq+zffxje9XxLlDo3Rb4hsTSrG76Qt0VeWC6DwoEFPDgorXTGN7c9yfxftFlFz15jzWVLUdS95hfqLVpqDAs3nLzGrjiKQ== (none)"
      ];
      group = "deployment";
      shell = pkgs.bash;
    };

    users.users."${cfg.mainUser}" = {
      isNormalUser = true;
      description = "me";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" "systemd-journal" ] ++ cfg.extraGroups;
      passwordFile = config.sops.secrets.me-password.path;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRy54Bxz2eul3zNZLq+Vw9DZPs7DCLTh9HsQdl8FFEw7co92C2a0+Ih5WxF2rh7Z89Em9yyHvMLu6iz8Zv78AY6CJVHgxeDzEcf3XtNanIbDMyD2omLn6MpnLCJWQCK0uYQtj4W/aCPLlSAJEyTUPhmy/syg/9An4xgx33YcWOyXNks24b4WttSM+tQ2qpem1yVnnV9imziYsdCEU34dacmyVY4ayWPxSWEEcxFIKcp/s10bbdYoIL/Zc88vRbBwZwk1hVOgJ+D8DFpIxHy+Uyr/KgRQCKp4Bju6AJUDYq6jKS3Bv/4zS+4ZF3ArV/AUxP5KxEPXsjhNic34uorPOcxTyJcXe7lylSYjD3h/I8hthmleiYCcOOHCKFjPSI2BpuXpG4T49tJ0jHMA45cP2I13jDoWbSYu8mKglarutykSbj6PjTfTmIXUSUwXkXW4052bWiaxReDySYjUw+anJZLXX/EqFyN/Eiw2CG/l3o8uKuASeqbmn+z/bq30FghAczHbDR3W/AOoDybqxSCle2dRzESmabHkhQep85BZJ8D1bNy6TVvIgAzsLPzEWWi/f2i6XAcmDHSaaqeq+zffxje9XxLlDo3Rb4hsTSrG76Qt0VeWC6DwoEFPDgorXTGN7c9yfxftFlFz15jzWVLUdS95hfqLVpqDAs3nLzGrjiKQ== (none)"
      ];
    };

    # https://github.com/cole-h/nixos-config/blob/colmena/modules/config/deploy.nix
    security.sudo.extraRules = [
      {
        users = [ "deployment" ];
        commands = [
          {
            command = "/nix/store/*/bin/switch-to-configuration";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-env";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    sops.secrets.me-password = {
      sopsFile = ../secrets/secrets.yaml;
      neededForUsers = true;
    };

    home-manager.users."${cfg.mainUser}" = {
      home.stateVersion = "22.11";
    };

  };
}
