{
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    "*.age"
    "secrets/cache/*"
    "resources/*"
  ];
  programs.nixpkgs-fmt.enable = true;
  programs.terraform.enable = true;
  programs.zprint = {
    enable = true;
    zprintOpts = "{:search-config? true}";
  };
}
