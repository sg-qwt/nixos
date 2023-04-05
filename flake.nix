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

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      flake = false;
    };

    nixos-cn = {
      url = "github:nixos-cn/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
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
          ];
        };
      pkgs = import nixpkgs-patched {
        inherit system;

        config.allowUnfree = true;

        overlays = [
          self.overlays.default
          emacs-overlay.overlays.default
        ];
      };

      mkOS = { name, p ? pkgs }: {
        ${name} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit home-manager helpers self inputs rootPath;
            pkgs = p;
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
      packages."${system}" = flake-utils.lib.flattenTree
        ({
          hello-custom = pkgs.my.hello-custom;
          proton-ge = pkgs.my.proton-ge;
        } //
        (import ./images.nix { inherit jovian nixpkgs system rootPath pkgs; }));

      devShells."${system}".infra = (import ./shells/infra.nix { inherit pkgs rootPath; });

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
