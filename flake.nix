{
  description = "NixOS configuration";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chugou = {
      url = "github:sg-qwt/chugou";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config.allowUnfree = true;

        overlays = [
          self.overlays.default
        ];
      };

      pkgs-latest = import nixpkgs-latest {
        inherit system;
        config.allowUnfree = true;
      };

      helpers = import ./lib/helpers.nix { inherit self nixpkgs; };

      mkOS = { name, p ? pkgs }: {
        ${name} = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit home-manager self inputs;
            lib = helpers.lib;
          };
          modules = [
            nixpkgs.nixosModules.readOnlyPkgs
            {
              _module.args.pkgs-latest = pkgs-latest;
              nixpkgs.pkgs = p;
              nixpkgs.overlays = nixpkgs.lib.mkForce p.overlays;
              networking.hostName = name;
              imports = helpers.profile-list;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ] ++ (import (./hosts + "/${name}") { inherit inputs; });
        };
      };

      treefmt-eval = (inputs.treefmt-nix.lib.evalModule pkgs ./lib/treefmt.nix);
    in
    {
      # expose for nix repl usage only
      inherit self;

      overlays.default = (helpers.default-overlays { inherit inputs; });

      # expose packages to flake here
      packages."${system}" = flake-utils.lib.flattenTree
        ((helpers.packages pkgs)
          //
          (import ./images.nix { inherit nixpkgs system pkgs self; }));

      devShells."${system}" =
        (helpers.shells { inherit pkgs self; } "dev");

      nixosConfigurations =
        builtins.foldl' (x: y: x // y) { }
          [
            (mkOS { name = "ge"; })
            (mkOS {
              name = "zheng";
              p = (pkgs.extend jovian.overlays.default);
            })
            (mkOS { name = "dui"; })
            (mkOS { name = "xun"; })
            (mkOS { name = "lei"; })
          ];

      formatter."${system}" = treefmt-eval.config.build.wrapper;

      checks."${system}".tfm = treefmt-eval.config.build.check self;
    };
}
