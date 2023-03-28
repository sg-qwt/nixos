{ nixpkgs, system, rootPath, pkgs }:
{
  azure-image = (nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit pkgs rootPath; };
    modules = [
      (import ./hosts/azure)
    ];
  }).config.system.build.azureImage;

  gnome-image = (nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    ];
  }).config.system.build.isoImage;
}
