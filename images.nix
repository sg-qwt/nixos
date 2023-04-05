{ nixpkgs, system, rootPath, pkgs, jovian }:
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

  deck-minimal-image = (nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit rootPath;
      pkgs = pkgs.extend (import "${jovian}/overlay.nix");
    };
    modules = [
      "${jovian}/modules"
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ./modules/mixins/deploy.nix
      ({ lib, config, ... }: {
        jovian.devices.steamdeck.enable = true;
        hardware.pulseaudio.enable = lib.mkForce false;
      })
    ];
  }).config.system.build.isoImage;
}
