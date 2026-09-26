{
  self,
  nixpkgs,
  inputs,
  pkgs,
}:
rec {
  patchDesktop =
    pkgs: pkg: appName: from: to:
    lib.hiPrio (
      pkgs.runCommand "$patched-desktop-entry-for-${appName}" { } ''
        ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
        ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      ''
    );

  profile-list =
    self + "/modules/profiles"
    |> builtins.readDir
    |> builtins.attrNames
    |> map (mname: self + "/modules/profiles/${mname}");

  mkProfile =
    s: pname: body:
    let
      profileOptions = body._profileOptions or { };
      profileConfig = builtins.removeAttrs body [ "_profileOptions" ];
    in
    {
      options.myos."${pname}" = {
        enable = s.lib.mkEnableOption pname;
      }
      // profileOptions;

      config = s.lib.mkIf s.config.myos."${pname}".enable profileConfig;
    };

  addPatches =
    pkg: patches:
    pkg.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ patches;
    });

  mylibs = {
    inherit mkProfile patchDesktop addPatches;
  };

  lib = nixpkgs.lib.extend (final: prev: mylibs);

  default-overlays = args: final: prev: {
    inherit mylibs;

    my =
      self + "/packages"
      |> builtins.readDir
      |> builtins.attrNames
      |> map (pkgname: {
        name = pkgname;
        value = prev.callPackage (self + "/packages/${pkgname}") (args // { inherit self; });
      })
      |> builtins.listToAttrs;
  };

  jovian-overlay = (
    final: prev: {
      gamescope-session = prev.gamescope-session.override {
        steam = prev.steam.override (old: {
          extraPkgs =
            pkgs: (if old ? extraPkgs then old.extraPkgs pkgs else [ ]) ++ [ pkgs.noto-fonts-cjk-sans ];
        });
      };
    }
  );

  packages =
    pkgs.my
    |> builtins.attrNames
    |> map (name: {
      inherit name;
      value = pkgs.my."${name}";
    })
    |> builtins.listToAttrs;

  shells =
    args: default:
    let
      devshells =
        self + "/shells"
        |> builtins.readDir
        |> builtins.attrNames
        |> map (sname: {
          name = sname;
          value = import (self + "/shells/${sname}") args;
        })
        |> builtins.listToAttrs;
    in
    devshells // { default = devshells."${default}"; };

  tfo = lib.importJSON (self + "/caveman/data/tfo.json");

  shared-data = (lib.importJSON (self + "/resources/shared-data/data.json")) // {
    hosts = {
      zheng.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpWTwJQ7923qsxZGWjxQrl8Bx6/+pdZDsiz0dg1akxz";
      li.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxduWDt3Qli+3gTUd4/3/qbVqy+wyNrqTxZhV/7/7eV";
      puer.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKcOrd7uUWfIqR7cyp6sc9bR4seNb8m3het9CFsxznN/";
      rocky.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDy3hWnYzgOJZ51yD25J5vLk33PAgKEdASoDL0UV5ivk";
      just.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHds+RAGMmOq8gw6hREjld78Rx4Ura0XgaEzmv5MUmMe";
      kirin.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID64w7UdM/25HKOaAkgUoYcodR08TcChK0JW46tfajh1";
    };
  };

  azbase = (
    nixpkgs.lib.nixosSystem {
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
    }
  );

  mkOS =
    { name, hostPubkey }:
    let
      p =
        if (name == "zheng" || name == "li") then
          pkgs.appendOverlays [
            inputs.jovian.overlays.default
            jovian-overlay
          ]
        else
          pkgs;
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
      ]
      ++ (import (../hosts + "/${name}") { inherit inputs; });
    };

  nodes = builtins.mapAttrs (
    hostname: value:
    (mkOS {
      name = hostname;
      hostPubkey = value.key;
    })
  ) shared-data.hosts;

  nixosConfigurations = nodes // {
    inherit azbase;
  };
}
