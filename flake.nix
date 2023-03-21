{
  description = "NixOS configuration";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
      inputs.utils.follows = "flake-utils";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    doomemacs = {
      url = "github:doomemacs/doomemacs/d9f18e6040d5aa96245f93ccd864163c2eab82c0";
      flake = false;
    };

    spacemacs = {
      url = "github:syl20bnr/spacemacs/develop";
      flake = false;
    };

    yacd-meta = {
      url = "github:metacubex/yacd-meta/gh-pages";
      flake = false;
    };

    nur.url = "github:nix-community/NUR";

    yacd = {
      url = "https://github.com/haishanh/yacd/releases/download/v0.3.6/yacd.tar.xz";
      flake = false;
    };

    jovian-nixos = {
      url = "github:zhaofengli/Jovian-NixOS/7a9e41a66f1b0174845538de11203600b2160d61";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cn = {
      url = "github:nixos-cn/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      system = "x86_64-linux";
      rootPath = ./.;
      helpers = import ./helpers.nix;
      nixpkgs-patched =
        (import inputs.nixpkgs { inherit system; }).applyPatches {
          name = "nixpkgs-patched";
          src = inputs.nixpkgs;
          patches = [
            ((import inputs.nixpkgs { inherit system; }).fetchpatch {
              url = "https://github.com/SuperSandro2000/nixpkgs/commit/449114c6240520433a650079c0b5440d9ecf6156.patch";
              hash = "sha256-8snymWug7U9GLlhJ0oKE0+lTtSFyijyE5IWVpsShCdw=";
            })
          ];
        };
      pkgs = import nixpkgs-patched {
        inherit system;

        config.allowUnfree = true;

        overlays = [
          self.overlays.default
          jovian-nixos.overlay
         # emacs-overlay.overlays.default
        ];
      };

      makeAzureBase = (nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs rootPath; };
        modules = [
          (import ./hosts/azure)
        ];
      }).config.system.build.azureImage;

      mkOS = name: {
        ${name} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit pkgs home-manager helpers self inputs rootPath;
          };
          modules = [
            nur.nixosModules.nur
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            nixos-cn.nixosModules.nixos-cn
            { networking.hostName = name; }
            { imports = helpers.profile-list; }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ] ++ (import (./hosts + "/${name}") { inherit inputs; });
        };
      };
    in
    {
      overlays.default = (helpers.default-overlays inputs);

      formatter."${system}" = treefmt-nix.lib.mkWrapper
        nixpkgs.legacyPackages.x86_64-linux
        {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
          programs.terraform.enable = true;
        };

      # expose packages to flake here
      packages."${system}" = flake-utils.lib.flattenTree {
        hello-custom = pkgs.my.hello-custom;
        proton-ge = pkgs.my.proton-ge;
        azure-image = makeAzureBase;
      };

      devShells."${system}".infra = (import ./shells/infra.nix { inherit pkgs rootPath; });

      nixosConfigurations =
        builtins.foldl' (x: y: x // y) { }
          [
            (mkOS "ge")
            (mkOS "zheng")
            (mkOS "dui")
          ];

    };
}
