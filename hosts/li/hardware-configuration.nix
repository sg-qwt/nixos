{ config, lib, pkgs, modulesPath, ... }:
let
  systemctl = lib.getExe' config.systemd.package "systemctl";
in
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
      "nowatchdog"
      "amd_pstate=active"
      "i915.enable_dpcd_backlight=1"
      "nvidia.NVreg_EnableBacklightHandler=0"
      "nvidia.NVReg_RegistryDwords=EnableBrightnessControl=0"
    ];
    kernelModules = [ "kvm-amd" ];
    blacklistedKernelModules = [ "nouveau" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "bcachefs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    amdgpu.initrd.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      open = true;
      nvidiaSettings = true;
      dynamicBoost.enable = true;

      package = config.boot.kernelPackages.nvidiaPackages.latest;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:101:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  services.fwupd.enable = true;

  services.logind.powerKey = "suspend";

  services.udev = {
    enable = true;
    # fixes mic mute button
    extraHwdb = ''
      evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
      KEYBOARD_KEY_ff31007c=f20
    '';
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{idVendor}=="0b05", ATTR{idProduct}=="19b6", ATTR{power/autosuspend}="-1"
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", ATTR{idProduct}=="193b", ATTR{power/wakeup}="disabled"
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${systemctl} poweroff"
    '';
  };

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
