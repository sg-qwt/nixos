{ nixpkgs, system, rootPath, pkgs, jovian }:
{
  azure-image = (nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit pkgs rootPath; };
    modules = [
      "${nixpkgs}/nixos/modules/virtualisation/azure-image.nix"
      ./modules/mixins/deploy.nix
      ./modules/mixins/azurebase.nix
      ({ pkgs, modulesPath, lib, config, ... }: {
        system.build.azureImage = lib.mkOverride 99
          (import "${modulesPath}/../lib/make-disk-image.nix" {
            inherit pkgs lib config;
            partitionTableType = "efi";
            postVM = ''
        ${pkgs.vmTools.qemu}/bin/qemu-img convert -f raw -o subformat=fixed,force_size -O vpc $diskImage $out/nixos.vhd
        rm $diskImage
      '';
            diskSize = config.virtualisation.azureImage.diskSize;
            format = "raw";
          });
      })
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
