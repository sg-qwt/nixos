s@{ config, pkgs, lib, helpers, inputs, self, ... }:
{
  imports = [
    ../../modules/mixins/deploy.nix
  ];
} //
helpers.mkProfile s "common"
  {
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
      settings = {

        substituters = [
          "https://ooo.edgerunners.eu.org/ghcr.io/sg-qwt/nixos"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "oranc:RZWCxVsNWs/6qPkfB17Mmk9HpkTv87UXnldHtGKkWLk="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        auto-optimise-store = true;
      };

      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
        dates = "weekly";
      };
    };
  }
