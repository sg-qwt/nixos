{
  description = "NixOS configuration";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nur.url = "github:nix-community/NUR";

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    oranc = {
      url = "github:linyinfeng/oranc";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      system = "x86_64-linux";
      pkgs-init = import inputs.nixpkgs { inherit system; };
      sources = import ./_sources/generated.nix { inherit (pkgs-init) fetchurl fetchgit fetchFromGitHub dockerTools; };
      jovian = sources.jovian-nixos.src;
      helpers = import ./helpers.nix { inherit sources; };
      patches = [
        (pkgs-init.fetchpatch {
          url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/207758.patch";
          hash = "sha256-1bxn+U0NslCTElG+EhJe43FRf+5tIgMh7gvPKAyGe0U=";
        })
      ];

      nixpkgs-patched =
        pkgs-init.applyPatches {
          name = "nixpkgs-patched";
          src = inputs.nixpkgs;
          inherit patches;
        };

      pkgs = import nixpkgs-patched {
        inherit system;

        config.allowUnfree = true;

        overlays = [
          self.overlays.default
          emacs-overlay.overlays.default
          oranc.overlays.default
        ];
      };

      nixpkgs = (import "${nixpkgs-patched}/flake.nix").outputs { inherit self; };

      mkOS = { name, p ? pkgs }: {
        ${name} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit home-manager helpers self inputs;
            pkgs = p;
          };
          modules = [
            nur.nixosModules.nur
            home-manager.nixosModules.home-manager
            oranc.nixosModules.oranc
            sops-nix.nixosModules.sops
            { networking.hostName = name; }
            { imports = helpers.profile-list; }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ] ++ (import (./hosts + "/${name}") { inherit inputs jovian; });
        };
      };
    in
    {
      overlays.default = (helpers.default-overlays { inherit inputs; });

      formatter."${system}" = treefmt-nix.lib.mkWrapper
        nixpkgs.legacyPackages.x86_64-linux
        {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
          programs.terraform.enable = true;
          programs.zprint = {
            enable = true;
            zprintOpts = "{:search-config? true}";
          };
        };

      # expose packages to flake here
      packages."${system}" = flake-utils.lib.flattenTree
        ({
          hello-custom = pkgs.my.hello-custom;
          proton-ge = pkgs.my.proton-ge-custom;
          gen-github-ci = pkgs.my.gen-github-ci;
        } //
        (import ./images.nix { inherit jovian nixpkgs system pkgs self; }));

      devShells."${system}" = (helpers.shells { inherit pkgs self; });

      nixosConfigurations =
        builtins.foldl' (x: y: x // y) { }
          [
            (mkOS { name = "ge"; })
            (mkOS
              {
                name = "zheng";
                p = (pkgs.extend (import "${jovian}/overlay.nix"));
              })
            (mkOS { name = "dui"; })
            (mkOS { name = "lei"; })
          ];

    };
}
