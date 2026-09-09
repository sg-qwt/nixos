{ config, lib, pkgs, modulesPath, inputs, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      kernelModules = [ ];
      availableKernelModules = [ "xhci_pci" "nvme" "uas" "sd_mod" ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "bcachefs" ];
  };

  hardware = {
    cpu.intel.npu.enable = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver     # VA-API (iHD) userspace
        vpl-gpu-rt             # oneVPL (QSV) runtime
        intel-compute-runtime  # OpenCL (NEO) + Level Zero for Arc/Xe
      ];
    };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  services.xserver.videoDrivers = [
    "modesetting"
  ];

  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  fileSystems."/" =
    { device = "UUID=3bd1ff99-7586-4376-a342-386d8d66daea";
      fsType = "bcachefs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/75A0-8614";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];
}
