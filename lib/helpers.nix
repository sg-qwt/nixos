{ self, nixpkgs, inputs, pkgs }:
rec {
  patchDesktop = pkgs: pkg: appName: from: to: lib.hiPrio
    (pkgs.runCommand "$patched-desktop-entry-for-${appName}" { }
      ''
        ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
        ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      '');

  profile-list =
    (map
      (mname: (self + "/modules/profiles/${mname}"))
      (builtins.attrNames (builtins.readDir (self + "/modules/profiles"))));

  mkProfile = s: pname: body:
    {
      options.myos."${pname}" = {
        enable = s.lib.mkEnableOption pname;
      };

      config = s.lib.mkIf s.config.myos."${pname}".enable body;
    };

  addPatches = pkg: patches:
    pkg.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ patches;
    });

  mylibs = {
    inherit mkProfile patchDesktop addPatches;
  };

  lib = nixpkgs.lib.extend (
    final: prev: mylibs
  );

  default-overlays =
    args: final: prev:
    {
      my =
        (builtins.listToAttrs
          (map
            (pkgname:
              {
                name = pkgname;
                value = (prev.callPackage (self + "/packages/${pkgname}") (args // { inherit self; }));
              })
            (builtins.attrNames (builtins.readDir (self + "/packages")))));
      inherit mylibs;
    };

  jovian-overlay =
    (final: prev: {
      gamescope-session = prev.gamescope-session.override {
        steam = prev.steam.override (old: {
          extraPkgs =
            pkgs: (if old ? extraPkgs then old.extraPkgs pkgs else [ ]) ++ [ pkgs.noto-fonts-cjk-sans ];
        });
      };
    });

  packages =
    (builtins.listToAttrs
      (map (name: { name = name; value = pkgs.my."${name}"; })
        (builtins.attrNames pkgs.my)));

  shells = args: default:
    let
      devshells =
        (builtins.foldl' (a: b: a // b) { }
          (map (sname: { "${sname}" = (import (self + "/shells/${sname}") args); })
            (builtins.attrNames (builtins.readDir (self + "/shells")))));
    in
    devshells // { default = devshells."${default}"; };

  shared-data =
    (lib.importJSON (self + "/resources/shared-data/data.json")) //
    (lib.importJSON (self + "/resources/shared-data/tfo.json")) //
    {
      hosts = {
        zheng.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpWTwJQ7923qsxZGWjxQrl8Bx6/+pdZDsiz0dg1akxz";
        dui.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLftJ5dhUg+HMKxqwMlUswnpQtPVdYFDxbD6YB58kGp";
        xun.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHMytlKhUyTAqKE3T9IkpEl7qheowlRdojUJaxdnIVj8";
        li.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxduWDt3Qli+3gTUd4/3/qbVqy+wyNrqTxZhV/7/7eV";
      };
    };

  azbase = (nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self;
    };
    modules = [
      nixpkgs.nixosModules.readOnlyPkgs
      {
        nixpkgs.pkgs = pkgs;
      }
      ./modules/mixins/deploy.nix
      ./modules/mixins/azurebase.nix
    ];
  });

  mkOS = { name, hostPubkey }:
    let
      p =
        if (name == "zheng") then
          pkgs.appendOverlays [
            inputs.jovian.overlays.default
            jovian-overlay
          ] else pkgs;
      home-manager = inputs.home-manager;
    in
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit home-manager self inputs;
        lib = lib;
      };
      modules = [
        nixpkgs.nixosModules.readOnlyPkgs
        home-manager.nixosModules.home-manager
        inputs.vaultix.nixosModules.default
        inputs.nix-index-database.nixosModules.nix-index
        {
          nixpkgs.pkgs = p;
          nixpkgs.overlays = nixpkgs.lib.mkForce p.overlays;
          networking.hostName = name;
          imports = profile-list;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          vaultix.settings.hostPubkey = hostPubkey;
        }
      ] ++ (import (../hosts + "/${name}") { inherit inputs; });
    };

  nodes = builtins.mapAttrs
    (hostname: value: (mkOS { name = hostname; hostPubkey = value.key; }))
    shared-data.hosts;

  nixosConfigurations = nodes // { inherit azbase; };
}
