s@{ config, pkgs, lib, inputs, self, ... }:
with lib;
let
  cfg = config.myos.common;
  btrfsExist = (builtins.any
    (filesystem: filesystem.fsType == "btrfs")
    (lib.attrValues config.fileSystems));
in
{
  imports = [
    ../../modules/mixins/deploy.nix
  ];

  options.myos.common = {
    enable = mkEnableOption "base shared profile";
  };

  config = mkIf cfg.enable {

    system.configurationRevision = self.rev or self.dirtyRev or "dirty";

    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      gnupg.sshKeyPaths = [ ];
    };

    time.timeZone = "Asia/Shanghai";

    i18n = {
      defaultLocale = "en_US.UTF-8";

      supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "zh_CN.UTF-8/UTF-8"
        "zh_CN/GB2312"
        "zh_CN.GBK/GBK"
        "zh_CN.GB18030/GB18030"
        "zh_TW.UTF-8/UTF-8"
        "zh_TW/BIG5"
      ];
    };

    nix = {
      package = pkgs.nixVersions.stable;

      registry.nixpkgs.flake = inputs.nixpkgs;
      registry.myos.flake = self;

      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
        dates = "weekly";
      };
    };

    myos.cache.enable = true;

    services.btrfs.autoScrub = lib.mkIf btrfsExist {
      enable = true;
    };
  };

}
