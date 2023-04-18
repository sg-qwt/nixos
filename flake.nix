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

    yacd-meta = {
      url = "github:metacubex/yacd-meta/gh-pages";
      flake = false;
    };

    nur.url = "github:nix-community/NUR";

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      flake = false;
    };

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
      rootPath = ./.;
      helpers = import ./helpers.nix;

      # nixpkgs-patched =
      #   (import inputs.nixpkgs { inherit system; }).applyPatches {
      #     name = "nixpkgs-patched";
      #     src = inputs.nixpkgs;
      #     patches = [
      #     ];
      #   };

      pkgs = import nixpkgs {
        inherit system;

        config.allowUnfree = true;

        overlays = [
          self.overlays.default
          emacs-overlay.overlays.default
          oranc.overlays.default
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
            oranc.nixosModules.oranc
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
      overlays.default = (helpers.default-overlays { inherit inputs rootPath; });

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
          proton-ge = pkgs.my.proton-ge;
          gen-github-ci = pkgs.my.gen-github-ci;
        } //
        (import ./images.nix { inherit jovian nixpkgs system rootPath pkgs; }));

      devShells."${system}" = (helpers.shells { inherit pkgs rootPath; });

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
