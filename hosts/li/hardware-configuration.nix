{ config, lib, pkgs, modulesPath, inputs, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    kernelPackages = inputs.jovian.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_jovian;
    loader = {
      systemd-boot.enable = true;
      systemd-boot.memtest86.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      kernelModules = [
        "hid-generic"
        "usbhid"
      ];
      availableKernelModules = [
        "nvme"
        "sdhci"
        "sdhci_pci"
        "xhci_pci"
        "cqhci"
        "mmc_block"
      ];
    };
    kernelParams = [
      "nowatchdog"
      "amd_pstate=active"

      "amdgpu.sched_hw_submission=4"
      "amdgpu.lockup_timeout=5000,10000,10000,5000"

      "pcie_ports=native"
      "pcie_ecrc=on"
    ];
    kernelModules = [ "kvm-amd" "ntsync" ];
    blacklistedKernelModules = [ ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "bcachefs" ];
  };

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    amdgpu.initrd.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    steam-hardware.enable = true;
  };

  services.xserver.videoDrivers = [
    "amdgpu"
  ];

  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/d220b16d-b8d7-4fa2-9042-aaa023d7b071";
      fsType = "bcachefs";
    };
  specialisation.fsck.configuration.fileSystems."/".options = [ "fsck" "fix_errors" ];

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/09C1-138C";
      fsType = "vfat";
    };

  swapDevices = [ ];
}
