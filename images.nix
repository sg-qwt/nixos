{ nixpkgs, system, self, pkgs }:
let
  mPath = p: { modulesPath, ... }: {
    imports = [ "${modulesPath}/${p}" ];
  };
  lib = nixpkgs.lib;
in
{
  azure-image = (lib.nixosSystem {
    inherit system;
    specialArgs = { inherit pkgs self; };
    modules = [
      (mPath "virtualisation/azure-image.nix")
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

  gnome-image = (lib.nixosSystem {
    inherit system;
    modules = [
      (mPath "installer/cd-dvd/installation-cd-graphical-gnome.nix")
    ];
  }).config.system.build.isoImage;
}
