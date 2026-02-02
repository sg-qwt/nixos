{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

    agent-shell = {
      url = "github:xenodium/agent-shell";
      flake = false;
    };
    acp = {
      url = "github:xenodium/acp.el";
      flake = false;
    };
    shell-maker = {
      url = "github:xenodium/shell-maker";
      flake = false;
    };
    eca-emacs = {
      url = "github:editor-code-assistant/eca-emacs";
      flake = false;
    };
    eca = {
      url = "file+https://github.com/editor-code-assistant/eca/releases/download/0.97.3/eca.jar";
      flake = false;
    };
    brepl = {
      url = "github:licht1stein/brepl?tag=v2.5.2";
      flake = false;
    };

    self.submodules = true;
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

      helpers = import ./lib/helpers.nix { inherit self nixpkgs inputs pkgs; };

      treefmt-eval = (inputs.treefmt-nix.lib.evalModule pkgs ./lib/treefmt.nix);
    in
    {
      # expose nix repl usage only
      repl = {
        inherit self pkgs;
        lib = helpers.lib;
      };

      shared-data = helpers.shared-data;

      vaultix = vaultix.configure rec {
        nodes = helpers.nodes;
        identity = self + "/resources/keys/age-yubikey-identity-main.txt";
        extraRecipients = [ "age1yubikey1q0mllu8l3pf4fynhye98u308ppk9tjx7aawvzhhqwvrn878nmcsfcwj37nf" ];
        extraPackages = [ pkgs.age-plugin-yubikey ];
        defaultSecretDirectory = "./caveman";
        cache = "${defaultSecretDirectory}/cache";
      };

      overlays.default = (helpers.default-overlays { inherit inputs; });

      # expose packages to flake here
      packages."${system}" = flake-utils.lib.flattenTree helpers.packages;

      devShells."${system}" =
        (helpers.shells { inherit pkgs self; } "dev");

      nixosConfigurations = helpers.nixosConfigurations;

      formatter."${system}" = treefmt-eval.config.build.wrapper;

      checks."${system}".tfm = treefmt-eval.config.build.check self;
    };
}
