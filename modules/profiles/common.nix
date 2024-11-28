s@{ config, pkgs, lib, inputs, self, ... }:
let
  btrfsExist = (builtins.any
    (filesystem: filesystem.fsType == "btrfs")
    (lib.attrValues config.fileSystems));
in
{
  imports = [
    ../../modules/mixins/deploy.nix
  ];

  config = {

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
      # package = pkgs.nixVersions.stable;

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

    programs.ssh.knownHosts = {
      "github.com".hostNames = [ "github.com" ];
      "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

      "gitlab.com".hostNames = [ "gitlab.com" ];
      "gitlab.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

      "git.sr.ht".hostNames = [ "git.sr.ht" ];
      "git.sr.ht".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
    };
  };

}
