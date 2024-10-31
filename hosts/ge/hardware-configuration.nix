{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  boot.kernelModules = [ "kvm-amd" "it87" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    it87
  ];
  boot.extraModprobeConfig = ''
    options it87 ignore_resource_conflict=1
  '';

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8FB7-D051";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/66676a5c-a315-46fb-a6b4-ba1ddd64ac10";
      fsType = "bcachefs";
    };

  swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  environment.etc."sensors.d/sensor.conf".text = ''
    chip "it8688-*"
      label in0 "CPU_VCORE"
      ignore in1
      ignore in2
      ignore in3
      label in4 "CPU_VCORE_SOC"
      label in5 "CPU_VDDP"
      label in6 "DRAM"
      label in7 "3VSB"
      label in8 "VBAT"
      label fan1 "CPU_FAN"
      label fan2 "SYS_FAN1"
      label fan3 "SYS_FAN2"
      ignore fan4
      ignore fan5
      label temp1 "SYSTEM"
      label temp2 "CHIPSET"
      label temp3 "CPU"
      label temp4 "PCIEX16"
      label temp5 "VRM_MOS"
      label temp6 "VSOC_MOS"
      ignore intrusion0

    chip "amdgpu-*"
      label fan1 "GPU_FAN"
  '';
}
