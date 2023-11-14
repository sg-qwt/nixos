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

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
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
          attic.overlays.default
          nvfetcher.overlays.default
        ];
      };

      sources = import ./_sources/generated.nix { inherit (pkgs) fetchurl fetchgit fetchFromGitHub dockerTools; };
      jovian = sources.jovian-nixos.src;
      helpers = import ./lib/helpers.nix { inherit sources self nixpkgs; };

      mkOS = { name, p ? pkgs }: {
        ${name} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit home-manager self inputs sources;
            pkgs = p;
            lib = helpers.lib;
          };
          modules = [
            attic.nixosModules.atticd
            nur.nixosModules.nur
            home-manager.nixosModules.home-manager
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

      treefmt-eval = (inputs.treefmt-nix.lib.evalModule pkgs ./lib/treefmt.nix);
    in
    {
      overlays.default = (helpers.default-overlays { inherit inputs; });

      # expose packages to flake here
      packages."${system}" = flake-utils.lib.flattenTree
        ({
          hello-custom = pkgs.my.hello-custom;
          proton-ge = pkgs.my.proton-ge-custom;
          gen-config = pkgs.my.gen-config;
          matrix-chatgpt-bot = pkgs.my.matrix-chatgpt-bot;
          mautrix-slack = pkgs.my.mautrix-slack;
          cljfmt = pkgs.my.cljfmt;
          rsshub = pkgs.my.rsshub;
          pop = pkgs.my.pop;
          libation = pkgs.my.libation;
          douyu-task = pkgs.my.douyu-task;
        } //
        (import ./images.nix { inherit jovian nixpkgs system pkgs self; })
        //
        (import ./bb/scripts.nix { inherit pkgs self; }));

      devShells."${system}" =
        (helpers.shells { inherit pkgs self; } "dev");

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
            (mkOS { name = "xun"; })
            (mkOS { name = "lei"; })
          ];

      formatter."${system}" = treefmt-eval.config.build.wrapper;

      checks."${system}".tfm = treefmt-eval.config.build.check self;
    };
}
