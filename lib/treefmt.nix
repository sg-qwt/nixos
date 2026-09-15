{
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    "*.age"
    "secrets/cache/*"
    "resources/*"
  ];
  programs.nixfmt.enable = true;
  programs.terraform.enable = true;
  programs.zprint = {
    enable = true;
    zprintOpts = "{:search-config? true}";
  };
}
