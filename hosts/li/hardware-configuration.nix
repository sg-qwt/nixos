{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ ];
    };
    kernelParams = [
      "acpi_backlight=native"

      "amd_pstate=active"
    ];
    kernelModules = [ "kvm-amd" ];
    blacklistedKernelModules = [ "nouveau" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "bcachefs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware = {
    graphics.enable = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      dynamicBoost.enable = true;

      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "570.133.07";
        sha256_64bit = "sha256-LUPmTFgb5e9VTemIixqpADfvbUX1QoTT2dztwI3E3CY=";
        openSha256 = "sha256-9l8N83Spj0MccA8+8R1uqiXBS0Ag4JrLPjrU3TaXHnM=";
        settingsSha256 = "sha256-XMk+FvTlGpMquM8aE8kgYK2PIEszUZD2+Zmj2OpYrzU=";
        usePersistenced = false;
      };
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 50;
  };


  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/091c05e6-1b85-41bc-b319-c80cb5c08d97";
      fsType = "bcachefs";
    };
  specialisation.fsck.configuration.fileSystems."/".options = [ "fsck" "fix_errors" ];

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/B337-9405";
      fsType = "vfat";
    };

  swapDevices = [ ];
}
