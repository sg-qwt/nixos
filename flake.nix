{
  description = "NixOS configuration";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-doom-emacs = {
      url = "github:nix-community/nix-doom-emacs/b65e204ce9d20b376acc38ec205d08007eccdaef";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay/6f5b9e6e9b04a750edfa9e706173635186e2c7ea";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    spacemacs = {
      url = "github:syl20bnr/spacemacs/develop";
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
  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      # hard-coded system here, sorry I'm lazy
      system = "x86_64-linux";

      helpers = import ./helpers.nix;

      pkgs = import nixpkgs {
        inherit system;

        config.allowUnfree = true;

        overlays = [
          self.overlays.default
          jovian-nixos.overlay
          emacs-overlay.overlays.default
          # (import nix-doom-emacs.inputs.emacs-overlay.outPath)
        ];
      };

      makeAzureBase = (nixpkgs.lib.nixosSystem {
	      inherit system;
        specialArgs = { inherit pkgs; };
        modules = [
          (import ./hosts/azure)
        ];
      }).config.system.build.azureImage;

      mkOS = name: {
        ${name} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs home-manager helpers self inputs; };
          modules = [
            nur.nixosModules.nur
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
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

      formatter."${system}" = pkgs.nixpkgs-fmt;

      # expose packages to flake here
      packages."${system}" = flake-utils.lib.flattenTree {
        hello-custom = pkgs.my.hello-custom;
        proton-ge = pkgs.my.proton-ge;
        ryujinx = pkgs.my.ryujinx;
        azure-image = makeAzureBase;
      };

      nixosConfigurations =
        builtins.foldl' (x: y: x // y) {}
          [
            (mkOS "ge")
            (mkOS "zheng")
            (mkOS "dui")
          ];

    };
}
