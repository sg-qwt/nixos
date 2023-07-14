{
  projectRootFile = "flake.nix";
  programs.nixpkgs-fmt.enable = true;
  programs.terraform.enable = true;
  programs.zprint = {
    enable = true;
    zprintOpts = "{:search-config? true}";
  };
}
