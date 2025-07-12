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

    vaultix = {
      url = "github:milieuim/vaultix";
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

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
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

      mkOS = { name, hostPubkey, p ? pkgs }: {
        ${name} = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit home-manager self inputs;
            lib = helpers.lib;
          };
          modules = [
            nixpkgs.nixosModules.readOnlyPkgs
            home-manager.nixosModules.home-manager
            vaultix.nixosModules.default
            nix-index-database.nixosModules.nix-index
            {
              _module.args.pkgs-latest = pkgs-latest;
              nixpkgs.pkgs = p;
              nixpkgs.overlays = nixpkgs.lib.mkForce p.overlays;
              networking.hostName = name;
              imports = helpers.profile-list;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              vaultix.settings.hostPubkey = hostPubkey;
            }
          ] ++ (import (./hosts + "/${name}") { inherit inputs; });
        };
      };

      treefmt-eval = (inputs.treefmt-nix.lib.evalModule pkgs ./lib/treefmt.nix);
    in
    {
      # expose nix repl usage only
      repl = {
        inherit self pkgs;
        lib = helpers.lib;
      };

      vaultix = vaultix.configure {
        nodes = self.nixosConfigurations;
        identity = self + "/resources/keys/age-yubikey-identity-main.txt";
        extraRecipients = [ "age1yubikey1q0mllu8l3pf4fynhye98u308ppk9tjx7aawvzhhqwvrn878nmcsfcwj37nf" ];
        extraPackages = [ pkgs.age-plugin-yubikey ];
        defaultSecretDirectory = "./secrets";
      };

      overlays.default = (helpers.default-overlays { inherit inputs; });

      # expose packages to flake here
      packages."${system}" = flake-utils.lib.flattenTree (helpers.packages pkgs);

      devShells."${system}" =
        (helpers.shells { inherit pkgs self; } "dev");

      nixosConfigurations =
        builtins.foldl' (x: y: x // y) { }
          [
            (mkOS {
              name = "zheng";
              hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpWTwJQ7923qsxZGWjxQrl8Bx6/+pdZDsiz0dg1akxz";
              p = pkgs.appendOverlays [
                jovian.overlays.default
                helpers.jovian-overlay
              ];
            })
            (mkOS {
              name = "dui";
              hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLftJ5dhUg+HMKxqwMlUswnpQtPVdYFDxbD6YB58kGp";
            })
            (mkOS {
              name = "xun";
              hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHIJkTioxExX+AHexbppyfFKJAhMfJe7js0f2QfSvJec";
            })
            (mkOS {
              name = "li";
              hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxduWDt3Qli+3gTUd4/3/qbVqy+wyNrqTxZhV/7/7eV";
            })
          ];

      formatter."${system}" = treefmt-eval.config.build.wrapper;

      checks."${system}".tfm = treefmt-eval.config.build.check self;
    };
}
